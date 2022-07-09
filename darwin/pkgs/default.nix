self: super:

{
  yabai4 = super.callPackage ./yabai.nix {};
  sketchybar = super.callPackage ./sketchybar.nix {};

  # NOTE: this seems to be an alternative way to do almost same thing but does not have correct clang
  #yabai = super.yabai.overrideAttrs (o: {
  #  version = "master";
  #  src = super.fetchFromGitHub {
  #    owner = "koekeishiya";
  #    repo = "yabai";
  #    rev = "17fcfb73d8bc013b0250a9be42adb91c1a7cb72e";
  #    sha256 = "065qdf5q955jr2cic47w0nxmp8n13dvjpmi6b779kggr38b1l7wz";
  #  };
  #});
}
