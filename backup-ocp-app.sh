#!/bin/bash

# Define your default namespace (change this to your project's default namespace)
DEFAULT_NAMESPACE="helloworld"

# Prompt for the namespace
read -p "Enter the namespace (leave empty for default '$DEFAULT_NAMESPACE'): " NAMESPACE

# Use the default namespace if none is provided
NAMESPACE="${NAMESPACE:-$DEFAULT_NAMESPACE}"

# Create a directory to store the backups
BACKUP_DIR="ocp-backup-$NAMESPACE-$(date +%Y%m%d%H%M)"
mkdir -p "$BACKUP_DIR"

# List of resources to back up
resources=(
  "configmaps"
  "secrets"
  "deployments"
  "services"
  "routes"
  "persistentvolumeclaims"
  "persistentvolumes"
  "imagestreams"
  "buildconfigs"
)

# Loop through the resources and export them
for resource in "${resources[@]}"; do
  echo "Exporting $resource from namespace '$NAMESPACE'..."
  oc get "$resource" -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/$resource.yaml"
done

# Optional: backup role bindings and roles
oc get rolebindings,roles -n "$NAMESPACE" -o yaml > "$BACKUP_DIR/roles.yaml"

echo "Backup completed. Files are stored in $BACKUP_DIR"

