{ stdenv, makeWrapper, symlinkJoin, lilypond, openlilylib-fonts, fonts }:

let
  getFont = let _fonts = openlilylib-fonts.override { inherit lilypond; }; in
    fontName:
    if builtins.hasAttr fontName _fonts
    then builtins.getAttr fontName _fonts
    else throw "${fontName} is not a known font";
in

stdenv.lib.appendToName "with-fonts" (symlinkJoin {
  inherit (lilypond) meta name version;

  paths = [ lilypond ] ++ map getFont fonts;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    local datadir="$out/share/lilypond/${lilypond.version}"
    for program in $out/bin/*; do
      wrapProgram "$program" --set LILYPOND_DATADIR "$datadir"
    done
  '';
})
