resource "aws_s3_bucket" "log_bucket" {
  bucket              = local.log_bucket_name
  object_lock_enabled = true

  tags = merge(local.common_tags, {
    Name          = local.log_bucket_name
    N2SF_Control  = "AuditLog,DU,DT"
    N2SF_Resource = "LogBucket"
  })
}

resource "aws_s3_bucket_public_access_block" "log_bucket_pab" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_sse" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.log_key.arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_object_lock_configuration" "log_bucket_object_lock" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 365
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.log_bucket_versioning
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "retain-audit-logs"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.log_bucket_versioning
  ]
}

data "aws_iam_policy_document" "log_bucket_policy_doc" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.log_bucket.arn,
      "${aws_s3_bucket.log_bucket.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowCloudTrailGetBucketAcl"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = [
      aws_s3_bucket.log_bucket.arn
    ]
  }

  statement {
    sid    = "AllowCloudTrailWriteLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.log_bucket.arn}/AWSLogs/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AllowConfigGetBucketAcl"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = [
      aws_s3_bucket.log_bucket.arn
    ]
  }

  statement {
    sid    = "AllowConfigWriteLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.log_bucket.arn}/AWSLogs/*"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.log_bucket_policy_doc.json

  depends_on = [
    aws_s3_bucket_public_access_block.log_bucket_pab
  ]
}