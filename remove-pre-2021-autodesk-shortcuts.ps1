# This script has been added as a "Script" in MECM, which you can run a la cart gainst individual machines, or collections.
# https://github.com/engrit-illinois/remove-pre-2021-autodesk-shortcuts

# Logging
$logPath = "c:\engrit\logs"
$ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "remove-pre-2021-autodesk-shortcuts_$ts.log"
$log = "$logPath\$logFile"
	
function log($msg) {
	if(!(Test-Path -PathType leaf -Path $log)) {
		$shutup = New-Item -ItemType File -Force -Path $log
	}
	
	$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss:ffff"
	$msg = "[$ts] $msg"
	
	Write-Host $msg
	$msg | Out-File $log -Append
}

$yearsToRemove = @("2015","2016","2017","2018","2019","2020")

# Grab as many obsolete shortcuts as possible from the start menu and public desktop
$shortcuts = @()
foreach($year in $yearsToRemove) {
	# Start menu shortcuts
	$shortcuts += @(Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Autodesk\" -Recurse -Filter "*$year*")
	$shortcuts += @(Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\" -Recurse -Filter "*autodesk*$year*")
	$shortcuts += @(Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\" -Recurse -Filter "*autocad*$year*")
	
	# Public desktop shortcuts
	$shortcuts += @(Get-ChildItem "C:\Users\Public\Desktop\" -Recurse -Filter "*autodesk*$year*")
	$shortcuts += @(Get-ChildItem "C:\Users\Public\Desktop\" -Recurse -Filter "*autocad*$year*")
	# This would catch non-Autodesk products
	#$shortcuts += @(Get-ChildItem "C:\Users\Public\Desktop\" -Recurse -Filter "*$year*")
}

# Keep only full paths
$shortcuts = $shortcuts.FullName

# Remove duplicates and sort so that files in folders are deleted before folders are deleted to avoid throwing meaningless errors
$shortcuts = $shortcuts | Select -Unique | Sort -Descending

# Log list of items being found
log "`nInitial items found:"
log "----------------"
log ($shortcuts | Out-String)
log "----------------"

# Exempt Moldflow Advisor 2019
$shortcuts = $shortcuts | Where { $_ -notlike "*moldflow*" }

# Log list of items being removed
log "`nItems to remove, after ignoring Moldflow:"
log "----------------"
log ($shortcuts | Out-String)
log "----------------"

# Remove items
log "`nRemoving items..."
foreach($shortcut in $shortcuts) {
	log "    Removing `"$shortcut`"..."
	Remove-Item -Force -Recurse -LiteralPath $shortcut
	log "    Done removing `"$shortcut`"."
}
log "Done removing items."

log "EOF"