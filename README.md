# powershell-csharp-winlogon
A way to impersonate a user with PowerShell.
Impersonating users with powershell can solve problems when used remotely.

Long story short :
It uses a WIN32 API to retrieve an impersonation token and then impersonates it with a .NET function.

Known solved problem :

In the case you can retrieve all your information locally but get errors (ex. "WMI generic failure") or blank values when commands are used remotely. (Context : When you remotely access a host with Windows Remote Management, with or without WinRM PowerShell plugin but finally using PowerShell commands on the remote Host, you may use WMI to query disk information and other ressources.)

Explanation:

Being considered as a remote user, some information may be missing (ex : SerialNumber etc.). Doing an impersonation of yourself once connected to the host allows you to be considered as a local user altough you are remotely connected. This way, you may retrieve your information.

Long story : PowerShell adds c# code to its assembly. This code accesses the WIN32 API and exposes specific functions to get a token with user's given credentials. This token is used in PowerShell with a .NET function to impersonate the user.We have the relation below :

   PowerShell <--> dynamically added C# assembly <--> Win32 API functions
   PowerShell <--> .NET functions
