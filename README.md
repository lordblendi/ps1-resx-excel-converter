# RESX <-> CSV/TSV converter

## RESX to CSV/TSV

Converts a set of localized `.resx` files into a single CSV/TSV file that can be opened and edited in Excel.

### Description

The script searches a folder for `.resx` files sharing a common prefix and combines all translations into a single CSV/TSV file.

Supported naming conventions:

#### Convention 1

```text
LabelEn.resx
LabelDe.resx
LabelFr.resx
LabelIt.resx
LabelNl.resx
```

#### Convention 2

```text
Labels.resx
Labels.DE.resx
Labels.FR.resx
Labels.IT.resx
```

In the second convention, the resource file without a language suffix is interpreted as **English (EN)**.

Each resource key becomes a row in the CSV/TSV and each language becomes a column.

### Parameters

#### Path

Path containing the `.resx` files.

#### Prefix

Base filename prefix used to identify related `.resx` files.

#### Delimiter
Specifies the delimiter used in the generated output file.

Supported values:

- `Semicolon`
- `Comma`
- `Tab`

Default: `Semicolon`

### Examples

#### Convert Labels resources

```powershell
.\resx-to-excel.ps1 -Path C:\Resources -Prefix Labels
```

Produces:

```text
Labels.csv
```

### Output

Creates a CSV/TSV file named:

```text
<Prefix>.csv
```

Example:

```text
Labels.csv
```

### CSV/TSV Format

Example:

```csv
Key;EN;DE;FR;IT;NL
Hello;Hello;Hallo;Bonjour;Ciao;Hallo
Goodbye;Goodbye;Auf Wiedersehen;Au revoir;Arrivederci;Tot ziens
```

### Script Flow

1. Search for all matching `.resx` files.
2. Determine the language code for each file.
3. Load each resource file as XML.
4. Extract all `<data>` entries.
5. Aggregate translations by resource key.
6. Generate a table with:
   - one row per resource key
   - one column per language
7. Export the result to `<Prefix>.csv`.

### Console Output

Example:

```text
The following files have been found:

Name                           Value
----                           -----
EN                             C:\Resources\Labels.resx
DE                             C:\Resources\Labels.DE.resx
FR                             C:\Resources\Labels.FR.resx
IT                             C:\Resources\Labels.IT.resx

Converting into csv...

Translations have been added to Labels.csv.
```

## Import CSV/TSV to RESX

### Description

The import script reads a CSV/TSV file created by `resx-to-excel.ps1` and updates the corresponding `.resx` files.

The script:

- Updates existing resource values.
- Adds missing resource keys to existing `.resx` files.
- Uses the English (`EN`) value when a translation is empty.
- Skips language files that do not exist.
- Supports both naming conventions described above.

### Parameters

#### File

Path to the CSV/TSV file containing translations.

#### Path

Path containing the `.resx` files.

#### Prefix

Base filename prefix used to identify related `.resx` files.

#### Delimiter

Specifies the delimiter used in the input file.

Supported values:

- `Semicolon`
- `Comma`
- `Tab`

Default:

```text
Semicolon
```

### Examples

#### Update existing resource files

```powershell
.\excel-to-resx.ps1 `
    -File .\output\Labels.csv `
    -Path C:\Resources `
    -Prefix Labels
```

#### Import a tab-delimited file

```powershell
.\excel-to-resx.ps1 `
    -File .\output\Labels.tsv `
    -Path C:\Resources `
    -Prefix Labels `
    -Delimiter Tab
```

### Translation Fallback

If a translation is missing or empty, the English value is used automatically.

Example CSV:

```csv
Key;EN;DE;FR
Hello;Hello;Hallo;Bonjour
Goodbye;Goodbye;;Au revoir
Welcome;Welcome;;Bienvenue
```

Resulting German resources:

```text
Hello     => Hallo
Goodbye   => Goodbye
Welcome   => Welcome
```

### Missing Language Files

Only existing `.resx` files are updated.

Example resource files:

```text
Labels.resx
LabelsDe.resx
LabelsFr.resx
```

If the CSV/TSV contains the columns:

```text
EN
DE
FR
IT
```

the script updates:

```text
Labels.resx
LabelsDe.resx
LabelsFr.resx
```

and skips:

```text
LabelsIt.resx
```

because the file does not exist.

No new `.resx` files are created.

### Import Script Flow

1. Load the CSV/TSV file.
2. Detect all language columns in the first row.
3. Match each language to an existing `.resx` file.
4. Skip languages without a matching file.
5. Update existing resource values.
6. Add missing resource keys.
7. Use the English value when a translation is empty.
8. Save the updated `.resx` files.

### Console Output

Example:

```text
Loading translation file...

Languages found: EN, DE, FR, IT

Processing 'C:\Resources\Labels.resx'
Processing 'C:\Resources\LabelsDe.resx'
Processing 'C:\Resources\LabelsFr.resx'

Skipping 'C:\Resources\LabelsIt.resx' (file not found)

Adding missing key 'WelcomeMessage'

Resource files updated successfully.
```