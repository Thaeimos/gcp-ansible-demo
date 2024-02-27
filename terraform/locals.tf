locals {
    apis            = ["iam.googleapis.com", "compute.googleapis.com", "storage.googleapis.com", "cloudkms.googleapis.com"]
    rotation_period = "2592000s" # 30 days
    algorithm       = "GOOGLE_SYMMETRIC_ENCRYPTION"

    tags = {
        managed-by = "terraform"
        project    = var.project 
    }
}