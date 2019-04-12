{ pkgs ? import <nixpkgs> {}}:
{
  jobsets = pkgs.runCommand "spec.json" {}
    ''
    cat > $out << EOF
    {
        "main": {
            "enabled": 1,
            "hidden": false,
            "description": "Main ARTIQ packages and board support packages for HITL CI",
            "nixexprinput": "nixScripts",
            "nixexprpath": "main.nix",
            "checkinterval": 300,
            "schedulingshares": 10,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 10,
            "inputs": {
                "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs-channels nixos-19.03", "emailresponsible": false },
                "nixScripts": { "type": "git", "value": "git://github.com/m-labs/nix-scripts.git", "emailresponsible": false },
                "artiqSrc": { "type": "git", "value": "git://github.com/m-labs/artiq.git master 1", "emailresponsible": false }
            }
        },
        "sinara-systems": {
            "enabled": 1,
            "hidden": false,
            "description": "Board support packages for other Sinara systems",
            "nixexprinput": "nixScripts",
            "nixexprpath": "sinara-systems.nix",
            "checkinterval": 86400,
            "schedulingshares": 1,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 10,
            "inputs": {
                "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs-channels nixos-19.03", "emailresponsible": false },
                "nixScripts": { "type": "git", "value": "git://github.com/m-labs/nix-scripts.git", "emailresponsible": false },
                "sinaraSystemsSrc": { "type": "git", "value": "git://github.com/m-labs/sinara-systems.git master 1", "emailresponsible": false },
                "m-labs": { "type": "sysbuild", "value": "artiq:main:generated-nix", "emailresponsible": false }
            }
        }
    }
    EOF
    '';
}
