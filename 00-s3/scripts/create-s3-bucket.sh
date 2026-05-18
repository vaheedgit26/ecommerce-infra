#!/usr/bin/env bash
#################################################################
# Usage: source create-s3-bucket.sh <project_name> <env> <region>
# Example: create-s3-bucket.sh ecommerce dev us-east-1
# Detects whether script is sourced or executed
#################################################################
set -e

# Step 0: Go to repo root
# cd "$(dirname "$0")"

PROJECT_NAME=$1
ENV=$2
REGION=$3

# Function to handle errors safely depending on context
abort() {
    local msg="$1"
    echo "$msg" >&2
    # Check if script is sourced
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        return 1  # Script is sourced, don't exit the shell
    else
        exit 1    # Script is run directly, safe to exit
    fi
}

# Check required arguments
if [[ -z "$PROJECT_NAME" || -z "$ENV" || -z "$REGION" ]]; then
    abort "Usage: source create-s3-bucket.sh <project_name> <env> <region>"
fi

# Change to terraform manifests directtory
cd ..

echo "============================================="
echo "Step 1: Create S3 bucket for Terraform state "
echo "============================================="

terraform init -upgrade

echo "===================================================="
echo "Step 2: Checking S3 bucket Configuration Validity"
echo "===================================================="
terraform validate

echo "================================================"
echo "Step 3: Generating plan for creating S3 bucket"
echo "================================================"
terraform plan \
  -var="project=$PROJECT_NAME" \
  -var="env=$ENV" \
  -var="region=$REGION" \
  -out=s3.tfplan 

echo "================================================"
echo "Step 4: Applying plan for creating S3 bucket"
echo "================================================"
terraform apply s3.tfplan    # Add -auto-approve if desired

echo "================================================"
echo "Step 5: Exporting TF_VARs for current shell"
echo "================================================"

# Capture Terraform outputs
export TF_VAR_env=$(terraform output -raw env)
export TF_VAR_region=$(terraform output -raw region)
export TF_VAR_bucket=$(terraform output -raw bucket_id)

echo "✅ TF_VARs exported for current shell:"
echo "========================================================"
echo "TF_VAR_env=$TF_VAR_env"
echo "TF_VAR_region=$TF_VAR_region"
echo "TF_VAR_bucket=$TF_VAR_bucket"
echo "You can now run Terraform commands with these variables."
echo "========================================================"

cat > bucket_details.txt <<EOF
env=$TF_VAR_env
region=$TF_VAR_region
bucket=$TF_VAR_bucket
EOF
