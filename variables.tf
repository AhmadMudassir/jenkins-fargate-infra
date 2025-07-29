variable "aws_region" {
    type= string
}

variable "ami" {
    type = string
}

variable "owner" {
  type =  string
}

variable "vpc-cidr" {
  type = string
}

variable "subnet1-cidr" {
  type = string
}

variable "subnet2-cidr" {
  type = string
}

variable "all-traffic-cidr" {
  type = string
}

variable "instance-type" {
  type = string
}