# ==============================================================================
# PHASE 1: AUTOMATED IDENTITY PROVISIONING & SYNC PIPELINE
# ==============================================================================
Import-Module ActiveDirectory

# 1. ENVIRONMENT CONFIGURATION VARIABLES
$TargetOU    = "OU=Sync_Users,DC=sc300lab,DC=com"
$UPNSuffix   = "yourtenant.onmicrosoft.com" # <-- Replace with your Entra domain
$DefaultPass = "SchwabLab2026!"

# 2. TARGET USER MATRIX
$Roster = @(
    @{ FirstName = "Marcus";    LastName = "Vance";      SamName = "mvance";      Title = "IAM Associate" },
    @{ FirstName = "Elena";     LastName = "Rostova";    SamName = "erostova";    Title = "Security Analyst" },
    @{ FirstName = "David";     LastName = "Kim";        SamName = "dkim";        Title = "Cloud Engineer" },
    @{ FirstName = "Alex";      LastName = "Admin";      SamName = "alexadmin";   Title = "Helpdesk Administrator" },
    @{ FirstName = "Vendor";    LastName = "Support";    SamName = "vsupport";    Title = "Third-Party Contractor" },
    @{ FirstName = "Emergency"; LastName = "BreakGlass"; SamName = "breakglass01";Title = "Break-Glass Account Override" }
)

# 3. EXECUTION PROVISIONING ENGINE
foreach ($User in $Roster) {
    $TargetUPN = "$($User.SamName)@$UPNSuffix"
    $SecurePassword = ConvertTo-SecureString $DefaultPass -AsPlainText -Force

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($User.SamName)'")) {
        New-ADUser -Name "$($User.FirstName) $($User.LastName)" `
                   -GivenName $User.FirstName `
                   -Surname $User.LastName `
                   -SamAccountName $User.SamName `
                   -UserPrincipalName $TargetUPN `
                   -Path $TargetOU `
                   -Title $User.Title `
                   -AccountPassword $SecurePassword `
                   -Enabled $true `
                   -ChangePasswordAtLogon $false
        
        Write-Host "Successfully provisioned local object: $($User.SamName)" -ForegroundColor Green
    } else {
        Write-Host "Identity $($User.SamName) already exists. Skipping." -ForegroundColor Yellow
    }
}

# 4. AUTOMATED PIPELINE REPLICATION
Write-Host "Triggering Entra Connect Synchronization Engine..." -ForegroundColor Cyan
Start-ADSyncSyncCycle -PolicyType Delta
Write-Host "Pipeline Success: Identities provisioned and synchronized to the cloud!" -ForegroundColor Green
