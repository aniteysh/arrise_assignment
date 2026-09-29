variable "instances" {
  description = "EC2 instances to provision"

  type = map(object({
    instance_type = string
    ami           = string
    key_name      = string

    root_volume = object({
      type = string
      size = number
    })

    environment = string
    owner       = string

    protect_from_destroy = bool
  })
}