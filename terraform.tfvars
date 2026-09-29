instances = {

  app-01 = {
    instance_type = "t3.micro"
    ami           = "ami-0123456789abcdef0"
    key_name      = "app-key"

    root_volume = {
      type = "gp3"
      size = 20
    }

    environment          = "production"
    owner                = "platform"
    protect_from_destroy = false
  }

  app-02 = {
    instance_type = "t3.small"
    ami           = "ami-0123456789abcdef0"
    key_name      = "app-key-2"

    root_volume = {
      type = "gp3"
      size = 30
    }

    environment          = "production"
    owner                = "platform"
    protect_from_destroy = false
  }

  app-03 = {
    instance_type = "t3.medium"
    ami           = "ami-0123456789abcdef0"
    key_name      = "app-key-3"

    root_volume = {
      type = "io1"
      size = 50
    }

    environment          = "production"
    owner                = "platform"
    protect_from_destroy = true
  }

  app-04 = {
    instance_type = "m5.large"
    ami           = "ami-0123456789abcdef0"
    key_name      = "app-key-4"

    root_volume = {
      type = "gp3"
      size = 60
    }

    environment          = "production"
    owner                = "platform"
    protect_from_destroy = false
  }

  app-05 = {
    instance_type = "c5.large"
    ami           = "ami-0123456789abcdef0"
    key_name      = "app-key-5"

    root_volume = {
      type = "gp2"
      size = 80
    }

    environment          = "production"
    owner                = "platform"
    protect_from_destroy = false
  }
}