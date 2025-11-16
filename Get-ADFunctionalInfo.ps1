<#
    Get-ADFunctionalInfo.ps1
    Collects Domain and Forest Functional Levels, plus AD Partitions
#>

$domain = Get-ADDomain
$forest = Get-ADForest

$results = [PSCustomObject]@{
    DomainName               = $domain.Name
    DomainFunctionalLevel    = $domain.DomainMode
    ForestName               = $forest.Name
    ForestFunctionalLevel    = $forest.ForestMode
}

"=== Domain/Forest Functional Levels ==="
$results | Format-Table

# Export to CSV
$results | Export-Csv -Path ".\DomainForestLevels.csv" -NoTypeInformation

# Get Partitions & Replication Locations
$partitions = Get-ADObject -SearchBase ($forest.PartitionsContainer) -Filter 'objectClass -eq "crossRef"' -Properties *

$partitionsFormatted = $partitions | Select-Object `
    name,
    nCName,
    @{n='ReplicaLocations'; e={$_.msDS-NC-Replica-Locations -join ';'}}

"=== Partitions Summary ==="
$partitionsFormatted | Format-Table

# Export partitions
$partitionsFormatted | Export-Csv -Path ".\ADPartitions.csv" -NoTypeInformation

# Export all to JSON
@{
    FunctionalLevels = $results
    Partitions       = $partitionsFormatted
} | ConvertTo-Json -Depth 5 | Out-File ".\ADFunctionalExport.json"

Write-Host "Export complete: DomainForestLevels.csv, ADPartitions.csv, ADFunctionalExport.json" -ForegroundColor Green
