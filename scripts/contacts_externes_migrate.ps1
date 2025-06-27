# Migrates external contacts from webetsolutions.com to oasis-projet.com
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile   = "./migration_contacts_to_oasis_$timestamp.log"
$csvFile   = "./migration_contacts_to_oasis_$timestamp.csv"
$results   = @()

$contacts = Get-MailContact
foreach ($contact in $contacts) {
    if ($contact.ExternalEmailAddress -like "*@webetsolutions.com") {
        $newEmail = $contact.ExternalEmailAddress.ToString().Replace("@webetsolutions.com", "@oasis-projet.com")
        try {
            Set-MailContact -Identity $contact.Identity -ExternalEmailAddress $newEmail
            Write-Host "➡ Contact mis à jour : $($contact.DisplayName)" -ForegroundColor Cyan
            $results += [pscustomobject]@{
                DisplayName = $contact.DisplayName
                Identity    = $contact.Identity
                OldAddress  = $contact.ExternalEmailAddress.ToString()
                NewAddress  = $newEmail
                Timestamp   = (Get-Date)
                Status      = "Migrated"
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
Write-Host "`n✅ Migration terminée. Logs : $logFile`nCSV : $csvFile" -ForegroundColor Green
