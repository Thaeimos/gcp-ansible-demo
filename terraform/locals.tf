locals {
    apis            = ["compute.googleapis.com"]
    rotation_period = "2592000s" # 30 days
    algorithm       = "GOOGLE_SYMMETRIC_ENCRYPTION"

    ssh_file_name = "./ssh-private-key.secrets"

    tags = {
        managed-by = "terraform"
        project    = var.project 
    }
}