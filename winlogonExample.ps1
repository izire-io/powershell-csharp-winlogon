$Global:DebugPreference = 'Continue'
$Global:VerbosePreference = 'Continue'
$Global:WarningPreference = 'Continue'

Import-Module "$(Split-Path -parent $MyInvocation.MyCommand.Path)\winlogonModule.psm1"

LogInUser

gwmi Win32_DiskDrive | select SerialNumber

LogOffUser
