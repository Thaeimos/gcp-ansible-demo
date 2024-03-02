variable "project" {
  description = "Project that we want to initialize."
  type        = string
}

variable "region" {
  description = "Region for this project."
  type        = string
}

variable "subnet_cidr" {
  description = "Network CIDR for the VMs to be deployed to."
  type        = string
}

variable "gcp_auth_file" {
  description = "IAM JSON file of the service account."
  type        = string
}

variable "vm_type" {
  description = "The type of machine to be used on compute engine."
  type        = string
  default = "n1-standard-1"
}
