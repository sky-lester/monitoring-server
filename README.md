# Setup Grafana, Prometheus and Ansible on Rocky Linux Server

## Create a Control User

```
sudo useradd -m -s /bin/bash monitor
echo "monitor ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/monitor
sudo chmod 0440 /etc/sudoers.d/monitor
sudo su - monitor
```

## Download setup.sh and make it executable

```
curl -L -o setup.sh https://raw.githubusercontent.com/sky-lester/monitoring-server/refs/heads/main/setup.sh && sudo chmod +x setup.sh
```
