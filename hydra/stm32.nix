{ pkgs ? import <nixpkgs> {}}:
{
  jobsets = pkgs.runCommand "spec.json" {}
    ''
    cat > $out << EOF
    {
        "adc2tcp": {
            "enabled": 1,
            "hidden": false,
            "description": "STM32 demo",
            "nixexprinput": "adc2tcp",
            "nixexprpath": "release.nix",
            "checkinterval": 300,
            "schedulingshares": 10,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 10,
            "inputs": {
                "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs-channels nixos-19.03", "emailresponsible": false },
                "adc2tcp": { "type": "git", "value": "git://github.com/m-labs/adc2tcp.git", "emailresponsible": false },
                "mozillaOverlay": { "type": "git", "value": "git://github.com/mozilla/nixpkgs-mozilla.git", "emailresponsible": false }
            }
        }
    }
    EOF
    '';
}
