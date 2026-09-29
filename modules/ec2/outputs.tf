output "instance_ids" {
  description = "Map of instance name to instance ID"

  value = merge(
    {
      for name, instance in aws_instance.unprotected :
      name => instance.id
    },
    {
      for name, instance in aws_instance.protected :
      name => instance.id
    }
  )
}

output "private_ips" {
  description = "Map of instance name to private IP"

  value = merge(
    {
      for name, instance in aws_instance.unprotected :
      name => instance.private_ip
    },
    {
      for name, instance in aws_instance.protected :
      name => instance.private_ip
    }
  )
}