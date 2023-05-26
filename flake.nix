{
  description = "pptx2md";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let

      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      src = pkgs.fetchFromGitHub {
        owner = "ssine";
        repo = "pptx2md";
        rev = "bb9762fcb537190cee3e71d18b56da07fdbbb3eb";
        hash = "sha256-sw1Io7nnohJvhwglrR8NjKi+OJ8K9QTfM0/93VZm2TY=";
      };

      pptx2md = pkgs.poetry2nix.mkPoetryApplication {
        projectDir = src;
        overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend
          (self: super: {
            python-pptx = super.python-pptx.overridePythonAttrs
              (
                old: {
                  buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
                }
              );
          });
        preferWheels = true; # else it fails
      };

    in
    {
      packages.${system} = {
        inherit pptx2md;
        default = pptx2md;
      };
    };
}
