{ stdenv, fetchurl, lilypond, ghostscript, gyre-fonts }:

let

  # urw-fonts = fetchgit {
  #   url = "https://git.ghostscript.com/urw-core35-fonts.git";
  #   rev = "91edd6ece36e84a1c6d63a1cf63a1a6d84bd443a";
  #   sha256 = "0gy9qqnhhx0jyg4slnbf860af9lip9cwjpa5ymjnby9gbfkxr0sg";
  # };

  version = "2.19.80";

in

lilypond.overrideAttrs (oldAttrs: {
  name = "lilypond-${version}";
  inherit version

  src = fetchurl {
    url = "http://download.linuxaudio.org/lilypond/sources/v${majorVersion}/lilypond-${version}.tar.gz";
    sha256 = "0lql4q946gna2pl1g409mmmsvn2qvnq2z5cihrkfhk7plcqdny9n";
  };

  configureFlags = [
    "--disable-documentation"
    "--with-urwotf-dir=${ghostscript}/share/ghostscript/fonts"
    "--with-texgyre-dir=${gyre-fonts}/share/fonts/truetype/"
  ];

})
