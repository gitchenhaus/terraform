resource "google_storage_bucket" "default" {
  project       = var.project
  name = "bucket-tfstate-${random_id.instance_id.hex}"
  force_destroy = false
  location      = var.location
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "random_id" "instance_id" {
  byte_length = 8
}