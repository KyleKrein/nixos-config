{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.ai;
  impermanence = config.${namespace}.impermanence;
  nvidia = config.${namespace}.hardware.nvidia;
  persist = impermanence.persistentStorage;
in {
  options.${namespace}.services.ai = with types; {
    enable = mkBoolOpt false "Enable local ai powered by ollama";
    models = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Download these models using `ollama pull` as soon as `ollama.service` has started.

        This creates a systemd unit `ollama-model-loader.service`.

        Search for models of your choice from: <https://ollama.com/library>
      '';
    };
    ui.enable = mkBoolOpt true "Enable openwebui at localhost:8080";
    ui.port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        Port for ui
      '';
    };
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      loadModels = cfg.models;
      acceleration =
        if nvidia.enable
        then "cuda"
        else null;
      home =
        if impermanence.enable
        then "${persist}/ollama"
        else "/var/lib/ollama";
      user = "ollama";
      group = "ollama";
    };

    services.open-webui.enable = cfg.ui.enable;
    services.open-webui.openFirewall = false;
    services.open-webui.host = "0.0.0.0";
    services.open-webui.port = cfg.ui.port;
    services.open-webui.stateDir =
      if impermanence.enable
      then "${persist}/open-webui"
      else "/var/lib/open-webui";
    systemd.services.open-webui.serviceConfig.User = "ollama";
    systemd.services.open-webui.serviceConfig.Group = "ollama";
    systemd.services.open-webui.serviceConfig.DynamicUser = lib.mkForce false;
  };
}
