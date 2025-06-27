# Rollback mail users from oasis-projet.com back to webetsolutions.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_mailusers_reverse_$timestamp.log"
$csvFile   = "./migration_mailusers_reverse_$timestamp.csv"
$results   = @()

$mailusers = Get-MailUser
foreach ($mu in $mailusers) {
    $prefix = $mu.PrimarySmtpAddress.Local
    $newPrimary = "SMTP:$prefix@webetsolutions.com"
    $oldAlias   = "smtp:$prefix@oasis-projet.com"
    try {
        Write-Host "↩ Rétro-migration: $($mu.DisplayName) -> $newPrimary" -ForegroundColor Yellow
        Set-MailUser -Identity $mu.Identity -EmailAddresses @($newPrimary, $oldAlias)
        $results += [pscustomobject]@{
            DisplayName = $mu.DisplayName
            Identity    = $mu.Identity
            NewPrimary  = "$prefix@webetsolutions.com"
            Timestamp   = (Get-Date)
            Status      = "Reverted"
        }
    } catch {
        Write-Warning "⛔ Erreur sur $($mu.DisplayName): $_"
        $results += [pscustomobject]@{
            DisplayName = $mu.DisplayName
            Identity    = $mu.Identity
            NewPrimary  = "$prefix@webetsolutions.com"
            Timestamp   = (Get-Date)
            Status      = "Error: $($_.Exception.Message)"
        }
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n🔁 Rétro-migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
