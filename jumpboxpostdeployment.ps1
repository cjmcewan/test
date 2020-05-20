Set-ExecutionPolicy RemoteSigned -force

$Username=$args[0]
$Password=$args[1]
$Fullname=$args[2]
$Description=$args[3]
$UserGroup=$args[4]

$SecurePassword=ConvertTo-SecureString $Password –asplaintext –force 

# Get local accounts module
Get-Command -Module  Microsoft.PowerShell.LocalAccounts

#Create user
New-LocalUser $Username -Description $Description -Password $SecurePassword
Set-LocalUser -Name $Username -Fullname $Fullname

#Add user to suitable group
Add-LocalGroupMember -Group $UserGroup -Member $Username

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Software
choco install visualstudiocode -y
choco install X2Go -y
choco install Putty -y

#Set up user folder structure
Get-WindowsCapability -Online | ? Name -Like 'OpenSSH*'
Set-Service ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service sshd -StartupType Automatic
Start-Service -Name sshd
ssh $Username@localhost | echo $Password
echo Exit
