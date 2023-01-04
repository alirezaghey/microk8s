terraform {
  required_version = ">= 0.12"
    required_providers {
      openstack = {
        source = "terraform-provider-openstack/openstack"
        version = "~> 1.48.0"
      }
    }
    
}


# Configure the OpenStack Provider
provider "openstack" {
  cloud   = "nz-test"
  use_octavia = "true"
}

# main master
module "main_master" {
  source = "./microk8s_main_master"
}

# rest of masters
module "master" {
  source = "./microk8s_master"
}



# outputs read from child modules

output "ip-main-master" {
  value       = module.main_master.ip-main-master
}

output "ip-master" {
  value       = module.master.ip-master
}

