output "network_id" {
    value = yandex_vpc_network.develop.id
}

output "subnet_id" {
  value =  {
    for k in yandex_vpc_subnet.develop: 
      k.name => { id = k.id, zone = k.zone, name = k.name }
  }
}

output "ip_static" {
  value = yandex_vpc_address.public-ip-static.external_ipv4_address[0].address
}