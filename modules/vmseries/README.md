# Palo Alto Networks VM-Series Module for Azure

A Terraform module for deploying a VM-Series firewall in Azure cloud.
The module is not intended for use with Scale Sets.

## Usage

```hcl
module "vmseries" {
  source  = "../../modules/vmseries"

  location            = "Australia East"
  resource_group_name = azurerm_resource_group.this.name
  name                = "myfw"
  username            = "panadmin"
  password            = "Change-Me-007"
  interfaces = [
    {
      name      = "myfw-mgmt-interface"
      subnet_id = lookup(module.vnet.subnet_ids, "subnet-mgmt", null)
    },
  ]
}
```

## Accept Azure Marketplace Terms

Accept the Azure Marketplace terms for the VM-Series images. In a typical situation use these commands:

```sh
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol --subscription MySubscription
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan bundle1 --subscription MySubscription
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan bundle2 --subscription MySubscription
```

You can revoke the acceptance later with the `az vm image terms cancel` command.
The acceptance applies to the entirety of your Azure Subscription.

## Caveat Regarding Region

By default, the VM-Series is placed into an Availability Zone "1". Hence, it can only deploy
successfully in the [Regions that support Zones](https://docs.microsoft.com/en-us/azure/availability-zones/az-region).
If your Region doesn't, use an alternative mechanism of Availability Set, which is inferior but universally supported:

```hcl
   avset_id = azurerm_availability_set.this.id
   avzone   = null
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.7 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking"></a> [accelerated\_networking](#input\_accelerated\_networking) | Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one (it is the PAN-OS management interface, which [does not support](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) acceleration). | `bool` | `true` | no |
| <a name="input_app_insights_settings"></a> [app\_insights\_settings](#input\_app\_insights\_settings) | A map of the Application Insights related parameters.<br><br>If the variable is:<br>- not defined - Application Insights will not be created (default behavior)<br>- defined as empty map `{}` - Application Insights will be created based on the default parameters<br>- defined as a map - Application Insights will be created with the defined properties, for any skipped - a default value will be used.<br><br>Available properties are:<br>- `name`                      - (optional\|string) Name of the Applications Insights instance. Can be `null`, in which case a default name is auto-generated.<br>- `workspace_mode`            - (optional\|bool)   Application Insights mode. If `true` (default), the "Workspace-based" mode is used. With `false`, the mode is set to legacy "Classic".<br>- `metrics_retention_in_days` - (optional\|number) Specifies the retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Azure defaults is 90.<br>- `log_analytics_name`        - (optional\|string) The name of the Log Analytics workspace. Can be `null`, in which case a default name is auto-generated.<br>- `log_analytics_sku`         - (optional\|string) Azure Log Analytics Workspace mode SKU. The default value is set to "PerGB2018". For more information refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/azure/azure-monitor//usage-estimated-costs#moving-to-the-new-pricing-model)<br><br>NOTICE. Azure support for classic Application Insights mode will end on Feb 29th 2024. It's already not available in some of the new regions.<br><br>NOTICE. Since upgrade to provider 3.x when destroying infrastructure with a classic Application Insights a resource is being left behind: `microsoft.alertsmanagement/smartdetectoralertrules`. This resource is not present in the state and it prevents resource group deletion.<br><br>A workaround is to set the following provider configuration:<pre>provider "azurerm" {<br>  features {<br>    resource_group {<br>      prevent_deletion_if_contains_resources = false<br>    }<br>  }<br>}<br><br>Example:</pre>{<br>      name                      = "AppInsights"<br>      workspace\_mode            = true<br>      metrics\_retention\_in\_days = 30<br>      log\_analytics\_name        = "LogAnalyticsName"<br>      log\_analytics\_sku         = "PerGB2018"<br>  }<pre></pre> | `map(any)` | `null` | no |
| <a name="input_avset_id"></a> [avset\_id](#input\_avset\_id) | The identifier of the Availability Set to use. When using this variable, set `avzone = null`. | `string` | `null` | no |
| <a name="input_avzone"></a> [avzone](#input\_avzone) | The availability zone to use, for example "1", "2", "3". Ignored if `enable_zones` is false. Conflicts with `avset_id`, in which case use `avzone = null`. | `string` | `"1"` | no |
| <a name="input_avzones"></a> [avzones](#input\_avzones) | After provider version 3.x you need to specify in which availability zone(s) you want to place IP.<br>ie: for zone-redundant with 3 availability zone in current region value will be:<pre>["1","2","3"]</pre> | `list(string)` | `[]` | no |
| <a name="input_bootstrap_options"></a> [bootstrap\_options](#input\_bootstrap\_options) | Bootstrap options to pass to VM-Series instance.<br><br>Proper syntax is a string of semicolon separated properties.<br>Example:<br>  bootstrap\_options = "type=dhcp-client;panorama-server=1.2.3.4"<br><br>A list of available properties: storage-account, access-key, file-share, share-directory, type, ip-address, default-gateway, netmask, ipv6-address, ipv6-default-gateway, hostname, panorama-server, panorama-server-2, tplname, dgname, dns-primary, dns-secondary, vm-auth-key, op-command-modes, op-cmd-dpdk-pkt-io, plugin-op-commands, dhcp-send-hostname, dhcp-send-client-id, dhcp-accept-server-hostname, dhcp-accept-server-domain, auth-key, vm-series-auto-registration-pin-value, vm-series-auto-registration-pin-id.<br><br>For more details on bootstrapping see documentation: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components | `string` | `""` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | Absolute ID of your own Custom Image to be used for creating new VM-Series. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software. | `string` | `null` | no |
| <a name="input_diagnostics_storage_uri"></a> [diagnostics\_storage\_uri](#input\_diagnostics\_storage\_uri) | The storage account's blob endpoint to hold diagnostic files. | `string` | `null` | no |
| <a name="input_enable_plan"></a> [enable\_plan](#input\_enable\_plan) | Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image. | `bool` | `true` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_ids). | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_type). | `string` | `"SystemAssigned"` | no |
| <a name="input_img_offer"></a> [img\_offer](#input\_img\_offer) | The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use "vmseries-flex"; for 9.1.0 or below use "vmseries1". | `string` | `"vmseries-flex"` | no |
| <a name="input_img_publisher"></a> [img\_publisher](#input\_img\_publisher) | The Azure Publisher identifier for a image which should be deployed. | `string` | `"paloaltonetworks"` | no |
| <a name="input_img_sku"></a> [img\_sku](#input\_img\_sku) | VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| <a name="input_img_version"></a> [img\_version](#input\_img\_version) | VM-series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all` | `string` | `"10.1.0"` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of the network interface specifications.<br><br>NOTICE. The ORDER in which you specify the interfaces DOES MATTER.<br>Interfaces will be attached to VM in the order you define here, therefore:<br>* The first should be the management interface, which does not participate in data filtering.<br>* The remaining ones are the dataplane interfaces.<br><br>Options for an interface object:<br>- `name`                 - (required\|string) Interface name.<br>- `subnet_id`            - (required\|string) Identifier of an existing subnet to create interface in.<br>- `private_ip_address`   - (optional\|string) Static private IP to asssign to the interface. If null, dynamic one is allocated.<br>- `public_ip_address_id` - (optional\|string) Identifier of an existing public IP to associate.<br>- `create_public_ip`     - (optional\|bool) If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.<br>- `availability_zone`    - (optional\|string) Availability zone to create public IP in. If not specified, set based on `avzone` and `enable_zones`.<br>- `enable_ip_forwarding` - (optional\|bool) If true, the network interface will not discard packets sent to an IP address other than the one assigned. If false, the network interface only accepts traffic destined to its IP address.<br>- `enable_backend_pool`  - (optional\|bool) If true, associate interface with backend pool specified with `lb_backend_pool_id`. Default is false.<br>- `lb_backend_pool_id`   - (optional\|string) Identifier of an existing backend pool to associate interface with. Required if `enable_backend_pool` is true.<br>- `tags`                 - (optional\|map) Tags to assign to the interface and public IP (if created). Overrides contents of `tags` variable.<br><br>Example:<pre>[<br>  {<br>    name                 = "fw-mgmt"<br>    subnet_id            = azurerm_subnet.my_mgmt_subnet.id<br>    public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id<br>  },<br>  {<br>    name                = "fw-public"<br>    subnet_id           = azurerm_subnet.my_pub_subnet.id<br>    lb_backend_pool_id  = module.inbound_lb.backend_pool_id<br>    enable_backend_pool = true<br>  },<br>]</pre> | `list(any)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region where to deploy VM-Series and dependencies. | `string` | n/a | yes |
| <a name="input_managed_disk_type"></a> [managed\_disk\_type](#input\_managed\_disk\_type) | Type of OS Managed Disk to create for the virtual machine. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_name"></a> [name](#input\_name) | VM-Series instance name. | `string` | n/a | yes |
| <a name="input_os_disk_name"></a> [os\_disk\_name](#input\_os\_disk\_name) | Optional name of the OS disk to create for the virtual machine. If empty, the name is auto-generated. | `string` | `null` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for VM-Series. If not defined the `ssh_key` variable must be specified. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm). | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group where to place the resources created. | `string` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | A list of initial administrative SSH public keys that allow key-pair authentication.<br><br>This is a list of strings, so each item should be the actual public key value. If you would like to load them from files instead, following method is available:<pre>[<br>  file("/path/to/public/keys/key_1.pub"),<br>  file("/path/to/public/keys/key_2.pub")<br>]</pre>If the `password` variable is also set, VM-Series will accept both authentication methods. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources created. | `map(any)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for VM-Series. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm). | `string` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interfaces"></a> [interfaces](#output\_interfaces) | List of VM-Series network interfaces. The elements of the list are `azurerm_network_interface` objects. The order is the same as `interfaces` input. |
| <a name="output_metrics_instrumentation_key"></a> [metrics\_instrumentation\_key](#output\_metrics\_instrumentation\_key) | The Instrumentation Key of the created instance of Azure Application Insights. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure. |
| <a name="output_mgmt_ip_address"></a> [mgmt\_ip\_address](#output\_mgmt\_ip\_address) | VM-Series management IP address. If `create_public_ip` was `true`, it is a public IP address, otherwise a private IP address. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The oid of Azure Service Principal of the created VM-Series. Usable only if `identity_type` contains SystemAssigned. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Custom Metrics

**(Optional)** Firewalls can publish custom metrics (for example `panSessionUtilization`) to Azure Application Insights.
This however requires a manual initialization: copy the output `metrics_instrumentation_key` and paste it into your
PAN-OS webUI -> Device -> VM-Series -> Azure. The module automatically completes the Step 1 of the
[official procedure](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall.html).

The metrics gathered within a single Azure Application Insights instance provided by the module, cannot be split to obtain
back a result for solely a single firewall. Thus for example if three firewalls use the same Instrumentation Key and report
their respective session utilizations as 90%, 20%, 10%, it is possible to see in Azure the average of 40%, the sum of 120%, the max of 90%, but it is *not possible* to know which of the firewalls reported the 90% utilization.
