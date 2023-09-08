#!/bin/bash

# Kiểm tra xem script được chạy với quyền root hay không
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script này với quyền root hoặc sử dụng sudo"
  exit 1
fi

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

# Chạy playbook Ansible
echo "Chạy playbook Ansible..."
ansible-playbook -i inventory.ini install_docker_portainer.yml

echo "Cài đặt Ansible và sshpass, sau đó chạy playbook Ansible thành công"
