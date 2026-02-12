#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  build_push_image.sh --region <region> --repo <repo> --tag <tag> --context <path> --dockerfile <path> [--account-id <id>] [--profile <aws_profile>] [--runtime <docker|podman>] [--platform <platform>]

Example (web):
  AWS_PROFILE=your-profile build_push_image.sh \
    --region us-east-1 \
    --repo peermetrics-web-dev \
    --tag prefix-aware \
    --context /path/to/web \
    --dockerfile /path/to/web/Dockerfile

Example (postgres):
  AWS_PROFILE=your-profile build_push_image.sh \
    --region us-east-1 \
    --repo peermetrics-postgres-dev \
    --tag 12.8-pgtrgm \
    --context /path/to/peermetrics \
    --dockerfile /path/to/peermetrics/Dockerfile.postgres
USAGE
}

ACCOUNT_ID=""
REGION=""
REPO=""
TAG=""
CONTEXT=""
DOCKERFILE=""
PROFILE="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-}}"
RUNTIME="docker"
PLATFORM=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --account-id)
      ACCOUNT_ID="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --tag)
      TAG="$2"
      shift 2
      ;;
    --context)
      CONTEXT="$2"
      shift 2
      ;;
    --dockerfile)
      DOCKERFILE="$2"
      shift 2
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --runtime)
      RUNTIME="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
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

if [[ -z "$REGION" || -z "$REPO" || -z "$TAG" || -z "$CONTEXT" || -z "$DOCKERFILE" ]]; then
  echo "Missing required arguments." >&2
  usage
  exit 1
fi

if [[ "$RUNTIME" != "docker" && "$RUNTIME" != "podman" ]]; then
  echo "Invalid --runtime: $RUNTIME (expected docker or podman)" >&2
  exit 1
fi

if ! command -v "$RUNTIME" >/dev/null 2>&1; then
  echo "Container runtime not found: $RUNTIME" >&2
  exit 1
fi

AWS_OPTS=(--region "$REGION")
if [[ -n "$PROFILE" ]]; then
  AWS_OPTS+=(--profile "$PROFILE")
fi

if [[ -z "$ACCOUNT_ID" ]]; then
  ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text "${AWS_OPTS[@]}")"
fi

echo "Using AWS account ID: $ACCOUNT_ID"
read -r -p "Continue? [y/N] " CONFIRM
CONFIRM_LOWER="$(printf '%s' "$CONFIRM" | tr '[:upper:]' '[:lower:]')"
if [[ "$CONFIRM_LOWER" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

aws ecr get-login-password "${AWS_OPTS[@]}" | \
  "$RUNTIME" login --username AWS --password-stdin "$REGISTRY"

BUILD_ARGS=(-f "$DOCKERFILE" -t "$IMAGE_URI")
if [[ -n "$PLATFORM" ]]; then
  BUILD_ARGS+=(--platform "$PLATFORM")
fi
BUILD_ARGS+=("$CONTEXT")

"$RUNTIME" build "${BUILD_ARGS[@]}"

"$RUNTIME" push "$IMAGE_URI"

echo "Pushed: $IMAGE_URI"
