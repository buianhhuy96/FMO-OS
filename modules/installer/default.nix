# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{pkgs, 
config,
lib,
systemImgCfg,
...}: with lib;
let 
  cfg = config.installer.installerScript;
  installerDir = ./src;
  system0 = "${(builtins.elemAt systemImgCfg 0).config.system.build.${(builtins.elemAt systemImgCfg 0).config.formatAttr}}/nixos.img";
  system1 = "${(builtins.elemAt systemImgCfg 1).config.system.build.${(builtins.elemAt systemImgCfg 1).config.formatAttr}}/nixos.img";
  system2 = "${(builtins.elemAt systemImgCfg 2).config.system.build.${(builtins.elemAt systemImgCfg 2).config.formatAttr}}/nixos.img";
  registration-agent-laptop = pkgs.callPackage ../registration-agent/registration-agent-laptop.nix {inherit pkgs; };

  

in
{
  options.installer.installerScript = {
    enable = mkEnableOption "Build and enable installer script";

    #imageList = mkOption {
    #  description = mdDoc ''
    #    List of images to be install.
    #  '';
    #  type = with types; listOf(set);
    #  default = [];
    #};

    runOnBoot = mkOption {
      description = mdDoc ''
        Enable installing script to run on boot.
      '';
      type = types.bool;
      default = [];
    };

    systems = mkOption{
      type = with types; listOf (submodule {
        options = {  
          name = mkOption {
            type = types.str;
            description = "Path to source file to copy";
            default = null;
          };   
          image = mkOption {
            type = types.attrs;
            description = "Path to source file to copy";
            default = null;
          };     
        };
      });
    };
  };

  config.environment = mkIf (cfg.enable && cfg.systems != []) (
   
    let
      imageText = map (system: "${system.name}||${system.image.config.system.build.${system.image.config.formatAttr}}/nixos.img") cfg.systems; 
      imageListText = builtins.concatStringsSep "||" imageText;
      installerGoScript = pkgs.buildGo120Module {
        name = "ghaf-installer";
        src = ./src;
        vendorSha256 = "sha256-MKMsvIP8wMV86dh9Y5CWhgTQD0iRpzxk7+0diHkYBUo=";
        proxyVendor=true;

        # TODO: here we need to choose debug/rel version according to variant
        ldflags = [
          "-X ghaf-installer/global.Images=${imageListText}"
          "-X ghaf-installer/screen.screenDir=${installerDir}/screen"
          "-X ghaf-installer/screen.registrationAgentScript=${registration-agent-laptop}/bin/registration-agent-laptop-orig"
        ];
      };
    in 
    {
      systemPackages = [installerGoScript];
      loginShellInit = mkIf (cfg.runOnBoot) (''sudo ${installerGoScript}/bin/ghaf-installer'');
      
});

}