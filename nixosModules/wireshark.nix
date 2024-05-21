{ pkgs, lib, config, ...}: 

{
  options = {
    wireshark.enable = lib.mkEnableOption "enables wireshark";
    wireshark.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The users to add to the wireshark group";
    };
  };

  config = lib.mkIf config.wireshark.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    users.users = lib.genAttrs config.wireshark.users (user: {
      extraGroups = [ "wireshark" ];
    });
  };
}
