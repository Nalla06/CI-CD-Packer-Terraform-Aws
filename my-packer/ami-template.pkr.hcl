packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

source "amazon-ebs" "my_ami" {
  region           = "us-east-1"
  source_ami       = "ami-08b5b3a93ed654d19"  # Linux (Change if needed)
  instance_type    = "t3.micro"
  ssh_username     = "ec2-user"
  ami_name         = "custom-ami-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.my_ami"]
  
  provisioner "shell" {
    inline = [
      "set -eux",
      "sudo touch /var/log/packer-provisioning.log",
      "echo 'Starting provisioning at $(date)' | sudo tee -a /var/log/packer-provisioning.log",
      
      "echo 'Updating system packages...' | sudo tee -a /var/log/packer-provisioning.log",
      "sudo yum update -y | sudo tee -a /var/log/packer-provisioning.log",
      
      "echo 'Installing CloudWatch Agent...' | sudo tee -a /var/log/packer-provisioning.log",
      "sudo yum install -y amazon-cloudwatch-agent | sudo tee -a /var/log/packer-provisioning.log",
      
      "echo 'Installing AWS SSM Agent...' | sudo tee -a /var/log/packer-provisioning.log",
      "sudo yum install -y amazon-ssm-agent | sudo tee -a /var/log/packer-provisioning.log",
      "sudo systemctl enable amazon-ssm-agent | sudo tee -a /var/log/packer-provisioning.log",
      "sudo systemctl start amazon-ssm-agent | sudo tee -a /var/log/packer-provisioning.log",
      
      "echo 'Installing Docker...' | sudo tee -a /var/log/packer-provisioning.log",
      "sudo yum install -y docker | sudo tee -a /var/log/packer-provisioning.log",
      "sudo systemctl enable docker | sudo tee -a /var/log/packer-provisioning.log",
      "sudo systemctl start docker | sudo tee -a /var/log/packer-provisioning.log",
      "sudo usermod -aG docker ec2-user | sudo tee -a /var/log/packer-provisioning.log",
      
      "echo 'Installing Git...' | sudo tee -a /var/log/packer-provisioning.log",
      "sudo yum install -y git | sudo tee -a /var/log/packer-provisioning.log",
      
      "echo 'Verifying installations...' | sudo tee -a /var/log/packer-provisioning.log",
      "docker --version | sudo tee -a /var/log/packer-provisioning.log || echo 'Docker not properly installed' | sudo tee -a /var/log/packer-provisioning.log",
      "git --version | sudo tee -a /var/log/packer-provisioning.log || echo 'Git not properly installed' | sudo tee -a /var/log/packer-provisioning.log",
      "amazon-cloudwatch-agent-ctl -a status | sudo tee -a /var/log/packer-provisioning.log || echo 'CloudWatch agent not properly configured' | sudo tee -a /var/log/packer-provisioning.log",
      "systemctl status amazon-ssm-agent | sudo tee -a /var/log/packer-provisioning.log || echo 'SSM agent not properly running' | sudo tee -a /var/log/packer-provisioning.log",
      
      "echo 'Provisioning completed at $(date)' | sudo tee -a /var/log/packer-provisioning.log"
    ]
  }
}