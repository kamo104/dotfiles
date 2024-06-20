{ pkgs, lib, config, ...}: 

{
  options.services.duckdns = {
    enable = lib.mkEnableOption "enables duckdns";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain to update with DuckDNS.";
    };
    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the file containing the DuckDNS token.";
    };
  };
  config = lib.mkIf config.services.duckdns.enable {
    systemd.user.services.duckdns = {
      enable = true;
      description = "duckdns service";
      after= ["network.target"];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "300s";
      };
      script = ''
        echo url="https://www.duckdns.org/update?domains=${config.services.duckdns.domain}\
        &token=$(cat ${config.services.duckdns.tokenFile})&ip=" \
        | ${pkgs.curl}/bin/curl -k -o ~/duckdns/duck.log -K -
      '';
    };
  };
}
