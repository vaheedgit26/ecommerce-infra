#!/usr/bin/env bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

print_error() {
  echo -e "$R $1 $N" >&2  # send the error to error terminal STDERR
}

print_info() {
  echo -e "$Y $1 $N"  
}

validate() {
    
  local COMPONENT=$1
  local ENV=$2
  local ACTION=$3

  local PROJECT=$4
  local BUCKET=$5
  local REGION=$6
  
  # Validate component
  if [[ "$COMPONENT" != "bastion" ]]; then
    print_error "Component should be 'bastion'(lower case) only for VPC creation"
    return 1
  fi

  # Validate ENV
  case "$ENV" in
    dev|qa|prod) ;;
    *)
      print_error "❌ Invalid env: $ENV"
      print_info  "Valid envs: dev|qa|prod"
      return 1
      ;;
  esac

  # Validate ACTION
  case "$ACTION" in
    plan|apply|destroy) ;;
    *)
      print_error "❌ Invalid action: $ACTION"
      print_info  "Valid ACTIONS: plan|apply|destroy"
      return 1
      ;;
  esac

  # Validate PROJECT
  if [[ -z "$PROJECT" ]]; then
    print_error "❌ PROJECT not provided and not found in Terraform output"
    return 1
  fi

  # Validate BUCKET
  if [[ -z "$BUCKET" ]]; then
    print_error "❌ BUCKET not provided and not found in Terraform output"
    print_info "👉 Run bootstrap (00-s3) or pass BUCKET manually"
    return 1
  fi
  
  # Validate REGION
  if [[ -z "$REGION" ]]; then
    print_error "❌ REGION not provided and not found in Terraform output"
    return 1
  fi
  
  return 0
}
