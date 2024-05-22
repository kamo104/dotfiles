# shell.nix
with import <nixpkgs> {};

mkShell {
  name = "TShock shell";
  packages = [
    (pkgs.callPackage ./TShock.nix {
      pluginsUrls = [
        {
          url="https://github.com/Moneylover3246/Crossplay/releases/download/2.2/Crossplay.dll";
          sha256="0pqqyr7897dwh4nn21jkwiilfphsf18l3qmlr4f5gg7pnrhz2ny1";
        }
      ];
      })
  ];
}
