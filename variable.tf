variable "region" {
  default = "us-east-1"
}

variable "private_subnets_cidr_block" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets_cidr_block" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "name" {
  default = "barilon-vpc"
}

variable "cidr" {
  default = "10.0.0.0/16"
}



variable "master_instance_type" {
  default = "t2.medium"
}

variable "amis" {
  type = map(string)
  default = {
    "us-east-1" = "ami-04a81a99f5ec58529"
  }

}

variable "myip" {
  default = ["86.138.63.224/32"]
}

variable "master-instance_count" {
  default = "2"
}

variable "worker-instance_count" {
  default = "3"
}

variable "worker_instance_type" {
  default = "t2.medium"
}

variable "haproxy_instance_type" {
  default = "t2.medium"
}

variable "proxy-instance-count" {
  default = "1"
}