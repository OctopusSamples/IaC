variable "octopus_address" {
    type = string
}

variable "octopus_api_key" {
    type = string
}

variable "octopus_space_id" {
    type = string
}

variable "octopus_github_password" {
    type = string
    sensitive = true
}

variable "octopus_feedz_password" {
    type = string
    sensitive = true
}

variable "octopus_feedz_username" {
    type = string
}