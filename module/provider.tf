terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.61.0"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.31.0"
    # }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.1"
    }
  }
  backend "s3" {
    bucket  = "infrasoc-1234"
    key     = "infra2/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


provider "aws" {
  region = var.region
}

# provider "kubernetes" {
#   config_path = "kubeconfig.yaml"
# }

# provider "helm" {
#   kubernetes {
#     config_path = "kubeconfig.yaml"
#   }
# }