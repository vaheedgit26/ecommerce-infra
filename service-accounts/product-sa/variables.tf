variable "project" {}
variable "env" {}
variable "region" {}

variable "namespace" { "ecommerce-dev" }
variable "service_account" { default = "product" }
variable "dynamodb_table" { default = "ecommerce-products" }
