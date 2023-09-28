sudo apt update
sudo apt install linux-azure -y  #It will install azure kernel(Used to get IP for VM)
sudo apt install openssh-server openssh-client -y
echo 'ALL ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers



