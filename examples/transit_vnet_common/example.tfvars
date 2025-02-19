# --- GENERAL --- #
# location              = "North Europe" # TODO adjust deployment region to your needs
location              = "Australia East" # TODO adjust deployment region to your needs
resource_group_name   = "common-refarch"
name_prefix           = "example-"
create_resource_group = true
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}
enable_zones = false


# --- VNET CONFIGURATION --- #
vnets = {
  "transit-vnet" = {
    create_virtual_network = true
    address_space          = ["10.0.0.0/25"] # TODO adjust the VNET and subnet address spaces if you plan to peer this vnet
    network_security_groups = {
      "management" = {
        rules = {
          vmseries_mgmt_allow_inbound = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefixes    = ["1.1.1.1"] # TODO adjust to allow public IPs to connect to the firewalls' management interfaces from the internet
            source_port_range          = "*"
            destination_address_prefix = "10.0.0.0/27"
            destination_port_ranges    = ["22", "443"]
          }
        }
      }
      "private" = {}
      "public"  = {}
    }
    route_tables = { # TODO these route tables provide basic black-holing, adjust for further security
      "management" = {
        routes = {
          "private_blackhole" = {
            address_prefix = "10.0.0.32/27"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            address_prefix = "10.0.0.64/27"
            next_hop_type  = "None"
          }
        }
      }
      "private" = {
        routes = {
          "default" = {
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.0.0.50"
          }
          "mgmt_blackhole" = {
            address_prefix = "10.0.0.0/27"
            next_hop_type  = "None"
          }
          "public_blackhole" = {
            address_prefix = "10.0.0.64/27"
            next_hop_type  = "None"
          }
        }
      }
      "public" = {
        routes = {
          "mgmt_blackhole" = {
            address_prefix = "10.0.0.0/27"
            next_hop_type  = "None"
          }
          "private_blackhole" = {
            address_prefix = "10.0.0.32/27"
            next_hop_type  = "None"
          }
        }
      }
    }
    create_subnets = true
    subnets = {
      "management" = {
        address_prefixes       = ["10.0.0.0/27"]
        network_security_group = "management"
        route_table            = "management"
      }
      "private" = {
        address_prefixes = ["10.0.0.32/27"]
        route_table      = "private"
      }
      "public" = {
        address_prefixes       = ["10.0.0.64/27"]
        network_security_group = "public"
        route_table            = "public"
      }
    }
  }
}



# --- LOAD BALANCING CONFIGURATION --- #
load_balancers = {
  "lb-public" = {
    vnet_name                         = "transit-vnet"
    network_security_group_name       = "public"
    network_security_allow_source_ips = ["1.1.1.1"] # TODO adjust to the public IPs that will connect to the public Load Balancer

    frontend_ips = {
      "palo-lb-app1-pip" = { # TODO this is just a basic load balancing rule that will balance HTTP(s) traffic, add more rules to balance different types of traffic
        create_public_ip = true
        rules = {
          "balanceHttp" = {
            protocol = "Tcp"
            port     = 80
          }
          "balanceHttps" = {
            protocol = "Tcp"
            port     = 443
          }
        }
      }
    }
  }
  "lb-private" = {
    frontend_ips = {
      "ha-ports" = {
        vnet_name          = "transit-vnet"
        subnet_name        = "private"
        private_ip_address = "10.0.0.50"
        rules = {
          HA_PORTS = {
            port     = 0
            protocol = "All"
          }
        }
      }
    }
  }
}



# --- VMSERIES CONFIGURATION --- #
availability_set = {
  "vmseries" = {
    fault_domain_count = 2
  }
}

vmseries_version = "10.2.2"
vmseries_vm_size = "Standard_DS3_v2"
vmseries_sku     = "byol"
# vmseries_password = "" # TODO by default the VM-Series admin password is autogenerated, uncomment and provide you own
vmseries = {
  "vmseries-1" = {
    availability_set_name = "vmseries"
    app_insights_settings = {}
    bootstrap_options     = "type=dhcp-client" # TODO add licensing, panorama configuration if needed
    vnet_name             = "transit-vnet"
    interfaces = [
      {
        name               = "mgmt"
        subnet_name        = "management"
        private_ip_address = "10.0.0.10"
        create_pip         = true
      },
      {
        name               = "private"
        subnet_name        = "private"
        load_balancer_name = "lb-private"
        private_ip_address = "10.0.0.40"
      },
      {
        name               = "public"
        subnet_name        = "public"
        load_balancer_name = "lb-public"
        private_ip_address = "10.0.0.70"
        create_pip         = true
      }
    ]
  }
  "vmseries-2" = {
    availability_set_name = "vmseries"
    app_insights_settings = {}
    bootstrap_options     = "type=dhcp-client" # TODO add licensing, panorama configuration if needed
    vnet_name             = "transit-vnet"
    interfaces = [
      {
        name               = "mgmt"
        subnet_name        = "management"
        private_ip_address = "10.0.0.11"
        create_pip         = true
      },
      {
        name               = "private"
        subnet_name        = "private"
        load_balancer_name = "lb-private"
        private_ip_address = "10.0.0.41"
      },
      {
        name               = "public"
        subnet_name        = "public"
        load_balancer_name = "lb-public"
        private_ip_address = "10.0.0.71"
        create_pip         = true
      }
    ]
  }
}
