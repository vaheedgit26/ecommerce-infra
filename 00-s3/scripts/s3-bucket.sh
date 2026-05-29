#!/usr/bin/env bash
set -euo pipefail
#################################################################
# Usage:
# bash s3-bucket.sh <project_name> <env> <region> <action>
#
# Example:
# bash s3-bucket.sh ecommerce dev us-east-1 apply
# bash s3-bucket.sh ecommerce dev us-east-1 destroy
#################################################################
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


# Parameters validation
if [[ $# -ne 4 ]]; then 
  print_error "Usage: bash s3-bucket.sh <project> <env> <region> <action>"
  print_info "Example: bash s3-bucket.sh ecommerce dev us-east-1 plan"
  exit 1
fi

# Ensure Terraform installed
command -v terraform >/dev/null 2>&1 || {
  print_error "Terraform is not installed"
  exit 1
}

# Print Terraform version
print_info "Terraform version"
terraform -version

PROJECT=$1
ENV=$2
REGION=$3
ACTION=$4

# Validate ACTION
case "$ACTION" in
  plan|apply|destroy) ;;
  *)
    print_error "❌ Invalid action: $ACTION"
    print_info  "Valid ACTIONS: plan|apply|destroy"
    return 1
    ;;
esac

cat <<EOF
~_~S~D Details:
     PROJECT : ${PROJECT}
     ENV     : ${ENV}
     REGION  : ${REGION}
     ACTION  : ${ACTION}
EOF

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PARENT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P)" 
#S3_DIR="${PARENT_DIR}/00-s3"

# Ensure S3 dir exists
#if [[ ! -d "$S3_DIR" ]]; then
#  print_error "❌ S3 bootstrap directory not found: ${S3_DIR}"
#  exit 1
#fi

print_info "Changing to: $PARENT_DIR"

# Change to previous directory
cd "$PARENT_DIR" || {
  print_error "❌ Failed to change directory to: ${PARENT_DIR}"
  exit 1
} 

# print_info "Creating State file Bucket: ${BUCKET}"

echo "============================================="
echo "Step 1: Terraform Init"
echo "============================================="
terraform init -upgrade

echo "============================================="
echo "Step 2: Validate"
echo "============================================="
terraform validate

PLAN_FILE="s3.tfplan"

echo "============================================="
echo "Step 3: ${ACTION}"
echo "============================================="

case "$ACTION" in

  plan)
     terraform plan \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION" \
      -out=${PLAN_FILE}
    ;;

  apply)
    if [[ -f "${PLAN_FILE}" ]]; then
      terraform apply ${PLAN_FILE}
    else
      print_error "⚠️ No plan file found, Run plan first..."
      exit 1
    fi
    ;;

  destroy)
    # 🔥 Safety confirmation
    read -p "⚠️ Are you sure you want to DELETE S3 bucket? Type 'yes' to continue: " CONFIRM

    if [[ "$CONFIRM" != "yes" ]]; then
      print_info "❌ Destroy cancelled...Exiting"
      exit 1
    fi

    terraform destroy \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION" \
      -auto-approve
    ;;

  *)
    abort "❌ Invalid action: ${ACTION}. Use plan, apply or destroy"
    ;;

esac
