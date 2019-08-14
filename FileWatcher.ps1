[CmdletBinding()]
Param(
    # Path to be monitored
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Path, 
    # File type to be monitored (* = wildcard)
    [Parameter(Position=1)]
    [string]$Filter = "*.*",
    # Inclusion of Subdirectories
    [switch]$Recurse,
    # Created
    [scriptblock]$CreatedAction,
    # Deleted
    [scriptblock]$DeletedAction,
    # Changed
    [scriptblock]$ChangedAction,
    # Renamed
    [scriptblock]$RenamedAction,
    # Check for ESC every ... seconds
    [int]$KeyboardTimeout = -1,
    # Log file list of changes - Needs specified
    [string]$LogFile = ''
)

Function DoAction(
    # Action specified to execute
    [scriptblock]$action,
    # File name and path being watched
    [string]$_,
    [System.Management.Automation.PSEventArgs]$eventArgs,
    $e
)
{
    # Action execution and catching the output
    $output = Invoke-Command $action

    if ($output) {
        # Write to output
        Write-Output $output
        # And to log file if we have to
        if ($LogFile -ne '') {
            Write-Output $output >> $LogFile
        }
    }
}

# Sanity check: 1+ action(s) required
if (!$CreatedAction -and !$DeletedAction -and !$ChangedAction -and !$RenamedAction) {
    Write-error "Specify at least one of -CreatedAction, -DeletedAction, -ChangedAction or -RenamedAction"
    return
}

# Remove all event handlers and events
@( "FileCreated", "FileDeleted", "FileChanged", "FileRenamed" ) | ForEach-Object {
    Unregister-Event -SourceIdentifier $_ -ErrorAction SilentlyContinue
    Remove-Event -SourceIdentifier $_ -ErrorAction SilentlyContinue
}

# Initialize file watching on the $Path argument's full path
[string]$fullPath = (Convert-Path $Path)

# Set up the file system watcher with the full path name of the supplied path
[System.IO.FileSystemWatcher]$fsw = New-Object System.IO.FileSystemWatcher $fullPath, $Filter -Property @{IncludeSubdirectories = $Recurse;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite, DirectoryName'}

# Register an event handler for all actions, if provided:
if ($CreatedAction) {
    Register-ObjectEvent $fsw Created -SourceIdentifier "FileCreated"
}
if ($DeletedAction) {
    Register-ObjectEvent $fsw Deleted -SourceIdentifier "FileDeleted"
}
if ($ChangedAction) {
    Register-ObjectEvent $fsw Changed -SourceIdentifier "FileChanged"
}
if ($RenamedAction) {
    Register-ObjectEvent $fsw Renamed -SourceIdentifier "FileRenamed"
}

[string]$recurseMessage = ''
if ($Recurse) {
    $recurseMessage = " and subdirectories"
}
[string]$pathWithFilter = Join-Path $fullPath $Filter

if ($KeyboardTimeout -eq -1) {
    Write-Host "Monitoring '$pathWithFilter'$recurseMessage. Press Ctrl+C to stop."
} else {
    Write-Host "Monitoring '$pathWithFilter'$recurseMessage. Press ESC to cancel in at most $KeyboardTimeout seconds, or Ctrl+C to abort."
}

# Initialize monitoring
$fsw.EnableRaisingEvents = $true

[bool]$exitRequested = $false

do {
    # Event trigger - waiting for events
    [System.Management.Automation.PSEventArgs]$e = Wait-Event -Timeout $KeyboardTimeout

    if ($e -eq $null) {
        # No evet? Then this is a timeout. Check for ESC
        while ($host.UI.RawUI.KeyAvailable) {
            $k = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
            if (($k.Character -eq 27) -and !$exitRequested) {
                Write-Host "ESC pressed. Exiting..."
                $exitRequested = $true
            }
        }
    } else {
        # Return file name
        [string]$name = $e.SourceEventArgs.Name
        # Change type
        [System.IO.WatcherChangeTypes]$changeType = $e.SourceEventArgs.ChangeType
        # Return date/time
        [string]$timeStamp = $e.TimeGenerated.ToString("yyyy-MM-dd HH:mm:ss")

        Write-Verbose "Host.Initialized() [$($e.EventIdentifier)] $changeType $name $timeStamp"

        switch ($changeType) {
            Changed { DoAction $ChangedAction $name $e $($e.SourceEventArgs) }
            Deleted { DoAction $DeletedAction $name $e $($e.SourceEventArgs) }
            Created { DoAction $CreatedAction $name $e $($e.SourceEventArgs) }
            Renamed { DoAction $RenamedAction $name $e $($e.SourceEventArgs) }
        }

        # Removing handled events
        Remove-Event -EventIdentifier $($e.EventIdentifier)

        Write-Verbose "--- END [$($e.EventIdentifier)] $changeType $name $timeStamp"
    }
} while (!$exitRequested)

if ($CreatedAction) {
    Unregister-Event FileCreated
}
if ($DeletedAction) {
    Unregister-Event FileDeleted
}
if ($ChangedAction) {
    Unregister-Event FileChanged
}
if ($RenamedAction) {
    Unregister-Event FileRenamed
}

Write-Host "Host.Exit()"
