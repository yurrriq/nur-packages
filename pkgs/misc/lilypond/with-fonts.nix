{ stdenv, lndir, makeWrapper, symlinkJoin, lilypond, openlilylib-fonts, fonts }:

let
  _fonts = openlilylib-fonts.override { inherit lilypond; };

  getFont = fontName:
    if builtins.hasAttr fontName _fonts
    then builtins.getAttr fontName _fonts
    else throw "${fontName} is not a known font";

  fontPaths = map getFont fonts;
in


symlinkJoin {
  name = (stdenv.lib.appendToName "with-fonts" lilypond).name;
  inherit (lilypond) meta version;

  paths = [ lilypond ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    local datadir="$out/share/lilypond/${lilypond.version}"

    for dir in ${stdenv.lib.strings.concatStringsSep " " fontPaths}; do
        ${lndir}/bin/lndir -silent "$dir" "$datadir"/fonts
    done

    for program in $out/bin/*; do
        wrapProgram "$program" --set LILYPOND_DATADIR "$datadir"
    done
  '';
}
