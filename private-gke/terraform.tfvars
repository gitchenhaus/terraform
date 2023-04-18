project                  = "test-project"
location                 = "asia-east2-b"
region                   = "asia-east2"

cluster_name             = "providercenter-core"
kubernetes_version       = "1.25.8-gke.200"


nodepool_prefix          = "providercenter"
node_disk_size_gb        = "30"
node_disk_type           = "pd-standard"

application_machine_type = "n2-standard-2"
application_node_num     = 3
monitor_machine_type     = "n2-standard-2"
monitor_node_num         = 1

vpc_name                 = "internal-providercenter"
vpc_cidr_block           = "10.0.10.0/24" 
vpc_secondary_cidr_block = "10.2.0.0/16"
services_secondary_cidr_block ="10.1.0.0/16"
master_orized_cidr   = "0.0.0.0/0"
