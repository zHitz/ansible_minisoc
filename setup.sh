#!/bin/bash
cat << "EOF"

██╗  ██╗██╗███████╗███████╗ ██████╗     ██████╗██╗   ██╗██████╗ ███████╗██████╗ ███████╗ ██████╗  ██████╗
██║  ██║██║██╔════╝██╔════╝██╔════╝    ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗██╔════╝
███████║██║███████╗███████╗██║         ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝███████╗██║   ██║██║     
██╔══██║██║╚════██║╚════██║██║         ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗╚════██║██║   ██║██║     
██║  ██║██║███████║███████║╚██████╗    ╚██████╗   ██║   ██████╔╝███████╗██║  ██║███████║╚██████╔╝╚██████╗
╚═╝  ╚═╝╚═╝╚══════╝╚══════╝ ╚═════╝     ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
                                                                                                         
EOF
# Kiểm tra xem script được chạy với quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script này với quyền root hoặc sử dụng sudo"
  exit 1
fi
echo "---------------------------------------------------------------------------------------------------------------------"
echo "                                        Install Ansible"
echo "---------------------------------------------------------------------------------------------------------------------"

# Cài đặt gói Ansible (nếu chưa được cài đặt)
if ! command -v ansible &>/dev/null; then
  echo "Cài đặt gói Ansible..."
  # Sử dụng trình quản lý gói tương ứng (apt, yum, dnf)
  if command -v apt-get &>/dev/null; then
    apt-get update
    apt-get install -y ansible
  elif command -v yum &>/dev/null; then
    yum install -y ansible
  elif command -v dnf &>/dev/null; then
    dnf install -y ansible
  else
    echo "Không tìm thấy trình quản lý gói phù hợp. Hãy cài đặt Ansible bằng cách thủ công."
    exit 1
  fi
fi
echo "---------------------------------------------------------------------------------------------------------------------"
echo "                                        Install sshpass"
echo "---------------------------------------------------------------------------------------------------------------------"

# Cài đặt gói sshpass (nếu chưa được cài đặt)
if ! command -v sshpass &>/dev/null; then
  echo "Cài đặt gói sshpass..."
  # Sử dụng trình quản lý gói tương ứng (apt, yum, dnf)
  if command -v apt-get &>/dev/null; then
    apt-get update
    apt-get install -y sshpass
  elif command -v yum &>/dev/null; then
    yum install -y sshpass
  elif command -v dnf &>/dev/null; then
    dnf install -y sshpass
  else
    echo "Không tìm thấy trình quản lý gói phù hợp cho sshpass. Hãy cài đặt sshpass bằng cách thủ công."
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

# Chạy playbook Ansible
echo "Chạy playbook Ansible..."
ansible-playbook -i inventory.ini install_docker_portainer.yml

echo "Cài đặt Ansible và sshpass, sau đó chạy playbook Ansible thành công"
