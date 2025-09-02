# Terraform AWS Infrastructure with Jenkins and ECS

## 📖 Overview
This project provisions a complete AWS environment using **Terraform**, including:
- **VPC** with public subnets, internet gateway, and routing
- **Security Groups** for HTTP, SSH, and Jenkins access
- **EC2 Instances** for Jenkins Master and Slave
- **ECR Repository** to store Docker images
- **ECS Cluster (Fargate)** to run containerized workloads
- **Application Load Balancer (ALB)** for ECS services
- **CloudWatch Log Group** for ECS logging

A **Jenkins pipeline** is used to build, push, and deploy a Node.js application from GitHub into ECS.

---

## 📂 Project Structure
```
.
├── main.tf
├── modules
│   ├── cloudwatch
│   ├── ec2
│   ├── ecs
│   └── vpc
├── terraform.tfvars
├── terraform.tfstate
└── variables.tf
```
### Modules
- **modules/vpc** → VPC, subnets, IGW, route tables, security groups
- **modules/ec2** → EC2 instances (Jenkins master and slave)
- **modules/ecs** → ECS cluster, task definition, service, and ALB
- **modules/cloudwatch** → Log group for ECS
- **main.tf** → Root module combining everything

---

<img width="1014" height="591" alt="jenkins-fargate-architect-dark" src="https://github.com/user-attachments/assets/c09b08d0-c9aa-4589-a4f9-9c3652be20e7" />

## ✅ Prerequisites
- Terraform installed locally (`>=1.3` recommended)
- AWS CLI installed and configured
- Docker installed locally (to push images to ECR)
- SSH key pair created in AWS (`key-ahmad` used here)
- IAM role: `ecsTaskExecutionRole` with ECS/ECR/CloudWatch permissions
- Jenkins plugins:
  - Docker Pipeline
  - Amazon ECR
  - AWS Credentials
  - Pipeline

---

## ⚡ Deployment Steps

### 1️⃣ Clone this repository
```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### 2️⃣ Initialize Terraform
```bash
terraform init
```

### 3️⃣ Review variables
Edit `terraform.tfvars` and `variables.tf` with your:
- VPC CIDRs
- AMI ID
- Instance type
- AWS region

### 4️⃣ Plan and Apply
```bash
terraform plan
terraform apply -auto-approve
```

This provisions:
- Jenkins master (EC2)
- Jenkins slave (EC2)
- ECS Fargate cluster + service
- ECR repository
- ALB for ECS service

---

## 🔧 Jenkins Setup

### Jenkins Master (EC2)
- Connect via SSH to the **Jenkins Master** instance
- Access Jenkins at `http://<Jenkins-Master-Public-IP>:8080`
- Install recommended plugins
- Create an **admin user**

### Jenkins Slave (EC2)
- **Important:** The Jenkins slave does **not auto-connect** to the master
- Go to **Manage Jenkins → Nodes → New Node**
- Add a node (label: `linux-slave`) with the slave’s IP
- Use SSH to connect Jenkins master → slave

### Credentials in Jenkins
Add the following credentials in Jenkins:
- **AWS Account ID** (`aws-account-id`) → String credential
- **AWS Access/Secret Keys** (`aws-jenkins`) → AWS credential type

---

## 🛠 Jenkins Pipeline

The pipeline will:
1. Clone your **application repo**:  
   👉 `https://github.com/AhmadMudassir/demo-node-app.git` (branch: `main`)
2. Build a Docker image
3. Push image to **ECR**
4. Update ECS service with the new image

### Sample Pipeline (`Jenkinsfile`)
```groovy
pipeline {
    agent { label 'linux-slave' }

    environment {
        AWS_DEFAULT_REGION = "us-east-2"
        CLUSTER_NAME = "ahmad-ecs-cluster-terra"
        SERVICE_NAME = "ahmad-service-terra"
        TASK_DEFINITION_NAME = "ahmad-taskdef-terra"
        DESIRED_COUNT = "2"
        IMAGE_REPO_NAME = "ahmad-repo-terra"
        IMAGE_TAG = "${env.BUILD_ID}"
        registryCredential = "aws-jenkins"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/AhmadMudassir/demo-node-app.git'
            }
        }

        stage('Build and Push Image') {
            steps {
                withCredentials([string(credentialsId: 'aws-account-id', variable: 'AWS_ACCOUNT_ID')]) {
                    script {
                        def REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
                        dockerImage = docker.build("${IMAGE_REPO_NAME}:${IMAGE_TAG}")

                        docker.withRegistry("https://${REPOSITORY_URI}", "ecr:${AWS_DEFAULT_REGION}:${registryCredential}") {
                            dockerImage.push()
                        }
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withCredentials([string(credentialsId: 'aws-account-id', variable: 'AWS_ACCOUNT_ID')]) {
                    withAWS(credentials: registryCredential, region: "${AWS_DEFAULT_REGION}") {
                        script {
                            env.REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
                            sh 'chmod +x script.sh && ./script.sh'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -a -f'
        }
    }
}
```

---

## 📝 Notes
- Jenkins slave must be manually registered with the master.
- The pipeline uses the `main` branch of [demo-node-app](https://github.com/AhmadMudassir/demo-node-app.git).
- Make sure AWS credentials and Docker credentials are stored in Jenkins before running.
- The ECS service will redeploy with the new image whenever the pipeline runs.

---
