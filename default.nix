{ pkgs ? import <nixpkgs> {} }:

{

  overlays = import ./overlays;

  pkgs = {

    browserpass = pkgs.callPackage ./pkgs/tools/security/browserpass {};

    erlang = pkgs.beam.interpreters.erlangR20.override {
      enableDebugInfo = true;
      installTargets = "install";
      wxSupport = false;
    };

    git-crypt = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/git-crypt {};

    lab = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/lab {};

    sourcetree = pkgs.callPackage ./pkgs/os-specific/darwin/sourcetree {};

    kubernetes = pkgs.callPackage ./pkgs/applications/networking/cluster/kubernetes {};

  };

}
