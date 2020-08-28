{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.thinkpad.dualscreen;

in {
  imports =
      [
        <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2>
      ];

  options = {
    thinkpad.dualscreen = {
      enable = mkEnableOption "Dualscreen configuration";
      xrandrScript = mkOption {
        type = types.str;
        description = "xrandr command to configure screen layout";
        default = ''
        ${pkgs.coreutils}/bin/echo "Running xrandr..."
        ${pkgs.xorg.xrandr}/bin/xrandr --output eDP1 --mode 3840x2160 --pos 0x2160 --rotate normal \
          --output VIRTUAL1 --off \
          --output VIRTUAL2 --off \
          --output VIRTUAL3 --primary --mode VIRTUAL3.454-3840x2160 --pos 0x0 --rotate normal \
          --output VIRTUAL4 --off
        '';
        defaultText = "See example";
        example = literalExample ''
        ''${pkgs.coreutils}/bin/echo "Running xrandr..."
        ''${pkgs.xorg.xrandr}/bin/xrandr --output eDP1 --mode 3840x2160 --pos 0x2160 --rotate normal \
          --output VIRTUAL1 --off \
          --output VIRTUAL2 --off \
          --output VIRTUAL3 --primary --mode VIRTUAL3.454-3840x2160 --pos 0x0 --rotate normal \
          --output VIRTUAL4 --off
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.bumblebee.enable = true;
    hardware.bumblebee.connectDisplay = true;
    nixpkgs.config.allowUnfree = true;

    systemd.user.services.intel-virtual-output = {
      enable = true;
      script = ''
      ${pkgs.coreutils}/bin/echo "Starting primusrun..."
      ${pkgs.primus}/bin/primusrun ${pkgs.xorg.xf86videointel}/bin/intel-virtual-output -f
      '';
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.dualscreen = {
      enable = true;
      preStart = "${pkgs.coreutils}/bin/sleep 2";
      script = cfg.xrandrScript;
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      after = [ "intel-virtual-output.service" ];
    };
  };
}
