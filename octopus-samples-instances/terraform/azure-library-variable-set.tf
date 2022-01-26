resource "octopusdeploy_library_variable_set" "azure_variable_set" {
  name = "Azure TF"
  description = "Library variable set storing Azure specific items you can leverage in your deployment process."
}

resource "octopusdeploy_variable" "azure_variable_set_worker_pool" {
  name = "Azure.WorkerPool"
  type = "WorkerPool"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.azure_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_variable_account" {
  name = "Azure.Account"
  type = "AzureAccount"
  is_editable = true
  is_sensitive = false
  value = octopusdeploy_azure_service_principal.azure_service_principal.id
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_network_subnet_azurecontainers_name" {
  name = "Azure.Network.Subnet.AzureContainers.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "acs"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_network_subnet_default_name" {
  name = "Azure.Network.Subnet.Default.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "default"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_sql_server_admin_password" {
  name = "Azure.SqlServer.Admin.Password"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  value = var.octopus_sql_server_sample_admin_password
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_sql_server_admin_username" {
  name = "Azure.SqlServer.Admin.UserName"
  type = "Sensitive"
  is_editable = false
  is_sensitive = true
  value = var.octopus_sql_server_sample_admin_username
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// UK Primary Region Variables
resource "octopusdeploy_variable" "azure_uk_primary_location_abbr" {
  name = "Azure.UK.Primary.Location.Abbr"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_location_name" {
  name = "Azure.UK.Primary.Location.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "UK South"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_network_security_group_name" {
  name = "Azure.UK.Primary.NetworkSecurityGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.UK.Primary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_name" {
  name = "Azure.UK.Primary.VirtualNetwork.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.UK.Primary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_address_space" {
  name = "Azure.UK.Primary.VirtualNetwork.AddressSpace"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.1.0.0/16\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_default_subnet_address" {
  name = "Azure.UK.Primary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.1.1.0/24\",\"10.1.2.0/24\"\"10.1.3.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_acs_subnet_address" {
  name = "Azure.UK.Primary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.1.100.0/24\",\"10.1.101.0/24\"\"10.1.102.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_resource_group_name" {
  name = "Azure.UK.Primary.ResourceGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "solutions_pem_uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_sql_server_Name" {
  name = "Azure.UK.Primary.SqlServer.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "octopus_solutions_uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// UK Secondary Region Variables
resource "octopusdeploy_variable" "azure_uk_secondary_location_abbr" {
  name = "Azure.UK.Secondary.Location.Abbr"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "ukwest"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_location_name" {
  name = "Azure.UK.Secondary.Location.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "UK West"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_network_security_group_name" {
  name = "Azure.UK.Secondary.NetworkSecurityGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.UK.Secondary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_name" {
  name = "Azure.UK.Secondary.VirtualNetwork.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.UK.Secondary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_address_space" {
  name = "Azure.UK.Secondary.VirtualNetwork.AddressSpace"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.2.0.0/16\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_default_subnet_address" {
  name = "Azure.UK.Secondary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.2.1.0/24\",\"10.2.2.0/24\"\"10.2.3.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_acs_subnet_address" {
  name = "Azure.UK.Secondary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.2.100.0/24\",\"10.2.101.0/24\"\"10.2.102.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_resource_group_name" {
  name = "Azure.UK.Secondary.ResourceGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "solutions_pem_uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_sql_server_Name" {
  name = "Azure.UK.Secondary.SqlServer.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "octopus_solutions_uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// US Primary Region Variables
resource "octopusdeploy_variable" "azure_us_primary_location_abbr" {
  name = "Azure.US.Primary.Location.Abbr"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "centralus"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_location_name" {
  name = "Azure.US.Primary.Location.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "Central US"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_network_security_group_name" {
  name = "Azure.US.Primary.NetworkSecurityGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.US.Primary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_name" {
  name = "Azure.US.Primary.VirtualNetwork.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.US.Primary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_address_space" {
  name = "Azure.US.Primary.VirtualNetwork.AddressSpace"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.3.0.0/16\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_default_subnet_address" {
  name = "Azure.US.Primary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.3.1.0/24\",\"10.3.2.0/24\"\"10.3.3.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_acs_subnet_address" {
  name = "Azure.US.Primary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.3.100.0/24\",\"10.3.101.0/24\"\"10.3.102.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_resource_group_name" {
  name = "Azure.US.Primary.ResourceGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "solutions_pem_ussouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_sql_server_Name" {
  name = "Azure.US.Primary.SqlServer.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "octopus_solutions_ussouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// US Secondary Region Variables
resource "octopusdeploy_variable" "azure_us_secondary_location_abbr" {
  name = "Azure.US.Secondary.Location.Abbr"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "eastus2"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_location_name" {
  name = "Azure.US.Secondary.Location.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "East US 2"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_network_security_group_name" {
  name = "Azure.US.Secondary.NetworkSecurityGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.US.Secondary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_name" {
  name = "Azure.US.Secondary.VirtualNetwork.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "#{Azure.US.Secondary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_address_space" {
  name = "Azure.US.Secondary.VirtualNetwork.AddressSpace"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.4.0.0/16\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_default_subnet_address" {
  name = "Azure.US.Secondary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.4.1.0/24\",\"10.4.2.0/24\"\"10.4.3.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_acs_subnet_address" {
  name = "Azure.US.Secondary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "[\"10.4.100.0/24\",\"10.4.101.0/24\"\"10.4.102.0/24\"]"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_resource_group_name" {
  name = "Azure.US.Secondary.ResourceGroup.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "solutions_pem_ussouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_sql_server_Name" {
  name = "Azure.US.Secondary.SqlServer.Name"
  type = "String"
  is_editable = true
  is_sensitive = false
  value = "octopus_solutions_ussouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}