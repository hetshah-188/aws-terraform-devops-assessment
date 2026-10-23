
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "devops-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "devops-nat-gateway"
  }
}

resource "aws_route" "private_app_nat" {
  count                  = 2
  route_table_id         = aws_route_table.private_app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
