# Description
Infra as code managed by Terraform.


# Make this work
- Fill out the values for the project, the region, the CIDR and **the location of the SA JSON file**.
- Execute the following commands:

```bash
terraform init
terraform apply
```

# Find image types and family
```bash
gcloud compute images list --filter "ubuntu"
```