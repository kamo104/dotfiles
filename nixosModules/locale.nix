{ pkgs, lib, config, ...}: 

{
  options = {
    locale.enable = lib.mkEnableOption "enables polish locale";
  };

  config = lib.mkIf config.locale.enable {
    i18n.supportedLocales = ["all"];
    time.timeZone = "Europe/Warsaw";
    i18n.defaultLocale = "en_US.UTF8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "pl_PL.UTF8";
      LC_IDENTIFICATION = "pl_PL.UTF8";
      LC_MEASUREMENT = "pl_PL.UTF8";
      LC_MONETARY = "pl_PL.UTF8";
      LC_NAME = "pl_PL.UTF8";
      LC_NUMERIC = "pl_PL.UTF8";
      LC_PAPER = "pl_PL.UTF8";
      LC_TELEPHONE = "pl_PL.UTF8";
      LC_TIME = "pl_PL.UTF8";
    };
  };
  
}
