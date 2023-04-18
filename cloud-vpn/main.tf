
resource "google_compute_network" "istio" {
  name                    = var.istio_network
  auto_create_subnetworks = "false"
  project                 = var.istio_project
}

resource "google_compute_network" "gce" {
  name                    = var.gce_network
  auto_create_subnetworks = "false"
  project                 = var.gce_project
}

resource "google_compute_subnetwork" "subnet_istio" {
  name          = var.istio_subnet
  network       = google_compute_network.istio.self_link
  ip_cidr_range = var.istio_subnet_cidr
  project = var.istio_project
  region  = var.region
}

# Create a regular subnet to be used by the GCE instance.
resource "google_compute_subnetwork" "subnet_gce" {
  name          = var.gce_subnet
  network       = google_compute_network.gce.self_link
  ip_cidr_range = var.gce_subnet_cidr
  project       = var.gce_project
  region        = var.region
}


resource "google_compute_address" "vpn_static_ip_gce" {
  name    = "vpn-static-ip-gce"
  project = var.gce_project
  region  = var.region
}

resource "google_compute_address" "vpn_static_ip_istio" {
  name    = "vpn-static-ip-istio"
  project = var.istio_project
  region  = var.region
}



resource "google_compute_vpn_gateway" "target_gateway_gce" {
  name    = "vpn-gce"
  project = var.gce_project
  network = google_compute_network.gce.self_link
  region  = var.region
}

resource "google_compute_vpn_gateway" "target_gateway_istio" {
  name    = "vpn-istio"
  project = var.istio_project
  network = google_compute_network.istio.self_link
  region  = var.region
}


resource "google_compute_forwarding_rule" "fr_esp_gce" {
  name        = "fr-esp-gce"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip_gce.address
  target      = google_compute_vpn_gateway.target_gateway_gce.self_link
  project     = var.gce_project
  region      = var.region
}

resource "google_compute_forwarding_rule" "fr_esp_istio" {
  name        = "fr-esp-istio"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip_istio.address
  target      = google_compute_vpn_gateway.target_gateway_istio.self_link
  project     = var.istio_project
  region      = var.region
}


resource "google_compute_forwarding_rule" "fr_udp500_gce" {
  name        = "fr-udp500-gce"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = google_compute_address.vpn_static_ip_gce.address
  target      = google_compute_vpn_gateway.target_gateway_gce.self_link
  project     = var.gce_project
  region      = var.region
}

resource "google_compute_forwarding_rule" "fr_udp500_istio" {
  name        = "fr-udp500-istio"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = google_compute_address.vpn_static_ip_istio.address
  target      = google_compute_vpn_gateway.target_gateway_istio.self_link
  project     = var.istio_project
  region      = var.region
}

resource "google_compute_forwarding_rule" "fr_udp4500_gce" {
  name        = "fr-udp4500-gce"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = google_compute_address.vpn_static_ip_gce.address
  target      = google_compute_vpn_gateway.target_gateway_gce.self_link
  project     = var.gce_project
  region      = var.region
}

resource "google_compute_forwarding_rule" "fr_udp4500_istio" {
  name        = "fr-udp4500-istio"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = google_compute_address.vpn_static_ip_istio.address
  target      = google_compute_vpn_gateway.target_gateway_istio.self_link
  project     = var.istio_project
  region      = var.region
}

resource "google_compute_vpn_tunnel" "tunnel1_gce" {
  name          = "tunnel1-gce"
  peer_ip       = google_compute_address.vpn_static_ip_istio.address
  shared_secret = var.vpn_shared_secret
  project       = var.gce_project

  target_vpn_gateway = google_compute_vpn_gateway.target_gateway_gce.self_link

  local_traffic_selector = ["0.0.0.0/0"]

  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.fr_esp_gce,
    google_compute_forwarding_rule.fr_udp500_gce,
    google_compute_forwarding_rule.fr_udp4500_gce,
  ]
}

resource "google_compute_vpn_tunnel" "tunnel1_istio" {
  name          = "tunnel1-istio"
  peer_ip       = google_compute_address.vpn_static_ip_gce.address
  shared_secret = var.vpn_shared_secret
  project       = var.istio_project

  target_vpn_gateway = google_compute_vpn_gateway.target_gateway_istio.self_link

  local_traffic_selector = ["0.0.0.0/0"]

  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.fr_esp_istio,
    google_compute_forwarding_rule.fr_udp500_istio,
    google_compute_forwarding_rule.fr_udp4500_istio,
  ]
}


resource "google_compute_route" "route_gce" {
  name       = "route-gce"
  network    = google_compute_network.gce.name
  dest_range = google_compute_subnetwork.subnet_istio.ip_cidr_range
  priority   = 1000
  project    = var.gce_project

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1_gce.self_link
}

resource "google_compute_route" "route_istio" {
  name       = "route-istio"
  network    = google_compute_network.istio.name
  dest_range = google_compute_subnetwork.subnet_gce.ip_cidr_range
  priority   = 1000
  project    = var.istio_project

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1_istio.self_link
}

# resource "google_compute_firewall" "allow_istio" {
#   name    = "allow-istio"
#   project = var.gce_project
#   network = google_compute_network.gce.name

#   source_ranges = [
#     google_compute_subnetwork.subnet_istio.ip_cidr_range,
#   ]

#   target_tags = ["allow-vpn"]

#   allow {
#     protocol = "tcp"
#   }
# }

# resource "google_compute_firewall" "allow_gce" {
#   name    = "allow-gce"
#   project = var.istio_project
#   network = google_compute_network.istio.name

#   source_ranges = [
#     google_compute_subnetwork.subnet_gce.ip_cidr_range,
#   ]

#   target_tags = ["allow-vpn"]

#   allow {
#     protocol = "tcp"
#   }
# }