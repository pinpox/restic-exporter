# Metrics

The following metrics are exported for given host (target)

```
❯ curl 'localhost:8999/probe?target=ahorn'
# HELP restic_snapshots_latest_time Time of the latest snapshot
# TYPE restic_snapshots_latest_time gauge
restic_snapshots_latest_time{hostname="ahorn"} 1.655762407e+09
# HELP restic_stats_latest_total_nfiles Number of files
# TYPE restic_stats_latest_total_nfiles gauge
restic_stats_latest_total_nfiles{hostname="ahorn"} 480
# HELP restic_stats_latest_total_size Total Size
# TYPE restic_stats_latest_total_size gauge
restic_stats_latest_total_size{hostname="ahorn"} 686011
```

## Configuration

Configuration is done via environment variables.

```
# Exporter configuration
RESTIC_EXPORTER_BIN="restic"
RESTIC_EXPORTER_PORT=8999
RESTIC_EXPORTER_ADDRESS=127.0.0.1

# Restic configuration
RESTIC_REPOSITORY=s3:https://s3.myhost.com/restic
RESTIC_PASSWORD_FILE=/var/src/secrets/restic/repo-pw

# Optional: S3 credentials
AWS_ACCESS_KEY_ID=restic-ahorn
AWS_SECRET_ACCESS_KEY=aaaaaabbbbbcccccddddd
```

## Nix flake

A nix flake is provided exposing the application as package. It also provides a
nixos module.
