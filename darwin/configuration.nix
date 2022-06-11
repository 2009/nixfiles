{ config, pkgs, ... }:

{
  # https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module
  imports = [ <home-manager/nix-darwin> ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.alacritty
      pkgs.emacsMacport
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/nixfiles/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
  };

  launchd.user.agents.yabai.serviceConfig.StandardErrorPath = "/tmp/yabai.log";
  launchd.user.agents.yabai.serviceConfig.StandardOutPath = "/tmp/yabai.log";

  services.skhd.enable = true;
  # TODO this must be how we reaad a file directly into the configuration
  # This seems to pickup the config file ~/.skhd so no need to read it in here
  #services.skhd.skhdConfig = builtins.readFile ../conf.d/skhd.conf;

  environment.etc = {
    # yabai need to be run with sudo without pass to work correctly
    "sudoers.d/10-yabai-command".text = ''
      %admin ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/yabai
    '';
  };

  users.users."justin.endacott" = {
    name = "justin.endacott";
    home = "/Users/justin.endacott";
  };

  home-manager.users."justin.endacott" = { pkgs, lib, ... }: {
    home.packages = [
      pkgs.source-code-pro
      pkgs.silver-searcher
      pkgs.fasd
      pkgs.git

      pkgs.mpv
      pkgs.ffmpeg

      #  working with JSON
      pkgs.fx
      pkgs.jq

      # JS development
      pkgs.yarn
      pkgs.nodePackages.prettier
      pkgs.nodePackages.js-beautify
      pkgs.nodePackages.typescript

      pkgs.elmPackages.elm

      #---- Work stuff (outfit) -----
      pkgs.imagemagick
      pkgs.circleci-cli
      pkgs.awscli2

      # pdfs
      pkgs.poppler_utils
    ];

    #programs.alacritty = {
    #  enable = true;
    #};

    #programs.emacs.enable = true;

    home.activation = {
      #myActivationAction = lib.hm.dag.entryAfter ["writeBoundary"] ''
      #  $DRY_RUN_CMD ln -s $VERBOSE_ARG \
      #      ${builtins.toPath ./link-me-directly} $HOME
      #'';
      cloneSpacemacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -d "$HOME/.emacs.d" ] || [ -z `ls -A "$HOME/.emacs.d"` ]
        then
          $DRY_RUN_CMD git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
          $DRY_RUN_CMD cd $HOME/.emacs.d
          $DRY_RUN_CMD git checkout develop
        else
          echo "Skipped spacemacs setup, $HOME/.emacs.d exists!"
        fi
      '';
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
