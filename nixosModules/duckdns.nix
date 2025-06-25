{ pkgs, lib, config, ...}: 

let 
  cfg = config.services.duckdns-custom;
in 
{
  options.services.duckdns-custom = {
    enable = lib.mkEnableOption "enables duckdns";
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The domains to update with DuckDNS.";
    };
    tokenFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the DuckDNS token.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "Username to run the duckdns service as.";
      default = "duckdns";
    };
    group = lib.mkOption {
      type = lib.types.str;
      description = "Group to run the duckdns service as.";
      default = "duckdns";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.duckdns-custom = {
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
        echo "Updating DuckDNS..." >&2
        echo "Token file: ${cfg.tokenFile}" >&2
        echo "Domains: ${builtins.concatStringsSep "," cfg.domains}" >&2
        TOKEN=$(cat ${cfg.tokenFile})
        echo "Token: $TOKEN" >&2
        echo url="https://www.duckdns.org/update?domains=${builtins.concatStringsSep "," cfg.domains}&token=$TOKEN&ip=" | ${pkgs.curl}/bin/curl -v -K -
        # echo url="https://www.duckdns.org/update?domains=${builtins.concatStringsSep "," cfg.domains}\
        # &token=$(cat ${cfg.tokenFile})&ip=" \
        # | ${pkgs.curl}/bin/curl -K -
      '';
    };
  };
}
