# Configure the OpenStack Provider
terraform {
  required_version = ">= 0.12"
    required_providers {
      openstack = {
        source = "terraform-provider-openstack/openstack"
        version = "~> 1.48.0"
      }
    }
    
}

provider "openstack" {
  cloud   = "nz-test"
  use_octavia = "true"
}

variable num_of_additionalmasters {
  type        = number
  default     = 5
  description = "Number of additional masters that will join the main control plane. This number will be set in the parent module and it'll change the setup_main_master script to create the specified number of join tokens."
}

# main master setup
data "openstack_images_image_v2" "osimage_ubuntu" {
  name = "ubuntu-2004-focal-v20220216"
}

resource "openstack_compute_instance_v2" "main-master" {
  count             = 1
  name              = "tf-az-ubuntu-main-master"
  key_pair          = "az"
  # availability_zone = (count.index % 2 == 0) ? "eu-fra-1" : "eu-fra-2"
  availability_zone = "eu-fra-1"
  image_name        = data.openstack_images_image_v2.osimage_ubuntu.name
  flavor_name       = "gen1a-std-2"
  user_data         = "${templatefile("microk8s_main_master/setup_main_master.tftpl", {num_of_additionalmasters = var.num_of_additionalmasters})}"

  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    volume_size           = 10
    uuid                  = data.openstack_images_image_v2.osimage_ubuntu.id
  }

  network {
    name = "nz-test-defaultnetwork"
  }

  security_groups = concat([
    "k8s"
  ])

  metadata = {
    groups = "k8s-control-plane"
  }
}

output "ip-main-master" {
  value = [for instance in openstack_compute_instance_v2.main-master : "${instance.name} => ${instance.access_ip_v4}"]
}