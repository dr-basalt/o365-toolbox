# Migrates mail users (other systems) from webetsolutions.com to oasis-projet.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_mailusers_to_oasis_$timestamp.log"
$csvFile   = "./migration_mailusers_to_oasis_$timestamp.csv"
$results   = @()

$mailusers = Get-MailUser
foreach ($mu in $mailusers) {
    $prefix = $mu.PrimarySmtpAddress.Local
    $newPrimary = "SMTP:$prefix@oasis-projet.com"
    $oldAlias   = "smtp:$prefix@webetsolutions.com"
    try {
        Write-Host "➡ Migration: $($mu.DisplayName) -> $newPrimary" -ForegroundColor Cyan
        Set-MailUser -Identity $mu.Identity -EmailAddresses @($newPrimary, $oldAlias)
        $results += [pscustomobject]@{
            DisplayName = $mu.DisplayName
            Identity    = $mu.Identity
            NewPrimary  = "$prefix@oasis-projet.com"
            Timestamp   = (Get-Date)
            Status      = "Migrated"
        }
    } catch {
        Write-Warning "⛔ Erreur sur $($mu.DisplayName): $_"
        $results += [pscustomobject]@{
            DisplayName = $mu.DisplayName
            Identity    = $mu.Identity
            NewPrimary  = "$prefix@oasis-projet.com"
            Timestamp   = (Get-Date)
            Status      = "Error: $($_.Exception.Message)"
        }
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ Migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
