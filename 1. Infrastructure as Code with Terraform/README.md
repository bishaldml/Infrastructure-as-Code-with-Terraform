Infrastructure as Code with Terraform

### 1. Overview
In this lab, you will use Terraform to create, update, and destroy Google Cloud resources. You will start by defining Google Cloud as the provider.

You will then create a VM instance without mentioning the network to see how terraform parses the configuration code. You will then edit the code to add network and create a VM instance on Google Cloud.

You will explore how to update the VM instance. You will edit the existing configuration to add tags and then edit the machine type. You will then execute terraform commands to destroy the resources created.
### 2. Objectives
In this lab you will learn how to perform the following tasks:

1. Verify Terraform installation
2.  Google Cloud as the provider
3.  reate, change, and destroy Google Cloud resources by using Terraform


```
terraform --version
```

```
vi main.tf
```

```
resource "google_compute_instance" "terraform" {
  name         = "terraform"
  machine_type = "e2-medium"

  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
  allow_stopping_for_update = true 
}
```


1.```terraform init```
2. ```terraform plan```
3. ```terraform apply```
4. ```terraform destroy```
