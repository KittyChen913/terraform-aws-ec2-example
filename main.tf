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

# 獲取所有可用的 AZ
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC：建立自定義 VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/18"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet：位於第一個 AZ
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet：位於第二個 AZ
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway：提供 public subnet 連接到網際網路
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Public Route Table：用於 public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Public Route Table Association：將 public subnet 與 public route table 關聯
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table：用於 private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private-rt"
  }
}

# Private Route Table Association：將 private subnet 與 private route table 關聯
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
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
  vpc_id      = aws_vpc.main_vpc.id

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
resource "aws_instance" "public" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "my-public-instance"
  }
}

# Private EC2 實例配置
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "my-private-instance"
  }
}

# Output：輸出實例 Public IP
output "instance_public_ip" {
  value       = aws_instance.public.public_ip
  description = "Public instance 的 Public IP"
}

# Output：輸出 Private Instance Private IP
output "instance_private_ip" {
  value       = aws_instance.private.private_ip
  description = "Private instance 的 Private IP"
}

# Output：輸出 SSH 登入命令
output "ssh_command" {
  value       = "ssh -i ~/.ssh/terraform-ec2 ec2-user@${aws_instance.public.public_ip}"
  description = "連接到 public instance 的 SSH 命令"
}
