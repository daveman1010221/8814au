{
  description = "Realtek RTL8814AU WiFi driver for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
    in {
      packages.${system}.rtl8814au = { config, pkgs, ... }: 
        let
          kernelPackages = config.boot.kernelPackages;
          kernel = kernelPackages.kernel;
        in pkgs.stdenv.mkDerivation rec {
          pname = "rtl8814au";
          version = "5.8.5.1";

          src = pkgs.fetchFromGitHub {
            owner = "daveman1010221";
            repo = "8814au";
            rev = "6aa1fd90cb7a577dacb609a8b745bd61cfadb4df"; # From nix-prefetch-git
            sha256 = "1r2q18579i9kcdynmrcccx0pa502v1gpwj54miigr8qpiw0s8gr3"; # From nix-prefetch-git
          };

          nativeBuildInputs = with pkgs; [ 
            kernel.dev  # Uses kernel-specific headers
            gcc
            make
            bc
          ];

          buildPhase = ''
            make -j$(nproc) KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
          '';

          installPhase = ''
            mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/
            cp 8814au.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/
            depmod -a
          '';

          meta = with pkgs.lib; {
            description = "Realtek RTL8814AU WiFi driver for Linux";
            homepage = "https://github.com/daveman1010221/8814au";
            license = licenses.gpl2;
            maintainers = with maintainers; [ david ];
          };
        };
    };
}
