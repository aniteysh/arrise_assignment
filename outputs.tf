output "instance_ids" {
  description = "Map of instance name to instance ID"
  value       = module.ec2.instance_ids
}

output "private_ips" {
  description = "Map of instance name to private IP"
  value       = module.ec2.private_ips
}