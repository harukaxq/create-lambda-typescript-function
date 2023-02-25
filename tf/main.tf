terraform {
  required_version = "~> 1.3.9"
  required_providers {
    sentry = {
      source = "jianyuan/sentry"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.24.0"
    }
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


module "docker" {
  source            = "./lambda/"
  type              = "docker"
  sentry_base_url   = var.sentry_base_url
  sentry_auth_token = var.sentry_auth_token
  name              = "test-a"
  build_path        = "./../template/"
}
module "file" {
  source            = "./lambda/"
  type              = "file"
  name              = "test-file"
  sentry_base_url   = var.sentry_base_url
  sentry_auth_token = var.sentry_auth_token
  build_path        = "./../template/"
}