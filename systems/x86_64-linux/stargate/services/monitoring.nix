{
  pkgs,
  lib,
  config,
  ...
}:
# https://dataswamp.org/~solene/2022-09-11-exploring-monitoring-stacks.html
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        # Grafana needs to know on which domain and URL it's running
        domain = "kylekrein.com";
        root_url = "https://grafana.kylekrein.com/";
        serve_from_sub_path = false;
      };
    };
  };
  services.prometheus.exporters.node.enable = true;

  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "stargate";
        static_configs = [
          {targets = ["localhost:9100"];}
        ];
      }
      {
        job_name = "hass";
        metrics_path = "/api/prometheus";
        scrape_interval = "10s";
        static_configs = [
          {targets = ["localhost:8123"];}
        ];
      }
    ];
  };
}
