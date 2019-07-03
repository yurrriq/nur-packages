{ stdenv, fetchsvn, xcbuildHook }:

stdenv.mkDerivation rec {
  name = "skim-${version}";
  version = "1.5.2";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/skim-app/code/tags/REL_${builtins.replaceStrings ["."] ["_"] version}";
    sha256 = "0l8jw8hfr391lx8jg7419d4pv35ihfwnwd82zfh194f6lvh2b9y0";
  };

  nativeBuildInputs = [ xcbuildHook ];
  xcbuildFlags = "-target Skim";

  installPhase = ''
    install -dm755 "$out/Applications/Skim.app"
    cp -R Products/Release/Skim "$_"
    chmod a+x "$_/Contents/MacOS/Skim"
  '';

  meta = with stdenv.lib; {
    description = "PDF reader and note-taker for OS X";
    homepage = "https://skim-app.sourceforge.io";
    repositories.svn = "http://svn.code.sf.net/p/skim-app/code/trunk";
    license = licenses.bsd2;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ yurrriq ];
  };
}
