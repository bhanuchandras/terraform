data "google_client_config" "current" {}

resource "google_container_cluster" "primary" {
  name               = "bhanu-chandra"
  zone               = "asia-east1"
  initial_node_count = 1


  master_auth {
    username = "${var.user}"
    password = "${var.passcode}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      foo = "jupyter"
    }

    tags = ["jupyter", "hub","python"]
  }
  enable_legacy_abac = true
}
# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
