{ fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, lib
, tree
, stdenv
, fetchurl
, pluginsUrls ? []
}:

buildDotnetModule rec {
  pname = "TShock";
  version = "5.2";

  src = builtins.fetchGit {
    url = "https://github.com/Pryaxis/TShock";
    rev = "0b6bf9ef4050f39f468d6782ea2992d8ce82e8bb";
    submodules = true;
  };

  projectFile = "TShockLauncher/TShockLauncher.csproj";

  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.runtime_6_0;

  tmp = lib.optional (pluginsUrls != []) (map (plugin: fetchurl {
      url = plugin.url;
      sha256 = plugin.sha256;
    }) pluginsUrls);
  plugins = builtins.concatStringsSep " " (builtins.concatLists tmp);
  
  postInstall = ''
    echo "Running postInstall step..."
    mkdir -p $out/lib/$pname
    cp -r ./TShockLauncher/bin/Release/net6.0/*/* $out/lib/$pname

    if [ -n "${plugins}" ]; then
      mkdir -p $out/lib/$pname/ServerPlugins
      for plugin in ${plugins}; do
        cp $plugin $out/lib/$pname/ServerPlugins/
      done
    fi
  '';
  executables = ["TShock.Server"];

  meta = with lib; {
    homepage = "https://ikebukuro.tshock.co/";
    description = "A moddable terraria server";
    license = licenses.unfree;
  };
}

