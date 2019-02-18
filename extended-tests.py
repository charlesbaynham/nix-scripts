import json
import sys
import time
import subprocess
import os

import artiq


with open(sys.argv[1], "r") as hydra_json_file:
    hydra_json = json.load(hydra_json_file)

drv = hydra_json["drvPath"]
assert drv.startswith("/nix/store/")
drv = drv[len("/nix/store/"):]
hydra_log = "/var/lib/hydra/build-logs/" + drv[:2] + "/" + drv[2:]

with open(hydra_log, "w") as log:
    def run(*args, **kwargs):
        subprocess.run(args, stdout=log, stderr=log, **kwargs).check_returncode()

    run("artiq_flash", "-t", "kc705", "-V", "nist_clock")

    time.sleep(15)

    # ping: socket: Operation not permitted
    #run("ping", "kc705-1", "-c10", "-w30")

    env = {
        "ARTIQ_ROOT": artiq.__path__[0] + "/examples/kc705_nist_clock",
        "ARTIQ_LOW_LATENCY": "1"
    }
    env.update(os.environ)
    run("python", "-m", "unittest", "discover", "-v", "artiq.test.coredevice", env=env)
