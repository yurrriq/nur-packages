{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib;
  modules = import ./modules;
  overlays = import ./overlays;
  pkgs = import ./pkgs { inherit pkgs; };
}
