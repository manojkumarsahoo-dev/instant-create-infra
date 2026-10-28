resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt"
  })
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "frontend_1" {
  subnet_id      = aws_subnet.frontend_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "frontend_2" {
  subnet_id      = aws_subnet.frontend_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "backend_1" {
  subnet_id      = aws_subnet.backend_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "backend_2" {
  subnet_id      = aws_subnet.backend_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database_1" {
  subnet_id      = aws_subnet.database_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database_2" {
  subnet_id      = aws_subnet.database_2.id
  route_table_id = aws_route_table.private.id
}
