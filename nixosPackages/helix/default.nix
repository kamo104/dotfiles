{ fetchzip, lib, rustPlatform, git, installShellFiles, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "24.07";

  src = fetchFromGitHub {
    owner = "intarga";
    repo = "helix";
    sha256="1g88fm9d8z4az9m7nw05cfw2xvsg3zzp2537kzq4na3p1n6bf6s0";
    # ref = "persistent_state";
    rev = "8b2e525aace22853659ff9a5f4a4944755dac698";
  };

  cargoHash = "sha256-sZadbMEs9lq+7Gx8DIbjVt3S+0hZyHrDdAxol6HI0uU=";

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
