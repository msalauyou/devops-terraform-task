#!/bin/bash
sudo apt update -y
sudo apt install -y apache2

sudo systemctl start apache2
sudo systemctl enable apache2

OS_VERSION=$(lsb_release -d | cut -f2)
DISK_USAGE=$(df -h / | grep / | awk '{print $4}')
MEMORY_USAGE=$(free -m | grep Mem | awk '{print "Free: "$7" MB, Used: "$3" MB"}')
RUNNING_PROCESSES=$(ps -e --no-headers | wc -l)

cat <<EOM > /var/www/html/index.html
<html>
  <head><title>System Info</title></head>
  <body>
    <h1>Hello World!</h1>
    <p><strong>OS Version:</strong> $OS_VERSION</p>
    <p><strong>Free Disk Space:</strong> $DISK_USAGE</p>
    <p><strong>Memory Usage:</strong> $MEMORY_USAGE</p>
    <p><strong>Number of Running Processes:</strong> $RUNNING_PROCESSES</p>
  </body>
</html>
EOM

sudo systemctl restart apache2

sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt update -y

sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
