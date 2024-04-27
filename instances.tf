data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = var.instances[0].type
  subnet_id                   = module.network.public1_subnet_id
  security_groups             = [aws_security_group.sg_allow_ssh_and_3000.id]
  associate_public_ip_address = "${var.instances[0].is_public}"
  key_name                    = aws_key_pair.ssh_key.key_name

  provisioner "file" {
    content     = tls_private_key.tls_pk.private_key_pem
    destination = "/home/ec2-user/.ssh/id_rsa"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = tls_private_key.tls_pk.private_key_openssh
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/.ssh/id_rsa"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = tls_private_key.tls_pk.private_key_openssh
    }
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> inventory"
  }

  tags = {
    Name = "${var.instances[0].name}"
  }
}

resource "aws_instance" "application" {
  ami             = data.aws_ami.amzn-linux-2023-ami.id
  instance_type   = "${var.instances[1].type}"
  subnet_id       = module.network.private1_subnet_id
  security_groups = [aws_security_group.sg_allow_ssh_from_vpc.id]
  key_name        = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "${var.instances[1].name}"
  }
}
