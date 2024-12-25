#!/bin/bash

declare -A SERVICES
SERVICES=(
  ["auth-service"]="./auth-service"
  ["user-service"]="./profile-service"
  ["task-service"]="./task-service"
  ["todo-frontend"]="./todo-fe"
)

build_and_push() {
  local service_name=$1
  local service_path=$2
  local image_name="${{ secrets.DOCKER_USERNAME }}/${service_name}:latest"

  echo "-----------------------------"
  echo "Building image for ${service_name}..."
  echo "-----------------------------"

  docker build -t "$image_name" "$service_path"
  if [ $? -ne 0 ]; then
    echo "Failed to build image for ${service_name}. Exiting."
    exit 1
  fi

  echo "Successfully built ${image_name}"

  echo "Pushing image to DockerHub..."
  docker push "$image_name"
  if [ $? -ne 0 ]; then
    echo "Failed to push image for ${service_name}. Exiting."
    exit 1
  fi

  echo "Successfully pushed ${image_name} to DockerHub"
}

echo "Login DockerHub..."
docker login -u ${{ secrets.DOCKER_USERNAME }} -p ${{ secrets.DOCKER_TOKEN }}
if [ $? -ne 0 ]; then
  echo "DockerHub login failed. Please check your credentials."
  exit 1
fi

for service in "${!SERVICES[@]}"; do
  build_and_push "$service" "${SERVICES[$service]}"
done