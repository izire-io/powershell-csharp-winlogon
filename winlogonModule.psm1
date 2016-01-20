
$WinLogon_signature = @"

/!\ IMPORTANT : INSERT THE C# CODE HERE !  --> winlogonSignature.cs

"@

function LogInUser
{
    <#
	.SYNOPSIS
	Authenticate ourselves with the given credentials.

	.DESCRIPTION
	This function returns $true if it success, $false otherwise.
    It stores the System.Security.Principal.WindowsImpersonationContext in $global:impersonateContext
    By default, the username and domain parameters are determined using [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    Refer to https://msdn.microsoft.com/en-us/library/windows/desktop/aa378184%28v=vs.85%29.aspx for more details
	#>
    param(
        [String][Parameter(Mandatory=$true)]$username,
        [String][Parameter(Mandatory=$true)]$password
	);

    Add-Type -TypeDefinition $WinLogon_signature

    if($Global:impersonateContext){LogOffUser}

    Write-Debug "Logging In (current user : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name))"
    Write-Debug "Retrieving a token using : user=$username domain=$domain password=$password"

	if ($username.Split('\').Length -eq 2) { $domain = $username.Split('\')[0]; $username = $username.Split('\')[1] }
	else { $domain = $null }

    $newToken = New-Object System.IntPtr
    # 2 = LOGON32_LOGON_INTERACTIVE
    # 0 = LOGON32_PROVIDER_DEFAULT
    if([WinLogon.WinLogon]::LogonUser($username,$domain,$password,2,0,[ref]$newToken) -eq 0)
    {
        Write-Debug "Failed to retrieve a token with logonType = INTERACTIVE. Win API message : $([WinLogon.WinLogon]::GetErrorMessage())"
        # 3 = LOGON32_LOGON_NETWORK
        if([WinLogon.WinLogon]::LogonUser($username,$domain,$password,3,0,[ref]$newToken) -eq 0)
        {
            Write-Debug "Failed to retrieve a token with logonType = NETWORK. Win API message : $([WinLogon.WinLogon]::GetErrorMessage())"
            return $false
        }
    }
    Write-debug "Retrieved a token : $newToken"
    try
    {
        $Global:impersonateContext = [System.Security.Principal.WindowsIdentity]::Impersonate($newToken)
        $Global:impersonateToken = $newToken
        $winID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        Write-Debug "Logged In (current user : $($winID.Name))"
    }
    catch
    {
        Write-Debug "Failed to impersonate : $($_.Exception.Message)"
        return $false
    }

    if($winID.ImpersonationLevel -ne [System.Security.Principal.TokenImpersonationLevel]::Impersonation)
    {
        Write-Debug "Inadequate impersonation level : $($winID.ImpersonationLevel)"
        LogOffUser
        return $false
    }
    return $true
}

function LogOffUser
{
    <#
	.SYNOPSIS
	Undo the LogInUser function.

	.DESCRIPTION
	This function undoes the impersonation done with the LogInUser function.
    It simply uses the WindowsImpersonationContext stored : $global:impersonateContext and his method : Undo()
    It also closes the token handle with the Win32 API CloseHandle function.
	#>
    if($Global:impersonateContext)
    {
        Write-Debug "Logging Off (current user : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name))"
        $Global:impersonateContext.Undo()
        $Global:impersonateContext = $Null
        if([WinLogon.WinLogon]::CloseHandle($Global:impersonateToken)){Write-Debug "Successfully closed the token handle : $Global:impersonateToken"}
        else{Write-Debug "Failed to close the token handle : $Global:impersonateToken. Win API message : $([WinLogon.WinLogon]::GetErrorMessage())"}
        $Global:impersonateToken = $null
        Write-Debug "Logged Off (current user : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name))"
    }
}

Export-ModuleMember -Function LogInUser
Export-ModuleMember -Function LogOffUser
