# Palo Alto Networks Transit VNet Common Example

This folder shows an example of Terraform code that helps to deploy a [Transit VNet design model](https://www.paloaltonetworks.com/resources/guides/azure-transit-vnet-deployment-guide-common-firewall-option) (common firewall option) with a VM-Series firewall on Microsoft Azure.

What's worth mentioning is that in this example we will use an *Availability Set* to provide the firewalls with resiliency. Each firewall will also have it's own *Application Insights* resource deployed in order to gather runtime metrics. For details on configuring a VM-Series firewall with Application Insights please refer to [documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall) (please note, that the instrumentation key mentioned in the documentation can be also retrieved directly from Terraform state file with the following command: `terraform output metrics_instrumentation_keys`).

## NOTICE

This example contains some files that can contain sensitive data, namely the `tfvars` file can contain `bootstrap_options` properties in `var.vmseries` definition. Keep in mind that this code is only an example. It's main purpose is to introduce the Terraform modules. It's not meant to be run on production in this form.

## Usage

1. Create a `terraform.tfvars` file and copy the content of [`example.tfvars`](./example.tfvars) into it.
1. Adjust the `terraform.tfvars` to your needs. Please follow the `TODO` markers at minimum.
1. Deploy the infrastructure with the following commands:

        $ terraform init
        $ terraform apply

1. When your done with testing you can destroy the infrastructure with the following command:

        $ terraform destroy

**NOTE**\
Due to the way AzureRM API works, it might be necessary to run the `destroy` command more than once.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ../../modules/loadbalancer | n/a |
| <a name="module_natgw"></a> [natgw](#module\_natgw) | ../../modules/natgw | n/a |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | ../../modules/vmseries | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ../../modules/vnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_set"></a> [availability\_set](#input\_availability\_set) | A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.<br><br>Key is the AS name, value can contain following properties:<br>- `update_domain_count` - specifies the number of update domains that are used, defaults to 5 (Azure defaults)<br>- `fault_domain_count` - specifies the number of fault domains that are used, defaults to 3 (Azure defaults) | `any` | `{}` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.<br>When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group. | `bool` | `true` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If `true`, enable zone support for resources. | `bool` | `true` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.<br><br>Key is the name of the Load Balancer as it will be available in Azure. This name is also used to reference the Load Balancer further in the code.<br>Value is an object containing following properties:<br><br>- `vnet_name` : (both) a name of a VNET that will host this resource, this a key from the `var.vnets` map<br>- `network_security_group_name`: (public LB) a name of a security group created with the `vnet_security` module, an ingress rule will be created in that NSG for each listener. <br>- `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.<br>- `avzones` : (public LB) a list of Availability Zones in which the Public IP will be available<br>- `frontend_ips`: (both) a map configuring both a listener and a load balancing rule, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), value is an object with the following properties:<br>  - `create_public_ip`: (public LB) defaults to `false`, when set to `true` a Public IP will be created and associated with a listener<br>  - `public_ip_name`: (public LB) defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure<br>  - `public_ip_resource_group`: (public LB) defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG<br>  - `private_ip_address`: (private LB) defaults to `null`, specify a static IP address that will be used by a listener<br>  - `subnet_name`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a subnet to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet<br>  - `zones` - defaults to `null`, specify in which zones you want to create frontend IP address. Pass list with zone coverage, ie: `["1","2","3"]`<br>  - `rules` - a map configuring the actual rules load balancing rules, a key is a rule name, a value is an object with the following properties:<br>    - `protocol`: protocol used by the rule, can be one the following: `TCP`, `UDP` or `All` when creating an HA PORTS rule<br>    - `port`: port used by the rule, for HA PORTS rule set this to `0` | `any` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix that will be added to all created resources.<br>There is no default delimiter applied between the prefix and the resource name. Please include the delimiter in the actual prefix.<br><br>Example:<pre>name_prefix = "test-"</pre>NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property. | `string` | `""` | no |
| <a name="input_natgws"></a> [natgws](#input\_natgws) | A map defining NAT Gateways, where key is the NatGW name and value is a set of properties described below.<br><br>- `create_natgw` : (default: `true`) when set to `true` will create a NatGW, `false` will source an existing one (in this case the name should already contain a prefix).<br>- `vnet_name` : a name of a VNET that will host this resource, this a key from the `var.vnets` map.<br>- `subnet_name` : a name of a Subnet that NatGW will be assigned to, this is a key from the `subnets` property from a VNET definition described by the `vnet_name` property.<br>- `zone` : Availability Zone is a zonal resource, provide a zone in which this resource will be created, when omitted, zone is set by AzureRM.<br><br>Properties below are only briefly documented, for details, default values, limitation refer to [modules documentation](../../modules/natgw):<br><br>- `idle_timeout` : session timeout for idle connections.<br>- `create_pip` : (default: `true`) create a Public IP to be used by NatGW.<br>- `existing_pip_name` : for `create_pip` set to `false`, a name of an exiting Public IP resource.<br>- `existing_pip_resource_group_name` : for `create_pip` set to `false`, a name of a Resource Group hosting the existing Public IP.<br>- `create_pip_prefix` : (default: `true`) create a Public IP Prefix to be used by NatGW<br>- `pip_prefix_length` : when creating a prefix resource, this is a netmask (IPv4) setting the amount of IP addresses available in the prefix.<br>- `existing_pip_prefix_name` : for `create_pip_prefix` set to `false`, a name of an existing prefix resource<br>- `existing_pip_prefix_resource_group_name` : for `create_pip_prefix` set to `false`, a name of a Resource Group hosting the existing prefix. | `any` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to . | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the created resources. | `map(string)` | `{}` | no |
| <a name="input_vmseries"></a> [vmseries](#input\_vmseries) | Map of virtual machines to create to run VM-Series - inbound firewalls. Keys are the individual names, values<br>are objects containing attributes unique to that individual virtual machine:<br><br>- `vnet_name` : a name of a VNET that will host this resource, this a key from the `var.vnets` map.<br>- `avzone` : the Azure Availability Zone identifier ("1", "2", "3"). Default is "1" in order to avoid non-HA deployments.<br>- `availability_set_name` : a name of an Availability Set as declared in `availability_set` property. Specify when HA is required but cannot go for zonal deployment.<br>- `bootstrap_options`: Bootstrap options to pass to VM-Series instances, semicolon separated values.<br>- `add_to_appgw_backend` : bool, `false` by default, set this to `true` to add this backend to an Application Gateway.<br>- `app_insights_settings` : a map defining Application Insights settings for this resource.<br><br>- `interfaces`: configuration of all NICs assigned to a VM. A list containing properties for each interface. Order is important, as Azure assigns NICs to a VM in the order you provide them here. Therefore the 1st NIC should be the Management one:<br>  - `name` : a name of an interface<br>  - `subnet_name`: (string) a name of a subnet as created in using `vnet_security` module<br>  - `create_pip`: (boolean) flag to create Public IP for an interface, defaults to `false`<br>  - `load_balancer_name`: (string) name of a Load Balancer created with the `loadbalancer` module to which a VM should be assigned, defaults to `null`<br>  - `private_ip_address`: (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used) | `any` | `{}` | no |
| <a name="input_vmseries_password"></a> [vmseries\_password](#input\_vmseries\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_vmseries_sku"></a> [vmseries\_sku](#input\_vmseries\_sku) | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"byol"` | no |
| <a name="input_vmseries_username"></a> [vmseries\_username](#input\_vmseries\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_vmseries_version"></a> [vmseries\_version](#input\_vmseries\_version) | VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | n/a | yes |
| <a name="input_vmseries_vm_size"></a> [vmseries\_vm\_size](#input\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | n/a | yes |
| <a name="input_vnets"></a> [vnets](#input\_vnets) | A map defining VNETs. A key is the VNET name, value is a set of properties describing a VNET.<br><br>- `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET (in this case the name should already contain a prefix).<br>- `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside or will be sourced from.<br>- `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets. Subnet names are not pre-fixable.<br>- `address_space` : a list of CIDRs for VNET.<br>- `subnets` : map of Subnets to create or source subnets<br>- `network_security_groups` : map of Network Security Groups to create<br>- `route_tables` : map of Route Tables to create.<br><br>For details on configuring the last three properties refer to [VNET module documentation](../../modules/vnet/README.md). | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_frontend_ips"></a> [lb\_frontend\_ips](#output\_lb\_frontend\_ips) | IP Addresses of the load balancers. |
| <a name="output_metrics_instrumentation_keys"></a> [metrics\_instrumentation\_keys](#output\_metrics\_instrumentation\_keys) | The Instrumentation Key of the created instances of Azure Application Insights. An instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewall. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure. |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
| <a name="output_vmseries_mgmt_ip"></a> [vmseries\_mgmt\_ip](#output\_vmseries\_mgmt\_ip) | IP addresses for the VMSeries management interface. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
