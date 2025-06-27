# Rollback external contacts from oasis-projet.com back to webetsolutions.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_contacts_reverse_$timestamp.log"
$csvFile   = "./migration_contacts_reverse_$timestamp.csv"
$results   = @()

$contacts = Get-MailContact
foreach ($contact in $contacts) {
    if ($contact.ExternalEmailAddress -like "*@oasis-projet.com") {
        $newEmail = $contact.ExternalEmailAddress.ToString().Replace("@oasis-projet.com", "@webetsolutions.com")
        try {
            Set-MailContact -Identity $contact.Identity -ExternalEmailAddress $newEmail
            Write-Host "↩ Contact remis à jour : $($contact.DisplayName)" -ForegroundColor Yellow
            $results += [pscustomobject]@{
                DisplayName = $contact.DisplayName
                Identity    = $contact.Identity
                OldAddress  = $contact.ExternalEmailAddress.ToString()
                NewAddress  = $newEmail
                Timestamp   = (Get-Date)
                Status      = "Reverted"
            }
        } catch {
            Write-Warning "⛔ Erreur sur $($contact.DisplayName): $_"
            $results += [pscustomobject]@{
                DisplayName = $contact.DisplayName
                Identity    = $contact.Identity
                OldAddress  = $contact.ExternalEmailAddress.ToString()
                NewAddress  = $newEmail
                Timestamp   = (Get-Date)
                Status      = "Error: $($_.Exception.Message)"
            }
        }
    }
}

$results | Tee-Object -FilePath $logFile | Out-Null
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding UTF8
Write-Host "`n🔁 Rétro-migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
