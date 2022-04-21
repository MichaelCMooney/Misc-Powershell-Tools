#Define your desired directory and the line count to iterate against (15000 is the defined linecount by default)
#Change the file name (File.txt is the default)

cd "DESIRED DIRECTORY"
$i=0; Get-Content File.txt -ReadCount 15000 | %{$i++; $_ | Out-File out_$i.txt}
