{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.thinkpad.dualscreen;

  mkOutput = o: name:
    concatStringsSep " " (
      [ "--output" name ] ++ (
        if o ? ${name}
        then
            (if o.${name}.primary then [ "--primary" ] else []) ++
            (if o.${name} ? "mode" then [ "--mode" o.${name}.mode ] else []) ++
            (if o.${name} ? "pos" then [ "--pos"  o.${name}.pos ] else []) ++
            (if o.${name} ? "rotate" then [ "--rotate" o.${name}.rotate ] else [])
        else
          [ "--off" ]
      )
    );

in {
  imports =
      [
        <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2>
      ];

  options = {
    thinkpad.dualscreen = {
      enable = mkEnableOption "Dualscreen configuration";
      outputs = mkOption {
        type = types.attrsOf types.attrs;
        description = "xrandr output configurations";
        defaultText = "See example for available options";
        default = {
          eDP1 = {
            primary = false;
            mode = "3840x2160";
            pos = "0x2160";
            rotate = "normal";
          };
        };
        example = literalExpression ''
          {
            eDP1 = {
              primary = false; # required
              mode = "3840x2160"; # optional
              pos = "0x2160"; # optional
              rotate = "normal"; # optional
            };
            VIRTUAL3 = {
              primary = true;
              mode = "VIRTUAL3.454-3840x2160";
              pos = "0x0";
              rotate = "normal";
            };
          }
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
      preStart = "${pkgs.coreutils}/bin/sleep 3";
      script = ''
        ${pkgs.coreutils}/bin/echo "Running xrandr..."
        ${pkgs.xorg.xrandr}/bin/xrandr \
          ${mkOutput cfg.outputs "eDP1"} \
          ${mkOutput cfg.outputs "VIRTUAL1"} \
          ${mkOutput cfg.outputs "VIRTUAL2"} \
          ${mkOutput cfg.outputs "VIRTUAL3"} \
          ${mkOutput cfg.outputs "VIRTUAL4"}
      '';
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      after = [ "intel-virtual-output.service" ];
    };
  };
}
