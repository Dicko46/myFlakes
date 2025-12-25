{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nur,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstable = nixpkgs-unstable.legacyPackages.${system};

    in
    {
      # NixOS Configuration
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs unstable;
          inherit nur;
        };
        modules = [
          # Module untuk setup NUR overlay
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                nur.overlays.default
                # Overlay fix untuk libtorrent
                (final: prev: {
                  # Fix libtorrent reference untuk semua package
                  libtorrent = prev.libtorrent-rakshasa;

                  # Override khusus untuk package NUR
                  nur = import nur {
                    nurpkgs = final;
                    pkgs = final;
                  };
                })
              ];

            }
          )

          ./configuration.nix
          # Home Manager sebagai module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";

              # Konfigurasi user dicko
              users.dicko = import ./home.nix;

              # Extra arguments untuk home.nix
              extraSpecialArgs = {
                inherit unstable;
                stable = pkgs;
                #  nur = inputs.nur;
              };
            };
          }
        ];
      };

      # Home Manager Standalone Configuration - FIXED
      # homeConfigurations = {
      # "dicko" = home-manager.lib.homeManagerConfiguration {
      # pkgs = pkgs;  # PAKAI 'pkgs = ' bukan 'inherit pkgs'
      # extraSpecialArgs = { inherit unstable; };
      # modules = [ ./home.nix ];
      #};
      #};
    };
}
