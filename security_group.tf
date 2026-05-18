resource "aws_security_group" "api_sg" {
  name        = "${local.name_prefix}-api-sg"
  description = "Security group for payment API boundary"
  vpc_id      = aws_vpc.payments_vpc.id

  ingress {
    description = "Allow HTTPS from approved external range"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_api_cidr]
  }

  egress {
    description = "Allow HTTPS egress only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-api-sg"
    N2SF_Control = "EB,IF,RA"
  })
}

resource "aws_security_group" "app_sg" {
  name        = "${local.name_prefix}-app-sg"
  description = "Security group for private payment application tier"
  vpc_id      = aws_vpc.payments_vpc.id

  ingress {
    description     = "Allow HTTPS traffic from API boundary only"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.api_sg.id]
  }

  egress {
    description = "Allow HTTPS egress for controlled service integration"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-app-sg"
    N2SF_Control = "SG,IS,IF"
  })
}