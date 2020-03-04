variable "stor_account_name" {
  default = "ocp4labpvstorage1"
}

variable "rg_name" {
  default = "ocp4lab-mbtr9-rg"
}

variable "location" {
  default = "canadacentral"
}

variable "account_tier" {
  default = "Standard"
}

variable "replication_teir" {
  default = "GRS"
}

variable "https_traffic" {
  default = "true"
}

variable "tag" {
  default = "ocp4lab"
}