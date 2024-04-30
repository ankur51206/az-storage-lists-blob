#!/bin/bash

# Set subscription ID
subscription_id="00000-0000-0000-0000-000000"
az account set --subscription $subscription_id

# List all storage accounts in the subscription
storage_accounts=$(az storage account list --query "[].name" -o tsv)

# Output headers for the table
printf "%-30s %-30s %-30s\n" "Storage Account Name" "Container Name" "Last Modified Date"

# Loop through each storage account
for storage_account in $storage_accounts
do
    # Get the connection string for the storage account
    connection_string=$(az storage account show-connection-string --name $storage_account --query connectionString -o tsv 2>/dev/null)
    
    # List all containers in the storage account
    containers=$(az storage container list --connection-string $connection_string --query "[].name" -o tsv 2>/dev/null)
    
    # Loop through each container
    for container in $containers
    do
        # Get the last modified date of blobs in the container
        last_modified=$(az storage blob list --connection-string $connection_string --container-name $container --query "[*].properties.lastModified" -o tsv | sort | tail -n 1 2>/dev/null)
        
        # Output the data in table format
        printf "%-30s %-30s %-30s\n" "$storage_account" "$container" "$last_modified"
    done
done
