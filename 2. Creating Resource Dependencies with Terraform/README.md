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
vi project.tf
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

```

```