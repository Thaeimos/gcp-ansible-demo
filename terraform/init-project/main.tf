resource "google_project_service" "project" {
  for_each = toset(local.apis)
  project  = var.project
  service  = each.key
}

data "google_project" "project" {}
data "google_storage_project_service_account" "gcs_account" {}

module "service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.0"

  project_id    = var.project
  prefix        = var.sa_prefix
  names         = [var.sa_name]
  generate_keys = true

  project_roles = [
    "${var.project}=>roles/editor",
    "${var.project}=>roles/storage.objectViewer",
  ]

  display_name = "Ansible SA"
  description  = "Ansible SA Description"
}

resource "local_file" "myaccountjson" {
  content  = module.service_accounts.keys[var.sa_name]
  filename = "${split("@", module.service_accounts.service_account.email)[0]}-key.json.secrets"
}

# Remote state bucket creation - Delay 60 secs
resource "time_sleep" "wait" {
  depends_on = [google_project_service.project]

  create_duration = "60s"
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_kms_key_ring" "keyring" {
  name     = lower("kms-key-${random_id.bucket_prefix.hex}")
  location = var.region

  depends_on = [
    google_project_service.project
  ]
}

resource "google_kms_crypto_key" "key" {
  name            = google_kms_key_ring.keyring.name
  key_ring        = google_kms_key_ring.keyring.id
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

  members = [
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