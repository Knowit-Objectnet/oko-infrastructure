output "vpc_id" {
  value = module.vpc.vpc_id
}

output "service_descovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.namespace.id
}

output "db_subnet_group" {
  value = module.vpc.database_subnet_group
}