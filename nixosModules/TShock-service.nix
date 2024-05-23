{ pkgs, lib, config, ...}: 

{
  options.services.TShock = {
    enable = lib.mkEnableOption "enables a TShock service";
    startCommand = lib.mkOption {
      type = lib.types.str;
      description = "script that runs the server command";
      default = "";
    };
  };
  config = lib.mkIf config.services.TShock.enable {
    networking.firewall.allowedTCPPorts = [ 7777 ];
    networking.firewall.allowedUDPPorts = [ 7777 ];
    systemd.user.services.TShock = {
      enable = true;
      description = "TShock service";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "5min";
        StartLimitBurst = 3;
      };
      script = ''

        SESSION_NAME="TShock"

        if ! ${pkgs.tmux}/bin/tmux list-sessions | grep -q "^{$SESSION_NAME}:"; then
          ${pkgs.tmux}/bin/tmux new-session -d -s "$SESSION_NAME" 
        fi

        ${pkgs.tmux}/bin/tmux send-keys -t "$SESSION_NAME" \
          "${config.services.TShock.startScript} && \
          ${pkgs.tmux}/bin/tmux kill-session -t $SESSION_NAME" C-m
          
        ${pkgs.tmux}/bin/tmux attach -c "$SESSION_NAME"
      '';
    };
  };
}
