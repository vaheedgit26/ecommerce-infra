#!/usr/bin/env bash

validate() {
  DEST_DIR_RESULT=""
  
  local COMPONENT=$1
  local ENV=$2
  local ACTION=$3

  # Validate ENV
  case "$ENV" in
    dev|qa|prod) ;;
    *)
      echo "❌ Invalid env: $ENV" >&2
      return 1
      ;;
  esac

  # Validate ACTION
  case "$ACTION" in
    plan|apply|destroy) ;;
    *)
      echo "❌ Invalid action: $ACTION" >&2
      return 1
      ;;
  esac
  
  # Validate component
  MATCHES=$(grep -E "^${COMPONENT}[[:space:]]*=" components.txt || true)
  COUNT=$(echo "$MATCHES" | grep -c . || true)

  if [[ "$COUNT" -eq 0 ]]; then
    echo "❌ Invalid component: $COMPONENT" >&2
    return 1
  fi

  if [[ "$COUNT" -gt 1 ]]; then
    echo "❌ Duplicate entries for $COMPONENT" >&2
    return 1
  fi

  DEST_DIR_RESULT=$(echo "$MATCHES" | cut -d= -f2 | xargs)
}
