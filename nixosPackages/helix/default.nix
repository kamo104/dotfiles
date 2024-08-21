{ fetchzip, lib, rustPlatform, git, installShellFiles, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "24.07";

  # This release tarball includes source code for the tree-sitter grammars,
  # which is not ordinarily part of the repository.
  # src = fetchzip {
  #   url = "https://github.com/helix-editor/helix/releases/download/${version}/helix-${version}-source.tar.xz";
  #   hash = "sha256-R8foMx7YJ01ZS75275xPQ52Ns2EB3OPop10F4nicmoA=";
  #   stripRoot = false;
  # };
  src = fetchFromGitHub {
    # url = "https://github.com/intarga/helix";
    owner = "intarga";
    repo = "helix";
    # hash = "";
    sha256="1g88fm9d8z4az9m7nw05cfw2xvsg3zzp2537kzq4na3p1n6bf6s0";
    # ref = "persistent_state";
    rev = "8b2e525aace22853659ff9a5f4a4944755dac698";
    # shallow = true;
  };

  cargoHash = "sha256-Y8zqdS8vl2koXmgFY0hZWWP1ZAO8JgwkoPTYPVpkWsA=";

  nativeBuildInputs = [ git installShellFiles ];

  env.HELIX_DEFAULT_RUNTIME = "${placeholder "out"}/lib/runtime";

  postInstall = ''
    # not needed at runtime
    rm -r runtime/grammars/sources

    mkdir -p $out/lib
    cp -r runtime $out/lib
    installShellCompletion contrib/completion/hx.{bash,fish,zsh}
    mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
    cp contrib/Helix.desktop $out/share/applications
    cp contrib/helix.png $out/share/icons/hicolor/256x256/apps
  '';

  meta = with lib; {
    description = "Post-modern modal text editor";
    homepage = "https://helix-editor.com";
    license = licenses.mpl20;
    mainProgram = "hx";
    maintainers = with maintainers; [ danth yusdacra zowoq ];
  };
}
