variable "aws_region" {
  description = "AWS 地區"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "admin"
}

variable "key_pair_name" {
  description = "Key Pair 名稱"
  type        = string
  default     = "terraform-ec2"
}

variable "public_key_path" {
  description = "SSH public key path"
  type        = string
  default     = "~/.ssh/terraform-ec2.pub"
}

variable "security_group_name" {
  description = "Security Group 名稱"
  type        = string
  default     = "main-sg"
}

variable "security_group_description" {
  description = "Security Group 描述"
  type        = string
  default     = "Security group for EC2"
}

variable "instance_type" {
  description = "EC2 Instance 類型"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "EC2 Instance 名稱"
  type        = string
  default     = "my-instance"
}

variable "ssh_port" {
  description = "SSH 連接埠"
  type        = number
  default     = 22
}

variable "allowed_cidr_blocks" {
  description = "允許 SSH 的 CIDR 區塊"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
