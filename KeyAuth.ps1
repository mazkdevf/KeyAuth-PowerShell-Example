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

class KeyAuthApp {
    [bool] $Success
    [string] $Message
    [string] $Name
    [string] $OwnerId
    [string] $Version
    [string] $SessionId
    [PSCustomObject] $Info

    KeyAuthApp([string]$name, [string]$ownerId, [string]$version) {
        $this.Name = $name
        $this.OwnerId = $ownerId
        $this.Version = $version
    }

    [void] Initialize() {
        try {
            $url = "https://keyauth.win/api/1.2/?type=init&ver=$([System.Web.HttpUtility]::UrlEncode($this.Version))&name=$([System.Web.HttpUtility]::UrlEncode($this.Name))&ownerid=$([System.Web.HttpUtility]::UrlEncode($this.OwnerId))"
            $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/x-www-form-urlencoded"

            if ($response -eq "KEYAUTH_INVALID") {
                $this.Success = $false
                $this.Message = "Invalid Application"
                return
            }

            if ($response.success -eq $true) {
                $this.SessionId = $response.sessionid
                $this.Success = $true
                $this.Message = "Initialization successful"
            } else {
                $this.Success = $false
                if ($response.message -like "*Select app & copy code snippet from https://keyauth.cc/app/*") {
                    $this.Message = "Invalid Application Name or Owner ID"
                } else {
                    $this.Message = $response.message
                }
            }
        } catch {
            $this.Success = $false
            $this.Message = "Initialization failed: $_"
        }
    }

    # SecureString $password doesn't work with KeyAuth Server.
    [void] Login([string]$username, [string]$password) {
        try {
            $hwid = $this.getHwid()
            $url = "https://keyauth.win/api/1.2/?type=login&username=$([System.Web.HttpUtility]::UrlEncode($username))&pass=$([System.Web.HttpUtility]::UrlEncode($password))&sessionid=$($([System.Web.HttpUtility]::UrlEncode($this.SessionId)))&name=$($([System.Web.HttpUtility]::UrlEncode($this.Name)))&ownerid=$($([System.Web.HttpUtility]::UrlEncode($this.OwnerId)))&hwid=$([System.Web.HttpUtility]::UrlEncode($hwid))"
            $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/x-www-form-urlencoded"

            if ($response.success -eq $true) {
                $this.Success = $true
                $this.Message = "Login successful"
                $this.Info = $response.info
            } else {
                $this.Success = $false
                $this.Message = $response.message
            }
        } catch {
            $this.Success = $false
            $this.Message = "Login failed: $_"
        }
    }

    # SecureString $password doesn't work with KeyAuth Server.
    [void] Register([string]$username, [string]$password, [string]$key) {
        try {
            $hwid = $this.getHwid()
            $url = "https://keyauth.win/api/1.2/?type=register&username=$([System.Web.HttpUtility]::UrlEncode($username))&pass=$([System.Web.HttpUtility]::UrlEncode($password))&key=$([System.Web.HttpUtility]::UrlEncode($key))&sessionid=$($([System.Web.HttpUtility]::UrlEncode($this.SessionId)))&name=$($([System.Web.HttpUtility]::UrlEncode($this.Name)))&ownerid=$($([System.Web.HttpUtility]::UrlEncode($this.OwnerId)))&hwid=$([System.Web.HttpUtility]::UrlEncode($hwid))"
            $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/x-www-form-urlencoded"

            if ($response.success -eq $true) {
                $this.Success = $true
                $this.Message = "Registration successful"
                $this.Info = $response.info
            } else {
                $this.Success = $false
                $this.Message = $response.message
            }
        } catch {
            $this.Success = $false
            $this.Message = "Registration failed: $_"
        }
    }

    [void] Upgrade([string]$username, [string]$key) {
        try {
            $hwid = $this.getHwid()
            $url = "https://keyauth.win/api/1.2/?type=upgrade&username=$([System.Web.HttpUtility]::UrlEncode($username))&key=$([System.Web.HttpUtility]::UrlEncode($key))&sessionid=$($([System.Web.HttpUtility]::UrlEncode($this.SessionId)))&name=$($([System.Web.HttpUtility]::UrlEncode($this.Name)))&ownerid=$($([System.Web.HttpUtility]::UrlEncode($this.OwnerId)))&hwid=$([System.Web.HttpUtility]::UrlEncode($hwid))"
            $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/x-www-form-urlencoded"
            if ($response.success -eq $true) {
                Write-Host $response.message
                exit 1
            } else {
                $this.Success = $false
                $this.Message = $response.message
            }
        } catch {
            $this.Success = $false
            $this.Message = "Upgrade failed: $_"
        }
    }

    [void] License([string]$key) {
        try {
            $hwid = $this.getHwid()
            $url = "https://keyauth.win/api/1.2/?type=license&key=$([System.Web.HttpUtility]::UrlEncode($key))&sessionid=$($([System.Web.HttpUtility]::UrlEncode($this.SessionId)))&name=$($([System.Web.HttpUtility]::UrlEncode($this.Name)))&ownerid=$($([System.Web.HttpUtility]::UrlEncode($this.OwnerId)))&hwid=$([System.Web.HttpUtility]::UrlEncode($hwid))"
            $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/x-www-form-urlencoded"

            if ($response.success -eq $true) {
                $this.Success = $true
                $this.Message = "License check successful"
                $this.Info = $response.info
            } else {
                $this.Success = $false
                $this.Message = $response.message
            }
        } catch {
            $this.Success = $false
            $this.Message = "License check failed: $_"
        }
    }

    [String] UnixTimeToDateTime([long]$unixTime) {
        return (Get-Date "1970-01-01 00:00:00").AddSeconds($unixTime)
    }

    [String] getHwid() {
        return [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    }

    [Boolean] SubExist([string]$sub) {
        return $this.Info.subscriptions.subscription -contains $sub
    }    
}
