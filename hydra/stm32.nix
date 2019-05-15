{ pkgs ? import <nixpkgs> {}}:
{
  jobsets = pkgs.runCommand "spec.json" {}
    ''
    cat > $out << EOF
    {
        "stabilizer": {
            "enabled": 1,
            "hidden": false,
            "description": "Stabilizer firmware",
            "nixexprinput": "stabilizer",
            "nixexprpath": "release.nix",
            "checkinterval": 300,
            "schedulingshares": 10,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 10,
            "inputs": {
                "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs-channels nixos-19.03", "emailresponsible": false },
                "stabilizer": { "type": "git", "value": "git://github.com/quartiq/stabilizer.git", "emailresponsible": false },
                "mozillaOverlay": { "type": "git", "value": "git://github.com/mozilla/nixpkgs-mozilla.git", "emailresponsible": false }
            }
        }
    }
    EOF
    '';
}
