# modules/system/wifi-scripts.nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    iw
    wireless-tools
    inetutils
    speedtest-cli
  ];

  # Scripts akan ditambahkan di home.nix
}