module "vpc_dev" {
  source         = "./vpc_dev"
  vpc_name       = "diplom"
  cloud_id       = var.cloud_id
  folder_id      = var.folder_id
  authorized_key = local.auth_key_file
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_ubuntu_version
}

resource "yandex_compute_instance" "web" {  
  name                      = var.bastion_settings.hostname
  platform_id               = var.vm_platform_id
  allow_stopping_for_update = true

  resources { 
    cores         = var.vms_resources["bastion"].cores
    memory        = var.vms_resources["bastion"].memory
    core_fraction = var.vms_resources["bastion"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vms_resources["bastion"].disk_size
      type     = var.vms_resources["bastion"].type
    }
  }
  scheduling_policy {
    preemptible = true    
  }
  network_interface {
    subnet_id      = module.vpc_dev.subnet_id["public"].id
    ip_address     = var.bastion_settings.ipaddress
    nat            = var.bastion_settings.nat
    nat_ip_address = module.vpc_dev.ip_static
  }
  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_public_key = file("~/.ssh/ssh-key-1756817743452.pub")
  }
}

resource "yandex_compute_instance" "master-node" {
  for_each = { for k, v in module.vpc_dev.subnet_id : k => v if v.name != "public" }

  name                  = each.key
  hostname              = each.key
  zone                  = each.value.zone
  platform_id           = var.vm_platform_id

  allow_stopping_for_update = true 

  resources { 
    cores         = var.vms_resources["bastion"].cores
    memory        = var.vms_resources["bastion"].memory
    core_fraction = var.vms_resources["bastion"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id  = data.yandex_compute_image.ubuntu.image_id
      size     = var.vms_resources["bastion"].disk_size
      type     = var.vms_resources["bastion"].type
    }
  }

  network_interface {
    subnet_id               = each.value.id
    nat                     = false
  }

  # Прерываемая машина
  scheduling_policy {
    preemptible = true
  }

}