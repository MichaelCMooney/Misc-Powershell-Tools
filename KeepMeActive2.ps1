param($minutes = 60)

$IPAddress = Get-NetIPAddress -AddressFamily IPv4
$Env = $env:COMPUTERNAME
$runTime = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
$runTimeRef = $(((get-date).ToUniversalTime()).ToString("yyyy/MM/dd T HH-6:mm:ss"))

# Threw in window sizing to make this move economical for screen space in refresh methods.
# Could also reference Set-WindowSize commented out below this method.
Function Set-WindowSize {
Param([int]$x=$host.ui.rawui.windowsize.width,
      [int]$y=$host.ui.rawui.windowsize.height)

    $size=New-Object System.Management.Automation.Host.Size($x,$y)
    $host.ui.rawui.WindowSize=$size   
}

echo "   "
echo "Enter Text Here So You Know It Started"
echo $Env
echo "Refresh Started At: "
echo $runTime

#Set-WindowSize 40 10

# For balloon icon
Add-Type -AssemblyName  System.Windows.Forms 

$global:balloon = New-Object System.Windows.Forms.NotifyIcon 

#Handler
[void](Register-ObjectEvent  -InputObject $balloon  -EventName MouseDoubleClick  -SourceIdentifier IconClicked  -Action {
  $global:balloon.dispose()
  Unregister-Event  -SourceIdentifier IconClicked
  Remove-Job -Name IconClicked
  Remove-Variable  -Name balloon  -Scope Global
}) 

$path = (Get-Process -id $pid).Path
$balloon.Icon  = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 

$obj = new-object -com wscript.shell

Function Set-Speaker($Volume){$wshShell = new-object -com wscript.shell;1..50 | % {$wshShell.SendKeys([char]174)};1..$Volume | % {$wshShell.SendKeys([char]175)}}

$myshell = New-Object -com "Wscript.Shell"

# Set the $rnd variable Minimum and Maximum thresholds that Get-Random will work within for the loop refresh.
# Or comment that out and just run with Start-Sleep -Seconds NumVal method to run this continuously.
for ($i = 0; $i -lt $minutes; $i++) {
  $rnd = Get-Random -Minimum 60 -Maximum 280
  #Start-Sleep -Seconds 240
  Start-Sleep -Seconds $rnd
  $myshell.sendkeys("{F15}")
  Set-Speaker -Volume 0
  [System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property
  $balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::Info
  $balloon.BalloonTipText  = 'TEXT FOR A WINDOWS BALLOON MESSAGE
  AND THIS CAN GO TO NEXT LINE LIKE SOa'
  $balloon.BalloonTipTitle  = "TITLE FOR A WINDOWS BALLOON MESSAGE" 
  $balloon.Visible  = $true 
  $balloon.ShowBalloonTip(5000)
  Start-Sleep -Seconds 3
  # Changing of speaker volume designed for persistent activity in case F15 key method above is not working.
  # Volume of 50 = Maximum volume in Windows (2x)
  Set-Speaker -Volume 50
}
