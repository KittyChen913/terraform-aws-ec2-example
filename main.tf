# EC2 Terraform 配置文件

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 連接到 AWS 東京區域，使用 admin profile
provider "aws" {
  region  = "ap-northeast-1"
  profile = "admin"
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
  key_name   = "terraform-ec2"
  public_key = file("~/.ssh/terraform-ec2.pub")
}

# Security Group：只開放 SSH
resource "aws_security_group" "main" {
  name        = "main-sg"
  description = "Security group for EC2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
