resource "aws_instance" "jenkins-master-terra" {
  ami = var.ami
  instance_type = var.instance-type
  key_name = "key-ahmad"
  associate_public_ip_address = true
  security_groups = [ var.sg-group ]
  subnet_id = var.subnet1
  iam_instance_profile = "ec2-CloudWatchAgent-SSM"

    user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install default-jre -y
    sudo apt install default-jdk -y

    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update
    sudo apt install jenkins -y

    # Ensure Jenkins is running. Use ctrl+z to exit
    sudo systemctl status jenkins
    EOF
    )

  tags = {
    "Name" = "Jekins-master-terra"
    "owner" = "ahmad"
    "jekins" = "master"
  }
}

resource "aws_instance" "jenkins-slave-terra" {
  ami = var.ami
  instance_type = "t3.micro"
  key_name = "key-ahmad"
  associate_public_ip_address = true
  security_groups = [ var.sg-group ]
  subnet_id = var.subnet2
  iam_instance_profile = "ec2-CloudWatchAgent-SSM"
    user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install default-jre -y
    sudo apt install default-jdk -y
    sudo apt install jq -y
    sudo apt install unzip -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    sudo apt-get install ca-certificates curl gnupg

    # Add Docker official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Use the following command to set up the repository
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the apt package index
    sudo apt update

    # Install the latest version of Docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo reboot
    sudo docker run hello-world

    EOF
    )

  tags = {
    "Name" = "Jenkins-slave-terra"
    "owner" = "ahmad"
    "jekins" = "slave"
  }
}