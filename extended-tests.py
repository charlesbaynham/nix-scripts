import json
import sys
import subprocess

with open(sys.argv[1], "r") as hydra_json_file:
    hydra_json = json.load(hydra_json_file)

drv = hydra_json["drvPath"]
assert drv.startswith("/nix/store/")
drv = drv[len("/nix/store/"):]
hydra_log = "/var/lib/hydra/build-logs/" + drv[:2] + "/" + drv[2:]

with open(hydra_log, "w") as log:
    def run(*args):
        subprocess.run(args, stdout=log, stderr=log).check_returncode()
    run("artiq_flash", "-t", "kc705", "-V", "nist_clock")
