{ lib, pkgs, }:

let

  _nixpkgs = lib.pinnedNixpkgs {
    rev = "7f06f36ffb00e7d9206692649356f9f8c7acb2a7";
    sha256 = "1iscfzg0cyv0zm43aqs1agsbm24bg8dmjjqj4mvzk5q7r42rnrms";
  };

in

rec {

  inherit (_nixpkgs) autojump kops kubernetes-helm kubetail;
  inherit (_nixpkgs.gitAndTools) git-crypt;

  erlang = pkgs.beam.interpreters.erlangR20.override {
    enableDebugInfo = true;
    installTargets = "install";
    wxSupport = false;
  };

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  icon-lang = pkgs.callPackage ./development/interpreters/icon-lang {
    withGraphics = false;
  };

  kubectx = pkgs.callPackage ./applications/networking/cluster/kubectx {};

  kubernetes = pkgs.callPackage ./applications/networking/cluster/kubernetes {};

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  noweb = pkgs.callPackage ./development/tools/literate-programming/noweb {
    inherit icon-lang;
    useIcon = true;
  };

} // (if pkgs.stdenv.isDarwin then {

  chunkwm = pkgs.recurseIntoAttrs (pkgs.callPackage ./os-specific/darwin/chunkwm {
    inherit (pkgs) callPackage stdenv fetchFromGitHub imagemagick;
    inherit (pkgs.darwin.apple_sdk.frameworks) Carbon Cocoa ApplicationServices;
  });

  clementine = pkgs.callPackage ./applications/audio/clementine {};

  copyq = pkgs.callPackage ./applications/misc/copyq {};

  diff-pdf = pkgs.callPackage ./tools/text/diff-pdf {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
  };

  m-cli = pkgs.m-cli.overrideAttrs (_: rec {
    name = "m-cli-${version}";
    version = "d03d8b9";
    src = pkgs.fetchFromGitHub {
      owner = "rgcr";
      repo = "m-cli";
      rev = version;
      sha512 = "39wfgp2cq6kqi7rcvxmw1hc61mcbjc1fwrb7d1s01vwrkrggn8arrzrik99qw7ymirg0aql5xc12ww3z5sfxyn7y4s1kb7v1r7kn2nm";
    };
  });

  inherit (_nixpkgs) musescore;

  onyx = pkgs.callPackage ./os-specific/darwin/onyx {};

  skhd = pkgs.skhd.overrideAttrs (_: rec {
    name = "skhd-${version}";
    version = "0.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "koekeishiya";
      repo = "skhd";
      rev = "v${version}";
      sha256 = "13pqnassmzppy2ipv995rh8lzw9rraxvi0ph6zgy63cbsdfzbhgl";
    };
  });

  skim = pkgs.callPackage ./applications/misc/skim {};

  sourcetree = pkgs.callPackage ./os-specific/darwin/sourcetree {};

  spotify = pkgs.callPackage ./applications/audio/spotify/darwin.nix {};

} else {

  inherit (_nixpkgs) browserpass;

  tellico = pkgs.libsForQt5.callPackage ./applications/misc/tellico {};

})
