using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."


$allRunningContainers = Get-AzContainerGroup -ResourceGroupName myResourceGroup
$removedContainerName = $allRunningContainers[0].Name

if($allRunningContainers.count -gt 1){
    $removedContainerIp = Get-AzContainerGroup -Name $removedContainerName -ResourceGroupName myResourceGroup | select -exp IpAddressIp    
    Remove-AzContainerGroup -Name  $removedContainerName -ResourceGroupName myResourceGroup
    
}

$body = $('{ "IpAddress":"'  + $removedContainerIp + '" }')



# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
