# Migrates room and equipment mailboxes from webetsolutions.com to oasis-projet.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_rooms_to_oasis_$timestamp.log"
$csvFile   = "./migration_rooms_to_oasis_$timestamp.csv"
$results   = @()

$resources = Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox
foreach ($mb in $resources) {
    $prefix = $mb.PrimarySmtpAddress.Local
    $newPrimary = "SMTP:$prefix@oasis-projet.com"
    $oldAlias   = "smtp:$prefix@webetsolutions.com"
    try {
        Write-Host "➡ Migration: $($mb.DisplayName) -> $newPrimary" -ForegroundColor Cyan
        Set-Mailbox -Identity $mb.Identity -EmailAddresses @($newPrimary, $oldAlias)
        $results += [pscustomobject]@{
            DisplayName = $mb.DisplayName
            Identity    = $mb.Identity
            NewPrimary  = "$prefix@oasis-projet.com"
            Timestamp   = (Get-Date)
            Status      = "Migrated"
        }
    } catch {
        Write-Warning "⛔ Erreur sur $($mb.DisplayName): $_"
        $results += [pscustomobject]@{
            DisplayName = $mb.DisplayName
            Identity    = $mb.Identity
            NewPrimary  = "$prefix@oasis-projet.com"
            Timestamp   = (Get-Date)
            Status      = "Error: $($_.Exception.Message)"
        }
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ Migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
