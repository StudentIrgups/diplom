locals {
    serial-port-enable = 1
    ssh-keys           = "${file("~/.ssh/ssh-key-1756817743452.pub")}"
    auth_key_file      = file("~/.yc/auth_key_diplom.json")
}