variable "project" {}
variable "env" {}
variable "region" {}

variable "namespace" {}
variable "service_account" { default = "cart-sa" }
variable "dynamodb_table" { default = "ecommerce-cart" }
