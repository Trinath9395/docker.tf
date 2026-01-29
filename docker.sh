#!/bin/bash
set -euo pipefail

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
