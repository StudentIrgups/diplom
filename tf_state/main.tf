resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.sa_id
  description        = "Static access key for object storage"
}

resource "yandex_storage_bucket" "test" {
  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket                = "to-save"
  max_size              = 1024*1024*1024
  
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }
}

resource "yandex_ydb_database_serverless" "diplom-ydb" {
  name      = "diplom-ydb"
  folder_id = var.folder_id
}

resource "yandex_ydb_table" "tfstate-lock" {
  depends_on = [ yandex_ydb_database_serverless.diplom-ydb ]
  connection_string = yandex_ydb_database_serverless.diplom-ydb.ydb_full_endpoint
  path = "tfstate-lock"

  column {
     name = "lockID"
     type = "Utf8"     
  }
  primary_key = ["lockID"]
}



