{ 
lib,
fetchurl, 
stdenv,
buildFHSEnv,
makeFontsConf,
freefont_ttf,
roboto
}:
let 
package = stdenv.mkDerivation rec {
  pname = "crystal-launcher";
  version = "latest"; # or specify a version if known

  src = fetchurl {
    url = "https://launcher.crystal-launcher.net/linux/launcher.tar.xz";
    sha256 = "sha256-NkngV1nH5oYP7wRUAuDylRkne0Q65FmHn0mnlibjV0c=";
  };

  # nativeBuildInputs = [ autoPatchelfHook makeWrapper];

  # buildInputs = [
  #   zlib
  #   xorg.libxcb
  # ];

  unpackPhase = ''
    tar -xvf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp launcher $out/bin/
    chmod +x $out/bin/launcher
    cp cacert.pem $out/bin/
  '';

  # FONTCONFIG_FILE = makeFontsConf {
  #   fontDirectories = [ freefont_ttf roboto ];
  # };

  meta = {
    description = "Crystal Launcher for nixos";
    license = lib.licenses.unfree;
    platforms   = [ "x86_64-linux" ];
  };
};
in
buildFHSEnv {
  inherit (package) pname version meta;
  runScript = "${package.outPath}/bin/launcher";
  # FONTCONFIG_FILE = makeFontsConf {
  #   fontDirectories = [ freefont_ttf roboto ];
  # };
  targetPkgs = pkgs:
    with pkgs; [
      libz
      libGL
      # mesa
      xorg.libX11
      xorg.libxcb
      xorg.libXrender
      xorg.libXtst
      xorg.libXext
      xorg.libXi
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
    ];
}

