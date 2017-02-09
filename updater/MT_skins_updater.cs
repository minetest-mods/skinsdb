using System;
//Json.NET library (http://json.codeplex.com/)
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Net;
using System.IO;

// MT skins updater for the skins mod
// Creator: Krock
// License: zlib (http://www.zlib.net/zlib_license.html)
namespace MT_skins_updater {
	class Program {
		static void Main(string[] args) {
			Console.WriteLine("Welcome to the MT skins updater!");
			Console.WriteLine("# Created by: Krock (2014-07-10)");
			Engine e = new Engine();
			Console.WriteLine(@"Path to the skins mod: (ex. 'E:\Minetest\mods\skinsdb\skins\')");
			string path = Console.ReadLine();
			Console.WriteLine("Start updating at page: ('0' to update everything)");
			int page = getInt(Console.ReadLine());
			e.Start(path, page);
			Console.WriteLine("Press any key to exit.");
			Console.ReadKey(false);
		}
		public static int getInt(string i) {
			int ret = 0;
			int.TryParse(i, out ret);
			return (ret > 0)? ret : 0;
		}
	}
	class Engine {
		string root = "http://minetest.fensta.bplaced.net";
		bool alternate = true; //should it use the special version of medadata saving?

		public void Start(string path, int page) {
			if (path.Length < 5) {
				Console.WriteLine("Too short path. STOP.");
				return;
			}
			if (path[path.Length - 1] != '\\') {
				path += '\\';
			}
			if(!Directory.Exists(path + "meta")){
				Console.WriteLine("Folder 'meta' not found. STOP.");
				return;
			}
			if(!Directory.Exists(path + "textures")){
				Console.WriteLine("Folder 'textures' not found. STOP.");
				return;
			}
			WebClient cli = new WebClient();
			//add useragent to identify
			cli.Headers.Add("User-Agent", "MT_skin_grabber 1.1");
			
			bool firstSkin = true;
			List<string> skin_local = new List<string>();
			int pages = page,
				updated = 0;

			for (; page <= pages; page++) {
				string contents = "";
				try {
					contents = cli.DownloadString(root + "/api/get.json.php?getlist&page=" + page);
				} catch(WebException e) { 
					Console.WriteLine("Whoops! Error at page ID: " + page + ". WebClient sais: " + e.Message);
					Console.WriteLine("Press any key to skip this page.");
					Console.ReadKey(false);
					continue;
				}
				Data o = JsonConvert.DeserializeObject<Data>(contents);
				if (o.pages != pages) {
					pages = o.pages;
				}

				Console.WriteLine("# Page " + page + " (" + o.per_page + " skins)");
				for (int i = 0; i < o.skins.Length; i++) {
					int id = o.skins[i].id;
					if(o.skins[i].type != "image/png"){
						Console.WriteLine("Image type '" + o.skins[i].type + "' not supported at skin ID: " + id);
						Console.WriteLine("Press any key to continue.");
						Console.ReadKey(false);
						continue;
					}
					//eliminate special chars!
					o.skins[i].name = WebUtility.HtmlDecode(o.skins[i].name);
					o.skins[i].author = WebUtility.HtmlDecode(o.skins[i].author);
					
					//to delete old, removed skins
					if (firstSkin) {
						firstSkin = false;

						string[] files = Directory.GetFiles(path + "textures\\");
						for (int f = 0; f < files.Length; f++) {
							string[] filePath = stringSplitLast(files[f], '\\'),
								fileName = stringSplitLast(filePath[1], '.'),
								fileVer = stringSplitLast(fileName[0], '_');
							if (fileVer[1] == "" || fileVer[0] != "character") continue;
							
							int skinNr = Program.getInt(fileVer[1]);
							if (skinNr <= id) continue;
							skin_local.Add(fileName[0]);
						}
					} else skin_local.Remove("character_" + id);
					
					//get file size, only override changed
					FileInfo localImg = new FileInfo(path + "textures\\character_" + id + ".png");
					byte[] imageData = Convert.FromBase64String(o.skins[i].img);
					bool isDif = true;
					if (localImg.Exists) isDif = (Math.Abs(imageData.Length - localImg.Length) >= 3);

					if (isDif) {
						File.WriteAllBytes(localImg.FullName, imageData);
						imageData = null;
						//previews
						try {
							cli.DownloadFile(root + "/skins/1/" + id + ".png", path + "textures\\character_" + id + "_preview.png");
						} catch (WebException e) {
							Console.WriteLine("Whoops! Error at skin ID: " + id + ". WebClient sais: " + e.Message);
							Console.WriteLine("Press any key to continue.");
							Console.ReadKey(false);
						}
					} else {
						Console.WriteLine("[SKIP] character_" + id);
						continue;
					}

					string meta = "";
					if (!alternate) {
						meta = "name = \"" + o.skins[i].name + "\",\n";
						meta += "author = \"" + o.skins[i].author + "\",\n";
						meta += "comment = \"" + o.skins[i].license + '"';
					} else {
						meta = o.skins[i].name + '\n' + o.skins[i].author + '\n' + o.skins[i].license;
					}
					File.WriteAllText(path + "meta\\character_" + id + ".txt", meta);
					updated++;
					Console.WriteLine("[" + id + "] " + shorten(o.skins[i].name, 20) + "\t by: " + o.skins[i].author + "\t (" + o.skins[i].license + ")");
				}
			}
			foreach (string fileName in skin_local) {
				if(File.Exists(path + "textures\\" + fileName + ".png")) {
					File.Delete(path + "textures\\" + fileName + ".png");
				}
				if(File.Exists(path + "textures\\" + fileName + "_preview.png")) {
					File.Delete(path + "textures\\" + fileName + "_preview.png");
				}
				if(File.Exists(path + "meta\\" + fileName + ".txt")) {
					File.Delete(path + "meta\\" + fileName + ".txt");
				}
				Console.WriteLine("[DEL] " + fileName + " (deleted skin)");
			}
			Console.WriteLine("Done. Updated " + updated + " skins!");
		}
		string shorten(string inp, int len) {
			char[] shr = new char[len];
			for (int i = 0; i < len; i++) {
				if (i < inp.Length) {
					shr[i] = inp[i];
				} else shr[i] = ' ';
			}
			return new string(shr);
		}

		string[] stringSplitLast(string path, char limiter) {
			int found = 0;
			int totalLen = path.Length - 1;
			for (int i = totalLen; i >= 0; i--) {
				if (path[i] == limiter) {
					found = i;
					break;
				}
			}
			if (found == 0) {
				return new string[] { "", "" };
			}

			int len = totalLen - found;
			char[] str_1 = new char[found],
				str_2 = new char[len];

			for (int i = 0; i < path.Length; i++) {
				if (i == found) continue;
				if (i < found) {
					str_1[i] = path[i];
				} else {
					str_2[i - found - 1] = path[i];
				}
			}
			return new string[] { new string(str_1), new string(str_2) };
		}
	}
	class Data {
		public Skins_data[] skins;
		public int page, pages, per_page;
	}
	class Skins_data {
		public string name, author, uploaded, type, license, img;
		public int id, license_id;
	}
}
