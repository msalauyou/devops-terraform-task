output "ubuntu_ami" {
  value = data.aws_ami.ubuntu.id
}

output "amazon_linux_ami" {
  value = data.aws_ami.amazon_linux.id
}

output "ubuntu_public_ip" {
  value = aws_instance.ubuntu.public_ip
}