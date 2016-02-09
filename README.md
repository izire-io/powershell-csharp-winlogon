# powershell-csharp-winlogon
A way to impersonate a user with PowerShell.
Impersonating users with powershell can solve problems when used remotely.

Long story short : It uses a WIN32 API to retrieve an impersonation token and then impersonates it with a .NET function.

Long story :

PowerShell adds c# code to its assembly. This code accesses the WIN32 API and exposes specific functions to get a token with a user's given credentials. This token is used in PowerShell with a .NET function to impersonate the user.

We have the relation below :

   PowerShell <--> dynamically added C# assembly <--> Win32 API functions
