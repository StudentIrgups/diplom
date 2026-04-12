terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">=0.80.0"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "terraform_sa" {
  name        = "terraform-sa"
  description = "Service account for Terraform"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
}

resource "yandex_iam_service_account_key" "sa_auth_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
}

# Сохраняем ключи локально
resource "local_file" "sa_key_file" {
  content = jsonencode({
    id                 = yandex_iam_service_account_key.sa_auth_key.id
    service_account_id = yandex_iam_service_account_key.sa_auth_key.service_account_id
    private_key        = yandex_iam_service_account_key.sa_auth_key.private_key
  })
  filename = "~/.sa-key.json"
}

resource "local_file" "sa_access_key_file" {
  content = jsonencode({
    access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key
  })
  filename = "~/.sa-access-key.json"
}

output "service_account_id" {
  value = yandex_iam_service_account.terraform_sa.id
}