#!/usr/bin/python3
from http.client import HTTPConnection
import json
import base64

server = "minetest.fensta.bplaced.net"
skinsdir = "u_skins/textures/"
metadir = "u_skins/meta/"
i = 1
pages = 1

c = HTTPConnection(server)
def addpage(page):
	global i, pages
	print("Page: " + str(page))
	r = 0
	try:
		c.request("GET", "/api/get.json.php?getlist&page=" + str(page) + "&outformat=base64")
		r = c.getresponse()
	except Exception:
		if r != 0:
			if r.status != 200:
				print("Error", r.status)
				exit(r.status)
		return
	
	data = r.read().decode()
	l = json.loads(data)
	if not l["success"]:
		print("Success != True")
		exit(1)
	r = 0
	pages = int(l["pages"])
	for s in l["skins"]:
		f = open(skinsdir + "character_" + str(i) + ".png", "wb")
		f.write(base64.b64decode(bytes(s["img"], 'utf-8')))
		f.close()
		f = open(metadir + "character_" + str(i) + ".txt", "w")
		f.write(str(s["name"]) + '\n')
		f.write(str(s["author"]) + '\n')
		f.write(str(s["license"]))
		f.close()
		try:
			c.request("GET", "/skins/1/" + str(s["id"]) + ".png")
			r = c.getresponse()
		except Exception:
			if r != 0:
				if r.status != 200:
					print("Error", r.status)
			continue
		
		data = r.read()
		f = open(skinsdir + "character_" + str(i) + "_preview.png", "wb")
		f.write(data)
		f.close()
		i = i + 1
addpage(1)
if pages > 1:
	for p in range(pages-1):
		addpage(p+2)
print("Skins have been updated!")
