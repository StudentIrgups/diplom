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
  default     = "~/.authorized_key_diplom.json"
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

variable "bastion_settings" {
  description = "VM NAT"
  type = object({
    hostname    = string
    zone        = string
    ipaddress   = string
    nat         = bool
  })
  default = {
    hostname        = "bastion"
    zone            = "ru-central1-a"
    ipaddress       = "192.168.1.111"
    nat             = true
  }
}

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
    type          = string
  }))
  default = {
    "bastion" = {
      cores         = 2
      memory        = 4
      core_fraction = 20
      disk_size     = 20
      type          = "network-hdd"
    },
  }
}

variable "vm_ubuntu_version" {
  type        = string
  default     = "ubuntu-2204-lts"
  description = "Distr"
}

variable "vm_platform_id" {
  type        = string
  default     = "standard-v3"
  description = "Platform id"
}

variable "req_packages" {
    type        = list(string)
    default     = [ "vim", "htop", "tmux", "net-tools", "nginx", "ansible", "git", "python3-venv", "libssl-dev", "liblzma-dev", "python3-tk", "libsqlite3-dev", "libreadline-dev", "libffi-dev", "libncurses5-dev", "libncursesw5-dev", "libbz2-dev", "build-essential", "gcc", "python3-pip", "docker.io" ]
    description = "Packages by default"
}

variable "nat_image_id" {
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
  description = "Image for NAT (bastion)"
}