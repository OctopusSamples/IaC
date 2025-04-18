resource "octopusdeploy_library_variable_set" "azure_variable_set" {
  name = "Azure TF"
  description = "Library variable set storing Azure specific items you can leverage in your deployment process."
  space_id = var.octopus_space_id
}

resource "octopusdeploy_variable" "azure_variable_set_worker_pool" {
  name = "Azure.WorkerPool"
  type = "WorkerPool"
  
  is_sensitive = false
  value = octopusdeploy_static_worker_pool.azure_worker_pool.id
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_variable_account" {
  name = "Azure.Account"
  type = "AzureAccount"
  
  is_sensitive = false
  value = octopusdeploy_azure_service_principal.azure_service_principal.id
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_network_subnet_azurecontainers_name" {
  name = "Azure.Network.Subnet.AzureContainers.Name"
  type = "String"
  
  is_sensitive = false
  value = "acs"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_network_subnet_default_name" {
  name = "Azure.Network.Subnet.Default.Name"
  type = "String"
  
  is_sensitive = false
  value = "default"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_network_subnet_nosqlendpoint_name" {
  name = "Azure.Network.Subnet.NoSqlEndpoint.Name"
  type = "String"
  
  is_sensitive = false
  value = "nosqlendpoint"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_sql_server_admin_password" {
  name = "Azure.SqlServer.Admin.Password"
  type = "Sensitive"
  
  is_sensitive = true
  sensitive_value = var.octopus_sql_server_sample_admin_password
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_sql_server_admin_username" {
  name = "Azure.SqlServer.Admin.UserName"
  type = "Sensitive"
  
  is_sensitive = true
  sensitive_value = var.octopus_sql_server_sample_admin_username
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// UK Primary Region Variables
resource "octopusdeploy_variable" "azure_uk_primary_location_abbr" {
  name = "Azure.UK.Primary.Location.Abbr"
  type = "String"
  
  is_sensitive = false
  value = "uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_location_name" {
  name = "Azure.UK.Primary.Location.Name"
  type = "String"
  
  is_sensitive = false
  value = "UK South"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_network_security_group_name" {
  name = "Azure.UK.Primary.NetworkSecurityGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.UK.Primary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_name" {
  name = "Azure.UK.Primary.VirtualNetwork.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.UK.Primary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_address_space" {
  name = "Azure.UK.Primary.VirtualNetwork.AddressSpace"
  type = "String"
  
  is_sensitive = false
  value = "10.1.0.0/16"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_default_subnet_address" {
  name = "Azure.UK.Primary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.1.1.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_acs_subnet_address" {
  name = "Azure.UK.Primary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.1.100.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_virtual_network_nosqlendpoint_subnet_address" {
  name = "Azure.UK.Primary.VirtualNetwork.NoSqlEndpointSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.1.200.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_resource_group_name" {
  name = "Azure.UK.Primary.ResourceGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "solutions_pem_uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_sql_server_Name" {
  name = "Azure.UK.Primary.SqlServer.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-sqlserver-uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// UK Secondary Region Variables
resource "octopusdeploy_variable" "azure_uk_secondary_location_abbr" {
  name = "Azure.UK.Secondary.Location.Abbr"
  type = "String"
  
  is_sensitive = false
  value = "ukwest"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_location_name" {
  name = "Azure.UK.Secondary.Location.Name"
  type = "String"
  
  is_sensitive = false
  value = "UK West"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_network_security_group_name" {
  name = "Azure.UK.Secondary.NetworkSecurityGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.UK.Secondary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_name" {
  name = "Azure.UK.Secondary.VirtualNetwork.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.UK.Secondary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_address_space" {
  name = "Azure.UK.Secondary.VirtualNetwork.AddressSpace"
  type = "String"
  
  is_sensitive = false
  value = "10.2.0.0/16"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_default_subnet_address" {
  name = "Azure.UK.Secondary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.2.1.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_acs_subnet_address" {
  name = "Azure.UK.Secondary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.2.100.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_virtual_network_nosqlendpoint_subnet_address" {
  name = "Azure.UK.Secondary.VirtualNetwork.NoSqlEndpointSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.2.200.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_resource_group_name" {
  name = "Azure.UK.Secondary.ResourceGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "solutions_pem_ukwest"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_sql_server_Name" {
  name = "Azure.UK.Secondary.SqlServer.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-sqlserver-ukwest"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// US Primary Region Variables
resource "octopusdeploy_variable" "azure_us_primary_location_abbr" {
  name = "Azure.US.Primary.Location.Abbr"
  type = "String"
  
  is_sensitive = false
  value = "centralus"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_location_name" {
  name = "Azure.US.Primary.Location.Name"
  type = "String"
  
  is_sensitive = false
  value = "Central US"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_network_security_group_name" {
  name = "Azure.US.Primary.NetworkSecurityGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.US.Primary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_name" {
  name = "Azure.US.Primary.VirtualNetwork.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.US.Primary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_address_space" {
  name = "Azure.US.Primary.VirtualNetwork.AddressSpace"
  type = "String"
  
  is_sensitive = false
  value = "10.3.0.0/16"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_default_subnet_address" {
  name = "Azure.US.Primary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.3.1.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_acs_subnet_address" {
  name = "Azure.US.Primary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.3.100.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_virtual_network_nosqlendpoint_subnet_address" {
  name = "Azure.US.Primary.VirtualNetwork.NoSqlEndpointSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.3.200.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_resource_group_name" {
  name = "Azure.US.Primary.ResourceGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "solutions_pem_uscentral"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_sql_server_Name" {
  name = "Azure.US.Primary.SqlServer.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-sqlserver-uscentral"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

// US Secondary Region Variables
resource "octopusdeploy_variable" "azure_us_secondary_location_abbr" {
  name = "Azure.US.Secondary.Location.Abbr"
  type = "String"
  
  is_sensitive = false
  value = "eastus2"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_location_name" {
  name = "Azure.US.Secondary.Location.Name"
  type = "String"
  
  is_sensitive = false
  value = "East US 2"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_network_security_group_name" {
  name = "Azure.US.Secondary.NetworkSecurityGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.US.Secondary.ResourceGroup.Name}_nsg"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_name" {
  name = "Azure.US.Secondary.VirtualNetwork.Name"
  type = "String"
  
  is_sensitive = false
  value = "#{Azure.US.Secondary.ResourceGroup.Name}_vnet"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_address_space" {
  name = "Azure.US.Secondary.VirtualNetwork.AddressSpace"
  type = "String"
  
  is_sensitive = false
  value = "10.4.0.0/16"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_default_subnet_address" {
  name = "Azure.US.Secondary.VirtualNetwork.DefaultSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.4.1.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_acs_subnet_address" {
  name = "Azure.US.Secondary.VirtualNetwork.ACSSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.4.100.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_virtual_network_nosqlendpoint_subnet_address" {
  name = "Azure.US.Secondary.VirtualNetwork.NoSqlEndpointSubnet.Address"
  type = "String"
  
  is_sensitive = false
  value = "10.4.200.0/24"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_resource_group_name" {
  name = "Azure.US.Secondary.ResourceGroup.Name"
  type = "String"
  
  is_sensitive = false
  value = "solutions_pem_useast"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_sql_server_Name" {
  name = "Azure.US.Secondary.SqlServer.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-sqlserver-useast"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_postgresql_server_admin_username" {
  name = "Azure.PostgreSql.Admin.UserName"
  type = "Sensitive"
  
  is_sensitive = true
  sensitive_value = var.octopus_postgresql_server_sample_admin_username
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_postgresql_server_admin_password" {
  name = "Azure.PostgreSql.Admin.Password"
  type = "Sensitive"
  
  is_sensitive = true
  sensitive_value = var.octopus_postgresql_server_sample_admin_password
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_postgresql_server_name" {
  name = "Azure.US.Primary.PostgreSql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-postgresql-uscentral"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_postgresql_server_name" {
  name = "Azure.US.Secondary.PostgreSql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-postgresql-useast"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_primary_postgresql_server_name" {
  name = "Azure.UK.Primary.PostgreSql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-postgresql-uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_postgresql_server_name" {
  name = "Azure.UK.Secondary.PostgreSql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-postgresql-ukwest"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_mysql_server_admin_username" {
  name = "Azure.MySql.Admin.UserName"
  type = "Sensitive"
  
  is_sensitive = true
  sensitive_value = var.octopus_mysql_server_sample_admin_username
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_mysql_server_admin_password" {
  name = "Azure.MySql.Admin.Password"
  type = "Sensitive"
  
  is_sensitive = true
  sensitive_value = var.octopus_mysql_server_sample_admin_password
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_primary_mysql_server_name" {
  name = "Azure.US.Primary.MySql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-mysql-uscentral"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_us_secondary_mysql_server_name" {
  name = "Azure.US.Secondary.MySql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-mysql-useast"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}
resource "octopusdeploy_variable" "azure_uk_primary_mysql_server_name" {
  name = "Azure.UK.Primary.MySql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-mysql-uksouth"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}

resource "octopusdeploy_variable" "azure_uk_secondary_mysql_server_name" {
  name = "Azure.UK.Secondary.MySql.Name"
  type = "String"
  
  is_sensitive = false
  value = "od-solutions-mysql-ukwest"
  owner_id = octopusdeploy_library_variable_set.azure_variable_set.id
}