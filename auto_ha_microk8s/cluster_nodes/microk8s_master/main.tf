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


# rest master setup
data "openstack_images_image_v2" "osimage_ubuntu" {
  name = "ubuntu-2004-focal-v20220216"
}


resource "openstack_compute_instance_v2" "master" {
  count             = 5
  name              = "tf-az-ubuntu-master-${count.index+1}"
  key_pair          = "az"
  # availability_zone = (count.index % 2 == 0) ? "eu-fra-1" : "eu-fra-2"
  availability_zone = "eu-fra-1"
  image_name        = data.openstack_images_image_v2.osimage_ubuntu.name
  flavor_name       = "gen1a-std-2"
  # TODO: This is a hack. Find a way to dynamically get the relative path
  user_data         = "${file("microk8s_master/setup_master.sh")}"

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

output "ip-master" {
  value = [for instance in openstack_compute_instance_v2.master : "${instance.name} => ${instance.access_ip_v4}"]
}