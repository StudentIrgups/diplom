###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "vpc_name" {
  type        = string
  description = "VPC network"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "mass_zones" {
  type = list(object({
    vpc_name       = string
    subnet_name    = string
    cidr           = string
    route_table_id = string
  }))
  default = [ { 
        vpc_name       = "ru-central1-a", 
        subnet_name    = "public", 
        cidr           = "192.168.1.0/24", 
        route_table_id = "" 
    },
    { 
        vpc_name       = "ru-central1-a", 
        subnet_name    = "private0", 
        cidr           = "192.168.2.0/24", 
        route_table_id = "" 
    },
    { 
        vpc_name       = "ru-central1-b", 
        subnet_name    = "private1", 
        cidr           = "192.168.3.0/24", 
        route_table_id = "" 
    },
    { 
        vpc_name       = "ru-central1-d", 
        subnet_name    = "private2", 
        cidr           = "192.168.4.0/24", 
        route_table_id = "" 
    } ]
}

variable "authorized_key" {
  type        = string
  default     = "~/.auth_key_diplom.json"
  description = "authorized key"
}

variable "bastion_settings" {
  description = "VM NAT"
  type = object({
    hostname    = string
    zone        = string
    ipaddress   = string
    nat         = bool
  })
}
