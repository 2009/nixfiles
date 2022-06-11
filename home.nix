{ config, pkgs, ... }:

# TODO: Not used for MACOX, remove mac related stuff

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "justin.endacott";
  home.homeDirectory = "/Users/justin.endacott";

  home.packages = [
    # pkgs is the set of all packages in the default home.nix implementation

    #pkgs.emacs
    pkgs.silver-searcher
    pkgs.alacritty
    pkgs.fasd

    # Mac Only
    # Copy *.app files from ~/.nix-profile/Applications
    # TODO conditionally install emacsMacport/emacs package
    pkgs.emacsMacport
    # TODO use nix-darwin to allow starting this automatically
    # https://github.com/cmacrae/config/blob/master/modules/macintosh.nix
    pkgs.yabai
    pkgs.skhd
  ];

  # Home Manger modules

  programs.git = {
    enable = true;

    userName = "Justin Endacott";
    userEmail = "justin.endacott@gmail.com";

    aliases = {
      st = "status";
    };

    extraConfig = {
      pull = { ff = "only"; };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
