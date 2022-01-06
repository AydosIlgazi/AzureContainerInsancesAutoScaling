using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.

$IpAddress = $Request.Body.IpAddress
$allRunningContainers = Get-AzContainerGroup -ResourceGroupName myResourceGroup  | select -exp IpAddressIp
$AppGw = Get-AzApplicationGateway -Name "myAppGateway" -ResourceGroupName "myResourceGroup"

if ($allRunningContainers.Contains($IpAddress)) {
    $allRunningContainersArray = [System.Collections.ArrayList]$allRunningContainers
    $allRunningContainersArray.Remove($IpAddress)
    $AppGw = Set-AzApplicationGatewayBackendAddressPool -ApplicationGateway $AppGw -Name "appGatewayBackendPool" -BackendIPAddresses $allRunningContainersArray
}
else{
    $AppGw = Set-AzApplicationGatewayBackendAddressPool -ApplicationGateway $AppGw -Name "appGatewayBackendPool" -BackendIPAddresses $allRunningContainers
}

Set-AzApplicationGateway -ApplicationGateway $AppGw

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $allRunningContainers
})
