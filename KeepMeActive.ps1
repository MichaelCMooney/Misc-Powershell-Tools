# Found that sending the "." key is imperfect. This solution requires another program to be open to place the "." key into.
# This should instead be replaced by the "F15" key, which is uncommon on most keyboards so most programs don't accept it, but WinOS will.

param($minutes = 60)

$myshell = New-Object -com "Wscript.Shell"

for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 60
  $myshell.sendkeys(".")
}
