# Migrates shared mailboxes from webetsolutions.com to oasis-projet.com
$oldDomain = "webetsolutions.com"
$newDomain = "oasis-projet.com"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_BALP_to_oasis_$timestamp.log"
$csvFile   = "./migration_BALP_to_oasis_$timestamp.csv"
$results   = @()

$sharedMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox
foreach ($mb in $sharedMailboxes) {
    $prefix = $mb.PrimarySmtpAddress.Local
    $currentPrimary = $mb.PrimarySmtpAddress.ToString()
    if ($currentPrimary -like "*@$oldDomain") {
        $newPrimary = "SMTP:$prefix@$newDomain"
        $oldAlias   = "smtp:$prefix@$oldDomain"
        try {
            Write-Host "➡ Migration: $($mb.DisplayName) -> $newPrimary" -ForegroundColor Cyan
            Set-Mailbox -Identity $mb.Identity -EmailAddresses @($newPrimary, $oldAlias)
            $results += [pscustomobject]@{
                DisplayName = $mb.DisplayName
                Identity    = $mb.Identity
                OldPrimary  = $currentPrimary
                NewPrimary  = "$prefix@$newDomain"
                Timestamp   = (Get-Date)
                Status      = "Migrated"
            }
        } catch {
            Write-Warning "⛔ Erreur sur $($mb.DisplayName): $_"
            $results += [pscustomobject]@{
                DisplayName = $mb.DisplayName
                Identity    = $mb.Identity
                OldPrimary  = $currentPrimary
                NewPrimary  = "$prefix@$newDomain"
                Timestamp   = (Get-Date)
                Status      = "Error: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "⏭ Déjà migrée ou autre domaine: $($mb.DisplayName)" -ForegroundColor DarkGray
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ Migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
