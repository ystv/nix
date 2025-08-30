# YSTV's NixOS Configs

A small (for now) repo containing some NixOS configs that YSTV uses.

### Remote Encoder ISO

```sh
nix build .#nixosConfigurations.remote-encoder.config.system.build.images.iso
```
