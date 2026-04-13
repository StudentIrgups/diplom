###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "authorized_key_diplom" {
  type        = string
  default     = "~/.yc/auth_key_diplom.json"
  description = "authorized key"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "credentials" {
  type    = string
  default = "credentials"
  description = "Credentials to access to s3"
}