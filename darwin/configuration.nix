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
    # Hide desktop icons
    finder.CreateDesktop = false;
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
    package = pkgs.yabai;
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

  services.spacebar.enable = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.config = {
    position                   = "top";
    display                    = "main";
    height                     = 26;
    title                      = "on";
    spaces                     = "on";
    clock                      = "on";
    power                      = "on";
    padding_left               = 20;
    padding_right              = 20;
    spacing_left               = 25;
    spacing_right              = 15;
    text_font                  = ''"Menlo:Regular:12.0"'';
    icon_font                  = ''"Font Awesome 6 Free:Solid:12.0"'';
    background_color           = "0xff202020";
    foreground_color           = "0xffa8a8a8";
    power_icon_color           = "0xffcd950c";
    battery_icon_color         = "0xffd75f5f";
    dnd_icon_color             = "0xffa8a8a8";
    clock_icon_color           = "0xffa8a8a8";
    power_icon_strip           = " ";
    space_icon                 = "•";
    space_icon_strip           = "1 2 3 4 5 6 7 8 9 10";
    spaces_for_all_displays    = "on";
    display_separator          = "on";
    display_separator_icon     = "";
    space_icon_color           = "0xff458588";
    space_icon_color_secondary = "0xff78c4d4";
    space_icon_color_tertiary  = "0xfffff9b0";
    clock_icon                 = "";
    dnd_icon                   = "";
    clock_format               = ''"%d/%m/%y %R"'';
    right_shell                = "on";
    right_shell_icon           = "";
    right_shell_command        = "whoami";
  };

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


  homebrew = {
    enable = true;
    autoUpdate = true;
    cleanup = "uninstall";
    brews = [
      # needed by rvm/ruby
      "gmp"
      "libyaml"
      "openssl@1.1"
    ];
    casks = [
      "keepingyouawake"

      # TODO could we use a nix package for these and launcher?
      "spark"
      "docker"
      "slack"
      "anki"
      # TODO chrome (where is profile information stored?)
      # TODO postman (where is configuration stored?)
    ];
    masApps = {};
    taps = [];
  };

  home-manager.users."justin.endacott" = { pkgs, lib, ... }: {
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

      pkgs.elmPackages.elm
      pkgs.elmPackages.elm-format

      # use ruby gem to include @prettier/plugin-ruby
      pkgs.rubyPackages.prettier

      #---- Work stuff (outfit) -----
      pkgs.imagemagick
      pkgs.circleci-cli
      pkgs.awscli2
      pkgs.saml2aws
      pkgs.postgresql

      # pdfs
      pkgs.poppler_utils
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
