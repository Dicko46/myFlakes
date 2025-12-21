# modules/hardware/mediatek-mt7921.nix - TAMBAHKAN
{ config, pkgs, ... }:

{
  # ... existing config ...

  # 🚀 WIFI PERFORMANCE BOOST
  boot.extraModprobeConfig = ''
    options mt7921e disable_aspm=Y
    options mt7921e reset_workaround=1
    options mt7921e msi=1
    # Signal improvement attempts
    options mt7921e antenna_sel=1
  '';

  # Additional network optimizations
  # networking = {
    # Optional: Disable IPv6 jika tidak diperlukan (bisa improve performance)
    # enableIPv6 = false;
    
    # DNS optimizations
    # nameservers = [ "1.1.1.1" "8.8.8.8" ];
  # };

  # Enhanced systemd service untuk WiFi
  systemd.services.mt7921-optimize = {
    description = "MT7921 WiFi Performance Boost";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "mt7921-optimize" ''
        sleep 5
        
        # Set regulatory domain dengan power boost
        ${pkgs.iw}/bin/iw reg set ID
        
        # Aggressive interface optimization
        ${pkgs.iproute2}/bin/ip link set dev wlp2s0 txqueuelen 2000
        ${pkgs.iw}/bin/iw dev wlp2s0 set power_save off
        
        # Set ASPM disable
        echo Y > /sys/module/mt7921e/parameters/disable_aspm
        
        # Additional performance tweaks
        echo 64 > /sys/class/net/wlp2s0/queues/rx-0/rps_flow_cnt 2>/dev/null || true
        echo 1 > /proc/sys/net/ipv4/tcp_fastopen 2>/dev/null || true
        
        echo "✅ MT7921 WiFi PERFORMANCE BOOST applied"
      '';
      RemainAfterExit = true;
    };
  };
}
