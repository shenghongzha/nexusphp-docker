#!/bin/bash

set -e

CodePath="./NexusPHP"
DataPath="./data"
LogPath="./log"

# Remove the code directory if it exists
if [ -d "$CodePath" ]; then
    rm -rf "$CodePath"
fi

# Remove the data directory if it exists
if [ -d "$DataPath" ]; then
    rm -rf "$DataPath"
fi

# Remove the log directory if it exists
if [ -d "$LogPath" ]; then
    rm -rf "$LogPath"
fi

# Clone the repository
git submodule update

# Wait for 5 seconds to finish cloning
sleep 5

# Copy the install files to the public directory
sourceDir="./NexusPHP/nexus/Install/install"
targetDir="./NexusPHP/public/install"

# Retry copying files if sourceDir exists
while [ ! -d "$sourceDir" ]; do
    sleep 5
done

mkdir -p "$targetDir"
cp -r "$sourceDir/"* "$targetDir/"

# Function to generate a random password
generate_password() {
    local length=$1
    local charset=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789
    local password=""
    
    for ((i=0; i<length; i++)); do
        local index=$((RANDOM % ${#charset}))
        password+="${charset:$index:1}"
    done
    
    echo "$password"
}

# Generate MySQL and Redis passwords
mysqlpassword=$(generate_password 16)
redispassword=$(generate_password 16)

# Save passwords to a .env file for Docker Compose
{
    echo "MYSQL_ROOT_PASSWORD=$mysqlpassword"
    echo "REDIS_PASSWORD=$redispassword"
} > docker-compose/.env

# Start the application
./start.sh

# Set the SQL script path
CONTAINER_NAME="pt-mysql"
SQL_SCRIPT_PATH="./docker-compose/sql/install.sql"
CONTAINER_SQL_SCRIPT_PATH="/opt/install.sql"

# Copy the SQL script to the container
docker cp "$SQL_SCRIPT_PATH" "$CONTAINER_NAME":"$CONTAINER_SQL_SCRIPT_PATH"

# Execute the SQL script
if ! docker exec -i "$CONTAINER_NAME" mysql -u root -p"$mysqlpassword" < "$CONTAINER_SQL_SCRIPT_PATH"; then
    echo "SQL script execution failed!"
    echo "Please create the database 'nexusphp' using the following command:"
    echo "create database nexusphp default charset=utf8mb4 collate utf8mb4_general_ci;"
else
    echo "SQL script executed successfully!"
fi

echo "Installation completed"