#!/bin/bash
yum update -y

# Install required tools if not already installed by Packer
amazon-linux-extras install -y docker
systemctl enable docker
systemctl start docker

# Install AWS CLI if not already installed
yum install -y awscli jq

# Set environment variables
export DB_HOST=$(aws ssm get-parameter --name /app/db/host --query Parameter.Value --output text)
export DB_NAME=$(aws ssm get-parameter --name /app/db/name --query Parameter.Value --output text)
export DB_USER=$(aws ssm get-parameter --name /app/db/user --query Parameter.Value --output text)
export DB_PASSWORD=$(aws ssm get-parameter --name /app/db/password --with-decryption --query Parameter.Value --output text)

# Login to JFrog Artifactory
aws secretsmanager get-secret-value --secret-id jfrog-credentials --query SecretString --output text | jq -r . > /tmp/jfrog-creds.json
JFROG_USER=$(cat /tmp/jfrog-creds.json | jq -r .username)
JFROG_PASSWORD=$(cat /tmp/jfrog-creds.json | jq -r .password)
JFROG_URL=$(cat /tmp/jfrog-creds.json | jq -r .url)

echo "$JFROG_PASSWORD" | docker login $JFROG_URL -u $JFROG_USER --password-stdin

# Pull the Docker image
docker pull $JFROG_URL/your-java-app:latest

# Run the container
docker run -d \
  --name java-app \
  -p 8080:8080 \
  -e DB_HOST=$DB_HOST \
  -e DB_NAME=$DB_NAME \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  $JFROG_URL/your-java-app:latest

# Enable and start container on boot
cat > /etc/systemd/system/docker-java-app.service << EOF
[Unit]
Description=Java Application Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a java-app
ExecStop=/usr/bin/docker stop -t 2 java-app
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable docker-java-app.service
systemctl start docker-java-app.service

# Setup CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/ec2/app/system",
            "log_stream_name": "{instance_id}-system"
          },
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "/ec2/app/docker",
            "log_stream_name": "{instance_id}-docker"
          }
        ]
      }
    }
  }
}
EOF

# Start the CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent