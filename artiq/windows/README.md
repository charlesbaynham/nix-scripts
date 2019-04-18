# Preparing a Windows image

```shell
nix-build install.nix
result/bin/networked-installer.sh
```

Follow the instructions.

Then press **return** to automatically complete the installation via SSH. The virtual machine will be shut down when the process is complete.

Move the image `c.img` to one of Nix' `extra-sandbox-paths` (`nix.sandboxPaths` on NixOS).


# Running the tests manually

```shell
nix-build --pure --arg diskImage "\"…/c.img\"" -I artiqSrc=…/artiq
```
