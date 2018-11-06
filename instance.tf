resource "google_compute_instance" "default" {
  project      = "cloudjupyter-bhanu"
  name         = "terraform"
  machine_type = "g1-small"
  zone         = "asia-south1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

