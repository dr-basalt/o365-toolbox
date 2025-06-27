# Rollback user mailboxes from oasis-projet.com back to webetsolutions.com
$oldDomain = "oasis-projet.com"
$newDomain = "webetsolutions.com"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./reverse_migration_BAL_user_to_web_$timestamp.log"
$csvFile   = "./reverse_migration_BAL_user_to_web_$timestamp.csv"
$results   = @()

$userMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
foreach ($mb in $userMailboxes) {
    $prefix = $mb.PrimarySmtpAddress.Local
    $currentPrimary = $mb.PrimarySmtpAddress.ToString()
    if ($currentPrimary -like "*@$oldDomain") {
        $newPrimary = "SMTP:$prefix@$newDomain"
        $oldAlias   = "smtp:$prefix@$oldDomain"
        try {
            Write-Host "↩ Rétro-migration: $($mb.DisplayName) -> $newPrimary" -ForegroundColor Yellow
            Set-Mailbox -Identity $mb.Identity -EmailAddresses @($newPrimary, $oldAlias)
            $results += [pscustomobject]@{
                DisplayName = $mb.DisplayName
                Identity    = $mb.Identity
                OldPrimary  = $currentPrimary
                NewPrimary  = "$prefix@$newDomain"
                Timestamp   = (Get-Date)
                Status      = "Reverted"
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
        Write-Host "⏭ Déjà sur $newDomain ou autre domaine: $($mb.DisplayName)" -ForegroundColor DarkGray
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n🔁 Rétro-migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
