{ lib, stdenv, fetchFromGitHub, memstreamHook, darwin }:

let
  inherit (stdenv.hostPlatform) system;
  target = {
    "aarch64-darwin" = "arm64";
    "x86_64-darwin" = "x86";
  }.${system} or (throw "Unsupported system: ${system}");
in

stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "2.7.4";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${version}";
    sha256 = "sha256-Y4xdRvbDl/VoukD/jN9jpRqtUpqVXwtK/S63+AM+eAM=";
  };

  buildInputs = with darwin.apple_sdk.frameworks; [ Carbon Cocoa SkyLight ]
    ++ lib.optionals (stdenv.system == "x86_64-darwin") [ memstreamHook ];

  makeFlags = [
    target
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/sketchybar $out/bin/sketchybar
  '';

  meta = with lib; {
    description = "A highly customizable macOS status bar replacement";
    homepage = "https://github.com/FelixKratz/SketchyBar";
    platforms = platforms.darwin;
    maintainers = [ maintainers.azuwis ];
    license = licenses.gpl3;
  };
}
