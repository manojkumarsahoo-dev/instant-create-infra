resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-1"
    Tier = "Public"
  })
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-2"
    Tier = "Public"
  })
}

resource "aws_subnet" "frontend_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.aws_region}a"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-frontend-1"
    Tier = "Frontend"
  })
}

resource "aws_subnet" "frontend_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.aws_region}b"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-frontend-2"
    Tier = "Frontend"
  })
}

resource "aws_subnet" "backend_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "${var.aws_region}a"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-backend-1"
    Tier = "Backend"
  })
}

resource "aws_subnet" "backend_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "${var.aws_region}b"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-backend-2"
    Tier = "Backend"
  })
}

resource "aws_subnet" "database_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.31.0/24"
  availability_zone = "${var.aws_region}a"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database-1"
    Tier = "Database"
  })
}

resource "aws_subnet" "database_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/24"
  availability_zone = "${var.aws_region}b"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database-2"
    Tier = "Database"
  })
}
