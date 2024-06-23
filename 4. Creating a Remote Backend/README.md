Creating a Remote Backend

## 1. Overview
In this lab, you will create a local backend and then create a Cloud Storage bucket to migrate the state to a remote backend

## 2. Objectives
In this lab, you will learn how to perform the following tasks:

1. Create a local backend.
2. Create a Cloud Storage backend.
3. Refresh your Terraform state.

### Task 1. Sign in to the Cloud Console
### Task 2. Verify Terraform is installed
```
terraform --version
```

### Task 3. Add a local backend
In this section, you will configure a local backend which will then be moved to a Cloud Storage bucket.
```
vi main.tf
```
To retrieve your Project ID, run the following command:
```
gcloud config list --format 'value(core.project)'
```
Copy the Cloud Storage bucket resource code into your main.tf configuration file:
```
provider "google" {
  project     = "Project ID"
  region      = "Region"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
}
```
Add a local backend to your main.tf file:
```
terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
```
The final code in main.tf is as shown below.
```
provider "google" {
  project     = "Project ID"
  region      = "Region"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
}
terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
```

```
terraform init
```

```
terraform apply
```
Examine your state file:
```
terraform show
```
Your google_storage_bucket.test-bucket-for-state resource should be displayed.

### Task 4. Add a Cloud Storage backend
1. Navigate back to your main.tf file in the editor. You will now replace the current local backend with a gcs backend.
2. To change the existing local backend configuration, replace the code for local backend with the following configuration in the main.tf file.
```
terraform {
  backend "gcs" {
    bucket  = "Project ID"
    prefix  = "terraform/state"
  }
}
```
The final code in main.tf is as shown below:
```
provider "google" {
  project     = "Project ID"
  region      = "Region"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
}
terraform {
  backend "gcs" {
    bucket  = "Project ID"
    prefix  = "terraform/state"
  }
}
```
3. Initialize your backend again. Type yes at the prompt to confirm.
```
terraform init -migrate-state
```
### Task 6. Clean up the workspace
1. First, revert your backend to local so you can delete the storage bucket. Copy and replace the gcs configuration with the following:
```
terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
```
2. Initialize the local backend again. Type yes at the prompt to confirm.
```
terraform init -migrate-state
```
3. In the main.tf file, add the force_destroy = true argument to your google_storage_bucket resource. When you delete a bucket, this boolean option will delete all contained objects.
```

resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
  force_destroy = true
}
```
4. Apply the changes. Type yes at the prompt to confirm.
```
terraform apply
```
5. You can now successfully destroy your infrastructure. Type yes at the prompt to confirm.
```
terraform destroy
```
