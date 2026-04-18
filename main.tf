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
    #core_fraction = var.vms_resources["bastion"].core_fraction
    core_fraction = 100
  }
  boot_disk {
    initialize_params {      
      image_id = var.nat_image_id
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
    ssh_public_key            = file("~/.ssh/ssh-key-1756817743452.pub")
    ssh_private_key           = tls_private_key.key.private_key_pem

    req_packages              = jsonencode(var.req_packages)
    name_control_node         = local.sorted_list_k8s_nodes[0].name
    sh_kubespray              = filebase64("${abspath(path.module)}/kubespray/kubespray.sh")
    file_extra                = filebase64("${abspath(path.module)}/kubespray/extra.yml")

    tpl_hosts                 = templatefile("${path.module}/hosts.tftpl", {
        k8s-nodes = local.sorted_list_k8s_nodes
    })

    tpl_proxy                 = templatefile("${path.module}/proxy.tftpl", {
        k8s-nodes   = local.sorted_list_k8s_nodes
        gitlab-vm   = yandex_compute_instance.gitlab.network_interface[0].ip_address
        gitlab-port = var.gitlab_external_port
    })
    sh_app                    = templatefile("${path.module}/nginx-app/nginx-app.tftpl", {
      dockerhub_username = var.dockerhub_username
      dockerhub_token    = var.dockerhub_token
    })
    yml_app                   = filebase64("${abspath(path.module)}/nginx-app/nginx-app.yml")
    
    docker_nginx              = templatefile("${path.module}/nginx-app/Dockerfile.tftpl", {
        nginx-index-file = var.nginx_index_file
    })
    sh_prometheus             = filebase64("${abspath(path.module)}/grafana/kube-prometheus.sh")
    yml_grafana_node_port     = filebase64("${abspath(path.module)}/grafana/grafana-node-port.yml")
    authorized_key_diplom     = filebase64("${var.authorized_key}")
    s3_key                    = filebase64("${var.s3_key}")
    
    cloud_id                  = var.cloud_id
    folder_id                 = var.folder_id
    public_ip                 = module.vpc_dev.ip_static    
    terraformrc               = filebase64("${abspath(path.module)}/terraform/.terraformrc") 

    tpl_atlantis              = templatefile("${path.module}/atlantis/atlantis.sh.tpl", {
      ip_bastion                       = module.vpc_dev.ip_static  
      nodeport                         = 32000
      atlantis_github_user             = var.atlantis_github_user
      atlantis_repo_allowlist          = var.atlantis_repo_allowlist
      atlantis_port                    = var.atlantis_port
      s3_bucket_name                   = var.s3_bucket_name
      s3_endpoint                      = var.s3_endpoint
      yc_key_file_path_bastion         = var.yc_key_file_path_bastion
      s3_credentials_file_path_bastion = var.s3_credentials_file_path_bastion     
      ssh_public_key_path_bastion      = var.ssh_public_key_path_bastion
      terraformrc_bastion              = var.terraformrc_bastion
      atlantis_github_token            = var.atlantis_github_token
      atlantis_webhook_secret          = var.atlantis_webhook_secret
      cloud_id                         = var.cloud_id
      folder_id                        = var.folder_id
      dockerhub_token                  = var.dockerhub_token
    })
#    token_gitlab_agent        = var.token_gitlab_agent
#    token_gitlab_runner       = var.token_gitlab_runner
  }
}

locals {
  private_subnets = { for k, v in module.vpc_dev.subnet_id : k => v if v.name != "public" }
  subnet_count = length(local.private_subnets)
  need_extra_vm = local.subnet_count > 0 && local.subnet_count % 2 == 0
  extra_subnet_key = local.need_extra_vm ? keys(local.private_subnets)[0] : null

  vm_subnets = merge(
    local.private_subnets,
    local.need_extra_vm ? {
      "extra-vm-${local.extra_subnet_key}" = local.private_subnets[local.extra_subnet_key]
    } : {}
  )
  
  vms_per_subnet = {
    for subnet_key in distinct([for k, v in local.vm_subnets : v.id]) :
    subnet_key => length([for k, v in local.vm_subnets : k if v.id == subnet_key])
  }

  distribution_message = join("\n", [
    "VM distribution per subnet:",
    join("\n", [for subnet, count in local.vms_per_subnet : "  - ${subnet}: ${count} VM(s)"])
  ])
}

# Информационный вывод
resource "terraform_data" "deployment_info" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "========================================"
      echo "Kubernetes Control Plane Deployment"
      echo "========================================"
      echo "Subnets available: ${local.subnet_count}"
      echo "VMs to create: ${length(local.vm_subnets)}"
      %{if local.need_extra_vm}
      echo "Added extra VM to ensure odd number for etcd quorum"
      %{endif}
      echo ""
      echo "${local.distribution_message}"
      echo "========================================"
    EOT
  }
}

