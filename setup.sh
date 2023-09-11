#!/bin/bash
clear
cat << "EOF"

██╗  ██╗██╗███████╗███████╗ ██████╗     ██████╗██╗   ██╗██████╗ ███████╗██████╗ ███████╗ ██████╗  ██████╗
██║  ██║██║██╔════╝██╔════╝██╔════╝    ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗██╔════╝
███████║██║███████╗███████╗██║         ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝███████╗██║   ██║██║     
██╔══██║██║╚════██║╚════██║██║         ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗╚════██║██║   ██║██║     
██║  ██║██║███████║███████║╚██████╗    ╚██████╗   ██║   ██████╔╝███████╗██║  ██║███████║╚██████╔╝╚██████╗
╚═╝  ╚═╝╚═╝╚══════╝╚══════╝ ╚═════╝     ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
                                                                                                         
EOF
echo "--------------------------------------------------------------------------------------------------------"
echo "                                  Deploy HISSC MiniSOC Multi Nodes Script"
echo "                            Welcome to the Deploy HISSC MiniSOC Multi Nodes Script"
echo "                             © 2023 HISSC CyberSoc. All rights reserved."
echo "--------------------------------------------------------------------------------------------------------"

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with root privileges or using sudo"
  exit 1
fi

echo "---------------------------------------------------------------------------------------------------------------------"
echo "                                        Install Ansible"
echo "---------------------------------------------------------------------------------------------------------------------"

# Install Ansible package (if not already installed)
if ! command -v ansible &>/dev/null; then
  echo "Installing Ansible..."
  # Use the appropriate package manager (apt, yum, dnf)
  if command -v apt-get &>/dev/null; then
    apt-get update > /dev/null
    apt-get install -y ansible > /dev/null
  elif command -v yum &>/dev/null; then
    yum install -y ansible > /dev/null
  elif command -v dnf &>/dev/null; then
    dnf install -y ansible > /dev/null
  else
    echo "Could not find a suitable package manager. Please install Ansible manually."
    exit 1
  fi
fi

echo "---------------------------------------------------------------------------------------------------------------------"
echo "                                        Install sshpass"
echo "---------------------------------------------------------------------------------------------------------------------"

# Install sshpass package (if not already installed)
if ! command -v sshpass &>/dev/null; then
  echo "Installing sshpass..."
  # Use the appropriate package manager (apt, yum, dnf)
  if command -v apt-get &>/dev/null; then
    apt-get update > /dev/null
    apt-get install -y sshpass > /dev/null
  elif command -v yum &>/dev/null; then
    yum install -y sshpass > /dev/null
  elif command -v dnf &>/dev/null; then
    dnf install -y sshpass > /dev/null
  else
    echo "Could not find a suitable package manager for sshpass. Please install sshpass manually."
    exit 1
  fi
fi

echo "---------------------------------------------------------------------------------------------------------------------"
echo "                                        Check SSH"
echo "---------------------------------------------------------------------------------------------------------------------"

# Specify the path to your inventory file
inventory_file="inventory.ini"

# Read the inventory file and extract host information
while IFS= read -r line; do
  # Check if the line contains host information
  if [[ $line =~ ^[a-zA-Z0-9_]+[[:space:]]+ansible_host=[[:alnum:].]+[[:space:]]+ansible_user=[[:alnum:]]+[[:space:]]+ansible_ssh_pass=[[:alnum:]]+[[:space:]]+ansible_become_pass=[[:alnum:]]+$ ]]; then
    # Extract the hostname or IP address
    host=$(echo "$line" | awk -F 'ansible_host=' '{print $2}' | awk '{print $1}')
    
    # Extract the SSH username
    username=$(echo "$line" | awk -F 'ansible_user=' '{print $2}' | awk '{print $1}')
    
    # Use ssh-keyscan to save the host's fingerprint
    ssh-keyscan -H "$host" >> ~/.ssh/known_hosts
  fi
done < "$inventory_file"

echo "---------------------------------------------------------------------------------------------------------------------"
echo "                                        Start Playbook"
echo "---------------------------------------------------------------------------------------------------------------------"

# Run the Ansible playbook
echo "Running Ansible playbook..."
ansible-playbook -i inventory.ini install_docker_portainer.yml

echo "Ansible and sshpass installation, followed by Ansible playbook execution, completed successfully."
