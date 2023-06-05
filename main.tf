#Workload Example
module "SharedToolServer" {
    source = "./modules/workload"
    providers = {
        azurerm = azurerm.shared_services
    }
    workload_name = "SharedToolServerX"
    vpc_name = ""
    region = "East US 2"
    resource_group_name = ""
    subnet_name = "" 
    custom_data = base64encode(templatefile("./modules/workload/scripts/sharedtool_init.tpl", {shared_server_ip = "10.8.8.8"}))
    ssh_public_key = var.ssh_public_key
    tags = { 
        "myenv" = "SharedServices"
        }
}


# # #Workload Example
module "workload1" {
    source = "./modules/workload"
    providers = {
        azurerm = azurerm.shared_services
    }
    workload_name = "Workload1"
    vpc_name = ""
    region = "East US 2"
    resource_group_name = ""
    subnet_name = ""
    ssh_public_key = var.ssh_public_key
    custom_data = base64encode(templatefile("./modules/workload/scripts/pingtest_init.tpl", {shared_server_ip = module.SharedToolServer.workload_vm_nic.private_ip_address}))
    tags = { 
        "myenv" = "env"
        "myapp-code" = "app" 
        }
    depends_on = [module.SharedToolServer]
 }
