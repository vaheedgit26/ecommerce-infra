##########################################################
#      usage: bash create.sh <component> <action>        #
#      example: bash create.sh vpc plan                  #
#      example: bash create.sh vpc apply                 #
##########################################################

#!/usr/bin/env bash
set -e

COMPONENT=$1
ACTION=$2

if [[ -z "$COMPONENT" || -z "$ACTION" ]]; then
  echo "Usage: bash create.sh <component> <plan|apply>"
  exit 1
fi

# Fetch values from bootstrap module
BUCKET=$(terraform -chdir=../../00-s3-create output -raw bucket_id)
ENV=$(terraform -chdir=../../00-s3-create output -raw env)
REGION=$(terraform -chdir=../../00-s3-create output -raw region)
PROJECT=$(terraform -chdir=../../00-s3-create output -raw project)

echo """
📄 Details:
     PROJECT  : ${PROJECT}
     ENV      : ${ENV}
     REGION   : ${REGION}
     BUCKET   : ${BUCKET}
     COMPONENT: ${COMPONENT}
     ACTION   : ${ACTION}
"""

echo "============================================="
echo "Step 1: Initialize ${COMPONENT} Module"
echo "============================================="

cd ..

terraform init -upgrade \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="key=${PROJECT_NAME}/${ENV}/${COMPONENT}/terraform.tfstate" \
  -backend-config="region=${REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

echo "============================================="
echo "Step 2: Validate ${COMPONENT}"
echo "============================================="

terraform validate

echo "============================================="
echo "Step 3: ${ACTION} for ${COMPONENT}"
echo "============================================="

PLAN_FILE="${COMPONENT}.tfplan"

if [[ "$ACTION" == "plan" ]]; then
  terraform plan \
    -out=${PLAN_FILE} \
    -var="project=$PROJECT" \
    -var="env=$ENV" \
    -var="region=$REGION"

elif [[ "$ACTION" == "apply" ]]; then
  # If plan file exists → use it
  if [[ -f "${PLAN_FILE}" ]]; then
    terraform apply ${PLAN_FILE}
  else
    echo "No plan file found. Running direct apply..."
    terraform apply \
      -var="project=$PROJECT" \
      -var="env=$ENV" \
      -var="region=$REGION"
  fi

else
  echo "❌ Invalid action. Use 'plan' or 'apply'"
  exit 1
fi
