import json
import bz2
import sys

with open(sys.argv[1], "r") as f:
    hydra_json = json.load(f)

drv = hydra_json["drvPath"]
assert drv.startswith("/nix/store/")
drv = drv[len("/nix/store/"):]
hydra_log = "/var/lib/hydra/build-logs/" + drv[:2] + "/" + drv[2:] + ".bz2"

with bz2.BZ2File(hydra_log, "w") as f:
    f.write(b"hack successful")
