variable "ami" {
    description = "Ubuntu AMI ID"
    type = string
}

variable "instance-type" {
    type = string
}

variable "subnet1" {
  type = string
}

variable "subnet2" {
  type = string
}

variable "sg-group" {
  type = string
}