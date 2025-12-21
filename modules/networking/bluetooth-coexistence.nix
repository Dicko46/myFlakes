# modules/networking/bluetooth-coexistence.nix
{ config, pkgs, ... }:

{
  # Bluetooth optimizations khusus untuk 2.4GHz WiFi
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        ControllerMode = "bredr";  # Basic mode, kurangi bandwidth
        
        # Nonaktifkan codec high-quality untuk kurangi interference
        Disable = "SBC-XQ,AptX,AptX-HD,LDAC";
      };
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 2;     # Kurangi reconnect attempts
      };
    };
  };

  # ✅ HANYA Bluetooth-specific settings, TANPA services.pipewire
  # Environment variables untuk audio optimization
  environment.sessionVariables = {
    # Optimasi untuk Bluetooth audio (kurangi bandwidth)
    PIPEWIRE_LATEX = "256/44100";
    BLUETOOTH_AVDTP_SYNC = "1";
  };

  # Systemd dependencies untuk pastikan urutan startup benar
  systemd.user.services.pipewire-pulse = {
    after = [ "bluetooth.service" ];
    wants = [ "bluetooth.service" ];
  };
}
