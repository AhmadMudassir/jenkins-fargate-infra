provider "aws" {
  region = var.aws_region
}

module "ec2-instances" {
  source = "./modules/ec2"
  ami = var.ami
  instance-type = var.instance-type
  sg-group = module.vpc.sg-group
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
}

module "vpc" {
  source = "./modules/vpc"
  vpc-cidr = var.vpc-cidr
  all-traffic-cidr = var.all-traffic-cidr
  owner = var.owner
  subnet1-cidr = var.subnet1-cidr
  subnet2-cidr = var.subnet2-cidr
}

module "ecs-fargate" {
  source = "./modules/ecs"
  vpc-id = module.vpc.vpc-id
  sg-group = module.vpc.sg-group
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
  aws_region = var.aws_region
  cloudwatch-group = module.cloudwatch.cloudwatch-group
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  owner = var.owner
}