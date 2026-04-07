module "tf_servacc" {
  source    = "./tf_servacc"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

module "tf_state" {
  source    = "./tf_state"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  sa_id     = module.tf_servacc.sa-id
}

resource "yandex_compute_disk" "name" {
  name = "test"
  block_size =  65536
}