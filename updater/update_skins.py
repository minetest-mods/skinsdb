import sys, requests, base64

# filename seperator to use, either default "-" or ".". see skinsdb/textures/readme.txt
#fsep = "_"
fsep = "."



print("Downloading skins from skinsdb.terraqueststudio.net ...")
# Requesting all skins and their raw texture using the API
r = requests.get('http://skinsdb.terraqueststudios.net/api/v1/content?client=script&page=1&per_page=10000')

if r.status_code != 200:
    sys.exit("Request failed!")

data = r.json()
count = 0

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


print("Fetched " + str(count) + " skins!")
