output "vpc-id" {
  value = aws_vpc.ahmad-vpc-terra.id
}

output "sg-group" {
  value = aws_security_group.ahmad-sg-terra.id
}

output "subnet1" {
  value = aws_subnet.ahmad-public-subnet1-terra.id
}

output "subnet2" {
  value = aws_subnet.ahmad-public-subnet2-terra.id
}