# powershell-csharp-winlogon
A way to impersonate a user with PowerShell.
Impersonating users with powershell can solve problems when used remotely.

Long story short :
It uses a WIN32 API to retrieve an impersonation token and then impersonates it with a .NET function.

Known solved problems :
When you remotely access a host with Windows Remote Management (with or without WinRM PowerShell plugin but finally using PowerShell on the remote Host), you may use WMI to query disks and other ressources. In this case you are considered as a remote user and some information may be missing (ex : SerialNumber etc.). Doing an impersonation of yourself once connected to the host allow you to be considered as a local user altough you are remotely connected. This way, it may help your to get your information.

This solution helped me to solve WMI generic failure errors and to retrieve missing (blank) properties.

Long story : PowerShell adds c# code to its assembly. This code accesses the WIN32 API and exposes specific functions to get a token with a user's given credentials. This token is used in PowerShell with a .NET function to impersonate the user.We have the relation below :

   PowerShell <--> dynamically added C# assembly <--> Win32 API functions
