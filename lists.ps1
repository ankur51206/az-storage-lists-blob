# Set subscription ID
$subscriptionId = "xxxxx-xxxx-xxxx-xxxx-xxxxxxx"
Set-AzContext -SubscriptionId $subscriptionId | Out-Null

# List all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount | Select-Object -Property StorageAccountName, ResourceGroupName

# Output headers for the table
Write-Output ("{0,-30} {1,-30} {2,-30}" -f "Storage Account Name", "Container Name", "Last Modified Date")

# Loop through each storage account
foreach ($storageAccount in $storageAccounts) {
    # Get the connection string for the storage account
    $accountKeys = Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName
    $connectionString = "DefaultEndpointsProtocol=https;AccountName=$($storageAccount.StorageAccountName);AccountKey=$($accountKeys[0].Value)"

    # Create storage context
    $context = New-AzStorageContext -ConnectionString $connectionString

    # List all containers in the storage account
    $containers = Get-AzStorageContainer -Context $context | Select-Object -ExpandProperty Name

    # Loop through each container
    foreach ($container in $containers) {
        # Get the last modified date of blobs in the container
        $lastModified = Get-AzStorageBlob -Container $container -Context $context |
                        Select-Object -ExpandProperty LastModified |
                        Sort-Object -Property $_ |
                        Select-Object -Last 1

        # Output the data in table format
        Write-Output ("{0,-30} {1,-30} {2,-30}" -f $storageAccount.StorageAccountName, $container, $lastModified)
    }
}
