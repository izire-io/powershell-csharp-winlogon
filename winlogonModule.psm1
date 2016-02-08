$WIN32_Wrapper_WindowsLogon_Signature = Get-Content -Raw  'winlogonSignature.cs'

function WinLogin
{
    <#
	.SYNOPSIS
	Try to impersonate with given user credentials.

	.DESCRIPTION
	It retrieves a token using credentials and then tries to impersonate.
	Success : return True
	Fail : return False

    Token retrieval : https://msdn.microsoft.com/en-us/library/windows/desktop/aa378184%28v=vs.85%29.aspx
	Impersonate : https://msdn.microsoft.com/en-us/library/w070t6ka(v=vs.110).aspx
	#>
    param([String][Parameter(Mandatory=$true)]$userName,
		  [String][Parameter(Mandatory=$true)]$password);

	# Split domain and user name if the current user name format is like 'domain\username'
	$tmp = $userName.Split('\')
	if ($tmp.Length -eq 2)
	{
		$domain = $tmp[0]
		$userName = $tmp[1]
	}
	else { $domain = $null }

	# Add our C# wrapper for later use (this does not stack, if already here, it does not show any debug message)
	# https://technet.microsoft.com/en-us/library/hh849914.aspx
	Add-Type -TypeDefinition $WIN32_Wrapper_WindowsLogon_Signature

	# If we already impersonate a user, we stop before impersonating another
    if($Global:impersonateContext){ LogOffUser }

    Write-Debug("Current user : " + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
	Write-Debug("Future user : domain = $domain , user name = $userName")

    Write-Debug 'Retrieving a token ...'
    $newToken = New-Object System.IntPtr

    #region Token retrieval
    
    # Logon types : https://msdn.microsoft.com/en-us/library/windows/desktop/aa378184(v=vs.85).aspx
    # See Winbase.h :
    # #define LOGON32_LOGON_INTERACTIVE       2
    # #define LOGON32_LOGON_NETWORK           3
    # #define LOGON32_LOGON_BATCH             4
    # #define LOGON32_LOGON_SERVICE           5
    # ...
    
    # 2 = LOGON32_LOGON_INTERACTIVE
    Write-Debug 'Logon mode : Interactive'
    if([WIN32_Wrapper.WindowsLogon]::LogonUser($userName,$domain,$password,2,0,[ref]$newToken) -eq 0)
    {
        Write-Debug 'Failed to retrieve a token'
        Write-Debug "Win32 Error message : $([WIN32_Wrapper.WindowsLogon]::GetErrorMessage())"
        # 3 = LOGON32_LOGON_NETWORK
        Write-Debug 'Logon mode : Network'
        if([WIN32_Wrapper.WindowsLogon]::LogonUser($userName,$domain,$password,3,0,[ref]$newToken) -eq 0)
        {
            Write-Debug 'Failed to retrieve a token'
            Write-Debug "Win32 Error message : $([WIN32_Wrapper.WindowsLogon]::GetErrorMessage())"
            return $false
        }
    }
    Write-debug "Token retrieved - $newToken"
    #endregion
    
    #region Impersonation AND global variables setup 
    try
    {
        # Try to impersonate the user with the retrieved impersonation token
        $Global:winlogonIC = [System.Security.Principal.WindowsIdentity]::Impersonate($newToken)
        $winID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    }
    catch
    {
        Write-Debug "Failed to impersonate : $($_.Exception.Message)"
        $Global:winlogonIC = $null
        return $false
    }

    if($winID.ImpersonationLevel -ne [System.Security.Principal.TokenImpersonationLevel]::Impersonation)
    {
        Write-Debug "Inadequate impersonation level : $($winID.ImpersonationLevel)"
        return $false
    }

    $Global:winlogonToken = $newToken
    Write-Debug "Impersonating user : $($winID.Name)"
    
    #endregion
    return $true
}

# todo : reformat
function WinLogout
{
    <#
	.SYNOPSIS
	Stop to impersonate the user.

	.DESCRIPTION
	If we have an existing context in global variables, we 'undo' the impersonation previously done.
    We use the WIN32_Wrapper function : CloseHandle over the token.
	#>
    if($Global:winlogonIC)
    {
        # Undo the impersonation
        Write-Debug "Stop to impersonate the user : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        $Global:winlogonIC.Undo()
        $Global:winlogonIC = $null
        
        # Close the token
        if([WIN32_Wrapper.WindowsLogon]::CloseHandle($Global:winlogonToken))
        {
            Write-Debug "Token handle closed : $($Global:impersonateToken)"
        }
        else
        {
            Write-Debug 'Failed to close the token'
            Write-Debug "Win32 Error message : $([WIN32_Wrapper.WindowsLogon]::GetErrorMessage())"
        }
        $Global:impersonateToken = $null
        Write-Debug 'User not impersonated anymore'
        Write-Debug "Current user : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    }
}

Export-ModuleMember -Function WinLogin
Export-ModuleMember -Function WinLogout
