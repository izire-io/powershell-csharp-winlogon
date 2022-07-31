# Presentation

This small powershell module provides a way to impersonate a user on Windows by calling a powershell method with its credentials.

# Why was it created to begin with ?

Originally, this was made to solve an issue:

When remotely connected to a Windows machine using [WinRM (Windows Remote Management)](WinRM), [WMI (Windows Management Infrastructure)](https://docs.microsoft.com/en-us/windows/win32/wmisdk/wmi-start-page) commands would fail to retrieve information and we would receive a `WMI Generic Failure` error message or blank values/result (ex: serial number of a disk drive etc.).

Connected locally with the same user, the commands work fine, so the discriminant factor would be the session (local vs remote) that queried the information.

## Solution

We remotely connect via WinRM then we impersonate ourself upon Windows (with same credentials used for WinRM).
We end up in a sub-session to the remote one. In this one, WMI commands do not fail anymore.

# Files

- `winlogonExample.ps1`: provides an example of how to use / call the script.
  - It imports the powershell module, call its `WinLogin` method, retrieve some device information via `wmi` then logout the sub-session via `WinLogout`
- `winlogonModule.psm1` is the powershell module that exposes two methods: `WinLogin` and `WinLogout`
  - This module uses powershell's `AddType -TypeDefinition` command to inject C# code into the current PowerShell session. The injected code is then used within exposed methods.
- `winlogonSignature.cs` is the C# code that is responsible for exposing `LogonUser` Win32 API method to the Powershell via .NET objects.
 
# NOTES

Information in this README may be incomplete as code written 6-7 years before README redaction. Please check code and logic prior using.

To solve WMI errors, WinLogin must be called when already connected remotely via WinRM.

May not be used in multiple threads as we use global variables.