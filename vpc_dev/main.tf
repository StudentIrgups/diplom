resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-table-private"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.bastion_settings.ipaddress
  }
}

resource "yandex_vpc_subnet" "develop" {
  for_each =  { for zone in var.mass_zones : zone.subnet_name => zone }
  name           = each.value.subnet_name
  zone           = each.value.vpc_name
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = [ each.value.cidr ]
  route_table_id = each.value.subnet_name != "public" ? each.value.route_table_id : null
}

resource "yandex_vpc_address" "public-ip-static" {
  name                = "ip-static-public"
  #deletion_protection = true
  external_ipv4_address {
    zone_id = var.default_zone
  }
}