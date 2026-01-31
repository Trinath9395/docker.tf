#!/bin/bash
set -euo pipefail
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

# Expand disk
growpart /dev/nvme0n1 4 || true
lvextend -l +50%FREE /dev/RootVG/rootVol || true
lvextend -l +50%FREE /dev/RootVG/varVol || true
xfs_growfs /
xfs_growfs /var

# Install Docker
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

#kubectl installation
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.0/2024-12-20/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv kubectl /usr/local/bin/kubectl

#eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
mv /tmp/eksctl /usr/local/bin
