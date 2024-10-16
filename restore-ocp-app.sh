#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <project-name> <backup-directory> Missing namespace and Directory arguements"
  exit 1
fi

# Define your project/namespace from the first argument
PROJECT="$1"

# Define the backup directory from the second argument
BACKUP_DIR="$2"

# Function to check the status of resources
check_resource() {
  local resource_type=$1
  local resource_name=$2
  local namespace=$3

  # Wait for the resource to be ready
  echo "Checking $resource_type: $resource_name..."
  for i in {1..10}; do
    if oc get "$resource_type" "$resource_name" -n "$namespace" &> /dev/null; then
      echo "$resource_type $resource_name is present."
      return 0
    fi
    echo "Waiting for $resource_type $resource_name to be created..."
    sleep 5
  done
  echo "Error: $resource_type $resource_name not found after 50 seconds."
  return 1
}

# Restore resources
echo "Restoring resources from $BACKUP_DIR..."

# Loop through the resource files in the backup directory
for file in "$BACKUP_DIR"/*.yaml; do
  echo "Applying $file..."
  oc apply -f "$file" -n "$PROJECT"

  # Extract the resource type and name from the YAML file
  resource_type=$(basename "$file" | sed 's/.yaml//')
  resource_name=$(oc get "$resource_type" -n "$PROJECT" -o jsonpath='{.items[-1].metadata.name}')

  # Check if the resource was restored successfully
  if check_resource "$resource_type" "$resource_name" "$PROJECT"; then
    echo "$resource_type $resource_name restored successfully."
  else
    echo "Failed to restore $resource_type $resource_name."
    exit 1
  fi
done

echo "All resources have been processed."
echo "Restore completed."

