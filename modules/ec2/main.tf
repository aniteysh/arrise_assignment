locals {
  protected_instances = {
    for name, config in var.instances :
    name => config
    if config.protect_from_destroy
  }

  unprotected_instances = {
    for name, config in var.instances :
    name => config
    if !config.protect_from_destroy
  }
}

resource "aws_instance" "unprotected" {
  for_each = local.unprotected_instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.root_volume.type
    volume_size = each.value.root_volume.size
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
  }
}

resource "aws_instance" "protected" {
  for_each = local.protected_instances

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_type = each.value.root_volume.type
    volume_size = each.value.root_volume.size
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
  }
}