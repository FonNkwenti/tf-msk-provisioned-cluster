data "aws_availability_zones" "main" {
}

data "aws_caller_identity" "main" {
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

}
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["al2023-ami-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

locals {
  dir_name = basename(path.cwd)
  name     = "${var.project_name}-${var.environment}"

  msk_vpc_cidr   = "10.10.0.0/16"
  spoke_a_vpc_cidr          = "10.15.0.0/16"

  main_azs   = slice(data.aws_availability_zones.main.names, 0, 3)
  main_az1   = data.aws_availability_zones.main.names[0]
  main_az2   = data.aws_availability_zones.main.names[1]
  main_az3   = data.aws_availability_zones.main.names[2]


  main_ami   = data.aws_ami.amazon_linux_2.id


  instance_name = "${local.name}-kafka"
  vpc_name      = "${local.name}-vpc"

    common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Service     = var.service_name
    CostCenter  = var.cost_center
  }
    aws_services = {
  # "ecrapi" : {
  #   "name" : "com.amazonaws.${var.main_region}.ecr.api"
  # }
  # "ecrdkr" : {
  #   "name" : "com.amazonaws.${var.main_region}.ecr.dkr"
  # }
  "sqs" : {
    "name" : "com.amazonaws.${var.main_region}.sqs"
  }
  # "s3" : {
  #   "name" : "com.amazonaws.${var.main_region}.s3"
  # }

}


}
