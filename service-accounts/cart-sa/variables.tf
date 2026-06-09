variable "project" {}
variable "env" {}
variable "region" {}

variable "namespace" { "ecommerce-dev" }
variable "service_account" { default = "cart" }
variable "dynamodb_table" { default = "ecommerce-cart" }
