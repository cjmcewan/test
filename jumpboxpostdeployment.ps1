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

$UserName=$args[0]
Write-Output $UserName



#function to register a native method
function Register-NativeMethod
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$dll,
 
        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $methodSignature
    )
 
    $script:nativeMethods += [PSCustomObject]@{ Dll = $dll; Signature = $methodSignature; }
}

#function to add native method
function Add-NativeMethods
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param($typeName = 'NativeMethods')
 
    $nativeMethodsCode = $script:nativeMethods | ForEach-Object { "
        [DllImport(`"$($_.Dll)`")]
        public static extern $($_.Signature);
    " }
 
    Add-Type @"
        using System;
        using System.Text;
        using System.Runtime.InteropServices;
        public static class $typeName {
            $nativeMethodsCode
        }
"@
}

$methodName = 'UserEnvCP'
$script:nativeMethods = @();

Register-NativeMethod "userenv.dll" "int CreateProfile([MarshalAs(UnmanagedType.LPWStr)] string pszUserSid,`
  [MarshalAs(UnmanagedType.LPWStr)] string pszUserName,`
  [Out][MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszProfilePath, uint cchProfilePath)";

Add-NativeMethods -typeName $MethodName;

$localUser = New-Object System.Security.Principal.NTAccount("$Username");
$userSID = $localUser.Translate([System.Security.Principal.SecurityIdentifier]);
$sb = new-object System.Text.StringBuilder(260);
$pathLen = $sb.Capacity;

Write-Verbose "Creating user profile for $UserName";
try
{
    [UserEnvCP]::CreateProfile($userSID.Value, $Username, $sb, $pathLen) | Out-Null;
}
catch
{
    Write-Error $_.Exception.Message;
    break;
}
