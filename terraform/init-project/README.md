# Description

How to initialize the Terraform project and have a bucket for remote state.


# Make this work
- Activate billing in GCP.
- Create project.
- Assign the roles needed for the [service account](./main.tf#L19).
- Execute the following commands:

```bash
terraform init
terraform apply
```

# Search for roles for the service account
```bash
gcloud iam roles list --filter "cloudkms" # KMS related
gcloud iam roles list --filter "Full control" # All admins roles
```