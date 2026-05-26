#!/usr/bin/env bash
set -euo pipefail
##########################################################################
# Usage: bash infra.sh <component> <env> <action> 
# Example:
#   bash create-delete.sh vpc dev plan [ project bucket region ] optional
##########################################################################
# Parameters validation
if [[ $# -lt 3 ]]; then
  echo "Usage: bash vpc.sh <component: vpc|eks|..> <env: dev|qa|prod> <action: plan|apply|destroy> [ project bucket region ] optional"
  echo "Example: bash create-delete.sh vpc dev plan"
  exit 1
fi

# Assigning input parameters
COMPONENT=$1
ENV=$2
ACTION=$3

# Safe optional args
PROJECT="${4:-}"    # set -u
BUCKET="${5:-}"     # set -u
REGION="${6:-}"     # set -u

if [[ "$COMPONENT" != "vpc" ]]; then
	echo "Component should be 'vpc'(lower case) only for VPC creation"
	exit 1
fi

case "$ENV" in
  dev|qa|prod) ;;
  *)
    echo "Invalid ENV: ${ENV}"
    echo "Valid envs: dev|qa|prod"
    exit 1
    ;;
esac

case "$ACTION" in
  plan|apply|destroy) ;;
  *)
    echo "Invalid ACTION: ${ACTION}"
    echo "Valid ACTIONS: plan|apply|destroy"
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" 
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P)" 
S3_DIR="${ROOT_DIR}/00-s3"

# Ensure S3 directory exists
if [[ ! -d "$S3_DIR" ]]; then
  echo "❌ S3 bootstrap directory not found: ${S3_DIR}"
  exit 1
fi

# Ensure Terraform installed
command -v terraform >/dev/null 2>&1 || {
  echo "❌ Terraform is not installed or not in PATH"
  exit 1
}

tf_output() {
  terraform -chdir="${S3_DIR}" output -raw "$1" 2>/dev/null || true
}

# Fallback
PROJECT="${PROJECT:-$(tf_output project)}"
BUCKET="${BUCKET:-$(tf_output bucket_id)}"
REGION="${REGION:-$(tf_output region)}"

if [[ -z "$PROJECT" ]]; then
  echo "❌ PROJECT not provided and not found in Terraform output"
  exit 1
fi

if [[ -z "$BUCKET" ]]; then
  echo "❌ BUCKET not provided and not found in Terraform output"
  echo "👉 Run bootstrap (00-s3) or pass BUCKET manually"
  exit 1
fi

if [[ -z "$REGION" ]]; then
  echo "❌ REGION not provided and not found in Terraform output"
  exit 1
fi

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

# Change to previous directory
cd "$ROOT_DIR" || {
  echo "❌ Failed to change directory to: ${ROOT_DIR}"
  exit 1
} 

echo "============================================="
echo "Step 1: Initialize Backend"
echo "============================================="
terraform init -upgrade \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="key=${PROJECT}/${ENV}/${COMPONENT}/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

echo "========================================"
echo "Step 2: Validate"
echo "========================================"
terraform validate

echo "========================================"
echo "Step 3: Terraform: ${ACTION}"
echo "========================================"
PLAN_FILE="${PROJECT}-${ENV}-${COMPONENT}.tfplan"

if [[ "$ACTION" == "apply" || "$ACTION" == "destroy" ]]; then
  trap '[[ -f "${PLAN_FILE}" ]] && rm -f "${PLAN_FILE}"' EXIT
fi

#-lock-timeout=300s \
TF_VARS=(
  -var="project=$PROJECT"
  -var="env=$ENV"
  -var="region=$REGION"
)

case "$ACTION" in

  plan)

    terraform plan \
      -input=false \
      -lock-timeout=5m \
      -out="${PLAN_FILE}" \
      "${TF_VARS[@]}" 
    ;;

  apply)

    if [[ ! -f "${PLAN_FILE}" ]]; then
      echo "❌ Plan file missing. Running plan first."
      terraform plan \
        -input=false \
        -lock-timeout=5m \
        -out="${PLAN_FILE}" \
        "${TF_VARS[@]}"
      # exit 1
    fi
    
    terraform apply -input=false -lock-timeout=5m "${PLAN_FILE}"
    ;;

  destroy)

    read -r -p "⚠️  Are you sure you want to destroy ${COMPONENT}? Type 'yes' to continue: " CONFIRM

    # if [[ ! "$CONFIRM" =~ ^[Yy][Ee][Ss]$ ]]; then

    if [[ "$CONFIRM" != "yes" ]]; then
      echo "❌ Destroy cancelled... Exiting"
      exit 1
    fi

    terraform destroy \
      -input=false \
      -lock-timeout=5m \
      -auto-approve \
      "${TF_VARS[@]}"
    ;;

  *)
    echo "❌ Invalid action: ${ACTION}"
    echo "Allowed: plan | apply | destroy"
    exit 1
    ;;

esac
