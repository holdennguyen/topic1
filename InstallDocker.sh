#!/bin/bash

# Update the installed packages and package cache
yum update -y

# Install the most recent Docker Engine package
amazon-linux-extras install docker -y

# Start the Docker service
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group (execute without using sudo)
usermod -a -G docker ec2-user

# Install Docker Compose dependencies
yum install -y curl python3-pip

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make the Docker Compose binary executable
chmod +x /usr/local/bin/docker-compose

# Install Git
yum install git