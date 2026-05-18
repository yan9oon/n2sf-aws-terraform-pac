data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name               = "${local.name_prefix}-cloudtrail-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-cloudtrail-cloudwatch-role"
    N2SF_Control = "AuditLog"
  })
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_policy" {
  name   = "${local.name_prefix}-cloudtrail-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_policy_doc.json

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-cloudtrail-cloudwatch-policy"
    N2SF_Control = "AuditLog"
  })
}

resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch_attach" {
  role       = aws_iam_role.cloudtrail_cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_policy.arn
}

resource "aws_cloudtrail" "main" {
  name                          = "${local.name_prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.log_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.log_key.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch_role.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.log_bucket_policy,
    aws_iam_role_policy_attachment.cloudtrail_cloudwatch_attach
  ]

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-trail"
    N2SF_Control = "AuditLog,IF,AC"
  })
}