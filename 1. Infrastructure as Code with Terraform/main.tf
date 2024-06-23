resource "google_compute_instance" "terraform" {
  name         = "terraform"
  machine_type = "e2-medium"

  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
  allow_stopping_for_update = true 
}
