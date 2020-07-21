import os, sys, re

OLD = sys.argv[1].encode('utf-8')
NEW = sys.argv[2].encode('utf-8')

if len(NEW) > len(OLD):
    raise ValueError("Cannot new shorter than the replacement")
new = NEW + b"\0" * (len(OLD) - len(NEW))

def patch_file(path):
    with open(path, "r+b") as f:
        s = f.read()
    occurrences = s.count(OLD)
    s = s.replace(OLD, new)
    if occurrences > 0:
        print("{}: replaced {}, left {}".format(path, occurrences, s.count(OLD)))
    with open(path, "w+b") as f:
        f.write(s)

for root, dirs, files in os.walk("."):
    for filename in files:
        path = "{}/{}".format(root, filename)
        patch_file(path)

def mangle_path(path):
    path = re.sub(r"^/c/", "C:/", path)
    return str(path)
        
OLD = mangle_path(sys.argv[1]).encode('utf-8')
NEW = mangle_path(sys.argv[2]).encode('utf-8')
        
for root, dirs, files in os.walk("."):
    for filename in files:
        path = "{}/{}".format(root, filename)
        patch_file(path)
