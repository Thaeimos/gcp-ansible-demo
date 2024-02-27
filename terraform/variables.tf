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
