#!/usr/bin/env bash
set -euo pipefail
##################################################################################
# Usage: bash main.sh  <component> <env> <action> [project bucket region]
# Example:
#   bash main.sh aws-lbc dev plan [project bucket region]
##################################################################################
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

VALID_COMPONENT="aws-lbc"

# Load validation functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_DIR}/validate.sh"

# Parameters validation
if [[ $# -lt 3 ]]; then 
  print_error "Usage: bash main.sh <component> <env> <action> [project bucket region]"
  print_info "Component: $VALID_COMPONENT (lowercase only)"
  print_info "Env: dev | qa | prod"
  print_info "Action: plan | apply | destroy"
  echo ""
  print_info "Example: bash main.sh $VALID_COMPONENT dev plan [project bucket region]"
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

# Inputs
COMPONENT="$1"
ENV="$2"
ACTION="$3"

# VALID_COMPONENT="argocd"
VALID_ENVS=("dev" "qa" "prod")
VALID_ACTIONS=("plan" "apply" "destroy")

if ! validate_component "$COMPONENT" "$VALID_COMPONENT"; then
  print_error "❌ Component validation failed"
  print_info  "Expected: '$VALID_COMPONENT', Found: '$COMPONENT' "
  exit 1
fi

if ! validate_from_list "$ENV" "${VALID_ENVS[@]}"; then
  print_error "❌ Env validation failed"
  print_info  "Expected one of: ${VALID_ENVS[*]}"           # VALID_ENVS[*] prints as a single string (VALID_ACTIONS[@] prints as an array)
  exit 1
fi

if ! validate_from_list "$ACTION" "${VALID_ACTIONS[@]}"; then
  print_error "❌ Action validation failed"
  print_info  "Expected one of: ${VALID_ACTIONS[*]}"        # VALID_ACTIONS[*] prints as a single string (VALID_ACTIONS[@] prints as an array)
  exit 1
fi

PARENT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P)" 
S3_DIR="${PARENT_DIR}/../00-s3"

# Ensure S3 dir exists
if [[ ! -d "$S3_DIR" ]]; then
  print_error "❌ S3 bootstrap directory not found: ${S3_DIR}"
  exit 1
fi

# tf_output AFTER S3_DIR defined ✅
tf_output() {
  terraform -chdir="${S3_DIR}" output -raw "$1" 2>/dev/null || true
}

# Fallback values
PROJECT="${4:-$(tf_output project)}"
BUCKET="${5:-$(tf_output bucket_id)}"
REGION="${6:-$(tf_output region)}"

if ! validate_item "$PROJECT"; then 
  print_error "❌ PROJECT not provided and not found in Terraform output"
  print_info "Usage: bash main.sh <component> <env> <action> [project bucket region]"
  exit 1
fi

if ! validate_item "$BUCKET"; then
  print_error "❌ BUCKET not provided and not found in Terraform output"
  print_info "Usage: bash main.sh <component> <env> <action> [project bucket region]"
  exit 1
fi

if ! validate_item "$REGION"; then
  print_error "❌ REGION not provided and not found in Terraform output"
  print_info "Usage: bash main.sh <component> <env> <action> [project bucket region]"
  exit 1
fi

# Print values
echo "----------------------------------------"
cat <<EOF
📄 Details:
     PROJECT   : ${PROJECT}
     ENV       : ${ENV}
     REGION    : ${REGION}
     BUCKET    : ${BUCKET}
     COMPONENT : ${COMPONENT}
     ACTION    : ${ACTION}
EOF
echo "----------------------------------------"

print_info "Sleeping for 3 seconds"
sleep 3

print_info "Changing to: $PARENT_DIR"

# Change to parent directory
cd "$PARENT_DIR" || {
  print_error "❌ Failed to change directory to: ${PARENT_DIR}"
  exit 1
} 

print_info "Using backend state bucket: ${BUCKET}"
print_info "State key: ${PROJECT}/${ENV}/${COMPONENT}/terraform.tfstate"

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

TF_VARS=(
  -var="project=$PROJECT"
  -var="env=$ENV"
  -var="region=$REGION"
  -var="remote_state_s3_bucket=$BUCKET"
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
      print_error "❌ Plan file missing. Run plan first."
      exit 1
    fi
    
    terraform apply -input=false -lock-timeout=5m "${PLAN_FILE}"
    ;;

  destroy)
    read -r -p "⚠️  Are you sure you want to destroy ${COMPONENT}? Type 'yes' to continue: " CONFIRM

    # if [[ ! "$CONFIRM" =~ ^[Yy][Ee][Ss]$ ]]; then

    if [[ "$CONFIRM" != "yes" ]]; then
      print_info "❌ Destroy cancelled... Exiting"
      exit 1
    fi

    terraform destroy \
      -input=false \
      -lock-timeout=5m \
      -auto-approve \
      "${TF_VARS[@]}"
    ;;

  *)
    print_error "❌ Invalid action: ${ACTION}"
    print_info  "Allowed: plan | apply | destroy"
    exit 1
    ;;

esac
