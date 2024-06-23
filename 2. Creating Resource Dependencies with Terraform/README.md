Creating Resource Dependencies with Terraform

## 1. Overview
In this lab, you will create two VMs in the default network. We will use variables to define the VM's attributes at runtime and use output values to print a few resource attributes.

We will then add a static IP address to the first VM to examine how terraform handles implicit dependencies. We will then create a GCS bucket by mentioning explicit dependency to the VM to examine how terraform handles explicit dependency.

## 2. Objectives
In this lab, you learn how to perform the following tasks:

1. Use variables and output values
2. Observe implicit dependency
3. Create explicit resource dependency

### Task 1. Sign in to the Cloud Console

### Task 2. Initialize Terraform
1. Open Cloud Shell (Activate Cloud Shell) and execute the following command to verify that terraform is installed.
```
terraform -version
```
2. Create a directory for your Terraform configuration and navigate to it by running the following command:
```
mkdir tf_project
cd tf_project
```

```
vi provider.tf
```

```
  provider "google" {
  project = "Project ID"
  region  = ""REGION""
  zone    = ""ZONE""
}
```

```
terraform init
```
Terraform has now installed the necessary plug-ins to interact with the Google Cloud API. Authentication is not required for API. The Cloud Shell credentials give access to the project and APIs.

In the remaining part of the lab, we will cover the two types of dependencies that Terraform can handle:

1. Implicit dependencies: Dependencies known to Terraform
2. Explicit dependencies: Dependencies unknown to Terraform


### Task 3. View Implicit Resource Dependency
To demonstrate how Terraform infers an implicit dependency, we assign a static IP address to the VM instance.

Create a VM instance
```
vi instance.tf
```

```
resource google_compute_instance "vm_instance" {
name         = "${var.instance_name}"
zone         = "${var.instance_zone}"
machine_type = "${var.instance_type}"
boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      }
  }
 network_interface {
    network = "default"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}
```
Create variables
```
vi variables.tf
```

```
variable "instance_name" {
  type        = string
  description = "Name for the Google Compute instance"
}
variable "instance_zone" {
  type        = string
  description = "Zone for the Google Compute instance"
}
variable "instance_type" {
  type        = string
  description = "Disk type of the Google Compute instance"
  default     = "e2-medium"
  }
```
By giving instance_type a default value, you make the variable optional. The instance_name, and instance_zone are required, and you will define them at run time.
