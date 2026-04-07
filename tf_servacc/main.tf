resource "yandex_iam_service_account" "servacc" {
  name = "sa-diplom"
}

resource "yandex_resourcemanager_folder_iam_member" "resource-manager" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.servacc.id}"
}

