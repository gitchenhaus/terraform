terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.22.0"
    }
  }
}

resource "google_compute_disk" "disk" {
  name  = "my-disk"
  type  = "pd-ssd"
  zone  = "asia-east2-a"
  size  = 50
}

resource "google_compute_network" "vpc_network" {
  name = "my-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "n2-standard-2"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7-v20210817"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.disk.id
  instance = google_compute_instance.vm_instance.id
}