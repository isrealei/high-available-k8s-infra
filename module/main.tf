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
# This security group allows the master node to communicate with the worker nodes and also allows ingress from the k8s api-server on port 6443
# link https://kubernetes.io/docs/reference/networking/ports-and-protocols/#api
resource "aws_security_group" "kube-master" {
  name   = "master-node-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow from anywhere to access k8s api-server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere
  }

  ingress {
    description = "Allow from any ip within the vpc"
    from_port   = 2379
    to_port     = 2380
    protocol    = "TCP"
    cidr_blocks = [var.cidr] # Allow only from within the vpc
  }

  ingress {
    description = "Allow from any ip within the vpc"
    from_port   = 10250
    to_port     = 10257
    protocol    = "TCP"
    cidr_blocks = [var.cidr] # Allow only from within the vpc
  }

  ingress {
    description = "Allow ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.myip] # Allow ssh access from my IP
  }

  ingress {
    description     = "allow ingress from worker nodes on port 10250"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.k8s-worker.id] # Allow worker nodes to communicate with master
  }

  ingress {
    description     = "allow ingress from haproxy on port 6443"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.ha-proxy.id] # Allow haproxy to communicate with master
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "kube-master-${var.environment}-sg"
    Env     = var.environment
    project = var.name
  }
}


# this is the security group for the k8s worker nodes
# this security group allows the worker nodes to communicate with the master node and also allows ingress from the k8s api-server on port 10250 and 10256
# link https://kubernetes.io/docs/reference/networking/ports-and-protocols/#node
resource "aws_security_group" "k8s-worker" {
  name   = "worker-node-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "This allows ingress from the master node on port 10250"
    from_port   = 10250
    to_port     = 10250
    protocol    = "TCP"
    cidr_blocks = [var.cidr] # Allow only from within the vpc
  }

  ingress {
    description = "This allows ingress from the master node on port 10256"
    from_port   = 10256
    to_port     = 10256
    protocol    = "TCP"
    cidr_blocks = [var.cidr] # Allow only from within the vpc
  }

  ingress {
    description = "This is for node port services and load balancers TCP"
    from_port   = 30000
    to_port     = 32767
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere
  }

  ingress {
    description = "This is for node port services and load balancers UDP"
    from_port   = 30000
    to_port     = 32767
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere
  }


  ingress {
    description = "Allow ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.myip] # Allow ssh access from my IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "kube-worker-${var.environment}-sg"
    Env     = var.environment
    project = var.name
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
    cidr_blocks = [var.myip]
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
    Name    = "ha-proxy-sg"
    Env     = var.environment
    project = var.name
  }
}

# security group for etcd
resource "aws_security_group" "etcd-sg" {
  name   = "etcd-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow from anywhere within the vpc"
    from_port   = 2379
    to_port     = 2380
    protocol    = "TCP"
    cidr_blocks = [var.cidr] # Allow only from within the vpc
  }

  ingress {
    description = "Allow ssh from my ip"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.myip] # Allow ssh access from my IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# master-noder-server
resource "aws_instance" "master" {

  instance_type               = var.master_instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.kube-master.id]
  subnet_id                   = module.vpc.public_subnets[count.index]
  associate_public_ip_address = true
  count                       = var.master-instance_count

  tags = {
    Name    = "kube-master-${count.index}"
    Env     = var.environment
    project = var.name
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# worker-nodes servers
resource "aws_instance" "workers" {

  instance_type               = var.worker_instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.k8s-worker.id]
  subnet_id                   = module.vpc.public_subnets[count.index]
  associate_public_ip_address = true
  count                       = var.worker-instance_count

  tags = {
    Name    = "kube-worker-${count.index}"
    Env     = var.environment
    project = var.name
  }

}

# ha-rpoxy server
resource "aws_instance" "load-balancer" {
  instance_type               = var.haproxy_instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.ha-proxy.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Name    = "load-balancer"
    Env     = var.environment
    project = var.name
  }
}

# etcd nodes 
resource "aws_instance" "etcd" {
  instance_type               = var.etcd_instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.master.key_name
  vpc_security_group_ids      = [aws_security_group.etcd-sg.id]
  subnet_id                   = module.vpc.public_subnets[count.index]
  associate_public_ip_address = false
  count                       = var.etcd-instance_count

  tags = {
    Name    = "etcd-node-${count.index}"
    Env     = var.environment
    project = var.name
  }
}


