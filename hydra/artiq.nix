{ pkgs ? import <nixpkgs> {}}:
{
  jobsets = pkgs.runCommand "spec.json" {}
    ''
    cat > $out << EOF
    {
        "fast": {
            "enabled": 1,
            "hidden": false,
            "description": "Core ARTIQ packages to build fast for CI purposes",
            "nixexprinput": "nixScripts",
            "nixexprpath": "artiq-fast.nix",
            "checkinterval": 300,
            "schedulingshares": 10,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 10,
            "inputs": {
                "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs-channels nixos-19.09", "emailresponsible": false },
                "nixScripts": { "type": "git", "value": "https://git.m-labs.hk/M-Labs/nix-scripts.git", "emailresponsible": false },
                "artiqSrc": { "type": "git", "value": "git://github.com/m-labs/artiq.git master 1", "emailresponsible": false }
            }
        },
        "full": {
            "enabled": 1,
            "hidden": false,
            "description": "Full set of ARTIQ packages",
            "nixexprinput": "nixScripts",
            "nixexprpath": "artiq-full.nix",
            "checkinterval": 86400,
            "schedulingshares": 1,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 10,
            "inputs": {
                "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs-channels nixos-19.09", "emailresponsible": false },
                "nixScripts": { "type": "git", "value": "https://git.m-labs.hk/M-Labs/nix-scripts.git", "emailresponsible": false },
                "sinaraSystemsSrc": { "type": "git", "value": "https://git.m-labs.hk/M-Labs/sinara-systems.git master 1", "emailresponsible": false },
                "artiq-fast": { "type": "sysbuild", "value": "artiq:fast:generated-nix", "emailresponsible": false }
            }
        },
        "urukul": {
            "enabled": 1,
            "hidden": false,
            "description": "Urukul CPLD gateware",
            "nixexprinput": "nixScripts",
            "nixexprpath": "urukul.nix",
            "checkinterval": 172800,
            "schedulingshares": 1,
            "enableemail": false,
            "emailoverride": "",
            "keepnr": 10,
            "inputs": {
                "nixpkgs": { "type": "git", "value": "git://github.com/NixOS/nixpkgs-channels nixos-19.09", "emailresponsible": false },
                "nixScripts": { "type": "git", "value": "https://git.m-labs.hk/M-Labs/nix-scripts.git", "emailresponsible": false },
                "urukulSrc": { "type": "git", "value": "git://github.com/quartiq/urukul", "emailresponsible": false }
            }
        }
    }
    EOF
    '';
}
