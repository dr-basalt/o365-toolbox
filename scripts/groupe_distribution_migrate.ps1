# Migrates distribution groups from webetsolutions.com to oasis-projet.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_distgroups_to_oasis_$timestamp.log"
$csvFile   = "./migration_distgroups_to_oasis_$timestamp.csv"
$results   = @()

$distGroups = Get-DistributionGroup
foreach ($group in $distGroups) {
    $prefix = $group.PrimarySmtpAddress.Local
    $newPrimary = "SMTP:$prefix@oasis-projet.com"
    $oldAlias   = "smtp:$prefix@webetsolutions.com"
    try {
        Write-Host "➡ Migration: $($group.DisplayName) -> $newPrimary" -ForegroundColor Cyan
        Set-DistributionGroup -Identity $group.Identity -EmailAddresses @($newPrimary, $oldAlias)
        $results += [pscustomobject]@{
            DisplayName = $group.DisplayName
            Identity    = $group.Identity
            NewPrimary  = "$prefix@oasis-projet.com"
            Timestamp   = (Get-Date)
            Status      = "Migrated"
        }
    } catch {
        Write-Warning "⛔ Erreur sur $($group.DisplayName): $_"
        $results += [pscustomobject]@{
            DisplayName = $group.DisplayName
            Identity    = $group.Identity
            NewPrimary  = "$prefix@oasis-projet.com"
            Timestamp   = (Get-Date)
            Status      = "Error: $($_.Exception.Message)"
        }
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ Migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
