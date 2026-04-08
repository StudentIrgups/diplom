resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  depends_on = [ yandex_iam_service_account.servacc ]
  service_account_id = yandex_iam_service_account.servacc.id
  description        = "Static access key for object storage"
}

resource "yandex_storage_bucket" "to-save-state" {
  depends_on = [ yandex_iam_service_account_static_access_key.sa-static-key ]
  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket                = "to-save-state"
  max_size              = 1024*1024*1024
  
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

resource "local_sensitive_file" "credentials" {
  depends_on = [ yandex_iam_service_account_static_access_key.sa-static-key ]
  filename = pathexpand("~/.${var.credentials}")
  content  = <<EOT
    [default]
      aws_access_key_id = ${yandex_iam_service_account_static_access_key.sa-static-key.access_key}
      aws_secret_access_key = ${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}
  EOT
  file_permission = "0600"
}



