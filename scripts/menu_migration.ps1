function Show-Menu {
    Clear-Host
    Write-Host "==== Menu de migration ====" -ForegroundColor Cyan
    Write-Host "1 - Migrer boîtes utilisateurs"
    Write-Host "2 - Rétro-migrer boîtes utilisateurs"
    Write-Host "3 - Migrer boîtes partagées"
    Write-Host "4 - Rétro-migrer boîtes partagées"
    Write-Host "5 - Migrer groupes M365"
    Write-Host "6 - Rétro-migrer groupes M365"
    Write-Host "7 - Migrer groupes de distribution"
    Write-Host "8 - Rétro-migrer groupes de distribution"
    Write-Host "9 - Migrer contacts externes"
    Write-Host "10 - Rétro-migrer contacts externes"
    Write-Host "11 - Migrer mail users"
    Write-Host "12 - Rétro-migrer mail users"
    Write-Host "13 - Migrer salles et équipements"
    Write-Host "14 - Rétro-migrer salles et équipements"
    Write-Host "0 - Quitter"
}

do {
    Show-Menu
    $choice = Read-Host "Choix"
    switch ($choice) {
        "1" { ./bal_migrate.ps1 }
        "2" { ./bal_migrate_inverse.ps1 }
        "3" { ./balp_migrate.ps1 }
        "4" { ./balp_migrate_inverse.ps1 }
        "5" { ./groupe_m365_migrate.ps1 }
        "6" { ./group_m365_migrate_inverse.ps1 }
        "7" { ./groupe_distribution_migrate.ps1 }
        "8" { ./groupe_distribution_migrate_inverse.ps1 }
        "9" { ./contacts_externes_migrate.ps1 }
        "10" { ./contacts_externes_migrate_inverse.ps1 }
        "11" { ./mailusers_other_system.ps1 }
        "12" { ./mailusers_other_system_inverse.ps1 }
        "13" { ./salles_migrate.ps1 }
        "14" { ./salles_migrate_inverse.ps1 }
        "0" { Write-Host "Fin du script." }
        default { Write-Host "Option invalide." -ForegroundColor Red }
    }
    if ($choice -ne "0") { Pause }
} while ($choice -ne "0")
