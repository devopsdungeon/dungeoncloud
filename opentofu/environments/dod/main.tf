terraform {
  required_version = ">= 1.5.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
  backend "s3" {
    bucket = "terraform-dod"
    endpoints = {
      s3 = "http://10.123.1.19:9000"
    }
    key = "dod.tfstate"

    access_key = var.s3_access_key
    secret_key = var.s3_secret_key

    region                      = "main"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

provider "kubectl" {
  config_path    = var.kube_config
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config
    config_context = var.kube_context
  }
}

module "kube-bootstrap" {
  source   = "../../modules/kube-bootstrap"
  le_email = var.le_email
}
