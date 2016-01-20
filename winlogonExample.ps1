$Global:DebugPreference = 'Continue'
$Global:VerbosePreference = 'Continue'
$Global:WarningPreference = 'Continue'

Import-Module "$(Split-Path -parent $MyInvocation.MyCommand.Path)\winlogonModule.psm1"

LogInUser -username 'domain\username' -password 'myPassword'

# Do stuff here
# Example : wmi requests etc.

LogOffUser
