{ stdenv, fetchFromGitHub, Carbon }:

stdenv.mkDerivation rec {
  name = "skhd-${version}";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "skhd";
    rev = "v${version}";
    sha256 = "184bcnxmc5jjv793d53xbhvifz4cslaga3jcgdvagjd8680p5n77";
  };

  patches = [
    ./define_MAX_once.patch
  ];

  buildInputs = [ Carbon ];

  makeFlags = [ "BUILD_PATH=$(out)/bin" ];

  postInstall = ''
    mkdir -p $out/Library/LaunchDaemons
    cp ${./org.nixos.skhd.plist} $out/Library/LaunchDaemons/org.nixos.skhd.plist
    substituteInPlace $out/Library/LaunchDaemons/org.nixos.skhd.plist --subst-var out
  '';

  meta = with stdenv.lib; {
    description = "Simple hotkey daemon for macOS";
    inherit (src.meta) homepage;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ lnl7 periklis yurrriq ];
    license = licenses.mit;
  };
}
