variable "octopus_address" {
    type = string
}

variable "octopus_api_key" {
    type = string
}

variable "octopus_space_name" {
    type = string
}

variable "octopus_github_password" {
    type = string
    sensitive = true
}

variable "octopus_github_username" {
    type = string
}