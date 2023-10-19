# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Generic x86_64 (for now) computer installer
{
  self,
  ghafOS,
  nixpkgs,
  nixos-generators,
  lib,
}: let
  formatModule = nixos-generators.nixosModules.iso;
  installer = {name, systemImgCfg}: let
    system = "x86_64-linux";

    #pkgs = import nixpkgs {inherit system;};

    installerImgCfg = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit lib;};
      modules =
        [
          (import "${ghafOS}/modules/host")
          
            
          ({modulesPath, lib, config,...}: {
            imports = [ (modulesPath + "/profiles/all-hardware.nix") ];

            nixpkgs.hostPlatform.system = system;
            nixpkgs.config.allowUnfree = true;

            hardware.enableAllFirmware = true;

            services.registration-agent = {
              enable = true;
            };

            ghaf = {
              profiles.installer.enable = true;
            };

            environment.noXlibs = false;
            # For WLAN firmwares
            hardware.enableRedistributableFirmware = true;

            networking = 
            {
              wireless.enable = lib.mkForce false;
              networkmanager.enable = true;
            };

           
          })

          {
            installer.installerScript = {
            enable = true;
            runOnBoot = true;
            systems = [
              { name  = "dell-latitude-7330-laptop-debug"; image = self.nixosConfigurations.dell-latitude-7330-laptop-debug; }
              { name  = "dell-latitude-7230-tablet-debug"; image = self.nixosConfigurations.dell-latitude-7230-tablet-debug; }
              { name  = "dell-latitude-dev-debug"; image = self.nixosConfigurations.dell-latitude-dev-debug; }
              ];
            };
          }
          
          formatModule
          {
            isoImage.squashfsCompression = "lz4"; 
          }
        ]
        ++ (import ../modules/fmo-module-list.nix)
        ++ (import "${ghafOS}/modules/module-list.nix");
    };
  in {
    name = "${name}-installer";
    inherit installerImgCfg system;
    installerImgDrv = installerImgCfg.config.system.build.${installerImgCfg.config.formatAttr};
  };
  targets = map installer [{name = "general"; 
                            # TODO: here we need to choose debug/rel version according to variant
                            systemImgCfg = [ self.nixosConfigurations.dell-latitude-7330-laptop-debug
                                             self.nixosConfigurations.dell-latitude-7230-tablet-debug
                                             self.nixosConfigurations.dell-latitude-dev-debug ] ;}];
in {
  packages = lib.foldr lib.recursiveUpdate {} (map ({name, system, installerImgDrv, ...}: {
    ${system}.${name} = installerImgDrv;
  }) targets);
}
