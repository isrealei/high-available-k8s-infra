variable "region" {
  type        = string
  description = "aws region"
}

variable "private_subnets_cidr_block" {
  type        = list(string)
  description = "Private Subnets CIDR Block"
}

variable "public_subnets_cidr_block" {
  type        = list(string)
  description = "public Subnets CIDR Block"
}

variable "name" {
  type        = string
  description = "vpc name"
}

variable "cidr" {
  type        = string
  description = "vpc cidr"
}


variable "master_instance_type" {
  description = "master node instance type"
}


variable "worker_instance_type" {
  description = "worker node instance type"
}


variable "haproxy_instance_type" {
  description = "proxy node instance type"
}

variable "amis" {
  type        = map(string)
  description = "ami for master node"
}

variable "myip" {
  description = "my ip address to access bastion host"
}

variable "master-instance_count" {
  description = "master node count"
}

variable "worker-instance_count" {
  description = "worker node count"
}

variable "proxy-instance-count" {
  description = "proxy node count"
}