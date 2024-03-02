output "state_bucket" {
  value = google_storage_bucket.default.name
}

output "email" {
  description = "The service account email."
  value       = module.service_accounts.service_account.email
}

output "iam_file" {
  description = "The service account IAM-format filename."
  value       = local_file.myaccountjson.filename
}
