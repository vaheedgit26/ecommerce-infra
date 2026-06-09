#!/usr/bin/env bash

# Validate component
validate_component() {
  local COMPONENT="$1"
  local VALID_COMPONENT="$2"
  
  if [[ "$COMPONENT" != "$VALID_COMPONENT" ]]; then
    return 1
  fi

  return 0
}

# Validate from list
validate_from_list() {
  local value="$1"
  shift                     # removes first argument
  local valid_list=("$@")   # capture remaining args as array

  for valid in "${valid_list[@]}"; do
    if [[ "$value" == "$valid" ]]; then
      return 0
    fi
  done

  return 1
}

# Validate PROJECT, BUCKET and REGION
validate_item() {
  local ITEM="$1"

  if [[ -z "$ITEM" ]]; then
    return 1
  fi

  return 0
}
