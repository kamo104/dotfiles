{ pkgs, lib, config, ...}: 

let 
  cfg = config.services.duckdns;
in 
{
  options.services.duckdns = {
    enable = lib.mkEnableOption "enables duckdns";
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The domains to update with DuckDNS.";
    };
    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the file containing the DuckDNS token.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "Username to run the duckdns service as.";
      default = "duckdns";
    };
    group = lib.mkOption {
      type = lib.types.string;
      description = "Group to run the duckdns service as.";
      default = "duckdns";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.duckdns = {
      enable = true;
      description = "duckdns service";
      after= ["network.target"];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "300s";
        User = cfg.user;
        Group = cfg.group;
      };
      script = ''
        #!/usr/bin/env bash
        echo url="https://www.duckdns.org/update?domains=${builtins.concatStringsSep "," cfg.domains}\
        &token=$(cat ${cfg.tokenFile})&ip=" \
        | ${pkgs.curl}/bin/curl -k -o ~/duckdns/duck.log -K -
      '';
    };
  };
}
