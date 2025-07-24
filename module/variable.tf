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
  type        = string
}


variable "worker_instance_type" {
  description = "worker node instance type"
  type        = string
}


variable "haproxy_instance_type" {
  description = "proxy node instance type"
  type        = string
}

variable "amis" {
  type        = map(string)
  description = "ami for master node"
}

variable "master-instance_count" {
  description = "master node count"
  type        = number
}

variable "worker-instance_count" {
  description = "worker node count"
  type        = number
}

variable "proxy-instance-count" {
  description = "proxy node count"
  type        = number
}

variable "etcd-instance_count" {
  description = "number of etcd nodes"
  type        = number
  default     = 3

}

variable "environment" {
  description = "value of the environment tag"
  type        = string
  default     = "dev"
}

variable "etcd_instance_type" {
  description = "instance type for etcd nodes"
  type        = string
  default     = "t3.medium"
}

variable "myip" {
  description = "my ip address to access bastion host"
  type        = string
  default     = ""
}
