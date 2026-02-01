#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  generate_secrets_env.sh --output <path> [--overwrite]

Example:
  generate_secrets_env.sh --output k8s/overlays/your-env/secrets.env
USAGE
}

OUTPUT=""
OVERWRITE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    --overwrite)
      OVERWRITE="true"
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$OUTPUT" ]]; then
  echo "Missing --output." >&2
  usage
  exit 1
fi

if [[ -f "$OUTPUT" && "$OVERWRITE" != "true" ]]; then
  echo "File exists: $OUTPUT" >&2
  echo "Use --overwrite to replace it." >&2
  exit 1
fi

rand() {
  openssl rand -base64 48 | tr -d '\n'
}

cat <<EOM > "$OUTPUT"
# Generated secrets for peermetrics
SECRET_KEY=$(rand)
INIT_TOKEN_SECRET=$(rand)
SESSION_TOKEN_SECRET=$(rand)
DEFAULT_ADMIN_PASSWORD=$(rand)
DATABASE_USER=peeruser
DATABASE_PASSWORD=$(rand)
EOM

echo "Wrote: $OUTPUT"
