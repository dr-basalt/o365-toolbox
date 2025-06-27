# Rollback distribution groups from oasis-projet.com back to webetsolutions.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_distgroups_reverse_$timestamp.log"
$csvFile   = "./migration_distgroups_reverse_$timestamp.csv"
$results   = @()

$distGroups = Get-DistributionGroup
foreach ($group in $distGroups) {
    $prefix = $group.PrimarySmtpAddress.Local
    $newPrimary = "SMTP:$prefix@webetsolutions.com"
    $oldAlias   = "smtp:$prefix@oasis-projet.com"
    try {
        Write-Host "↩ Rétro-migration: $($group.DisplayName) -> $newPrimary" -ForegroundColor Yellow
        Set-DistributionGroup -Identity $group.Identity -EmailAddresses @($newPrimary, $oldAlias)
        $results += [pscustomobject]@{
            DisplayName = $group.DisplayName
            Identity    = $group.Identity
            NewPrimary  = "$prefix@webetsolutions.com"
            Timestamp   = (Get-Date)
            Status      = "Reverted"
        }
    } catch {
        Write-Warning "⛔ Erreur sur $($group.DisplayName): $_"
        $results += [pscustomobject]@{
            DisplayName = $group.DisplayName
            Identity    = $group.Identity
            NewPrimary  = "$prefix@webetsolutions.com"
            Timestamp   = (Get-Date)
            Status      = "Error: $($_.Exception.Message)"
        }
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n🔁 Rétro-migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
