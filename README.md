# RESX to CSV

Converts a set of localized `.resx` files into a single CSV file that can be opened and edited in Excel.

## Description

The script searches a folder for `.resx` files sharing a common prefix and combines all translations into a single CSV file.

Supported naming conventions:

### Convention 1

```text
LabelEn.resx
LabelDe.resx
LabelFr.resx
LabelIt.resx
LabelNl.resx
```

### Convention 2

```text
Labels.resx
Labels.DE.resx
Labels.FR.resx
Labels.IT.resx
```

In the second convention, the resource file without a language suffix is interpreted as **English (EN)**.

Each resource key becomes a row in the CSV and each language becomes a column.

## Parameters

### Path

Path containing the `.resx` files.

### Prefix

Base filename prefix used to identify related `.resx` files.

### Delimiter
Specifies the delimiter used in the generated output file.

Supported values:

- `Semicolon`
- `Comma`
- `Tab`

Default: `Semicolon`

## Examples

### Convert Labels resources

```powershell
.\resx-to-csv.ps1 -Path C:\Resources -Prefix Labels
```

Produces:

```text
Labels.csv
```

## Output

Creates a CSV file named:

```text
<Prefix>.csv
```

Example:

```text
Labels.csv
```

## CSV Format

Example:

```csv
Key;EN;DE;FR;IT;NL
Hello;Hello;Hallo;Bonjour;Ciao;Hallo
Goodbye;Goodbye;Auf Wiedersehen;Au revoir;Arrivederci;Tot ziens
```

## Script Flow

1. Search for all matching `.resx` files.
2. Determine the language code for each file.
3. Load each resource file as XML.
4. Extract all `<data>` entries.
5. Aggregate translations by resource key.
6. Generate a table with:
   - one row per resource key
   - one column per language
7. Export the result to `<Prefix>.csv`.

## Console Output

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