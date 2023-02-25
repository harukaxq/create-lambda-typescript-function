terraform {
  required_version = "~> 1.3.9"
  required_providers {
    sentry = {
      source = "jianyuan/sentry"
    }
    aws = {
      source  = "hashicorp/aws"
    }
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
  backend "s3" {
    bucket  = "lambda-pkg-tf-state"
    region  = "us-east-1"
    key     = "local.tfstate"
    profile = "cibo"
  }

}
provider "aws" {
  profile = "cibo"
  region  = "us-east-1"
}
provider "sentry" {
  base_url = "${var.sentry_base_url}/api"
  token    = var.sentry_auth_token
}
variable "sentry_auth_token" {
  type = string
}
variable "sentry_base_url" {
  default = "https://sentry.io"
}

data "aws_region" "current" {}
data "aws_caller_identity" "this" {}
data "aws_ecr_authorization_token" "token" {}
provider "docker" {
  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

module "docker" {
  source            = "./lambda/"
  type              = "docker"
  sentry_base_url   = var.sentry_base_url
  sentry_auth_token = var.sentry_auth_token
  name              = "docker-a"
  build_path        = "./../template/"
}
module "file" {
  source            = "./lambda/"
  type              = "fise"
  name              = "file-a"
  sentry_base_url   = var.sentry_base_url
  sentry_auth_token = var.sentry_auth_token
  build_path        = "./../template/"
}
module "file2" {
  source            = "./lambda/"
  type              = "file"
  sentry_base_url   = var.sentry_base_url
  sentry_auth_token = var.sentry_auth_token
  create_lambda_function_url = true
  name              = "file-b"
  build_path        = "./../template/"
}
output "url" {
  value = module.file2.lambda_function_url
}