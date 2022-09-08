{ config, pkgs, ... }:

{
  # https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module
  imports = [
    <home-manager/nix-darwin>
    ./services/sketchybar.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      #pkgs.alacritty
      #pkgs.emacsMacport
    ];

  # custom packages
  nixpkgs.overlays = [ (import ./pkgs) ];

	nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.defaults = {
    dock.autohide = true;

    # Don't rearrange spaces by most recent
    dock.mru-spaces = false;

    # Autohide top menubar
    NSGlobalDomain._HIHideMenuBar = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";

    # Show file extensions and hidden files in finder
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.ShowPathbar = true;

    # Needed for yaibai to be able to switch to a display with no windows
    finder.CreateDesktop = true;
    screencapture.location = "$HOME/workfiles/Screenshots";
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/nixfiles/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;
  programs.vim.enable = true;
  # FIXME This option for default config don't seem to work, instead include a
  # simple config ourselves
  programs.vim.enableSensible = true;

  services.yabai = {
    enable = true;
    package = pkgs.yabai4;
    enableScriptingAddition = true;
  };

  launchd.user.agents.yabai.serviceConfig.StandardErrorPath = "/tmp/yabai.log";
  launchd.user.agents.yabai.serviceConfig.StandardOutPath = "/tmp/yabai.log";

  # TODO this must be how we read a file directly into the configuration
  # This seems to pickup the config file ~/.skhd so no need to read it in here
  #services.skhd.skhdConfig = builtins.readFile ../conf.d/skhd.conf;

  services.skhd.enable = true;

  launchd.user.agents.skhd.serviceConfig.StandardErrorPath = "/tmp/skhd.log";
  launchd.user.agents.skhd.serviceConfig.StandardOutPath = "/tmp/skhd.log";

  # TODO need to break these out and work out how to structure folder
  services.sketchybar.enable = true;
  services.sketchybar.package = pkgs.sketchybar;

  launchd.user.agents.sketchybar.serviceConfig.StandardErrorPath = "/tmp/sketchybar.log";
  launchd.user.agents.sketchybar.serviceConfig.StandardOutPath = "/tmp/sketchybar.log";

  environment.etc = {
    # yabai need to be run with sudo without pass to work correctly
    "sudoers.d/10-yabai-command".text = ''
      %admin ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/yabai
    '';
  };

  users.users.jendacott = {
    name = "justin.endacott";
    home = "/Users/jendacott";
  };


  homebrew = {
    enable = true;
    autoUpdate = true;
    cleanup = "uninstall";
    brews = [
      # needed by rvm/ruby
      "gmp"
      "libyaml"
      "openssl@1.1"

      # stacked commits with git
      "withgraphite/tap/graphite"
    ];
    casks = [
      "keepingyouawake"

      # TODO could we use a nix package for these and launcher?
      "emacs"
      "alacritty"
      "spark"
      "docker"
      #"slack"
      "anki"
      "postman"
      "aws-vpn-client"
      # TODO chrome (where is profile information stored?)
      # TODO postman (where is configuration stored?)
    ];
    masApps = {};
    taps = [];
  };

  home-manager.users.jendacott = { pkgs, lib, config, ... }: {
    home.stateVersion = "22.05";

    # dotfiles
    home.file.".spacemacs".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/spacemacs;
    home.file.".skhdrc".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/skhdrc;
    home.file.".yabairc".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/yabairc;

    # TODO needs zsh configured through nix
    programs.zsh.oh-my-zsh.enable = true;

    home.packages = [
      pkgs.source-code-pro
      pkgs.font-awesome

      pkgs.silver-searcher
      pkgs.fasd
      pkgs.bat # better cat
      pkgs.git

      pkgs.mpv
      pkgs.ffmpeg

      #  working with JSON
      pkgs.fx
      pkgs.jq

      # JS development
      pkgs.yarn
      pkgs.nodePackages.js-beautify
      pkgs.nodePackages.typescript
      pkgs.nodePackages.eslint

      pkgs.elmPackages.elm
      pkgs.elmPackages.elm-format

      # use ruby gem to include @prettier/plugin-ruby
      # FIXME: this doesn't seem to be available, installed with yarn for now
      # NOTE: this might install to the gemset being used when running darwin-rebuild
      pkgs.rubyPackages.prettier

      #---- Work stuff (outfit) -----
      pkgs.imagemagick
      pkgs.circleci-cli
      pkgs.awscli2
      pkgs.saml2aws
      pkgs.postgresql # used for pgsql client

      # pdfs
      pkgs.poppler_utils
      pkgs.exiftool
      pkgs.pdftk
    ];

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
