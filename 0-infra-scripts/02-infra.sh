#!/usr/bin/env bash
# set -e
set -euo pipefail
##############################################
# Usage: bash infra.sh <component> <env> <action>
# Example:
#   bash infra.sh vpc dev plan
#   bash infra.sh eks dev apply
#   bash infra.sh alb dev destroy
##############################################
COMPONENT=$1
ENV=$2
ACTION=$3

LOG_FILE="infra-${COMPONENT}-${ENV}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ -z "$COMPONENT" || -z "$ENV" || -z "$ACTION" ]]; then
  echo "Usage: bash infra.sh <component: vpc|eks|..> <env: dev|qa|prod> <action: plan|apply|destroy>"
  echo "Example: bash infra.sh vpc dev plan"
  exit 1
fi

if ! terraform -chdir=../00-s3 output -raw bucket_id >/dev/null 2>&1; then
  echo "❌ Bootstrap (00-s3) not applied"
  exit 1
fi

# Fetch values from bootstrap module
BUCKET=$(terraform -chdir=../00-s3 output -raw bucket_id)
#ENV=$2 #$(terraform -chdir=../00-s3 output -raw env)
REGION=$(terraform -chdir=../00-s3 output -raw region)
PROJECT=$(terraform -chdir=../00-s3 output -raw project)

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

case "${COMPONENT}" in
  vpc) DEST_DIR="00-vpc" ;;
  eks) DEST_DIR="01-eks" ;; 
  alb) DEST_DIR="02-alb" ;;
  *) 
    echo "Unknown component: ${COMPONENT}"
	exit 1 
	;;
esac


if [[ -z ${DEST_DIR} ]]; then
  echo "No Destination Directory found"
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

PLAN_FILE="${PROJECT}-${ENV}-${COMPONENT}.tfplan"

if [[ "$ACTION" == "apply" || "$ACTION" == "destroy" ]]; then
  trap 'rm -f "${PLAN_FILE}"' EXIT
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
