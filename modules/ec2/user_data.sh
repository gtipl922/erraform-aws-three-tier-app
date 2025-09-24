#!/bin/bash
# modules/ec2/user_data.sh

# Set variables from Terraform template
DB_HOST="${db_host}"
DB_NAME="${db_name}"

# Update system and install nginx
yum update -y
amazon-linux-extras install -y nginx1

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Create a simple HTML page with DB connection info
cat > /usr/share/nginx/html/index.html << EOF
<html>
<head>
    <title>Three-Tier App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .info { background: #f5f5f5; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
 <div class="container">
        <h1>🚀 Welcome to the Three-Tier Application!</h1>
        <div class="info">
            <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
            <p><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
            <p><strong>Database Host:</strong> $DB_HOST</p>
            <p><strong>Database Name:</strong> $DB_NAME</p>
            <p><strong>Deployed with:</strong> Terraform + AWS</p>
        </div>
        <p><em>This is a auto-scaled instance behind a load balancer</em></p>
    </div>
</body>
</html>
EOF

# Set proper permissions
chmod 644 /usr/share/nginx/html/index.html

# Restart nginx to apply changes
systemctl restart nginx

echo "User data script completed successfully!"