resource "yandex_compute_instance" "k8s" {
  for_each = local.vm_subnets
  
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

resource "yandex_compute_instance" "gitlab" {    
  name                      = "gitlab"
  hostname                  = "gitlab"
  zone                      = var.default_zone
  platform_id               = var.vm_platform_id

  allow_stopping_for_update = true 

  resources { 
    cores         = var.gitlab_machine_cores
    memory        = var.gitlab_machine_memory
    core_fraction = var.gitlab_machine_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id  = data.yandex_compute_image.ubuntu.image_id
      size      = var.gitlab_machine_disk_size
      type      = var.gitlab_machine_disk_type
    }
  }

  network_interface {
    subnet_id =  [ for k, v in module.vpc_dev.subnet_id : v if v.name != "public" && v.zone == var.default_zone ][0]["id"]
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

resource "local_file" "gitlab_vars" {
  content = yamlencode({
    gitlab_hostname        = "gitlab.local"
    install_gitlab_runner  = true
    # GitLab
    gitlab_url             = yandex_compute_instance.gitlab.network_interface[0].ip_address
    gitlab_external_url    = "${yandex_compute_instance.bastion.network_interface[0].nat_ip_address}:${var.gitlab_external_port}"
    # Project
    project_name           = var.nginx_index_file_project_name
    project_name_deploy    = "deploy-app"
    container_name         = "app"
    project_visibility     = "public"
    setup_cicd             = true
    # Kubernetes
    kube_namespace         = "app"
    kubeconfig_path        = "~/.kube/config"
    # GitHub
    github_owner           = var.atlantis_github_user
    github_repo            = var.nginx_index_file_project_name
  })
  filename = "${path.module}/gitlab/vars.yml"
}

resource "local_file" "gitlab_vault" {
  content = yamlencode({
    gitlab_admin_password = "tdfsdfsdfs=xxxxxxxxxxxxxxxxxxx"
    # GitLab API
    gitlab_admin_token    = "glpat-xxxxxxxxxxxxxxxxxxt2r"
    # Docker Hub
    dockerhub_username    = var.dockerhub_username
    dockerhub_token       = var.dockerhub_token
    # GitHub
    github_token          = var.atlantis_github_token
  })
  filename = "${path.module}/gitlab/vault_plain.yml"
}

resource "local_file" "gitlab_inventory" {
  content = templatefile("${path.module}/gitlab/templates/hosts.yml.tpl", {
    gitlab_ip = yandex_compute_instance.gitlab.network_interface[0].ip_address
  })
  filename = "${path.module}/gitlab/hosts.yml"
}

resource "random_password" "vault_pass" {
  length  = 32
  special = false
}

resource "null_resource" "copy_ansible_files" {
  depends_on = [ yandex_compute_instance.bastion,
                 yandex_compute_instance.gitlab ]
  connection {
    host        = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
    user        = "ubuntu"
    private_key = file("~/.ssh/ssh-key-1756817743452")
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/ansible-gitlab"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/${var.atlantis_github_user}/ansible-gitlab.git /tmp/ansible-gitlab"
    ]
  }

  provisioner "file" {
    source      = local_file.gitlab_vars.filename
    destination = "/tmp/ansible-gitlab/inventory/production/group_vars/all/vars.yml"
  }

  provisioner "file" {
    source      = local_file.gitlab_vault.filename
    destination = "/tmp/ansible-gitlab/inventory/production/group_vars/all/vault_plain.yml"
  }

  provisioner "file" {
    content     = random_password.vault_pass.result
    destination = "/tmp/ansible-gitlab/.vault_pass"
  }

  # Зашифровать vault на бастионе
  provisioner "remote-exec" {
    inline = [
      "while ! command -v ansible-playbook >/dev/null 2>&1; do sleep 5; done",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu",
      "while [ ! -f /home/ubuntu/.ssh/id_rsa ]; do echo 'Waiting for SSH key...'; sleep 5; done",
      "chmod 600 /home/ubuntu/.ssh/id_rsa",
      "cd /tmp/ansible-gitlab",
      "ansible-vault encrypt inventory/production/group_vars/all/vault_plain.yml --vault-password-file .vault_pass --output inventory/production/group_vars/all/vault.yml",
      "rm inventory/production/group_vars/all/vault_plain.yml"
    ]
  }

  provisioner "file" {
    source      = local_file.gitlab_inventory.filename
    destination = "/tmp/ansible-gitlab/inventory/production/hosts.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp/ansible-gitlab",
      "while ! nc -z ${yandex_compute_instance.gitlab.network_interface[0].ip_address} 22; do echo 'Waiting for GitLab VM...'; sleep 5; done",
      "ansible-playbook -i inventory/production/hosts.yml deploy-gitlab-vm.yml --vault-password-file .vault_pass"
    ]
  }
}

/* resource "null_resource" "fetch_token" {
  provisioner "local-exec" {
    command = "ssh -i ~/.ssh/ssh-key-1756817743452 -o StrictHostKeyChecking=no ubuntu@${yandex_compute_instance.bastion.network_interface[0].nat_ip_address} 'ssh ubuntu@${yandex_compute_instance.gitlab.network_interface[0].ip_address} \"cat /tmp/gitlab_api_token.txt\"' > ${path.module}/gitlab/gitlab_token.txt"
  }
}

data "http" "github_public_key" {
  url = "https://api.github.com/repos/${var.atlantis_github_user}/${var.nginx_index_file_project_name}/actions/secrets/public-key"
  request_headers = {
    Authorization = "token ${var.atlantis_github_token}"
    Accept        = "application/vnd.github.v3+json"
  }
} */