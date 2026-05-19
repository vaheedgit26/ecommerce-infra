#!/usr/bin/env bash
set -e

##############################################
# Usage: bash infra.sh <component> <action>
# Example:
#   bash infra.sh vpc plan
#   bash infra.sh eks apply
#   bash infra.sh alb destroy
##############################################

COMPONENT=$1
ACTION=$2

if [[ -z "$COMPONENT" || -z "$ACTION" ]]; then
  echo "Usage: bash infra.sh <component> <plan|apply|destroy>"
  echo "Example: bash infra.sh vpc plan"
  exit 1
fi

# Fetch values from bootstrap module
BUCKET=$(terraform -chdir=../00-s3 output -raw bucket_id)
ENV=$(terraform -chdir=../00-s3 output -raw env)
REGION=$(terraform -chdir=../00-s3 output -raw region)
PROJECT=$(terraform -chdir=../00-s3 output -raw project)

PLAN_FILE="${COMPONENT}.tfplan"

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

cd ../${COMPONENT}

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
      -out=${PLAN_FILE} \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION"
    ;;

  apply)
    if [[ -f "${PLAN_FILE}" ]]; then
      terraform apply ${PLAN_FILE}
    else
      echo "⚠️ No plan file found. Running direct apply..."
      terraform apply \
        -var="project=$PROJECT" \
        -var="env=$ENV" \
        -var="region=$REGION"
    fi
    ;;

  destroy)
    read -p "⚠️ Are you sure you want to destroy ${COMPONENT}? Type 'yes' to continue: " CONFIRM

    if [[ "$CONFIRM" != "yes" ]]; then
      echo "❌ Destroy cancelled"
      exit 1
    fi

    terraform destroy \
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
