if((Get-PSSnapin "Microsoft.SharePoint.PowerShell") -eq $null)
    {
        Add-PSSnapin Microsoft.SharePoint.PowerShell
    }


    $webUrl = "http://sharepoint%URL"

    $docLibraryName = "Shared Documents"
    #Subfolder location
    $docLibraryUrlName = "Shared Documents\subfolder_name"

    $localFolderPath = "C:\Users\Test_Loc"

    #Open web and library
    $web = Get-SPWeb $webUrl
    write-host $webUrl

    $docLibrary = $web.Lists[$docLibraryName]
    write-host $docLibrary

    $files = ([System.IO.DirectoryInfo] (Get-Item $localFolderPath)).GetFiles()

    write-host $files

    ForEach($file in $files)
    {

#Adjust for doc type
if($file.Name.Contains(".doc"))
{
    write-host $file

        #Open the file in local location
        try
        {
        $fileStream = ([System.IO.FileInfo] (Get-Item $file.FullName)).OpenRead()

        #Add the file to the web respository
        $folder =  $web.getfolder($docLibraryUrlName)

        write-host "Host.Copying File(): " $file.Name " to " $folder.ServerRelativeUrl "..[+].."
        $spFile = $folder.Files.Add($folder.Url + "/" + $file.Name,[System.IO.Stream]$fileStream, $true)
        write-host "[+] Successfully copied files"

        #Close file stream upon success
        $fileStream.Close();
        }
        catch
        {
        Write "Host.Error(): $file.name: $_" >>c:\log.txt
            continue;
        }
}
    }

    #Closure
    $web.Dispose()
