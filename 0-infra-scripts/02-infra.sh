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

# Assigning input parameters
COMPONENT=$1
ENV=$2
ACTION=$3

# ENV validation
case "$ENV" in
  dev|qa|prod) ;;
  *)
    echo "❌ Invalid env: $ENV"
    echo "Valid: (dev|qa|prod)"
    exit 1
    ;;
esac

# ACTION validation
case "$ACTION" in
  plan|apply|destroy) ;;
  *)
    echo "❌ Invalid action: $ACTION"
    exit 1
    ;;
esac

if [[ ! -f components.txt ]]; then
  echo "❌ components.txt not found"
  exit 1
fi

# Component validation
MATCHES=$(grep -E "^${COMPONENT}[[:space:]]*=" components.txt || true)

COUNT=$(grep -c -E "^${COMPONENT}[[:space:]]*=" components.txt || true)

if [[ "$COUNT" -eq 0 ]]; then
  echo "❌ Invalid component: $COMPONENT"
  echo "Refer to file: components.txt"
  exit 1
fi

if [[ "$COUNT" -gt 1 ]]; then
  echo "❌ Duplicate entries found for $COMPONENT"
  exit 1
fi

DEST_DIR=$(echo "$MATCHES" | cut -d= -f2 | xargs)


# Log file config
LOG_FILE="infra-${COMPONENT}-${ENV}-$(date +%F-%H%M).log"
exec > >(tee -a "$LOG_FILE") 2>&1

S3_DIR="../00-s3"


# Ensure S3-Bucket created first
if ! terraform -chdir="${S3_DIR}" output -raw bucket_id >/dev/null 2>&1; then
  echo "❌ Bootstrap (00-s3) not applied"
  exit 1
fi


# Fetch values from bootstrap S3 module
BUCKET=$(terraform -chdir="${S3_DIR}" output -raw bucket_id)
# ENV=$2 #$(terraform -chdir=../00-s3 output -raw env)
REGION=$(terraform -chdir="${S3_DIR}" output -raw region)
PROJECT=$(terraform -chdir="${S3_DIR}" output -raw project)

# Print values
echo """
📄 Details:
     PROJECT   : ${PROJECT}
     ENV       : ${ENV}
     REGION    : ${REGION}
     BUCKET    : ${BUCKET}
     COMPONENT : ${COMPONENT}
     ACTION    : ${ACTION}
"""

# 🚫 Block destroy in prod (safety)
if [[ "$ENV" == "prod" && "$ACTION" == "destroy" ]]; then
  echo "❌ Destroy is NOT allowed in production!"
  exit 1
fi

PLAN_FILE="${PROJECT}-${ENV}-${COMPONENT}.tfplan"

# ✅ Set trap immediately after defining PLAN_FILE
trap '[[ -f "${PLAN_FILE:-}" ]] && rm -f "${PLAN_FILE}"' EXIT

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
echo "============================================="
echo "Step 2: Validate"
echo "============================================="

terraform validate

##############################################
# Step 3: Action Handler
##############################################
echo "============================================="
echo "Step 3: ${ACTION}"
echo "============================================="


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
