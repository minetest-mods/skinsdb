#!/usr/bin/python3
from http.client import HTTPConnection,HTTPException,BadStatusLine,_CS_IDLE
import json
import base64
from contextlib import closing
import sys,os,shutil,time

def die(message,code=23):
		print(message,file=sys.stderr)
		raise SystemExit(code)

server = "minetest.fensta.bplaced.net"
skinsdir = "../textures/"
metadir = "../meta/"
curskin = 0
curpage = 1
pages = None

def replace(location,base,encoding=None,path=None):
	if path is None:
		path = os.path.join(location,base)
	mode = "wt" if encoding else "wb"
	# an unpredictable temp name only needed for a+rwxt directories
	tmp = os.path.join(location,'.'+base+'-tmp')
	def deco(handle):
		with open(tmp,mode,encoding=encoding) as out:
			handle(out)
		os.rename(tmp,path)
	return deco

def maybeReplace(location,base,encoding=None):
	def deco(handle):
		path = os.path.join(location,base)
		if os.path.exists(path): return
		return replace(location,base,encoding=encoding,path=path)(handle)
	return deco

class Penguin:
	"idk"
	def __init__(self, url, recv, diemessage):
		self.url = url
		self.recv = recv
		self.diemessage = diemessage		

class Pipeline(list):
	"Gawd why am I being so elaborate?"
	def __init__(self, threshold=10):
		"threshold is how many requests in parallel to pipeline"
		self.threshold = threshold
		self.sent = True
	def __enter__(self):
		self.reopen()
		return self
	def __exit__(self,typ,exn,trace):
		self.send()
		self.drain()
	def reopen(self):
		self.c = HTTPConnection(server)
		self.send()
	def append(self,url,recv,diemessage):
		self.sent = False
		super().append(Penguin(url,recv,diemessage))
		if len(self) > self.threshold:			
			self.send()
			self.drain()
	def trydrain(self):		
		for penguin in self:
			print('drain',penguin.url)
			try:
				penguin.response.begin()
				penguin.recv(penguin.response)
			except BadStatusLine as e:
				print('derped requesting',penguin.url)
				return False			
			except HTTPException as e:
				die(penguin.diemessage+' '+repr(e)+' (url='+penguin.url+')')
		self.clear()
		return True
	def drain(self):
		print('draining pipeline...',len(self))
		assert self.sent, "Can't drain without sending the requests!"
		self.sent = False
		while self.trydrain() is not True:
			self.c.close()
			print('drain failed, trying again')
			time.sleep(1)
			self.reopen()
	def trysend(self):
		for penguin in pipeline:
			print('fill',penguin.url)
			try:
				self.c.request("GET", penguin.url)
				self.c._HTTPConnection__state = _CS_IDLE
				penguin.response = self.c.response_class(self.c.sock,
														 method="GET")
				# begin LATER so we can send multiple requests w/out response headers
			except BadStatusLine:
				return False
			except HTTPException as e:
				die(diemessage+' because of a '+repr(e))
		return True
	def send(self):
		if self.sent: return
		print('filling pipeline...',len(self))
		while self.trysend() is not True:
			self.c.close()
			print('derped resending')
			time.sleep(1)
			self.reopen()
		self.sent = True
		
with Pipeline() as pipeline:
	# two connections is okay, right? one for json, one for preview images
	c = HTTPConnection(server)
	def addpage(page):
		global curskin, pages
		print("Page: " + str(page))
		r = 0
		try:
			c.request("GET", "/api/get.json.php?getlist&page=" + str(page) + "&outformat=base64")
			r = c.getresponse()
		except Exception:
			if r != 0:
				if r.status != 200:
					die("Error", r.status)
			return
		
		data = r.read().decode()
		l = json.loads(data)
		if not l["success"]:
			die("Success != True")
		r = 0
		pages = int(l["pages"])
		foundOne = False
		for s in l["skins"]:
			# make sure to increment this, even if the preview exists!
			curskin = curskin + 1
			previewbase = "character_" + str(curskin) + "_preview.png"
			preview = os.path.join(skinsdir, previewbase)
			if os.path.exists(preview):
				print('skin',curskin,'already retrieved')
				continue
			print('updating skin',curskin,'id',s["id"])
			foundOne = True
			@maybeReplace(skinsdir, "character_" + str(curskin) + ".png")
			def go(f):
				f.write(base64.b64decode(bytes(s["img"], 'utf-8')))
				f.close()
				
			@maybeReplace(metadir, "character_" + str(curskin) + ".txt",
						  encoding='utf-8')
			def go(f):
				f.write(str(s["name"]) + '\n')
				f.write(str(s["author"]) + '\n')
				f.write(str(s["license"]))
			url = "/skins/1/" + str(s["id"]) + ".png"
			def closure(skinsdir,previewbase,preview,s):
				"explanation: python sucks"
				def tryget(r):
					print('replacing',s["id"])
					if r.status != 200:
						print("Error", r.status)
						return
					@replace(skinsdir,previewbase,path=preview)
					def go(f):
						shutil.copyfileobj(r,f)
				return tryget
					
			pipeline.append(url,closure(skinsdir,previewbase,preview,s),
							"Couldn't get {} because of a".format(
								s["id"]))
		if not foundOne:
			print("No skins updated on this page. Seems we're done?")
			#raise SystemExit
	addpage(curpage)
	while pages > curpage:
		curpage = curpage + 1
		addpage(curpage)
	print("Skins have been updated!")
	
