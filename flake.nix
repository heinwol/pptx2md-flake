{
  description = "pptx2md";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, poetry2nix }:
    let

      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};
      poetry2nixLib = (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; });

      src = pkgs.fetchFromGitHub {
        owner = "ssine";
        repo = "pptx2md";
        rev = "baa1a551b7c451ec7b8a76b4979448c5c742f44b";
        hash = "sha256-oU7cetUA3M+0g5waIz3TTmen7uILsF8idjmRAF3TVxM=";
      };

      pptx2md = poetry2nixLib.mkPoetryApplication {
        projectDir = src;
        overrides = poetry2nixLib.defaultPoetryOverrides.extend
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
