variable "project" {}
variable "env" {}

variable "oidc_provider_url" {}
variable "oidc_provider_arn" {}

variable "remote_state_s3_bucket" {}    # To read VPC and EKS output values
