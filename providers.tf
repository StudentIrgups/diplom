terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.80.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = file(var.authorized_key)  
}

provider "aws" {
  alias  = "ydb"
  region = "ru-central1"

  endpoints  {
    #dynamodb = yandex_ydb_database_serverless.diplom-ydb.ydb_full_endpoint
    dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1ggcn8va1l6908f7dkp/etn420sda6a4d4rflp04"
  }

  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true 
  skip_metadata_api_check     = true

}