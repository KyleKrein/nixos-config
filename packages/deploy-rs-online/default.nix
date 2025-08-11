{
  writeShellScriptBin,
  lib,
  jq,
  deploy-rs,
  ...
}:
writeShellScriptBin "deploy-rs-online" ''
  set -euo pipefail

  # ANSI colors (safe form for bash inside Nix)
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  NC=$'\033[0m'

  # Flake path from first argument, default to "."
  FLAKE_PATH="''${1:-.}"
  shift || true

  # Collect extra args after --
  DEPLOY_ARGS=()
  if [ "$#" -gt 0 ]; then
    if [ "$1" = "--" ]; then
      shift
      DEPLOY_ARGS=("$@")
    fi
  fi

  # Check if user provided --skip-checks or -s; if not, add -s
  SKIP_CHECKS_SET=false
  for arg in "''${DEPLOY_ARGS[@]}"; do
    if [ "$arg" = "--skip-checks" ] || [ "$arg" = "-s" ]; then
      SKIP_CHECKS_SET=true
      break
    fi
  done
  if ! $SKIP_CHECKS_SET; then
    DEPLOY_ARGS+=("-s")
  fi

  # Run nix flake check first
  if ! $SKIP_CHECKS_SET; then
    echo "Running nix flake check on $FLAKE_PATH..."
    if ! nix flake check "$FLAKE_PATH"; then
      echo "$RED Flake check failed! Aborting deployment. $NC"
      exit 1
    fi
  fi

  # Get node names
  NODES=$(nix eval --json "$FLAKE_PATH#deploy.nodes" | ${lib.getExe jq} -r 'keys[]')

  RESULTS=()

  for node in $NODES; do
    HOST=$(nix eval --raw "$FLAKE_PATH#deploy.nodes.$node.hostname")
    echo -n "Checking $node ($HOST)... "
    if ssh -o ConnectTimeout=3 -o BatchMode=yes "$HOST" true 2>/dev/null; then
      echo "$GREEN ONLINE ✅ $NC — deploying"
      if ${lib.getExe deploy-rs} "$FLAKE_PATH#$node" "''${DEPLOY_ARGS[@]}"; then
        RESULTS+=("$node: $GREEN OK $NC")
      else
        RESULTS+=("$node: $RED DEPLOY ERROR $NC")
      fi
    else
      echo "$RED OFFLINE ❌ $NC — skipping"
      RESULTS+=("$node: $YELLOW OFFLINE $NC ")
    fi
  done

  echo
  echo "===== Deployment summary ====="
  for r in "''${RESULTS[@]}"; do
    echo -e "$r"
  done
''
