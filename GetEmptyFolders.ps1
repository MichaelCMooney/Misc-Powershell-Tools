Get-ChildItem C:\Desired\Location\ -Recurse -Directory | Where-Object {(Get-ChildItem $_.FullName -File -Recurse -Force).Count -eq 0} | Export-Csv -Path C:\Output\Location.csv
