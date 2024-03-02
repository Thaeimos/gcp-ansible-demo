terraform {
  required_version = ">= 1.1.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.18.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
  }
}

provider "google" {
  credentials = file(var.gcp_auth_file)
  project = var.project
  region  = var.region
}