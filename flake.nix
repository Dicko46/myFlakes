{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstable = nixpkgs-unstable.legacyPackages.${system};
    in {
      # NixOS Configuration
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs unstable;
        };
        modules = [
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
