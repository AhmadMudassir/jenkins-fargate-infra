resource "aws_vpc" "ahmad-vpc-terra" {
  cidr_block = var.vpc-cidr
  tags = {
    "Name" = "ahmad-vpc-terra"
    "owner" = "ahmad"
  }
}

resource "aws_internet_gateway" "ahmad-igw-terra" {  
    vpc_id = aws_vpc.ahmad-vpc-terra.id
    tags = {
        "Name" = "ahmad-igw-terra"
        "owner" = var.owner
    }
}

resource "aws_subnet" "ahmad-public-subnet1-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  cidr_block = var.subnet1-cidr
  availability_zone = "us-east-2c"
  tags = {
    "Name" = "ahmad-public-subnet1-terra"
    "owner" = var.owner
  }
}

resource "aws_subnet" "ahmad-public-subnet2-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  cidr_block = var.subnet2-cidr
  availability_zone = "us-east-2a"
  tags = {
    "Name" = "ahmad-public-subnet2-terra"
    "owner" = var.owner
  }
}

resource "aws_route_table" "ahmad-public-sub-rt-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  route {
    cidr_block = var.all-traffic-cidr
    gateway_id = aws_internet_gateway.ahmad-igw-terra.id
  }
  tags = {
    "Name" = "ahmad-public-sub-rt-terra"
    "owner" = var.owner
  }
}

resource "aws_route_table_association" "ahmad-subnet1-association" {
  subnet_id = aws_subnet.ahmad-public-subnet1-terra.id
  route_table_id = aws_route_table.ahmad-public-sub-rt-terra.id
}

resource "aws_route_table_association" "ahmad-subnet2-association" {
  subnet_id = aws_subnet.ahmad-public-subnet2-terra.id
  route_table_id = aws_route_table.ahmad-public-sub-rt-terra.id
}

resource "aws_security_group" "ahmad-sg-terra" {
  name = "Http and SSH and Jenkins"
  vpc_id = aws_vpc.ahmad-vpc-terra.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [var.all-traffic-cidr]
  }  

  tags = {
    "Name" = "ahmad-sg-terra"
    "owner" = var.owner
  }
}
