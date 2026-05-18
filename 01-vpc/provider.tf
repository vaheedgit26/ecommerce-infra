terraform {
  # required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

# Remote Backend
 backend "s3" {
    bucket  = "remote-state-aws-88s-dev" # Replace with your unique bucket name
    key     = "terraform-eks-vpc"
    region  = "us-east-1"
    encrypt = true
    use_lockfile   = true
  }
}

provider "aws" {
  region = var.region
}
