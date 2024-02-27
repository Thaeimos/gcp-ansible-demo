locals {
    apis            = ["iam.googleapis.com", "compute.googleapis.com", "storage.googleapis.com", "cloudkms.googleapis.com"]
    rotation_period = "2592000s" # 30 days
    algorithm       = "GOOGLE_SYMMETRIC_ENCRYPTION"
}

resource "google_project_service" "project" {
    for_each = toset(local.apis)
    project = var.project
    service = each.key
}

data "google_project" "project" {}
data "google_storage_project_service_account" "gcs_account" {}

# Remote state bucket creation
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_kms_key_ring" "keyring" {
  name = lower("kms-key-${random_id.bucket_prefix.hex}")
  location = var.region

  depends_on = [ 
    google_project_service.project 
  ]
}

resource "google_kms_crypto_key" "key" {
  name = google_kms_key_ring.keyring.name
  key_ring = google_kms_key_ring.keyring.id
  rotation_period = local.rotation_period

  version_template {
    algorithm = local.algorithm
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {

  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members       = [
     "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
}

resource "google_storage_bucket" "default" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "EUROPE-WEST1"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.key.id
  }
  depends_on = [
    google_kms_crypto_key_iam_binding.crypto_key
  ]
}