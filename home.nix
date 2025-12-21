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
    mangohud
    lutris
    protonup-qt
    heroic
    gamemode

    # Multimedia
    obsidian
    mpv
    vlc
    vscode
    nil
    proton-pass

    # Internet
    motrix
    brave
    media-downloader
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

    (writeShellScriptBin "wifi-boost" ''
      echo "🚀 APPLYING WIFI PERFORMANCE BOOST"

      # Aggressive optimizations
      sudo iw reg set ID
      sudo iw dev wlp2s0 set power_save off
      sudo ip link set dev wlp2s0 txqueuelen 2000
      echo Y | sudo tee /sys/module/mt7921e/parameters/disable_aspm

      # Network optimizations
      echo 0 | sudo tee /proc/sys/net/ipv4/tcp_slow_start_after_idle
      echo 4000 | sudo tee /proc/sys/net/core/netdev_max_backlog
      echo 1 | sudo tee /proc/sys/net/ipv4/tcp_fastopen 2>/dev/null || true

      echo ""
      echo "✅ WiFi PERFORMANCE BOOST activated"
      echo "   - Maximum transmit power"
      echo "   - Power save disabled"
      echo "   - Network buffers optimized"
    '')

    (writeShellScriptBin "wifi-monitor" ''
      echo "📊 WIFI PERFORMANCE MONITOR"
      echo "==========================="

      while true; do
        clear
        echo "$(date) - MT7921 Status"
        echo "----------------------"

        # Connection info
        LINK_INFO=$(iw dev wlp2s0 link 2>/dev/null)
        echo "📶 Connected: $(echo "$LINK_INFO" | grep "SSID" | cut -d: -f2)"
        echo "📡 Signal: $(echo "$LINK_INFO" | grep "signal" | awk '{print $2}') dBm"
        echo "⬇️  RX Rate: $(echo "$LINK_INFO" | grep "rx bitrate" | awk '{print $3, $4}')"
        echo "⬆️  TX Rate: $(echo "$LINK_INFO" | grep "tx bitrate" | awk '{print $3, $4}')"

        # Interface stats
        echo ""
        echo "📈 Interface Stats:"
        cat /proc/net/wireless | grep wlp2s0

        echo ""
        echo "Press Ctrl+C to exit - Refreshing every 3 seconds..."
        sleep 3
      done
    '')

    (writeShellScriptBin "wifi-restart" ''
      echo "🔄 RESTARTING WIFI INTERFACE"
      sudo ip link set wlp2s0 down
      sleep 2
      echo "Interface down..."
      sudo ip link set wlp2s0 up
      sleep 3
      echo "Interface up - reconnecting..."

      # Re-apply optimizations
      sudo iw dev wlp2s0 set power_save off
      echo "✅ WiFi interface restarted and optimized"
    '')
    # Script custom untuk MT7921
    (writeShellScriptBin "wifi-set-params" ''
      echo "⚙️ Setting available MT7921e parameters..."

      # Set parameter yang tersedia
      echo Y | sudo tee /sys/module/mt7921e/parameters/disable_aspm

      echo "✅ Parameters set"
      echo ""
      echo "Current values:"
      echo "disable_aspm: $(cat /sys/module/mt7921e/parameters/disable_aspm)"
    '')

    (writeShellScriptBin "wifi-fix-all" ''
      echo "🔧 Applying all WiFi fixes..."

      # Set regulatory domain
      sudo iw reg set ID
      echo "✅ Regulatory domain set to ID"

      # Restart WiFi interface
      sudo ip link set wlp2s0 down
      sleep 2
      sudo ip link set wlp2s0 up
      echo "✅ WiFi interface wlp2s0 restarted"

      # Disable powersave via iw
      sudo iw dev wlp2s0 set power_save off
      echo "✅ Power save disabled"

      # Set available parameters
      echo Y | sudo tee /sys/module/mt7921e/parameters/disable_aspm
      echo "✅ ASPM disabled"

      # Optimize TCP settings
      echo 0 | sudo tee /proc/sys/net/ipv4/tcp_slow_start_after_idle
      echo "✅ TCP optimizations applied"

      echo ""
      echo "🎯 All fixes applied. Current status:"
      iw reg get | head -2
      echo "Power save: $(iw dev wlp2s0 get power_save)"
      echo "disable_aspm: $(cat /sys/module/mt7921e/parameters/disable_aspm)"
    '')

    (writeShellScriptBin "wifi-status" ''
      echo "=== MT7921 STATUS (wlp2s0) ==="
      echo ""
      echo "🌍 Regulatory: $(iw reg get | head -1)"
      echo ""
      echo "📡 Interface: wlp2s0"
      echo ""
      echo "📶 Connection:"
      iw dev wlp2s0 link | grep -E "SSID|signal|tx bitrate|rx bitrate" | head -4
      echo ""
      echo "⚡ Power Save: $(iw dev wlp2s0 get power_save 2>/dev/null || echo 'off')"
      echo ""
      echo "🔧 Module Parameters:"
      echo "disable_aspm: $(cat /sys/module/mt7921e/parameters/disable_aspm 2>/dev/null || echo 'N/A')"
      echo ""
      echo "📊 TCP Optimizations:"
      echo "tcp_slow_start_after_idle: $(cat /proc/sys/net/ipv4/tcp_slow_start_after_idle)"
    '')

    (writeShellScriptBin "wifi-status-24ghz" ''
      echo "=== 2.4GHz WiFi Status ==="
      echo ""

      # WiFi Info
      LINK_INFO=$(iw dev wlp2s0 link 2>/dev/null)
      echo "📶 WiFi Connection:"
      echo "$LINK_INFO" | grep -E "SSID|signal|tx bitrate|rx bitrate" | head -4

      # Channel info
      CHANNEL=$(iw dev wlp2s0 info | grep channel | awk '{print $2}')
      echo "📡 Channel: $CHANNEL"

      # Performance indicators
      echo ""
      echo "📊 Performance:"
      echo "Power Save: $(iw dev wlp2s0 get power_save 2>/dev/null || echo 'off')"
      echo "ASPM: $(cat /sys/module/mt7921e/parameters/disable_aspm 2>/dev/null || echo 'N/A')"
      echo "TCP Slow Start: $(cat /proc/sys/net/ipv4/tcp_slow_start_after_idle)"
    '')

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
      garbage = "sudo nix-collect-garbage";
      pffmpeg = "progress -M -c ffmpeg";
      vdown = "./home/dicko/Downloads/M3u8/download_batch.sh";
      vretry = "./home/dicko/Downloads/M3u8/failed_dowmload.sh";
      wifiboost = "wifi-boost";
      wifimon = "wifi-monitor";
      wifirestart = "wifi-restart";
      wifistat = "wifi-status-24ghz";
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
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Dicko46";
      email = "dickorahmansyah@gmail.com";
    };
  };

  # XDG directories
  xdg.enable = true;
}
