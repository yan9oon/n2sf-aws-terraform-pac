resource "aws_vpc" "payments_vpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-vpc"
    N2SF_Control = "SG,IS,EB"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.payments_vpc.id

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-igw"
    N2SF_Control = "EB"
  })
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.payments_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-public-a"
    Tier         = "Public"
    N2SF_Control = "SG,IS,EB"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.payments_vpc.id
  cidr_block              = "10.20.11.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-private-a"
    Tier         = "Private"
    N2SF_Control = "SG,IS,IF"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.payments_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-public-rt"
    N2SF_Control = "EB"
  })
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.payments_vpc.id

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-private-rt"
    N2SF_Control = "SG,IS,IF"
  })
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}