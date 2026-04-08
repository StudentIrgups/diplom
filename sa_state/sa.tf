resource "yandex_iam_service_account" "servacc" {
  name = "sa-diplom"
}

resource "yandex_resourcemanager_folder_iam_member" "resource-manager" {
  depends_on = [ yandex_iam_service_account.servacc ]
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.servacc.id}"
}

resource "yandex_iam_service_account_key" "sa-auth-key" {
  service_account_id = yandex_iam_service_account.servacc.id
  key_algorithm      = "RSA_2048"
}

resource "local_sensitive_file" "key_json" {
  filename = pathexpand("${var.authorized_key_diplom}")
  content = jsonencode({
    "id"                 = yandex_iam_service_account_key.sa-auth-key.id
    "service_account_id" = yandex_iam_service_account_key.sa-auth-key.service_account_id
    "created_at"         = yandex_iam_service_account_key.sa-auth-key.created_at
    "key_algorithm"      = yandex_iam_service_account_key.sa-auth-key.key_algorithm
    "public_key"         = yandex_iam_service_account_key.sa-auth-key.public_key
    "private_key"        = yandex_iam_service_account_key.sa-auth-key.private_key
  })
  file_permission = "0600"
}