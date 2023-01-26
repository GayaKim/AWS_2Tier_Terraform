#vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "tf-vpc"
  }
}

#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

#public subnet a
resource "aws_subnet" "pub_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet-public1-ap-northeast-2a"
  }
}

#public subnet c
resource "aws_subnet" "pub_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet-public1-ap-northeast-2c"
  }
}

#pub rt
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf-rtb-public"
  }
}

#public a <-> pub rt
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub_a.id
  route_table_id = aws_route_table.pub.id
}

#public c <-> pub rt
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.pub_c.id
  route_table_id = aws_route_table.pub.id
}

#private subnet a
resource "aws_subnet" "pri_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "tf-subnet-private1-ap-northeast-2a"
  }
}

#private subnet c
resource "aws_subnet" "pri_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "tf-subnet-private2-ap-northeast-2c"
  }
}

# private a rt
resource "aws_route_table" "pri_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_a.id
  }

  tags = {
    Name = "tf-rtb-private1-ap-northeast-2a"
  }
}

# private c rt
resource "aws_route_table" "pri_c" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_a.id
  }

  tags = {
    Name = "tf-rtb-private2-ap-northeast-2c"
  }
}

#private subnet a <-> private rt a
resource "aws_route_table_association" "pri_a" {
  subnet_id      = aws_subnet.pri_a.id
  route_table_id = aws_route_table.pri_a.id
}

#private subnet c <-> private rt c
resource "aws_route_table_association" "pri_c" {
  subnet_id      = aws_subnet.pri_c.id
  route_table_id = aws_route_table.pri_c.id
}

#elastic IP(pub a) for Nat-Gateway
resource "aws_eip" "pub_a" {
  vpc = true

  tags = {
    Name = "tf-eip-ap-northeast-2a"
  }
}

#Nat-Gateway
resource "aws_nat_gateway" "gw_a" {
  allocation_id = aws_eip.pub_a.id
  subnet_id     = aws_subnet.pub_a.id
  tags = {
    Name = "tf-nat-public1-ap-northeast-2a"
  }
  depends_on = [aws_internet_gateway.gw]
}

