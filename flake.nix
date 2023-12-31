# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  description = "Ghaf - Documentation and implementation for TII SSRC Secure Technologies Ghaf Framework";

  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.vedenemo.dev"
      "https://cache.ssrcdevops.tii.ae"
    ];
    extra-trusted-public-keys = [
      "cache.vedenemo.dev:RGHheQnb6rXGK5v9gexJZ8iWTPX6OcSeS56YeXYzOcg="
      "cache.ssrcdevops.tii.ae:oOrzj9iCppf+me5/3sN/BxEkp5SaFkHfKTPPZ97xXQk="
    ];
  };

  inputs = rec {
    ghafOS.url = "github:tiiuae/ghaf";
  };

  outputs = {
    self,
    ghafOS,
  }: let
    # Retrieve inputs from Ghaf
    nixpkgs = ghafOS.inputs.nixpkgs;
    flake-utils = ghafOS.inputs.flake-utils;
    nixos-generators = ghafOS.inputs.nixos-generators;
    nixos-hardware = ghafOS.inputs.nixos-hardware;
    microvm = ghafOS.inputs.microvm;
    jetpack-nixos = ghafOS.inputs.jetpack-nixos;

    systems = with flake-utils.lib.system; [
      x86_64-linux
      aarch64-linux
    ];
    lib = nixpkgs.lib.extend (final: _prev: {
      ghaf = import "${ghafOS}/lib" {
        inherit self;
        lib = final;
        inherit nixpkgs;
      };
    });
  in
    # Combine list of attribute sets together
    lib.foldr lib.recursiveUpdate {} [
   
      # ghaf lib
      {
        lib = lib.ghaf;
      }

      # Target configurations
      (import ./targets {inherit self lib ghafOS nixpkgs nixos-generators nixos-hardware microvm jetpack-nixos;})

    ];
}
