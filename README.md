# gcp-ansible-demo

# Features
- [Docker image](../utilities/docker-image-bins/) with necessary tooling.
- Folder with [init resources for remote backend.](./init-project/)
- Use ["for_each" instead of count.](./main.tf#L1)
- [Dynamic subnets.](./main.tf#L21-L24)
- Pinned versions [for providers.](./versions.tf#L2)
- Dynamic output for [ssh connection.](./outputs.tf#L3)
- [Creation of SSH key](./main.tf#L40) for connection.
- [Whitelist only my IP only](./main.tf#L47) (Dynamically as well) for SSH connectivity.
- Install "cloud-init" software [if image doesn't have it.](./main.tf#L93)
- Configure instances using ["cloud-init" software with YAML.](./main.tf#L97)
- Service account [setup](./terraform/init-project/main.tf#L16).