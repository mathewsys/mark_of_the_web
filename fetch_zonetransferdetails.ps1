# Define the folder to scan
# $folderPath = "C:\Users\rathe\Downloads"
$folderPath = "D:\"

# Define the output file
$outputFile = "$env:TEMP\ZoneTransfer_Report.txt"
if (Test-Path $outputFile) { Remove-Item $outputFile }

# Get all files recursively
$files = Get-ChildItem -Path $folderPath -Recurse -File -ErrorAction SilentlyContinue

foreach ($file in $files) {
    try {
        # Get all ADS streams for the file
        $streams = Get-Item -Path $file.FullName -Stream * -ErrorAction Stop
        foreach ($stream in $streams) {
            if ($stream.Stream -eq "Zone.Identifier") {
                $zoneData = Get-Content -Path "$($file.FullName):Zone.Identifier" -ErrorAction SilentlyContinue
                Add-Content -Path $outputFile -Value "File: $($file.FullName)"
                Add-Content -Path $outputFile -Value "Zone Identifier:"
                Add-Content -Path $outputFile -Value $zoneData
                Add-Content -Path $outputFile -Value "`n-------------------------`n"
            }
        }
    } catch {
        # Ignore files that don't support ADS or return error
        continue
    }
}

# Open the report in Notepad
if (Test-Path $outputFile) {
    notepad $outputFile
} else {
    Write-Host "No Zone.Identifier data found in $folderPath"
}
