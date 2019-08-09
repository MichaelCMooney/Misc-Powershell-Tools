$lastBootTime = Get-CimInstance -ClassName win32_operatingsystem | select lastbootuptime
$lastBootTime = $lastBootTime.lastbootuptime

$events = Get-EventLog -LogName System -After $lastBootTime | where {$_.eventId -eq 6008}

$smtpServer = 

if ($events -ne $null) {
    Send-MailMessage -From FROMEMAIL@gmail.com -Subject "Unexpected shutdown detected on server" -To TOEMAIL@gmail.com -SmtpServer mail.domain.com
}
