packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

#AWS Config
source "amazon-ebs" "mongodb-ubuntu" {
  ami_name = "packer_AWS_{{timestamp}}"

  region         = "eu-west-1"
  source_ami     = "ami-63b0341a" // 16.04 Release 20171208
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false

}
#Azure Config
source "azure-arm" "mongodb-ubuntu" {
  managed_image_resource_group_name = "PackerResourceGroup"
  managed_image_name                = "packer-ubuntu-azure-{{timestamp}}"
  use_azure_cli_auth                = true


  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "16.04-LTS"
  image_version   = "16.04.201712080"

  location       = "westeurope"
  vm_size        = "Standard_A2"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
}

#Builder
build {
  hcp_packer_registry {
    bucket_name = "ubuntu-mongodb-old"
    description = <<EOT
Ubuntu Server 16.04 Release(Release 20171208) with MongoDB 4.2 published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "version" = "1.0.0"
    }
  }
  provisioner "shell" {
    only    = ["amazon-ebs.mongodb-ubuntu"]
    scripts = ["./scripts/install_aws_ssm_cli.sh", "./scripts/install_mongo_db.sh"]
  }
  provisioner "shell" {
    only    = ["azure-arm.ubuntu"]
    scripts = ["./scripts/install_mongo_db_azure.sh"]
  }
  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ubuntu"

  }
  sources = [
    "source.amazon-ebs.mongodb-ubuntu", "source.azure-arm.mongodb-ubuntu"
  ]
}
