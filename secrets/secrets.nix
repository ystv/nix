let
  ops = {
    nix-builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM32qDHEY8Aswp8/mbs7JPgtduHNcTdR7zRR7c9vbjpZ ops@nix-builder";
  };
  archessmn = {
    helios = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKbv0CfhD/1mE+OORtFtHcj9PA3Gal6S/+czXp82B0t archessmn@helios";
  };
in
{
  "wifi-mydevices-password.age".publicKeys = [
    ops.nix-builder
    archessmn.helios
  ];
}
