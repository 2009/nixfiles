{ lib, stdenv, fetchFromGitHub, darwin, xxd, xcbuild }:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "7.1.1";

  #replace = {
  #  "aarch64-darwin" = "--replace '-arch x86_64' ''";
  #  "x86_64-darwin" = "--replace '-arch arm64e' '' --replace '-arch arm64' ''";
  #}.${stdenv.system};

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-H1zMg+/VYaijuSDUpO6RAs/KLAAZNxhkfIC6CHk/xoI=";
  };

  nativeBuildInputs = [ xxd xcbuild ];

  buildInputs = with darwin.apple_sdk.frameworks; [
    Carbon
    Cocoa
    ScriptingBridge
    SkyLight
  ];

  #postPatch = ''
  #  substituteInPlace makefile ${replace};
  #'';

  # need at least 12.0 command line tools and include apple clang in PATH for this to work
  buildPhase = ''
    PATH=/usr/bin:/bin /usr/bin/make install
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1/
    cp ./bin/yabai $out/bin/yabai
    cp ./doc/yabai.1 $out/share/man/man1/yabai.1
  '';

  meta = with lib; {
    description = ''
      A tiling window manager for macOS based on binary space partitioning
    '';
    homepage = "https://github.com/koekeishiya/yabai";
    platforms = platforms.darwin;
    maintainers = with maintainers; [ cmacrae shardy ];
    license = licenses.mit;
  };
}
