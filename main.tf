# EC2 Terraform 配置文件

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 連接到 AWS 指定 region，使用指定 profile
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# 自動讀取最新的 Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair：上傳本地公鑰到 AWS
resource "aws_key_pair" "my_key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}

# Security Group：只開放 SSH
resource "aws_security_group" "main" {
  name        = var.security_group_name
  description = var.security_group_description

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 實例配置
resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.main.id]

  tags = {
    Name = "my-instance"
  }
}

# Output：輸出實例 Public IP
output "instance_public_ip" {
  value = aws_instance.main.public_ip
}

# Output：輸出 SSH 登入命令
output "ssh_command" {
  value       = "ssh -i ~/.ssh/terraform-ec2 ec2-user@${aws_instance.main.public_ip}"
  description = "SSH 登入命令"
}
