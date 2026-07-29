
<#
.SYNOPSIS
Converts a set of localized .resx files into a single CSV file.

.DESCRIPTION
Searches the specified folder for .resx files matching a common prefix and
combines all translations into a single CSV file.

Each resource key becomes a row in the CSV and each language becomes a column.

.PARAMETER Path
Path containing the .resx files.

.PARAMETER Prefix
Base filename prefix used to identify related .resx files.

.EXAMPLE
.\resx-to-csv.ps1 -Path . -Prefix CmStrings

Converts all CmStrings*.resx files in the current directory into
translations.csv.

.EXAMPLE
.\resx-to-csv.ps1 -Path C:\Resources -Prefix BlankSlate

Converts BlankSlate.resx and BlankSlate.<LANG>.resx files found in
C:\Resources into translations.csv.

.OUTPUTS
Creates a file named translations.csv in the current working directory.

.NOTES
The default resource file without a language suffix is interpreted as English (EN).
#>
param(
    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory)]
    [string]$Prefix
)

# Get all files
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

Write-Output "The following files have been found:"
$languageFiles


Write-Output "Converting into csv..."
$translations = @{}

foreach ($lang in $languageFiles.Keys) {

    [xml]$resx = Get-Content $languageFiles[$lang]

    foreach ($node in $resx.root.data) {

        $key = $node.name
        $value = $node.value

        if (-not $translations.ContainsKey($key)) {
            $translations[$key] = @{}
        }

        $translations[$key][$lang] = $value
    }
}

$rows = foreach ($key in $translations.Keys | Sort-Object) {

    $row = [ordered]@{
        Key = $key
    }

    foreach ($lang in $languageFiles.Keys | Sort-Object) {
        $row[$lang] = $translations[$key][$lang]
    }

    [pscustomobject]$row
}

$filename = "$Prefix.csv"

$rows | Export-Csv $filename -NoTypeInformation -UseCulture -Encoding UTF8

Write-Output "Translations have been added to $filename."