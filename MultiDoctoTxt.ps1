$wdFormatDocument = 0

$objWord = New-Object -comobject Word.Application
$objWord.Visible = $True
$objDoc = $objWord.Documents.Add()

$colFiles = gci("C:\Location\*.doc")

Move-Item -Path C:\OldLocation\*.doc -Destination C:\NewLocation

foreach ($objFile in $colFiles)
{
    $strFile = $objFile.FullName
    $strNewFile = $objFile.DirectoryName + "\" `
        + $objFile.Name.Split(".")[0] + ".txt"
        $objDoc = $objWord.Documents.Open($strFile, $False)
        $a = $objDoc.SaveAs([ref] $strNewFile, [ref] $wdFormatDocument)
        $objDoc.Close()
        Move-Item -Path C:\OldLocation\*.txt -Destination C:\TempLocation\UsedTo\VerifyComplete
}

$a = $objWord.Quit()
