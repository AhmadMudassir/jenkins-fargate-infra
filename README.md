# 🚀 Terraform + ECS Fargate + Jenkins Master/Slave CI/CD Project

This project provisions a **complete CI/CD environment** on AWS using
**Terraform**.\
It sets up the networking, Jenkins (master/slave), and an **ECS Fargate
cluster** with an **Application Load Balancer (ALB)** to deploy
containerized applications.\
The CI/CD pipeline uses **Jenkins** to build and push Docker images to
**Amazon ECR** and then deploys them to ECS.

------------------------------------------------------------------------

## 📂 Project Overview

### Infrastructure Provisioned with Terraform

-   **VPC** -- Custom VPC with public/private subnets, route tables, and
    internet/NAT gateways.\
-   **ECS (Fargate)** -- Cluster with task definitions and ECS services
    for application deployment.\
-   **ALB** -- Application Load Balancer to expose ECS services.\
-   **ECR** -- Private registry to store Docker images built by
    Jenkins.\
-   **EC2 (Jenkins Master & Slave)** -- EC2 instances provisioned for
    Jenkins master and build slave agents.\
-   **IAM Roles & Policies** -- To allow Jenkins to push to ECR and
    trigger ECS deployments.\
-   **CloudWatch Logs** -- Centralized logging for ECS tasks and
    Jenkins.

<img width="1014" height="591" alt="jenkins-fargate-architect-dark" src="https://github.com/user-attachments/assets/fda1b71c-f12a-40d7-883a-ad89649c3769" />


### Jenkins Setup

-   **Master node** -- Runs Jenkins server with necessary plugins.\
-   **Slave node(s)** -- Auto-connected via SSH to handle builds and
    Docker image creation.\
-   **ECR Authentication** -- Jenkins authenticates to ECR for pushing
    images.\
-   **Pipeline** -- Automates build, push, and ECS deploy.

------------------------------------------------------------------------

## 🔄 CI/CD Workflow

1.  **Code Push**\
    Developer pushes code changes to the **main branch** of this
    repository.

2.  **Jenkins Pipeline Triggered**

    -   Jenkins checks out this repo (`git` plugin points to this
        repo).\
    -   Builds a Docker image for the application.\
    -   Tags the image with commit SHA or build number.

3.  **Push to Amazon ECR**

    -   Jenkins logs in to ECR.\
    -   Pushes the built image.

4.  **Deploy to ECS Fargate**

    -   ECS task definition is updated with the new image.\
    -   ECS service performs rolling deployment via the ALB.

5.  **Accessible Application**

    -   ALB DNS name provides access to the running app.

------------------------------------------------------------------------

## 📌 Jenkins Pipeline Notes

-   Jenkinsfile is configured to **use this repo directly**.\
-   Example Git checkout in pipeline:

``` groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-org/your-repo.git'
            }
        }
    }
}
```

> Replace `your-org/your-repo.git` with the actual repo URL.\
> This ensures the pipeline always pulls from **this project
> repository**.

------------------------------------------------------------------------

## 📖 How to Use

### 1️⃣ Clone the Repository

``` bash
git clone https://github.com/your-org/your-repo.git
cd your-repo
```

### 2️⃣ Initialize Terraform

``` bash
terraform init
```

### 3️⃣ Apply Infrastructure

``` bash
terraform apply
```

This provisions VPC, ECS, ECR, Jenkins master/slave EC2 instances, and
ALB.

### 4️⃣ Configure Jenkins

-   Access Jenkins via the EC2 public IP.\
-   Install recommended plugins (`Pipeline`, `Git`, `ECS`, `ECR`).\
-   Configure Jenkins credentials for AWS (IAM user with permissions).

### 5️⃣ Run the Pipeline

-   Push changes to the `main` branch.\
-   Jenkins triggers the pipeline and deploys to ECS automatically.

------------------------------------------------------------------------

## 🎯 Key Features

-   Fully automated AWS infrastructure with **Terraform**.\
-   Jenkins **master/slave** setup for distributed builds.\
-   CI/CD pipeline for Dockerized apps.\
-   **ECR + ECS Fargate + ALB** integration for seamless deployment.\
-   Logs and monitoring with **CloudWatch**.

------------------------------------------------------------------------

## 📜 License

This project is licensed under the MIT License -- feel free to use and
adapt it.
