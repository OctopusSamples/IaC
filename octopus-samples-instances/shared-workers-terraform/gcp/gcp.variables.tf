variable "gcp_project" {
  description = "The GCP Project to create resources in"
  type        = string
  default     = "#{Project.GCP.Project}"
}

variable "gcp_region" {
  description = "The GCP region to create resources in"
  type        = string
  default     = "#{Project.GCP.Region}"
}

variable "gcp_zone" {
  description = "The GCP zone to create resources in"
  type        = string
  default     = "#{Project.GCP.Zone}"
}

variable "instance_count" {
  description = "Number of instances you want"
  type        = number
  default     = "#{Project.GCP.Instance.Count}"
}

variable "instance_name" {
  description = "Name of the instance (will get index appended)"
  type        = string
  default     = "#{Project.GCP.Instance.Name}"
}

variable "instance_size" {
  description = "Size of the machine instance"
  type        = string
  default     = "#{Project.GCP.Instance.Size}"
}

variable "instance_osimage" {
  description = "Name of the Operating System image to use"
  type        = string
  default     = "#{Project.GCP.Instance.OSImage}"
}

variable "database_service_account_name" {
  description = "Name of the service account to access databases"
  type = string
}