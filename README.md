# AutoScaling on Azure Container Instances
<table>
<tr>
<td>
Azure container instances service lets users to run their images on the cloud server. This project implements an example autoscaling functionality to the constainer instances using other azure cloud services. 
</td>
</tr>
</table>

## Architecture
![me](https://github.com/AydosIlgazi/swe590api/blob/master/assets/Architecture.png)

## Services
- **Azure Container Instances**: Service that runs the containers.
- **Application Gateway**: Makes container instances publicly available, load balances the incoming request and sends the alerts to the other services to trigger scale.
- **Logic Apps**: Provides scaling in/out workflow and functionality to the alerts that are triggered from gateway.
- **Azure Functions**: Triggered by the logic apps to execute necessary functions.
- **Virtual Networks**: A network that encapsulates other azure components.
- **Container Registries**: Stores container images to use automatic initialization of container instances later.


## Implementation

- Using Azure CLI
```bash
#Create a vnet and application gateway subnet
az network vnet create --name myVNet --resource-group myResourceGroup --location eastus --address-prefix 10.0.0.0/16 --subnet-name myAGSubnet --subnet-prefix 10.0.1.0/24

#Create a subnet for containers, container ip addresses will be 10.0.2.* automatically in the subnet
az network vnet subnet create --name myACISubnet --resource-group myResourceGroup --vnet-name myVNet  --address-prefix 10.0.2.0/24

#Create public ip
az network public-ip create --resource-group myResourceGroup --name myAGPublicIPAddress --allocation-method Static --sku Standard

#Create Container
az container create --name appcontainer --resource-group myResourceGroup --image <image> --vnet myVNet --subnet myACISubnet

#Create Application Gateway
az network application-gateway create --name myAppGateway --location eastus --resource-group myResourceGroup --capacity 2 --sku Standard_v2 --http-settings-protocol http --public-ip-address myAGPublicIPAddress --vnet-name myVNet --subnet myAGSubnet --servers <ContainerIp>
```

- Using Windows Powershell
Container registry is necessary only if you want to use your image. Otherwise you give image like "mcr.microsoft.com/azuredocs/aci-helloworld" without registering it. In this example, I have used my image from dockher hub. 
```bash
Install-Module Az
Import-Module Az

#if current user having an undefined ExecutionPolicy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted   

Connect-AzAccount
registry = New-AzContainerRegistry -ResourceGroupName "myResourceGroup" -Name "myContainerRegistry001" -EnableAdminUser -Sku Basic
Connect-AzContainerRegistry -Name $registry.Name

docker pull aydosilgazi/swe590api
docker tag aydosilgazi/swe590api mycontainerregistry001.azurecr.io/aydosilgazi/swe590api:v1
docker push mycontainerregistry001.azurecr.io/swe590api:v1
```

- Using Azure Dashboard

    * Create Azure Functions
        ```bash
        #Examples written in Powershell
        assets/RemoveContainerInstance
        assets/UpdateBackendPool
        ```

    * Create Logic Apps
        - Add Container Logic App
            `assets/AddContainerLogicApp`
            # Image
        - Remove Container Logic App
            `assets/RemoveContainerLogicApp`
            # Image

    * Create Alert in Application Gateway and Connect Triggers to the Corresponding Logic Apps. In case of using controllers in this example like {ipAddress/Data}, it is necessary to create custom probes in the application gateway to solve Service Unavailable problem.
