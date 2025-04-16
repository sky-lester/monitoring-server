#!/bin/bash

# Install Docker
echo "Installing Docker..."
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io git docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Apply group change immediately
export DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3)
sudo newgrp docker <<EONG
    echo "Reloading user groups..."
    sudo usermod -aG docker $USER
EONG

# Install Ansible
echo "Installing Ansible..."
sudo dnf remove -y ansible
sudo dnf install -y python3-pip
pip3 install --upgrade pip --user
pip3 install ansible --user

git clone https://github.com/sky-lester/monitoring-server.git

# # Run Prometheus in Docker
# echo "Starting Prometheus..."
# sudo docker run -d --name=prometheus \
#   -p 9090:9090 \
#   -v ~/monitoring-server/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
#   prom/prometheus

# # Run Grafana in Docker
# echo "Installing and starting Grafana..."
# sudo docker run -d --name=grafana \
#   -p 3000:3000 \
#   grafana/grafana

cd ~/monitoring-server
docker compose up -d

PUBLIC_IP=$(curl -s http://icanhazip.com)

echo "Installation complete!"
echo "Access Grafana at http://${PUBLIC_IP}:3000"
echo "Access Prometheus at http://${PUBLIC_IP}:9090"


# Generate SSH key pair for current user if not already existing
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Generating SSH key pair..."
  mkdir -p ~/.ssh
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
  echo "SSH public key:"
  cat ~/.ssh/id_rsa.pub
else
  echo "SSH key already exists at ~/.ssh/id_rsa"
fi

# Prompt user to run Ansible playbook manually
echo "Copy the .pem file to the ~/.ssh directory"
echo "scp ~/.ssh/id_rsa.pub dev1@${PUBLIC_IP}:~/.ssh/."
echo "To install playbook, run: ansible-playbook -i ~/monitoring-server/ansible/inventory.ini ~/monitoring-server/playbook.yml"


cat <<EOF > ./run_command.txt
ansible-playbook -i ~/monitoring-server/ansible/inventory.ini ~/monitoring-server/ansible/playbook.yml
EOF