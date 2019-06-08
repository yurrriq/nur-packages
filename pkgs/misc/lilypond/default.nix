{ stdenv, fetchurl, ghostscript, texinfo, imagemagick, texi2html, guile
, python2, gettext, flex, perl, bison, pkgconfig, autoreconfHook, dblatex
, fontconfig, freetype, pango, fontforge, help2man, zip, netpbm, groff
, makeWrapper, rsync, t1utils
, texlive, tex ? texlive.combine {
    inherit (texlive) scheme-small lh metafont epsf;
  }
}:

let

  version = "2.18.2";

in

stdenv.mkDerivation {
  name = "lilypond-${version}";
  inherit version;

  src = fetchurl {
    url = "http://download.linuxaudio.org/lilypond/sources/v${stdenv.lib.versions.majorMinor version}/lilypond-${version}.tar.gz";
    sha256 = "01xs9x2wjj7w9appaaqdhk15r1xvvdbz9qwahzhppfmhclvp779j";
  };

  postInstall = ''
    for f in "$out/bin/"*; do
        # Override default argv[0] setting so LilyPond can find
        # its Scheme libraries.
        wrapProgram "$f" --set GUILE_AUTO_COMPILE 0 \
                         --set PATH "${ghostscript}/bin" \
                         --argv0 "$f"
    done
  '';

  configureFlags = [
    "--disable-documentation"
    "--with-ncsb-dir=${ghostscript}/share/ghostscript/fonts"
  ];

  preConfigure = ''
    sed -e "s@mem=mf2pt1@mem=$PWD/mf/mf2pt1@" -i scripts/build/mf2pt1.pl
    export HOME=$TMPDIR/home
  '';

  nativeBuildInputs = [ makeWrapper pkgconfig autoreconfHook ];

  autoreconfPhase = "NOCONFIGURE=1 sh autogen.sh";

  buildInputs =
    [ ghostscript texinfo imagemagick texi2html guile dblatex tex zip netpbm
      python2 gettext flex perl bison fontconfig freetype pango
      fontforge help2man groff rsync t1utils
    ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Music typesetting system";
    homepage = http://lilypond.org/;
    license = licenses.gpl3;
    maintainers = with maintainers; [ marcweber yurrriq ];
    platforms = platforms.all;
  };

  patches = [ ./findlib.patch ];

  broken = stdenv.isDarwin;
}
