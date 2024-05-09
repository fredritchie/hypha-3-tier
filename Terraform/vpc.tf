resource "aws_vpc" "webapp_VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "webapp"
  }
}
resource "aws_subnet" "subnet-public-1" {
  vpc_id                  = aws_vpc.webapp_VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-1"
  }
}
resource "aws_subnet" "subnet-public-2" {
  vpc_id                  = aws_vpc.webapp_VPC.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-2"
  }
}
resource "aws_internet_gateway" "webapp-igw" {
  vpc_id = aws_vpc.webapp_VPC.id

  tags = {
    Name = "webapp_IGW"
  }
}

resource "aws_route_table" "webapp_route_table" {
  vpc_id = aws_vpc.webapp_VPC.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webapp-igw.id
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-public-1.id
  route_table_id = aws_route_table.webapp_route_table.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet-public-2.id
  route_table_id = aws_route_table.webapp_route_table.id
}
resource "aws_subnet" "subnet-private-1" {
  vpc_id                  = aws_vpc.webapp_VPC.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "private-1"
  }
}
resource "aws_subnet" "subnet-private-2" {
  vpc_id                  = aws_vpc.webapp_VPC.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "private-2"
  }
}
resource "aws_nat_gateway" "weba-nat" {
  allocation_id = aws_eip.webapp_eip.id
  subnet_id     = aws_subnet.subnet-public-1.id

  tags = {
    Name = "webapp gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.webapp-igw]
}

resource "aws_eip" "webapp_eip" {
  domain   = "vpc"
}
resource "aws_route_table" "webapp_private_route_table" {
  vpc_id = aws_vpc.webapp_VPC.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.weba-nat.id  
    }
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet-private-1.id
  route_table_id = aws_route_table.webapp_private_route_table.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.subnet-private-2.id
  route_table_id = aws_route_table.webapp_private_route_table.id
}