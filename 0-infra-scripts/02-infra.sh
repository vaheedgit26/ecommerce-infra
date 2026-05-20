#!/usr/bin/env bash
# set -e
set -euo pipefail
##################################################
# Usage: bash infra.sh <component> <env> <action>
# Example:
#   bash infra.sh vpc dev plan
#   bash infra.sh eks dev apply
#   bash infra.sh alb dev destroy
##################################################
# Parameters validation
if [[ $# -ne 3 ]]; then
  echo "Usage: bash infra.sh <component: vpc|eks|..> <env: dev|qa|prod> <action: plan|apply|destroy>"
  echo "Example: bash infra.sh vpc dev plan"
  exit 1
fi

if [[ ! -f components.txt ]]; then
    echo "❌ File not found: 'components.txt'"
    exit 1
fi

# Load functions
source "$(dirname "$0")/lib/validate.sh"

# Assigning input parameters
COMPONENT=$1
ENV=$2
ACTION=$3

# Log file config
LOG_FILE="infra-${COMPONENT}-${ENV}-$(date +%F-%H%M).log"
exec > >(tee -a "$LOG_FILE") 2>&1

S3_DIR="../00-s3"

tf_output() {
  terraform -chdir="${S3_DIR}" output -raw "$1"
}

# Ensure S3-Bucket created first
if ! tf_output bucket_id >/dev/null 2>&1; then
  echo "❌ Bootstrap (00-s3) not applied"
  exit 1
fi

BUCKET=$(tf_output bucket_id)
REGION=$(tf_output region)
PROJECT=$(tf_output project)

# Print values
cat <<EOF
📄 Details:
     PROJECT   : ${PROJECT}
     ENV       : ${ENV}
     REGION    : ${REGION}
     BUCKET    : ${BUCKET}
     COMPONENT : ${COMPONENT}
     ACTION    : ${ACTION}
EOF

# 🚫 Block destroy in prod (safety)
if [[ "$ENV" == "prod" && "$ACTION" == "destroy" ]]; then
  echo "❌ Destroy is NOT allowed in production!"
  exit 1
fi

# validate() Function call
if ! validate "$COMPONENT" "$ENV" "$ACTION"; then
  echo "❌ Validation failed"
  exit 1
fi

# DEST_DIR=$(validate "$COMPONENT" "$ENV" "$ACTION")
DEST_DIR="$DEST_DIR_RESULT"

echo "${DEST_DIR}"

if [[ -z "${DEST_DIR:-}" ]]; then
  echo "No Destination Directory found to run terraform"
  exit 1
fi

cd "${DEST_DIR}"

##############################################
# Step 1: Terraform Init (Dynamic Backend)
##############################################
echo "============================================="
echo "Step 1: Initialize Backend"
echo "============================================="

terraform init -upgrade \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="key=${PROJECT}/${ENV}/${COMPONENT}/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"


##############################################
# Step 2: Validate
##############################################
echo "========================================"
echo "Step 2: Validate"
echo "========================================"

terraform validate

##############################################
# Step 3: Action Handler
##############################################
echo "========================================"
echo "Step 3: ${ACTION}"
echo "========================================"
PLAN_FILE="${PROJECT}-${ENV}-${COMPONENT}.tfplan"

if [[ "$ACTION" == "apply" || "$ACTION" == "destroy" ]]; then
  trap '[[ -f "${PLAN_FILE}" ]] && rm -f "${PLAN_FILE}"' EXIT
fi


case "$ACTION" in

  plan)
    terraform plan \
      -input=false \
      -out="${PLAN_FILE}" \
      -lock-timeout=300s \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION"
    ;;

  apply)
    if [[ ! -f "${PLAN_FILE}" ]]; then
      echo "❌ Plan file missing. Run plan first."
      exit 1
    fi
    terraform apply -input=false "${PLAN_FILE}"
    ;;

  destroy)
    read -r -p "⚠️ Are you sure you want to destroy ${COMPONENT}? Type 'yes' to continue: " CONFIRM

    if [[ "$CONFIRM" != "yes" ]]; then
      echo "❌ Destroy cancelled"
      exit 1
    fi

    terraform destroy \
      -input=false \
      -auto-approve \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION"
    ;;

  *)
    echo "❌ Invalid action: ${ACTION}"
    echo "Allowed: plan | apply | destroy"
    exit 1
    ;;

esac
