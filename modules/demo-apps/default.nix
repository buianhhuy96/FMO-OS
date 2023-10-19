# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  pkgs,
  lib,
  config,
  ...
}: {
  config.ghaf.graphics.demo-apps = with lib; mkForce {
    chromium        = true;
    firefox         = false;
    gala-app        = false;
    element-desktop = false;
    zathura         = false;
  };
}
