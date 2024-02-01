<# 

    ██████╗ ███████╗ ██╗    ███████╗██╗  ██╗ █████╗ ███╗   ███╗██████╗ ██╗     ███████╗
    ██╔══██╗██╔════╝███║    ██╔════╝╚██╗██╔╝██╔══██╗████╗ ████║██╔══██╗██║     ██╔════╝
    ██████╔╝███████╗╚██║    █████╗   ╚███╔╝ ███████║██╔████╔██║██████╔╝██║     █████╗  
    ██╔═══╝ ╚════██║ ██║    ██╔══╝   ██╔██╗ ██╔══██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝  
    ██║     ███████║ ██║    ███████╗██╔╝ ██╗██║  ██║██║ ╚═╝ ██║██║     ███████╗███████╗
    ╚═╝     ╚══════╝ ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝
                                    
                                    Author: Mazkdevf         

    Description: Fun example showcasing KeyAuth API integration for PowerShell authentication.
    GitHub Repository: https://github.com/mazkdevf/KeyAuth-PowerShell-Example
    Date: 1.2.2024
    Version: 1.0
    License: Check LICENSE file :)

#>

## Importing KeyAuth API class from KeyAuth.ps1 file in the same directory
. ".\KeyAuth.ps1"

$KeyAuthApp = [KeyAuthApp]::new(
    "KeyAuth PowerShell Example", # Replace with your application name from https://keyauth.cc/app/
    "OwnerId", # Replace with your Owner ID from https://keyauth.cc/app/?page=account-settings
    "1.0" # Replace with your application version (default: 1.0)
)

Write-Host "`nConnecting...`n`n"
$KeyAuthApp.Initialize()
if (-not $KeyAuthApp.Success) {
    Write-Host "`n`n Status: Failure: $($KeyAuthApp.Message)`n`n"
    Start-Sleep -Seconds 3
    exit 1
}

Clear-Host

$continueMenu = $true
while ($continueMenu) {
    $choice = Read-Host -Prompt @"
`n`n  [1] Login
  [2] Register
  [3] Upgrade
  [4] License key only

  Choose option
"@

    switch ($choice) {
        1 {
            $username = Read-Host "`n Enter username"
            $password = Read-Host "`n Enter password"
            $KeyAuthApp.Login($username, $password)
            $continueMenu = $false
            break
        }
        2 {
            $username = Read-Host "`n Enter username"
            $password = Read-Host "`n Enter password"
            $key = Read-Host "`n Enter license key"
            $KeyAuthApp.Register($username, $password, $key)
            $continueMenu = $false
            break
        }
        3 {
            $username = Read-Host "`n Enter username"
            $key = Read-Host "`n Enter license key"
            $KeyAuthApp.Upgrade($username, $key)
            $continueMenu = $false
            break
        }
        4 {
            $key = Read-Host "`n Enter license key"
            $KeyAuthApp.License($key)
            $continueMenu = $false
            break
        }
        default {
            Write-Host "`n`n Status: Failure: Invalid Selection`n`n"
            Start-Sleep -Seconds 3
            exit 1
        }
    }
}

if (-not $KeyAuthApp.Success) {
    Write-Host "`n`n Status: Failure: $($KeyAuthApp.Message)`n`n"
    Start-Sleep -Seconds 3
    exit 1
}

if ($KeyAuthApp.Success) {
    Clear-Host
    Write-Host "`n`n Logged in! `n`n"
    Write-Host "`n Username: $($KeyAuthApp.Info.username)"
    Write-Host "`n IP address: $($KeyAuthApp.Info.ip)"
    Write-Host "`n Hardware-Id: $($KeyAuthApp.Info.hwid)"
    Write-Host "`n Created at: $($KeyAuthApp.UnixTimeToDateTime($KeyAuthApp.Info.createdate))"
    
    if (-not [string]::IsNullOrEmpty($KeyAuthApp.Info.lastlogin)) {
        Write-Host "`n Last login at: $($KeyAuthApp.UnixTimeToDateTime($KeyAuthApp.Info.lastlogin))"
    }

    Write-Host "`n Your subscription(s):"
    
    foreach ($subscription in $KeyAuthApp.Info.subscriptions) {
        Write-Host "`n Subscription name: $($subscription.subscription) - Expires at: $($KeyAuthApp.UnixTimeToDateTime($subscription.expiry)) - Time left in seconds: $($subscription.timeleft)"
    }

    Write-Host "`n Does have access to 'default' subscription?: $(if ($KeyAuthApp.SubExist("default")) { "Yes" } else { "No" })"
    Write-Host "`n`n`n  Closing in five seconds...`n`n "
    Start-Sleep -Seconds 5
    Exit 0
} else {
    Write-Host "`n`n Failed to retrieve user information: $($KeyAuthApp.Message)"
    Exit 1
}