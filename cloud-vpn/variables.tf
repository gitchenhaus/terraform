# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "gce_project" {
  description = "The gce project ID for the network"
  type        = string
}

variable "istio_project" {
  description = "The istio project ID for the network"
  type        = string
}


variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "gce_network" {
  description = "The gce vpc network"
  type        = string
}

variable "gce_subnet" {
}

// The CIDR used by the GCE instance's subnet
variable "gce_subnet_cidr" {
}

variable "istio_network" {
  description = "The istio vpc network"
  type        = string
}

// The subnet used to deploy the GKE cluster
variable "istio_subnet" {
}

// The CIDR used by the GKE cluster's subnet
variable "istio_subnet_cidr" {
}


variable "vpn_shared_secret" {
  description = "vpn shared secret"
  type        = string
}

# variable "target_peer_ip" {
#   description = "peer_ip"
#   type        = string
# }

# variable "target_cidr" {
#   description  = "target cidr"
#   type         = string
# }