<#
.SYNOPSIS
Updates localized .resx files from a CSV file.

.DESCRIPTION
Reads a CSV/TSV file where each row represents a resource key and each
language is represented by a column.

Updates the corresponding .resx files and creates missing resource
entries when necessary.

If a translation is missing for a language, the English value is used.

.PARAMETER File
Path to the CSV or TSV file.

.PARAMETER Path
Directory containing the .resx files.

.PARAMETER Prefix
Resource file prefix.

.PARAMETER Delimiter
Delimiter used in the input file.

Supported values: Comma, Semicolon, Tab

Default value: Semicolon

.EXAMPLE
.\excel-to-resx.ps1 -Path ".\Files" -Prefix "YourStrings" -Delimiter "Semicolon" -File .\output\translations.csv

.NOTES
The default resource file without a language suffix is interpreted as EN.
#>

param(
    [Parameter(Mandatory)]
    [string]$File,

    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter(Mandatory)]
    [string]$Prefix,

    [ValidateSet('Comma', 'Semicolon', 'Tab')]
    [string]$Delimiter = 'Semicolon'
)

$delimiterChar = switch ($Delimiter) {
    'Comma'     { ',' }
    'Semicolon' { ';' }
    'Tab'       { "`t" }
}

Write-Host "Loading translation file..."

$rows = Import-Csv -Path $File -Delimiter $delimiterChar

if (-not $rows) {
    throw "No data found in $File"
}

$languages = $rows[0].PSObject.Properties.Name |
    Where-Object { $_ -ne 'Key' }

Write-Host "Languages found: $($languages -join ', ')"

foreach ($lang in $languages) {
    $langCode = $lang.Substring(0,1).ToUpper() + $lang.Substring(1).ToLower()
    $fileWithLangCode = Join-Path $Path "$Prefix$langCode.resx"
    $defaultFile = Join-Path $Path "$Prefix.resx"

    $resxFile = if (($lang -eq 'EN') -and (Test-Path $defaultFile)) {
            $defaultFile
    }
    else {
        $fileWithLangCode
    }

    Write-Host "Processing $resxFile"

    if (-not (Test-Path $resxFile)) {
        Write-Host "Skipping $resxFile (file not found)"
        continue
    }

    [xml]$resx = Get-Content $resxFile

    $existingNodes = @{}

    foreach ($node in $resx.root.data) {
        $existingNodes[$node.name] = $node
    }

    foreach ($row in $rows) {

        $key = $row.Key

        if ([string]::IsNullOrWhiteSpace($key)) {
            continue
        }

        $englishValue = $row.EN
        $translationValue = $row.$lang

        if ([string]::IsNullOrWhiteSpace($translationValue)) {
            $translationValue = $englishValue
        }

        if ($existingNodes.ContainsKey($key)) {
            if (-not [string]::IsNullOrWhiteSpace($translationValue)) {
                $existingNodes[$key].value = $translationValue
            }
        }
        else {
            Write-Host "Creating node for $key"

            $dataNode = $resx.CreateElement("data")
            $dataNode.SetAttribute("name", $key)
            # because this is a special namespace attribute
            $attr = $resx.CreateAttribute("xml", "space", "http://www.w3.org/XML/1998/namespace")
            $attr.Value = "preserve"
            $dataNode.Attributes.Append($attr) | Out-Null

            $valueNode = $resx.CreateElement("value")
            $valueNode.InnerText = $translationValue

            $dataNode.AppendChild($valueNode) | Out-Null
            $resx.DocumentElement.AppendChild($dataNode) | Out-Null
        }
    }

    $resx.Save($resxFile)
}

Write-Host "Resource files updated successfully."