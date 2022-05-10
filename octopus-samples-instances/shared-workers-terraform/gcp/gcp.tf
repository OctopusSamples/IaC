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

    access_config {
      // Ephemeral public IP - needed to send and receive traffic directly to and from outside network
    }
  }

  metadata_startup_script = file("../configure-tentacle.sh")

  service_account {
    email = google_service_account.database_service_account.email
    scopes = ["cloud-platform"]
  }

  tags = ["octopus-samples-worker"]
}

output "ip" {
  value = google_compute_instance.vm_instance[*].network_interface[0].access_config[0].nat_ip
}

