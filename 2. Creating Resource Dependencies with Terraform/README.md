Creating Resource Dependencies with Terraform

## 1. Overview
In this lab, you will create two VMs in the default network. We will use variables to define the VM's attributes at runtime and use output values to print a few resource attributes.

We will then add a static IP address to the first VM to examine how terraform handles implicit dependencies. We will then create a GCS bucket by mentioning explicit dependency to the VM to examine how terraform handles explicit dependency.

## 2. Objectives
In this lab, you learn how to perform the following tasks:

1. Use variables and output values
2. Observe implicit dependency
3. Create explicit resource dependency
