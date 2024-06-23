pipeline {
    agent any

    stages {
        stage("List files"){
            steps {
                sh 'pwd'
                sh 'ls -ltr'
            }
        }
        stage("Terraform Destroy"){
            steps {
                sh 'terraform destroy -auto-approve'
            }
        }
        stage("Terraform init"){
            steps {
                sh 'terraform init'
            }
        }
        stage("Terraform plan"){
            steps {
                sh 'terraform plan'
            }
        }
        stage("Terraform apply"){
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
        stage("terraform destroy"){
            steps {
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}
