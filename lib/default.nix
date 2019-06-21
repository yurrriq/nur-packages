rec {

  fetchTarballFromGitHub =
    { owner, repo, rev, sha256, ... }:
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/tarball/${rev}";
      inherit sha256;
  };

  fromJSONFile = f: builtins.fromJSON (builtins.readFile f);

  seemsDarwin = null != builtins.match ".*darwin$" builtins.currentSystem;

  fetchNixpkgs = args@{ rev, sha256, ... }:
    fetchTarballFromGitHub (args // { owner = "NixOS"; repo = "nixpkgs"; });

  pinnedNixpkgs = args: import (fetchNixpkgs args) {};

  mkHelmBinary = { pkgs, version, flavor, sha256 }: pkgs.stdenv.mkDerivation rec {
    pname = "helm";
    name = "${pname}-${version}";
    inherit version;
    src = builtins.fetchTarball {
    url = "https://storage.googleapis.com/kubernetes-helm/helm-v${version}-${flavor}.tar.gz";
      inherit sha256;
    };
    installPhase = ''
      install -dm755 "$out/bin"
      install -m755 helm "$_"
    '';
  };

  mkHelmfile = { pkgs, version, sha256, modSha256 }: pkgs.helmfile.overrideAttrs(_: {
    name = "helmfile-${version}";
    pname = "helmfile";
    inherit modSha256 version;
    src = pkgs.fetchFromGitHub {
      owner = "roboll";
      repo = "helmfile";
      rev = "v${version}";
      inherit sha256;
    };
    buildFlagsArray = ''
      -ldflags=
          -X main.Version=${version}
    '';
  });

  mkKops =  { pkgs, version, sha256 }: pkgs.kops.overrideAttrs(old: rec {
    pname = "kops";
    name = "${pname}-${version}";
    inherit version;
    src = pkgs.fetchFromGitHub {
      rev = version;
      owner = "kubernetes";
      repo = "kops";
      inherit sha256;
    };
    buildFlagsArray = ''
      -ldflags=
          -X k8s.io/kops.Version=${version}
          -X k8s.io/kops.GitVersion=${version}
    '';
  });

  mkKubernetes = { pkgs, version, sha256 }: pkgs.kubernetes.overrideAttrs(old: rec {
    pname = "kubernetes";
    name = "${pname}-${version}";
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v${version}";
      inherit sha256;
    };
  });

  buildK8sEnv = { pkgs, name, config }:
    let
      deps = rec {
        kubernetes-helm = mkHelmBinary ({ inherit pkgs; } // config.helm);
        kubernetes = mkKubernetes ({ inherit pkgs; } // config.k8s);
        kubectx = pkgs.kubectx.override {
          kubectl = (kubernetes.override { components = [ "cmd/kubectl" ]; }).overrideAttrs(oldAttrs: rec {
            pname = "kubectl";
            name = "${pname}-${oldAttrs.version}";
          });
        };
        helmfile = (mkHelmfile ({ inherit pkgs; } // config.helmfile)).override { inherit kubernetes-helm; };
        kops = mkKops ({ inherit pkgs; } // config.kops);
        inherit (pkgs) kubetail;
      };
    in
    pkgs.buildEnv {
      inherit name;
      paths = with deps; [
        helmfile
        kops
        kubectx
        kubernetes
        kubernetes-helm
        kubetail
      ];
      passthru = { inherit config pkgs; } // deps;
    };

}
