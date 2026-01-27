# A script meant to be run as admin

# Re-run this script as admin if not already running as admin. Apparently
# doesn't keep the current working directory though.
# https://blog.expta.com/2017/03/how-to-self-elevate-powershell-script.html
# Compared with the above link, added "-Wait" and to ensure the elevated
# process completes before exiting this one, and "-ExecutionPolicy Bypass" to
# be allowed to run this script.
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -Wait -ArgumentList $CommandLine
        Exit
    }
}

# Enable and start the ssh-agent service
Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service
