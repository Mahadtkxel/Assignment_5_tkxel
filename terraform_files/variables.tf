variable "azure_credentials" {
  description = "Azure credentials in JSON format"
  type        = string
}



variable "environment_name" {
  type = string
}

variable "rg_name" {
  type = string
  description = "resource group name"
}

variable "adm_user" {
  type = string
  description = "user name"
  sensitive = true
}



variable "adm_pass" {
    type = string
    description = "mahad user login pass"
    sensitive = true
}

variable "keydata" {
  type = string
  sensitive = true
  description = "public key file location"
}