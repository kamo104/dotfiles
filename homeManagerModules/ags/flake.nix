{
  description = "AGS dev flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in         
      {
        devShell = with pkgs; mkShell rec {
          buildInputs =  [
            (python311.withPackages (ps: with ps; [
                pip
                stdenv
            ]))
            nodePackages.typescript-language-server
          ];
          shellHook = ''
            if [ ! -d ".env" ]; then
              echo "installing..."
              python3 -m venv .env
              source ".env/bin/activate"
              pip install Image
              pip install materialyoucolor
              echo "done"
            fi

            source .env/bin/activate
          '';
        };
    });
}

