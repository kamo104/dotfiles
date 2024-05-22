{ fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, lib
, tree
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

  nativeBuildInputs = [ tree ];

# Fetch plugins from URLs defined in pluginsPath
  plugins = lib.optional (pluginsUrls != []) (map (url: builtins.fetchurl { url = url; }) pluginsUrls);

  postInstall = ''
    echo "Running postInstall step..."
    mkdir -p $out/lib/$pname
    cp -r ./TShockLauncher/bin/Release/net6.0/*/* $out/lib/$pname
    # if [ ! -z "${pluginsUrls}" ]; then
    #   cp -r ${pluginsUrls}/* $out/lib/$pname/ServerPlugins
    # fi;

    if [ ! -z "${plugins}" ]; then
      mkdir -p $out/lib/$pname/ServerPlugins
      for plugin in ${lib.concatStringsSep " " (map (p: "${p.outPath}") plugins)}; do
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

