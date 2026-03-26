#!/bin/bash
set -euxo pipefail

# Logs
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# needed packages
dnf update -y
# Add required dependencies for the Jenkins package
sudo dnf install -y fontconfig java-21-amazon-corretto dnf-plugins-core

# jenkins install 
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo dnf upgrade -y


sudo dnf install jenkins -y
sudo systemctl daemon-reload

# Create Jenkins temp directory on the Jenkins disk
mkdir -p /var/lib/jenkins/tmp
chown jenkins:jenkins /var/lib/jenkins/tmp
chmod 700 /var/lib/jenkins/tmp

# Tell Jenkins Java to use that temp directory instead of /tmp
mkdir -p /etc/systemd/system/jenkins.service.d
cat > /etc/systemd/system/jenkins.service.d/override.conf <<'EOF'
[Service]
Environment="JAVA_OPTS=-Djava.io.tmpdir=/var/lib/jenkins/tmp"
EOF


# only if not on EC2
# # Install AWS CLI v2
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# Install Terraform from official repo
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
dnf install -y terraform

# Start and enable Jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins
