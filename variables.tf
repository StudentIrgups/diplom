###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "authorized_key" {
  type        = string
  default     = "~/.authorized_key.json"
  description = "authorized key"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "diplom_infrastructure"
  description = "VPC network&subnet"
}

variable "public_cidr0" {
  type = string
  default = "192.168.10.0/24"
  description = "Public CIDR 10"
}
