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

Create output values
```
vi outputs.tf
```

```
output "network_IP" {
  value = google_compute_instance.vm_instance.instance_id
  description = "The internal ip address of the instance"
}
output "instance_link" {
  value = google_compute_instance.vm_instance.self_link
  description = "The URI of the created resource."
}
```
Assign a static IP: 

Now add to your configuration by assigning a static IP to the VM instance in instance.tf
```
resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}
```
Update the network_interface configuration for your instance like so:
```
 network_interface {
    network = "default"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }
```
The final code is as shown below.
```
 resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}
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
      nat_ip = google_compute_address.vm_static_ip.address
    }
  }
}
```
#
1. Initialize terraform by running the following command:
```
terraform init
```
2. Run the following command to preview the resources created:
```
terraform plan
```
If prompted, enter the details for the instance creation as shown below:
var.instance_name: myinstance

var.instance_zone: ZONE

3. Run the following command to view the order of resource creation
```
terraform apply
```
If prompted, enter the details for the instance creation as shown below:
var.instance_name: myinstance

var.instance_zone: ZONE

### Task 4. Create Explicit Dependency
Explicit dependencies are used to inform dependencies between resources that are not visible to Terraform. In this example, consider that you will run on your instance that expects to use a specific Cloud Storage bucket, but that dependency is configured inside the application code and thus not visible to Terraform. In that case, you can use depends_on to explicitly declare the dependency.

```
vi exp.tf
```
Add a Cloud Storage bucket and an instance with an explicit dependency on the bucket by adding the following base code into exp.tf:
```
# Create a new instance that uses the bucket
resource "google_compute_instance" "another_instance" {

  name         = "terraform-instance-2"
  machine_type = "e2-micro"
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
  # Tells Terraform that this VM instance must be created only after the
  # storage bucket has been created.
  depends_on = [google_storage_bucket.example_bucket]
}
```
Add the following code to create a bucket.
```
# New resource for the storage bucket our application will use.
resource "google_storage_bucket" "example_bucket" {
  name     = "<UNIQUE-BUCKET-NAME>"
  location = "US"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}
```
The final code is as show below:
```
resource "google_compute_instance" "another_instance" {

  name         = "terraform-instance-2"
  machine_type = "e2-micro"
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
  # Tells Terraform that this VM instance must be created only after the
  # storage bucket has been created.
  depends_on = [google_storage_bucket.example_bucket]
}
resource "google_storage_bucket" "example_bucket" {
  name     = "<UNIQUE-BUCKET-NAME>"
  location = "US"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}
```

```
terraform plan
```
If prompted, enter the details for the instance creation as shown below:

var.instance_name: myinstance

var.instance_zone: ZONE

```
terraform apply
```
If prompted, enter the details for the instance creation as shown below:

var.instance_name: myinstance

var.instance_zone: ZONE


### Task 5. View Dependency Graph
To view resource dependency graph of the resource created, execute the following command
```
terraform graph | dot -Tsvg > graph.svg
```
