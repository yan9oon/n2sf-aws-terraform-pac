locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project       = var.project_name
    Environment   = var.environment
    ManagedBy     = "Terraform"
    ResearchScope = "N2SF-PaC-PoC"

    N2SF_Class    = var.n2sf_grade
    N2SF_Service  = "Payments"
    N2SF_DataType = "PaymentTransactionData"
  }

  log_bucket_name = "${replace(local.name_prefix, "_", "-")}-log-bucket"
}