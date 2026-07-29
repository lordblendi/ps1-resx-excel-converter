param(
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory)]
    [string]$Prefix
)

$languageFiles = @{}

Get-ChildItem -Path $Path -Filter "$Prefix*.resx" | ForEach-Object {
    $baseName = $_.BaseName
    if ($baseName -eq $Prefix) {
        $languageFiles['EN'] = $_.FullName
    }
    elseif ($baseName -match "^$Prefix\.?([A-Za-z]{2})$") {
        $languageFiles[$matches[1].ToUpper()] = $_.FullName
    }
}

$languageFiles