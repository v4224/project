#!/bin/bash

DOCKER_USERNAME="hoangvu42"
IMAGES="images.txt"

REPORT_FILE="trivy_scan_images_report.txt"

pull_image() {
  local image_name="${DOCKER_USERNAME}/${1}:latest"

  echo "-----------------------------"
  echo "Pulling image: ${image_name}..."
  echo "-----------------------------"

  docker pull "$image_name"
  if [ $? -ne 0 ];
  then
    echo "Failed to pull image: ${image_name}. Skipping."
    return 1
  fi

  echo "Successfully pulled ${image_name}"
  return 0
}

scan_image() {
  local image_name="${DOCKER_USERNAME}/${1}:latest"

  echo "-----------------------------"
  echo "Scanning image: ${image_name}..."
  echo "-----------------------------"

  echo "---------------------------------" >> "$REPORT_FILE"
  echo "Scanning Image: ${image_name}" >> "$REPORT_FILE"
  echo "---------------------------------" >> "$REPORT_FILE"
  trivy image "$image_name" >> "$REPORT_FILE"
  if [ $? -ne 0 ];
  then
    echo "Failed to scan image: ${image_name}. Check Trivy setup."
    return 1
  fi

  echo "Scan completed for ${image_name}"
  return 0
}

if [ -f "$REPORT_FILE" ];
then
  rm "$REPORT_FILE"
fi
touch "$REPORT_FILE"

for image in "${IMAGES[@]}";
do
  pull_image "$image" && scan_image "$image"
done

echo "Report file: $REPORT_FILE"
