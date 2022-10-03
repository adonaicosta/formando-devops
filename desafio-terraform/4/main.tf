terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev" // https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
}

# detalhes da instancia a ser clonada
data "aws_instance" "source_instance" {
  instance_id = var.source_instance_id
}

# armazena os detalhes da instancia
output "source_instance" {
  value       = "${data.aws_instance.source_instance}"
  description = "Detalhes da instância"
}

# cria uma AMI com os mesmos parâmetros
resource "aws_ami_from_instance" "sourceami" {
  name               = "source-instance"
  source_instance_id = var.source_instance_id
}

# cria a nova instância ec2
resource "aws_instance" "newinstance" {
    ami                    = aws_ami_from_instance.sourceami.id
    instance_type          = data.aws_instance.source_instance.instance_type
    vpc_security_group_ids = data.aws_instance.source_instance.vpc_security_group_ids
    subnet_id              = data.aws_instance.source_instance.subnet_id
    tags = {
        Name = "${data.aws_instance.source_instance.tags.Name}-cloned"
    }
}