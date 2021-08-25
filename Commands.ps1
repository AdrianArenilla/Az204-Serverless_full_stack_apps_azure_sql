############################################
#login -> cloudadmin
#password -> c70Ud4DmIn.1234
#ID -> 148783
#serverName -> bus-server148783
############################################


# Know local ip address
$ipUser = (Invoke-WebRequest -Uri "https://ipinfo.io/ip").Content
Write-Output $ipUser

# Login
$adminSqlLogin = "cloudadmin"

# Password
$password = Read-Host "Your username is $adminSqlLogin. Please enter a password for your Azure SQL Database server that meets the password requirements"

# Local ip address
$ipAddress = Read-Host "Disconnect your VPN, open PowerShell on your machine and run $ipUser. Please enter the value (include periods) next to 'Address': "
Write-Host "Password and IP Address stored"

# Get resource group and location and random string
$resourceGroupName = "busesStopRG"

# Create a new resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location
$resourceGroup = Get-AzResourceGroup | Where ResourceGroupName -like $resourceGroupName
$location = "westeurope"
$uniqueID = '148783'

# The logical server name has to be unique in the system
$serverName = "bus-server$($uniqueID)"

# The sample database name
$dataBaseName = "bus-db"
Write-Host "Please note your unique ID for future exercises in this module:"
Write-Host $uniqueID
Write-Host "Your resource group name is:"
Write-Host $resourceGroupName
Write-Host "Your server name is:"
Write-Host $serverName

# Create a new server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $serverName -Location $location -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

# Create a server firewall rule that allows access from the specified IP range and all Azure services
$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName "AllowedIPs" -StartIpAddress $ipAddress -EndIpAddress $ipAddress
$allowAzureIpsRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -AllowAllAzureIPs

# Create a database
$database = New-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $dataBaseName -Edition "GeneralPurpose" -VCore 4 -ComputeGeneration "Gen5" -ComputeModel Serverless -MinimumCapacity 0.5
Write-Host "Database deployed"


# Configuración de secretos de forma segura con GitHub:
# Server=tcp:bus-server148783.database.windows.net,1433;Initial Catalog=bus-db;Persist Security Info=False;User ID=cloudadmin;Password=c70Ud4DmIn.1234;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;

# Connection String:
# Server=tcp:bus-server148783.database.windows.net,1433;Database=bus-db;User ID=cloudadmin;Password=c70Ud4DmIn.1234;Encrypt=true;Connection Timeout=30;

# EJERCICIO 2
$resourceGroupName = "busesStopRG"
$resourceGroup = Get-AzResourceGroup | Where ResourceGroupName -like $resourceGroupName
$uniqueID = '148783'
$location = "westeurope"

# Azure function name
$azureFunctionName = $("azfunc$($uniqueID)")
$azureFunctionName

# Create a storage account
$storageAccountName = $("storageaccount$($uniqueID)")
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -Location $location -SkuName Standard_GRS

# Get storage account name
$storageAccountName = (Get-AzStorageAccount -ResourceGroup $resourceGroupName).StorageAccountName
$storageAccountName

# Create a new Function App
$functionApp = New-AzFunctionApp -Name $azureFunctionName -ResourceGroupName $resourceGroupName -StorageAccount $storageAccountName -FunctionsVersion 3 -RuntimeVersion 3 -Runtime dotnet -Location $location
$functionApp


# EJERCICIO 3
https://github.com/AdrianArenilla/Az204-Serverless_full_stack_apps_azure_sql

# Resource group name and resource group
$resourceGroupName = "busesStopRG"
$resourceGroup = Get-AzResourceGroup | Where ResourceGroupName -like $resourceGroupName
$location = "westeurope"

# Get the repository name
$appRepository = Read-Host "Enter your GitHub repository URL (e.g. https://github.com/[username]/serverless-full-stack-apps-azure-sql):"

# Clone the repo - note this asks for the token
$cloneRepository = git clone $appRepository

# Get subscription ID
$subId = [Regex]::Matches($resourceGroup.ResourceId, "(\/subscriptions\/)+(.*\/)+(.*\/)").Groups[2].Value
$subId = $subId.Substring(0,$subId.Length-1)

# Deploy logic app
az deployment group create --name DeployResources --resource-group $resourceGroupName --template-file ./deployment-scripts/template.json --parameters subscription_id=$subId location=$location
