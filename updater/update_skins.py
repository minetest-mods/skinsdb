import sys, requests, base64

# filename seperator to use, either default "-" or ".". see skinsdb/textures/readme.txt
#fsep = "_"
fsep = "."

download_preview = ( len (sys.argv) > 1 and sys.argv[1] == "with_preview" )


print("Downloading skins from minetest.fensta.bplaced.net ...")
# Requesting all skins and their raw texture using the API
r = requests.get('http://minetest.fensta.bplaced.net/api/v2/get.json.php?getlist&page=1&per_page=999999999')

if r.status_code != 200:
    sys.exit("Request failed!")

data = r.json()
count = 0

if download_preview:
    print("Writing to file and downloading previews ...")
else:
    print("Writing skins")


for json in data["skins"]:
    id = str(json["id"])

    # Texture file
    raw_data = base64.b64decode(json["img"])
    file = open("../textures/character" + fsep + id + ".png", "wb")
    file.write(bytearray(raw_data))
    file.close()

    # Meta file
    name = str(json["name"])
    author = str(json["author"])
    license = str(json["license"])
    file = open("../meta/character_" + id + ".txt", "w")
    file.write(name + "\n" + author + "\n" + license + "\n")
    file.close()
    print("Added #%s Name: %s Author: %s License: %s" % (id, name, author, license))
    count += 1

    if download_preview:
        # Downloading the preview of the skin
        r2 = requests.get('http://minetest.fensta.bplaced.net/skins/1/' + id + ".png")
        if r2.status_code == 200:
            # Preview file
            preview = r2.content
            file = open("../textures/character_" + id + fsep + "preview.png", "wb")
            file.write(bytearray(preview))
            file.close()
        else:
            print("Failed to download skin preview #" + id)


print("Fetched " + str(count) + " skins!")
