module "servers" {
	source = "./servers"
	servers = 5
}

output "ip_address" {
	value = module.servers.ip_address
}
