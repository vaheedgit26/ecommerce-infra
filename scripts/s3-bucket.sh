#!/usr/bin/env bash
#################################################################
# Usage:
# bash s3-bucket.sh <project_name> <env> <region> <action>
#
# Example:
# bash s3-bucket.sh ecommerce dev us-east-1 apply
# bash s3-bucket.sh ecommerce dev us-east-1 destroy
#################################################################

set -e

PROJECT=$1
ENV=$2
REGION=$3
ACTION=$4

# Function to handle errors safely depending on context
abort() {
    local msg="$1"
    echo "$msg" >&2
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        return 1
    else
        exit 1
    fi
}

# Validate inputs
if [[ -z "$PROJECT_NAME" || -z "$ENV" || -z "$REGION" || -z "$ACTION" ]]; then
    abort "Usage: source create-s3-bucket.sh <project_name> <env> <region> <plan|apply|destroy>"
fi

echo """
📄 Details:
     PROJECT_NAME : ${PROJECT}
     ENV          : ${ENV}
     REGION       : ${REGION}
     ACTION       : ${ACTION}
"""

# Move to terraform directory
cd ..

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

  apply)
    terraform plan \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION" \
      -out=${PLAN_FILE}

    terraform apply ${PLAN_FILE}
    ;;

  destroy)
    # 🔥 Safety confirmation
    read -p "⚠️ Are you sure you want to DELETE S3 bucket? Type 'yes' to continue: " CONFIRM

    if [[ "$CONFIRM" != "yes" ]]; then
        echo "❌ Destroy cancelled"
        return 1 2>/dev/null || exit 1
    fi

    terraform destroy \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION"
    ;;

  *)
    abort "❌ Invalid action: ${ACTION}. Use apply or destroy"
    ;;

esac
