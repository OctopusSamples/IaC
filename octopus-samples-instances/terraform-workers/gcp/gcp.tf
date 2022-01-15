resource "google_compute_instance" "vm_instance" {
  count        = var.instance_count
  name         = "${var.instance_name}-${count.index + 1}"
  machine_type = var.instance_size

  boot_disk {
    initialize_params {
      image = var.instance_osimage
      size = 30
    }
  }

  network_interface {
    network = "default" #google_compute_network.vpc_network.name
  }

  metadata_startup_script = file("../configure-tentacle.sh")

  tags = ["octopus-samples-worker"]
}

output "ip" {
  value = google_compute_instance.vm_instance[*].network_interface[0].access_config[0].nat_ip
}

