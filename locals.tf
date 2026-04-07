locals {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${file("~/.ssh/ssh-key-1756817743452.pub")}"
}