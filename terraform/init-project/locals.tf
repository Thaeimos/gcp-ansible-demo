locals {
  apis            = ["iam.googleapis.com", "compute.googleapis.com", "storage.googleapis.com", "cloudkms.googleapis.com", "cloudresourcemanager.googleapis.com", "pubsub.googleapis.com"]
  rotation_period = "2592000s" # 30 days
  algorithm       = "GOOGLE_SYMMETRIC_ENCRYPTION"
}