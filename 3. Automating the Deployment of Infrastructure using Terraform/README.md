Automating the Deployment of Infrastructure Using Terraform

## 1. Overview
Terraform enables you to safely and predictably create, change, and improve infrastructure. It is an open-source tool that codifies APIs into declarative configuration files that can be shared among team members, treated as code, edited, reviewed, and versioned.

In this lab, you create a Terraform configuration with a module to automate the deployment of Google Cloud infrastructure. Specifically, you deploy one auto mode network with a firewall rule and two VM instances, as shown in this diagram:

## 2. Objectives
In this lab, you learn how to perform the following tasks:

1. Create a configuration for an auto mode network
2. Create a configuration for a firewall rule
3. Create and deploy a configuration
4. Verify the deployment of a configuration

### Task 1. Set up Terraform and Cloud Shell
To confirm that Terraform is installed, run the following command:
```
terraform --version
```
To create a directory for your Terraform configuration, run the following command:
```
mkdir tfinfra
cd tfinfra
```

```
vi provider.tf
```
Copy the code into provider.tf
```
provider "google" {}
```
To initialize Terraform, run the following command:
```
terraform init
```

### Task 2. Create mynetwork and its resources
```
vi mynetwork.tf
```

```
# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
name = "mynetwork"
# RESOURCE properties go here
auto_create_subnetworks = "true"
}
# Add a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
name = "mynetwork-allow-http-ssh-rdp-icmp"
# RESOURCE properties go here
network = google_compute_network.mynetwork.self_link
allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
    }
allow {
    protocol = "icmp"
    }
source_ranges = ["0.0.0.0/0"]
}
# Create the mynet-us-vm instance
module "mynet-us-vm" {
  source           = "./instance"
  instance_name    = "mynet-us-vm"
  instance_zone    = "Zone"
  instance_network = google_compute_network.mynetwork.self_link
}
# Create the mynet-eu-vm" instance
module "mynet-eu-vm" {
  source           = "./instance"
  instance_name    = "mynet-eu-vm"
  instance_zone    = "Zone 2"
  instance_network = google_compute_network.mynetwork.self_link
}
```
Configure the VM instance
```
vi main.tf
```

```
resource "google_compute_instance" "vm_instance" {
  name         = "${var.instance_name}"
  zone         = "${var.instance_zone}"
  machine_type = "${var.instance_type}"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      }
  }
  network_interface {
    network = "${var.instance_network}"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}
```
Define the 4 input variables in variables.tf
```
vi variables.tf
```

```
variable "instance_name" {}
variable "instance_zone" {}
variable "instance_type" {
  default = "e2-micro"
  }
variable "instance_network" {}
```
By giving instance_type a default value, you make the variable optional. The instance_name, instance_zone, and instance_network are required, and you will define them in mynetwork.tf

Add the following VM instances to mynetwork.tf
```

# Create the mynet-us-vm instance
module "mynet-us-vm" {
  source           = "./instance"
  instance_name    = "mynet-us-vm"
  instance_zone    = "Zone"
  instance_network = google_compute_network.mynetwork.self_link
}

# Create the mynet-eu-vm" instance
module "mynet-eu-vm" {
  source           = "./instance"
  instance_name    = "mynet-eu-vm"
  instance_zone    = "Zone 2"
  instance_network = google_compute_network.mynetwork.self_link
}
```
These resources are leveraging the module in the instance folder and provide the name, zone, and network as inputs. Because these instances depend on a VPC network, you are using the google_compute_network.mynetwork.self_link reference to instruct Terraform to resolve these resources in a dependent order. In this case, the network is created before the instance.

Verify that mynetwork.tf looks like this, including brackets {}
```
# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
name = "mynetwork"
# RESOURCE properties go here
auto_create_subnetworks = "true"
}
# Add a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
name = "mynetwork-allow-http-ssh-rdp-icmp"
# RESOURCE properties go here
network = google_compute_network.mynetwork.self_link
allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
    }
allow {
    protocol = "icmp"
    }
source_ranges = ["0.0.0.0/0"]
}
# Create the mynet-us-vm instance
module "mynet-us-vm" {
  source           = "./instance"
  instance_name    = "mynet-us-vm"
  instance_zone    = "Zone"
  instance_network = google_compute_network.mynetwork.self_link
}
# Create the mynet-eu-vm" instance
module "mynet-eu-vm" {
  source           = "./instance"
  instance_name    = "mynet-eu-vm"
  instance_zone    = "Zone 2"
  instance_network = google_compute_network.mynetwork.self_link
}
```

Create mynetwork and its resources:

To rewrite the Terraform configuration files to a canonical format and style, run the following command:
```
terraform fmt
```
To initialize Terraform, run the following command:
```
terraform init
```
To create an execution plan, run the following command:
```
terraform plan
```
To apply the desired changes, run the following command:
```
terraform apply
```
### Task 3. Verify your deployment: In the Cloud Console, verify that the resources were created.
