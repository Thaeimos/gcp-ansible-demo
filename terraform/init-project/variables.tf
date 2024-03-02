variable "project" {
  description = "Project that we want to initialize."
  type        = string
}

variable "region" {
  description = "Region for this project."
  type        = string
}

variable "sa_name" {
  type        = string
  description = "Name of the service account."
  default     = ""
}

variable "sa_prefix" {
  type        = string
  description = "Prefix applied to service account names."
  default     = ""
}
