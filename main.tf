module "vpc_dev" {
  source           = "./vpc_dev"
  vpc_name         = "diplom"
  cloud_id         = var.cloud_id
  folder_id        = var.folder_id
  authorized_key   = local.auth_key_file
  bastion_settings = var.bastion_settings
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_ubuntu_version
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "yandex_compute_instance" "bastion" {  
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
    user-data          = data.template_file.cloudinit-bastion.rendered
    serial-port-enable = 1
  }
}

data "template_file" "cloudinit-bastion" {
  template = file("./cloud-init-bastion.yml")

  vars = {
    ssh_public_key  = file("~/.ssh/ssh-key-1756817743452.pub")
    ssh_private_key = tls_private_key.key.private_key_pem

    req_packages              = jsonencode(var.req_packages)
    name_control_node         = local.sorted_list_k8s_nodes[0].name
    file_kubespray            = filebase64("${abspath(path.module)}/kubespray/kubespray.sh")
    file_extra                = filebase64("${abspath(path.module)}/kubespray/extra.yml")

    file_ansible_hosts        = templatefile("${path.module}/hosts.tftpl", {
        k8s-nodes = local.sorted_list_k8s_nodes
    })
  }
}

resource "yandex_compute_instance" "k8s" {
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
    subnet_id = each.value.id
    nat       = false
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    serial-port-enable = 1
    user-data          = data.template_file.cloud-init.rendered
  }
}

data "template_file" "cloud-init" {
  template = file("./cloud-init.yml")
  vars = {
    ssh_public_key_local   = local.ssh-keys
    ssh_public_key_bastion = tls_private_key.key.public_key_openssh
  }
}

locals {
  sorted_list_k8s_nodes    = flatten([
  for k, v in yandex_compute_instance.k8s : {
      name              = v.name
      network_public    = v.network_interface[0]["nat_ip_address"]
      network_private   = v.network_interface[0]["ip_address"]
    }
  ])
}

resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl",
    {      
      k8s-nodes   = local.sorted_list_k8s_nodes
    }
  )
  filename          = "${abspath(path.module)}/hosts.ini"
  file_permission   = "0644"
}