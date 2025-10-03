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
  cfg = config.${namespace}.programs.librewolf;
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  options.${namespace}.programs.librewolf = with types; {
    enable = mkBoolOpt false "Enable librewolf with best settings";
  };

  config = mkIf cfg.enable {
    programs = {
      librewolf = {
        enable = true;
        languagePacks = ["de" "en-US" "ru"];

        /*
        ---- POLICIES ----
        */
        # Check about:policies#documentation for options.
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"
          OfferToSaveLogins = false;
          OffertosaveloginsDefault = false;
          PasswordManagerEnabled = false;
          NoDefaultBookmarks = true;

          /*
          ---- EXTENSIONS ----
          */
          # Check about:support for extension/add-on ID strings.
          # Valid strings for installation_mode are "allowed", "blocked",
          # "force_installed" and "normal_installed".
          #https://mozilla.github.io/policy-templates/#extensionsettings
          ExtensionSettings = {
            "*".installation_mode = "allowed"; # blocks all addons except the ones specified below
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # Privacy Badger:
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
              installation_mode = "force_installed";
            };

            # Dark Reader
            "addon@darkreader.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              installation_mode = "force_installed";
            };
            #auto tab discard
            "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/auto-tab-discard/latest.xpi";
              installation_mode = "force_installed";
            };
            #aliasvault
            "{a06e3383-fc5f-431d-8405-1c54c2f85971}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/aliasvault/latest.xpi";
              installation_mode = "force_installed";
            };
            # global speed
            "{f4961478-ac79-4a18-87e9-d2fb8c0442c4}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/global-speed/latest.xpi";
              installation_mode = "force_installed";
            };
            # sponsorblock
            "sponsorBlocker@ajay.app" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
              installation_mode = "force_installed";
            };

            # Adguard adblocker
            "adguardadblocker@adguard.com" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/adguard-adblocker/latest.xpi";
              installation_mode = "force_installed";
            };
          };
          /*
          ---- PREFERENCES ----
          */
          # Check about:config for options.
          Preferences = {
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            "browser.startup.page" = 3; # restore session on startup
            "browser.topsites.contile.enabled" = lock-false;
            "browser.formfill.enable" = lock-false;
            "browser.search.suggest.enabled" = lock-false;
            "browser.search.suggest.enabled.private" = lock-false;
            "browser.urlbar.suggest.searches" = lock-false;
            "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
            "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
            "browser.newtabpage.activity-stream.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
          };
        };
      };
    };
  };
}
