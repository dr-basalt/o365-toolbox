# Rollback room and equipment mailboxes from oasis-projet.com back to webetsolutions.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_rooms_reverse_$timestamp.log"
$csvFile   = "./migration_rooms_reverse_$timestamp.csv"
$results   = @()

$resources = Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox
foreach ($mb in $resources) {
    $prefix = $mb.PrimarySmtpAddress.Local
    $newPrimary = "SMTP:$prefix@webetsolutions.com"
    $oldAlias   = "smtp:$prefix@oasis-projet.com"
    try {
        Write-Host "↩ Rétro-migration: $($mb.DisplayName) -> $newPrimary" -ForegroundColor Yellow
        Set-Mailbox -Identity $mb.Identity -EmailAddresses @($newPrimary, $oldAlias)
        $results += [pscustomobject]@{
            DisplayName = $mb.DisplayName
            Identity    = $mb.Identity
            NewPrimary  = "$prefix@webetsolutions.com"
            Timestamp   = (Get-Date)
            Status      = "Reverted"
        }
    } catch {
        Write-Warning "⛔ Erreur sur $($mb.DisplayName): $_"
        $results += [pscustomobject]@{
            DisplayName = $mb.DisplayName
            Identity    = $mb.Identity
            NewPrimary  = "$prefix@webetsolutions.com"
            Timestamp   = (Get-Date)
            Status      = "Error: $($_.Exception.Message)"
        }
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n🔁 Rétro-migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
