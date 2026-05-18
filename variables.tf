variable "aws_region" {
  description = "AWS region for Terraform PoC"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "n2sf-payments-poc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "research"
}

variable "n2sf_grade" {
  description = "N2SF information grade"
  type        = string
  default     = "S"
}

variable "allowed_api_cidr" {
  description = "CIDR allowed to access API endpoint in this PoC"
  type        = string
  default     = "203.0.113.0/24"
}