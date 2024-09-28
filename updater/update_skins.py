import os.path, sys, requests, base64


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

    name = "character." + id
    if True:
        legacy_name = "character_" + id
        if os.path.exists("../textures/" + legacy_name + ".png"):
            name = legacy_name


    # Texture file
    raw_data = base64.b64decode(json["img"])
    file = open("../textures/" + name + ".png", "wb")
    file.write(bytearray(raw_data))
    file.close()

    # Meta file
    meta_name = str(json["name"])
    meta_author = str(json["author"])
    meta_license = str(json["license"])
    file = open("../meta/" + name + ".txt", "w")
    file.write(meta_name + "\n" + meta_author + "\n" + meta_license + "\n")
    file.close()
    print("Added #%s Name: %s Author: %s License: %s" % (id, meta_name, meta_author, meta_license))
    count += 1

print("Fetched " + str(count) + " skins!")
