# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Generic x86_64 computer -target
{
  self,
  lib,
  ghafOS,
  nixos-generators,
  nixos-hardware,
  microvm,
}: let
  name = "dell-latitude-dev";
  system = "x86_64-linux";
  formatModule = nixos-generators.nixosModules.raw-efi;
  dell-dev-x86 = variant: extraModules: let
    hostConfiguration = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit lib;};
      modules =
        [
          microvm.nixosModules.host
                      
          (import "${ghafOS}/modules/host/default.nix")
          (import "${ghafOS}/modules/virtualization/microvm/microvm-host.nix")

          {
            services = {
              dci = {
                enable = true;
                compose-path = "/var/fogdata/docker-compose.yml";
                pat-path = "/var/fogdata/PAT.pat";
              };
              registration-agent = {
                enable = true;
              };
            };

            ghaf = {
              hardware.x86_64.common.enable = true;

              virtualization.microvm-host.enable = true;
              host.networking.enable = true;



              # Enable all the default UI applications
              profiles = {
                applications.enable = true;
                #TODO clean this up when the microvm is updated to latest
                release.enable = variant == "release";
                debug.enable = variant == "debug";
              };
            };
          }

          formatModule

          #TODO: how to handle the majority of laptops that need a little
          # something extra?
          # SEE: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
          # nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen

          {
            boot.kernelParams = [
              "intel_iommu=on,igx_off,sm_on"
              "iommu=pt"

              # TODO: Change per your device
              # Passthrough Intel WiFi card
              "vfio-pci.ids=8086:a0f0"
            ];
          }
        ]
        ++ (import ../modules/fmo-module-list.nix)
        ++ (import "${ghafOS}/modules/module-list.nix")
        ++ extraModules;
    };
  in {
    inherit hostConfiguration;
    name = "${name}-${variant}";
    package = hostConfiguration.config.system.build.${hostConfiguration.config.formatAttr};
  };
  debugModules = with ghafOS; [ (import "${ghafOS}/modules/development/usb-serial.nix" {inherit lib; inherit config; ghaf.development.usb-serial.enable = true;})];
  targets = [
    (dell-dev-x86 "debug" [])
    (dell-dev-x86 "release" [])
  ];
in {
  nixosConfigurations =
    builtins.listToAttrs (map (t: lib.nameValuePair t.name t.hostConfiguration) targets);
  packages = {
    x86_64-linux =
      builtins.listToAttrs (map (t: lib.nameValuePair t.name t.package) targets);
  };
}
