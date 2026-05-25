#!/usr/bin/env bash
set -euo pipefail
#####################################################################
# Usage: bash infra.sh <component> <env> <action> 
# Example:
#   bash vpc.sh vpc dev plan 
#####################################################################
# Parameters validation
if [[ $# -ne 3 ]]; then
    echo "Usage: bash vpc.sh <component: vpc|eks|..> <env: dev|qa|prod> <action: plan|apply|destroy>"
    echo "Example: bash vpc.sh vpc dev plan"
    exit 1
fi

# Assigning input parameters
COMPONENT=$1
ENV=$2
ACTION=$3

if [[ "$COMPONENT" != "vpc" ]]; then
	echo "Component should be: 'vpc' only"
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

# S3_DIR="../00-s3"

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

# Change to previous directory
cd ..

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

case "$ACTION" in

  plan)

      terraform plan \
        -input=false \
        -out="${PLAN_FILE}" \
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

    read -r -p "⚠️  Are you sure you want to destroy ${COMPONENT}? Type 'yes' to continue: " CONFIRM

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

