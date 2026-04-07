resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  for_each =  { for zone in var.mass_zones : zone.subnet_name => zone }
  name           = each.value.subnet_name
  zone           = each.value.vpc_name
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = [ each.value.cidr ]
  route_table_id = each.value.route_table_id
}