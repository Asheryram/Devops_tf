#!/bin/bash
set -e

############################ 
# SYSTEM SETUP
############################
apt-get update -y
apt-get install -y curl git awscli jq netcat

############################ 
# INSTALL NODE.JS 18
############################
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

############################ 
# APP DIRECTORY
############################
mkdir -p /opt/todo-app
cd /opt/todo-app

############################ 
# CLONE APP FROM GITHUB
############################
git clone https://github.com/Asheryram/todo-app.git .
npm install

############################ 
# RETRIEVE CREDENTIALS FROM SECRETS MANAGER
############################
CREDENTIALS=$( aws secretsmanager get-secret-value \
  --secret-id ${db_credentials_secret_id} \
  --region ${aws_region} \
  --query SecretString \
  --output text )

DB_USER=$(echo $CREDENTIALS | jq -r '.username')
DB_PASSWORD=$(echo $CREDENTIALS | jq -r '.password')

############################ 
# EXPORT ENV VARIABLES
############################
cat << ENV > /etc/profile.d/todo-env.sh
export PORT=3000
export DB_HOST="${db_host}"
export DB_USER="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export DB_NAME="${db_name}"
export DB_PORT="${db_port}"
ENV

source /etc/profile.d/todo-env.sh

############################ 
# WAIT FOR DATABASE TO BE READY
############################
echo "⏳ Waiting for database to be reachable..."
until nc -z ${db_host} ${db_port}; do
  echo "Waiting for DB at ${db_host}:${db_port}..."
  sleep 5
done
echo "✅ Database reachable!"

############################ 
# START APPLICATION
############################
cd /opt/todo-app
nohup node server.js > app.log 2>&1 &

############################ 
# CONFIRM APP IS RUNNING
############################
sleep 5
if curl -s http://localhost:3000/health | grep -q "OK"; then
  echo "✅ App started successfully"
else
  echo "❌ App failed to start. Check app.log"
fi