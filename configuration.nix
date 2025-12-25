# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/hardware/mediatek-mt7921.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Enable Optimization (deduplication)
  nix.settings.auto-optimise-store = true;

  # fix initramfs phase boot
  hardware.amdgpu.initrd.enable = true;

  # Enable swapfile
  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ]; # Mengatifkan file swap
  boot.kernel.sysctl = {
    # set swap agresif
    "vm.swappiness" = 10;
    # Optimasi untuk WiFi 2.4GHz dengan Bluetooth
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_rmem" = "1024 87380 6291456";
    "net.ipv4.tcp_wmem" = "1024 87380 6291456";
    "net.core.rmem_max" = 6291456;
    "net.core.wmem_max" = 6291456;
    "net.core.netdev_max_backlog" = 3000; # Tingkatkan buffer untuk interference
  };
  boot.kernelPackages = pkgs.linuxPackages_latest; # Use latest kernel.
  # Networking
  networking.networkmanager.enable = true; # Enable network manager
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enable wireless support via wpa_supplicant.
  networking.firewall.enable = false; # Mematikan firewall agar vpn tidak diblokir
  boot.kernelModules = [ "tun" ]; # Enable Tun for vpn services
  networking.networkmanager.wifi.powersave = false; # disable wifi power save

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Asia/Singapore";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_SG.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_SG.UTF-8";
    LC_IDENTIFICATION = "en_SG.UTF-8";
    LC_MEASUREMENT = "en_SG.UTF-8";
    LC_MONETARY = "en_SG.UTF-8";
    LC_NAME = "en_SG.UTF-8";
    LC_NUMERIC = "en_SG.UTF-8";
    LC_PAPER = "en_SG.UTF-8";
    LC_TELEPHONE = "en_SG.UTF-8";
    LC_TIME = "en_SG.UTF-8";
  };

  # List services that you want to enable:
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # AMD Graphics Configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    # Optional: Low latency config untuk Bluetooth
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dicko = {
    isNormalUser = true;
    description = "Dicko Rahmansyah";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # packages = with pkgs; [
    #   # kdePackages.kate
    # ];
  };
  # Install firefox.
  programs.firefox.enable = false;
  programs.zsh.enable = true;
  # Enable Flatpak support
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;
  xdg.portal.extraPortals = [
    pkgs.kdePackages.xdg-desktop-portal-kde
    pkgs.xdg-desktop-portal-gtk
  ];
  xdg.portal.config = {
    common.default = "*"; # atau "gtk" jika ingin prioritas GTK
    kde = {
      default = [
        "kde"
        "gtk"
      ];
    };
  };
  # Allow installing non-free packages.
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Enable nix-ld untuk run binary FHS
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    micro
    yt-dlp
    ffmpeg-full
    mihomo
    libva-utils
    vulkan-tools # vulkaninfo
    vulkan-loader
    zsh
    pciutils
    usbutils
    iw
    wirelesstools
    inetutils
    speedtest-cli
    smartmontools
    ntfs3g
    exfatprogs
    kdePackages.partitionmanager
    unrar
    unzip
    steam-run
    desktop-file-utils

    # NUR Packages

  ];

  services.mihomo = {
    enable = true;
    tunMode = true;
    configFile = "/etc/mihomo/config.yaml";
  };

  systemd.user.services.update-desktop-database = {
    description = "Update desktop database";
    wantedBy = [ "default.target" ];
    after = [ "flatpak-update.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.desktop-file-utils}/bin/update-desktop-database %h/.local/share/applications";
    };
  };
  programs.gamemode.enable = true;
  documentation.man.enable = true; # Enable man pages
  documentation.man.generateCaches = true; # Menghasilkan cache manual page
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 10808 10809 2017 8080 ];
  # networking.firewall.allowedUDPPorts = [ 10808 10809 53 ];
  # Or disable the firewall altogether.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
