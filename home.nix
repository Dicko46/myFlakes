{
  pkgs,
  ...
}:

{
  # Basic configuration
  home.username = "dicko";
  home.homeDirectory = "/home/dicko";
  home.stateVersion = "25.05";

  # HAPUS SEMUA nixpkgs.config karena sudah diatur di level system
  # nixpkgs.config.allowUnfree = true;

  # Auto update user desktop database
  home.activation.updateDesktopDatabase = ''
    if [ -d "$HOME/.local/share/applications" ]; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database "$HOME/.local/share/applications"
    fi
  '';

  # Packages - hanya gunakan pkgs regular, jangan campur dengan unstable dulu
  home.packages = with pkgs; [

    # Windows Apps + Gaming
    wine
    winetricks
    cabextract
    zenity
    p7zip
    mangohud
    lutris
    protonup-qt
    heroic
    gamemode
    freetype
    winePackages.fonts

    # Multimedia
    obsidian
    mpv
    vlc
    vscode
    nil
    proton-pass

    # Internet
    brave
    firefox-esr
    tdl
    ayugram-desktop

    # CLI
    fastfetch
    git
    eza
    bat
    progress

    # GStreamer
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi

    # KDE Applications
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kdeconnect-kde
    krename

    # Python
    python3
    python313Packages.beautifulsoup4
    python313Packages.tqdm
    python313Packages.requests
    python313Packages.requests-file
    python313Packages.playwright
    playwright

  ];
  # ++ (with unstable; [
  #   # UNSTABLE - untuk tools development/gaming yang butuh versi terbaru
  # ]);

  # ZSH configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      update = "sudo nixos-rebuild switch --flake /home/dicko/myFlakes#nixos";
      flake-update = "sudo nix flake update /home/dicko/myFlakes";
      garbage = "sudo nix-collect-garbage";
      pffmpeg = "progress -M -c ffmpeg";
      mihomo-status = "sudo systemctl status mihomo.service";
      mihomo-start = "sudo systemctl start mihomo.service";
      mihomo-stop = "sudo systemctl stop mihomo.service";
      mihomo-restart = "sudo systemctl restart mihomo.service";
      mihomo-enable = "sudo systemctl enable mihomo.service";
      mihomo-disable = "sudo systemctl disable mihomo.service";
      mihomo-log = "journalctl -u mihomo.service -f";
      mihomo-config = "sudo micro /etc/mihomo/config.yaml";
      mihomo-update = "sudo mihomo update";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "amuse";
    };
  };
  programs.mpv = {
    enable = true;
    config = {
      volume = 40; # Set volume awal 30%
      volume-max = 100;
      save-position-on-quit = true;
      profile = "gpu-hq";
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "auto-safe";
      screenshot-format = "png";
      screenshot-directory = "~/Pictures/Screenshots";
      sub-auto = "fuzzy";
      sl = "id";
      sub-codepage = "sjis";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Dicko46";
      email = "dickorahmansyah@gmail.com";
    };
  };
  # Fix permission issues
  home.activation.ensureGitConfig = ''
    if [ ! -d "$HOME/.config/git" ]; then
      mkdir -p "$HOME/.config/git"
    fi
    chmod 755 "$HOME/.config/git"
  '';

  # XDG directories
  xdg.enable = true;
}
