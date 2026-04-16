###cloud vars
variable "cloud_id" {
  type        = string
  default     = ""
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = ""
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
      core_fraction = 50
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
  sensitive   = true
}

variable "s3_key" {
  type        = string
  default     = "~/.aws/credentials"
  description = "S3 key"
  sensitive   = true  
}

variable "atlantis_github_user" {
  type        = string
  default     = ""
  description = "GITNUB username"
}

variable "atlantis_repo_allowlist" {
  type        = string
  default     = ""
  description = "Repo to monitor"
}

variable "atlantis_port" {
  type        = string
  default     = "83"
  description = "External nginx(proxy) port"
}

variable "s3_bucket_name" {
  type        = string 
  default     = "to-save-state"
  description = "Bucket to lock and keep state"
}
      
variable "s3_endpoint" {
  type        = string 
  default     = "https://storage.yandexcloud.net"
  description = "S3 endpoint"
}

variable "yc_key_file_path_bastion" {
  type        = string
  default     = "/home/ubuntu/authorized-key-diplom.json"
  description = "Location of sa auth file on bastion"
}
      
variable "s3_credentials_file_path_bastion" {
  type        = string
  default     = "/home/ubuntu/credentials"
  description = "Location s3 credentials on bastion"
}
      
variable "ssh_public_key_path_bastion" {
  type        = string
  default     = "/home/ubuntu/id_rsa.pub"
  description = "Location SSH pub key on bastion"
}
      
variable "terraformrc_bastion" {
  type = string
  default = "/home/ubuntu/.terraformrc"
  description = "Location of terraformrc file on bastion"
}
      
variable "atlantis_github_token" {
  type        = string
  description = "GITHUB token"  
  sensitive   = true
}

variable "atlantis_webhook_secret" {
  type        = string
  description = "GITHUB webhook secret"  
  sensitive   = true
}

variable "token_gitlab_runner" {
  type        = string 
  default     = ""
  description = "Token for CI"
}

variable "token_gitlab_agent" {
  type        = string
  default     = ""
  description = "Token gitlab agent"
}

variable "gitlab_machine_disk_size" {
  type        = number
  default     = 30
  description = "Disk size of gitlab machine"
}

variable "gitlab_machine_disk_type" {
  type        = string
  default     = "network-ssd"
  description = "Disk type of gitlab machine"
}

variable "gitlab_machine_cores" {
  type        = number
  default     = 4
  description = "CPU cores of gitlab machine"
}

variable "gitlab_machine_memory" {
  type        = number
  default     = 6
  description = "RAM of gitlab machine"
}

variable "gitlab_machine_core_fraction" {
  type        = number
  default     = 50
  description = "Core fraction of gitlab machine"
}