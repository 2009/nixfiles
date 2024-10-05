{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sketchybar;
in
{
  options = with types; {
    #services.sketchybar.enable = mkOption {
    #  type = bool;
    #  default = false;
    #  description = "Whether to enable the sketcybar status bar.";
    #};

    #services.sketchybar.package = mkOption {
    #  type = path;
    #  description = "The sketchybar package to use.";
    #};

    # TODO this currently does not work and requires configuration in ~/.config/sketchybarrc
    services.sketchybar.config = mkOption {
      type = str;
      default = "";
      example = literalExpression ''
        sketchybar --bar height=32        \
                         blur_radius=50   \
                         position=top     \
                         padding_left=10  \
                         padding_right=10 \
                         color=0x15ffffff
      '';
      description = ''
        Plain text configuration file.
      '';
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && (cfg.config != "")) {
      environment.etc.sketchybarrc.text = cfg.config;
    })

    (mkIf (cfg.enable) {
      environment.systemPackages = [ cfg.package ];

      launchd.user.agents.sketchybar = {
        serviceConfig.ProgramArguments = [ "${cfg.package}/bin/sketchybar" ];

        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
        serviceConfig.EnvironmentVariables = {
          PATH = "${cfg.package}/bin:${config.environment.systemPath}";
        };
      };
    })
  ];
}
