#!/bin/bash

set -e

# Function to get user input
ask_mysql() {
    read -p "Do you want to start MySQL service? [Y/n] " mysql_input
    mysql_choice=${mysql_input:-y}
}

ask_redis() {
    read -p "Do you want to start Redis service? [Y/n] " redis_input
    redis_choice=${redis_input:-y}
}

ask_mysql
ask_redis

# Initialize the passwords
mysqlpassword=""
redispassword=""

# Get the passwords from the .env file
while IFS='=' read -r key value; do
    case "$key" in
        MYSQL_ROOT_PASSWORD) mysqlpassword="$value" ;;
        REDIS_PASSWORD) redispassword="$value" ;;
    esac
done < <(grep -E 'MYSQL_ROOT_PASSWORD|REDIS_PASSWORD' docker-compose/.env)

# Determine which docker-compose file to use
if [[ "$mysql_choice$redis_choice" == "nn" ]]; then
    echo "Starting services with docker-compose.yml..."
    docker-compose up -d
elif [[ "$mysql_choice$redis_choice" == "yn" ]]; then
    echo "Root MySQL password: $mysqlpassword"
    docker-compose -f docker-compose/docker-compose10.yml up -d
elif [[ "$mysql_choice$redis_choice" == "ny" ]]; then
    echo "Redis password: $redispassword"
    docker-compose -f docker-compose/docker-compose01.yml up -d
elif [[ "$mysql_choice$redis_choice" == "yy" ]]; then
    echo "Root MySQL password: $mysqlpassword"
    echo "Redis password: $redispassword"
    docker-compose -f docker-compose/docker-compose11.yml up -d
else
    echo "Unexpected case. Please check your input."
    exit 1
fi

# Set the container name and bash script path
CONTAINER_NAME="pt-php"
BASH_SCRIPT_PATH="./docker-compose/sh/timetask.sh"
CONTAINER_BASH_SCRIPT_PATH="/opt/timetask.sh"

# Copy the bash script to the container
docker cp "$BASH_SCRIPT_PATH" "$CONTAINER_NAME":"$CONTAINER_BASH_SCRIPT_PATH"

# Execute the bash script in the container
if ! docker exec -it "$CONTAINER_NAME" sh -c "sh $CONTAINER_BASH_SCRIPT_PATH"; then
    echo "Timed task script execution failed!"
    echo "Please enter the container and execute related commands manually."
else
    echo "Timed task script executed successfully!"
fi