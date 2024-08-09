# create a vpc to launch all the k8s nodes

data "aws_availability_zones" "azs" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.12.0"

  name = var.name
  cidr = var.cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets_cidr_block
  public_subnets  = var.public_subnets_cidr_block

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    project   = "barilon"
  }
}

# master nodes ec2 instances

resource "aws_key_pair" "master" {
  key_name   = "barilon"
  public_key = file("~/.ssh/id_rsa.pub")
}


# This is the security group for the k8s master node.

resource "aws_security_group" "k8s-master" {
  name   = "master-node-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow from anywhere to access k8s api-server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow from any ip within the vpc"
    from_port   = 2379
    to_port     = 2380
    protocol    = "TCP"
    cidr_blocks = [var.cidr]
  }

  ingress {
    description = "Allow from any ip within the vpc"
    from_port   = 10250
    to_port     = 10257
    protocol    = "TCP"
    cidr_blocks = [var.cidr]
  }

  ingress {
    description = "Allow ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.myip
  }

  ingress {
    description     = "allow ingress from haproxy on port 6443"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.ha-proxy.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "k8s-master-sg"
    project = "barilon"
  }
}


# this is the security group for the k8s worker nodes

resource "aws_security_group" "k8s-worker" {
  name   = "worker-node-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow from k8s api-server"
    from_port   = 10250
    to_port     = 10250
    protocol    = "TCP"
    cidr_blocks = [var.cidr]
  }

  ingress {
    description = "Allow from any ip within the vpc"
    from_port   = 10256
    to_port     = 10256
    protocol    = "TCP"
    cidr_blocks = [var.cidr]
  }

  ingress {
    description = "Allow from any ip within the vpc"
    from_port   = 30000
    to_port     = 32767
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.myip
  }

   ingress {
    description = "Allow traffic from ingress server"
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    security_groups = [ aws_security_group.ingress-entry-point.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "k8s-worker-sg"
    project = "barilon"
  }
}

# security group for the ha-proxy server

resource "aws_security_group" "ha-proxy" {
  name   = "ha-proxy-server-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.myip
  }
  ingress {
    description = "Allow from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow from anywhere within the vpc"
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = [var.cidr]
  }
  ingress {
    description = "Allow from anywhere within the vpc"
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "k8s-master-sg"
    project = "barilon"
  }
}

# security group for cluster entry point

resource "aws_security_group" "ingress-entry-point" {
  name   = "ingress-entry-point-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.myip
  }
  ingress {
    description = "Allow from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow within vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = [var.cidr]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name    = "ingress-entry-point-sg"
    project = "barilon"
  }

}

# master-noder-server

resource "aws_instance" "master" {

  instance_type               = var.master_instance_type
  ami                         = lookup(var.amis, var.region)
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.k8s-master.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  count                       = var.master-instance_count

  tags = {
    Name = "k8s-master"
  }

}

# worker-nodes servers

resource "aws_instance" "workers" {

  instance_type               = var.worker_instance_type
  ami                         = lookup(var.amis, var.region)
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.k8s-worker.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  count                       = var.worker-instance_count

  tags = {
    Name = "k8s-worker"
    app  = "barilon"
  }

}

# ha-rpoxy server

resource "aws_instance" "ha-proxy" {
  instance_type               = var.haproxy_instance_type
  ami                         = lookup(var.amis, var.region)
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.ha-proxy.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  count                       = var.proxy-instance-count

  tags = {
    Name = "ha-proxy-server"
    app  = "barilon"
  }
}


resource "aws_instance" "cluster-entry-point" {
  instance_type               = var.haproxy_instance_type
  ami                         = lookup(var.amis, var.region)
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.ingress-entry-point.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true


  tags = {
    Name = "ingress-entry-point"
    app  = "barilon"
  }
}