<#
.SYNOPSIS
    PowerShell Profile
.DESCRIPTION
    This PowerShell Script is used to configure the PowerShell profile
.EXAMPLE
    PS> .\Microsoft.PowerShell_profile.ps1
    PowerShell Profile
.LINK
    https://github.com/mortyewary/mortyewary
.NOTES
    Author: Waylon Neal
#>

# Define a function to reload the PowerShell profile
function Invoke-ProfileReload {
    $profilePath = $PROFILE
    if (Test-Path $profilePath) {
        . $profilePath
        Write-Host "PowerShell profile reloaded successfully."
    } else {
        Write-Warning "PowerShell profile not found."
    }
}

# Import custom modules
Import-Module "$env:USERPROFILE\Documents\PowerShell\modules\modules.psm1" -Force


$themePath = "$env:USERPROFILE\scoop\apps\oh-my-posh\26.19.0\themes"

# oh-my-posh
$OutputEncoding = [System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
oh-my-posh init pwsh --config "$themePath\dracula.omp.json" | Invoke-Expression

# komorebi environmental variable
$Env:KOMOREBI_CONFIG_HOME = "$env:USERPROFILE\.config\komorebi"