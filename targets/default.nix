# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# List of target configurations
{
  self,
  lib,
  nixpkgs,
  ghafOS,
  nixos-generators,
  nixos-hardware,
  microvm,
  jetpack-nixos,
}:
lib.foldr lib.recursiveUpdate {} [
  (import ./installer.nix {inherit self nixpkgs ghafOS lib nixos-generators;})
  (import ./dell-latitude-7330-laptop.nix {inherit self ghafOS lib nixos-generators nixos-hardware microvm;})
  (import ./dell-latitude-7230-tablet.nix {inherit self ghafOS lib nixos-generators nixos-hardware microvm;})
  (import ./dell-latitude-dev.nix {inherit self ghafOS lib nixos-generators nixos-hardware microvm;})
]
