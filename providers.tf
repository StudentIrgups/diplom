terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.80.0"
    }
  }
  required_version = ">=1.8.4"
  
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "to-save-state"
    region = "ru-central1"
    key    = "terraform.tfstate"

    shared_credentials_files = ["~/.credentials"]
    
    use_lockfile = true                 

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = local.auth_key_file 
}