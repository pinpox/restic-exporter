{
  description = "prometheus exporter for restic backups";

  inputs = { flake-utils.url = "github:numtide/flake-utils"; };

  outputs = { self, nixpkgs, flake-utils, ... }:

    {
      nixosModules.default = self.nixosModules.restic-exporter;

      nixosModules.restic-exporter = { lib, pkgs, config, ... }:
        with lib;

        let cfg = config.services.restic-exporter;
        in
        {

          options.services.restic-exporter = {

            enable = mkEnableOption "restic-exporter";

            port = mkOption {
              type = types.str;
              default = "8080";
              description = "Port under which restic-exporter is accessible.";
            };

            address = mkOption {
              type = types.str;
              default = "localhost";
              example = "127.0.0.1";
              description = "Address under which restic-exporter is accessible.";
            };

            environmentFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = ''
                Environment file (see <literal>systemd.exec(5)</literal>
                "EnvironmentFile=" section for the syntax) to define extra variables
                for the exporter
              '';
            };

            user = mkOption {
              type = types.str;
              default = "restic-exporter";
              description = "User account under which restic-exporter runs.";
            };

            group = mkOption {
              type = types.str;
              default = "restic-exporter";
              description = "Group under which restic-exporter runs.";
            };

          };

          config = mkIf cfg.enable {

            systemd.services.restic-exporter = {
              description = "A restic metrics exporter";
              wantedBy = [ "multi-user.target" ];
              serviceConfig = mkMerge [{
                User = cfg.user;
                Group = cfg.group;
                CacheDirectory = "restic-exporter";
                ExecStart = "${self.packages."${pkgs.system}".default}/bin/restic-exporter";
                Restart = "on-failure";
                EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
                Environment = [
                  "RESTIC_EXPORTER_BIN=${pkgs.restic}/bin/restic"
                  "RESTIC_EXPORTER_PORT=${cfg.port}"
                  "RESTIC_EXPORTER_ADDRESS=${cfg.address}"
                  "RESTIC_EXPORTER_CACHEDIR=/var/cache/restic-exporter"
                ];
              }];
            };

            users.users = mkIf (cfg.user == "restic-exporter") {
              restic-exporter = {
                isSystemUser = true;
                group = cfg.group;
                description = "restic-exporter system user";
              };
            };

            users.groups =
              mkIf (cfg.group == "restic-exporter") { restic-exporter = { }; };

          };
          meta.maintainers = with lib.maintainers; [ pinpox ];
        };
    }

    //

    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {

        formatter = pkgs.nixpkgs-fmt;
        packages = flake-utils.lib.flattenTree rec {

          default = pkgs.buildGoModule rec {
            pname = "restic-exporter";
            version = "1.0.0";
            src = self;
            vendorSha256 = "sha256-HUruT0+yOP+v5lxd4jrxYhRBzE0FcoW4OpcWgRRedwA=";
            installCheckPhase = ''
              runHook preCheck
              $out/bin/restic-exporter -h
              runHook postCheck
            '';
            doCheck = true;
            meta = with pkgs.lib; {
              description = "restic prometheus exporter";
              homepage = "https://github.com/pinpox/restic-exporter";
              platforms = platforms.unix;
              maintainers = with maintainers; [ pinpox ];
            };
          };

        };
      });
}
