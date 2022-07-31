$Global:DebugPreference = 'Continue'
$Global:VerbosePreference = 'Continue'
$Global:WarningPreference = 'Continue'

Import-Module "$(Split-Path -parent $MyInvocation.MyCommand.Path)\winlogonModule.psm1"

if(WinLogin)
{
    WinLogin("YOU_DOMAIN\YouUsername", "YourPassword")

    gwmi Win32_DiskDrive | select SerialNumber
        
    WinLogout
}
