Set-ExecutionPolicy RemoteSigned -force

$Username="callum.mcewan"
$Password="testing_123$"
$Fullname="Callum McEwan"
$Description="Amey"
$UserGroup=$args"Administrators"

$SecurePassword=ConvertTo-SecureString $Password –asplaintext –force 

# Get local accounts module
Get-Command -Module  Microsoft.PowerShell.LocalAccounts

#Create user
New-LocalUser $Username -Description $Description -Password $SecurePassword
Set-LocalUser -Name $Username -Fullname $Fullname

#Add user to suitable group
Add-LocalGroupMember -Group $UserGroup -Member $Username

# Install Chocolatey
#Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Software
#choco install visualstudiocode -y
#choco install X2Go -y
#choco install Putty -y
