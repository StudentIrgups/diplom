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
  default     = "~/.yc/auth_key_diplom.json"
  description = "Authorized key"
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
    default     = [ "net-tools", "nginx", "ansible", "git", "python3-venv", "libssl-dev", "liblzma-dev", "python3-tk", "libsqlite3-dev", "libreadline-dev", "libffi-dev", "libncurses5-dev", "libncursesw5-dev", "libbz2-dev", "build-essential", "gcc", "python3-pip", "docker.io" ]
    description = "Packages by default"
}

variable "nat_image_id" {
  type        = string
  default     = "fd8g9ua2q01c2qvigpmb" # ubuntu 22.04
  description = "Image for NAT (bastion)"
}

variable "nginx_index_file" {
  type        = string
  default     = "https://github.com/StudentIrgups/nginx_index_file.git"
  description = "Index.html for app"
}

variable "dockerhub_username" {
  type        = string
  default     = "alexbeznosov"
  description = "Username for DockerHub"
}

variable "dockerhub_token" {
  type        = string  
  description = "Token for DockerHub"
  default     = ""
  sensitive   = true
}

variable "s3_key" {
  type        = string
  default     = "~/.aws/credentials"
  description = "S3 key"
  sensitive   = true  
}

#atlantis
variable "github_token" {
  type        = string
  description = "Token to connect to github"
  sensitive   = true
}

variable "db_host" {
  type        = string
  default     = "localhost"
  description = "DB atlantis host"
}

variable "db_user" {
  type        = string
  default     = "mysql"
  description = "DB antlantis user"
}

variable "db_password" {
  type        = string
  default     = "mysql"
  description = "DB antlantis password"
}

variable "db_name" {
  type        = string
  default     = "mysql"
  description = "DB antlantis name"
}

variable "mysql_root_password" {
  type        = string
  default     = "mysql"
  description = "DB antlantis root password"
}

variable "repos" {
  type        = string
  default     = "github.com/StudentIrgups/diplom"
  description = "Repo to monitor"
}

variable "github_username" {
  type        = string
  default     = "StudentIrgups"
  description = "GITHUB username"
}

# Kubernetes
variable "k8s_namespace" {
  default = "atlantis"
}

# Atlantis
variable "atlantis_version" {
  default = "v0.27.2"
}

variable "atlantis_replicas" {
  default = 1
}

variable "atlantis_port" {
  default = 4141
}

variable "atlantis_memory_request" {
  default = "512Mi"
}

variable "atlantis_memory_limit" {
  default = "2Gi"
}

variable "atlantis_cpu_request" {
  default = "250m"
}

variable "atlantis_cpu_limit" {
  default = "1000m"
}

# GitHub
variable "github_user" {
  description = "GitHub username"
}

variable "webhook_secret" {
  description = "Webhook secret"
  sensitive   = true
}

variable "repo_allowlist" {
  default = "github.com/myorg/*"
}