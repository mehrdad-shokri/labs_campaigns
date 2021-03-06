#
# Script to detect the existence of Nansh0u IoCs on an infected machine
#

$ErrorActionPreference = "silentlycontinue"

$Nansh0uFound = $false

# IoCs
$PAYLOAD_NAMES = "avast.exe", "kvast.exe", "360protect.exe", "rock.exe", "rocks.exe", "lt.exe", "tl.exe", "tls.exe", "lcn.exe", "lolcn.exe"
$PAYLOAD_BASE_PATH = "C:\ProgramData\"
$DRIVER_NAME = "SA6482"
$REGISTRY_PATH_ADSL = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run"
$REGISTRY_PATH_RUN = "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"

Write-Output "Nansh0u-Campaign Detection Tool"
Write-Output "Written By Guardicore Labs"
Write-Output "Contact us at: labs@guardicore.com"

# Check for miner filenames in C:\ProgramData
$payloadFound = $false
foreach ($pn in $PAYLOAD_NAMES) {
    if ([System.IO.File]::Exists($(Join-Path -Path $PAYLOAD_BASE_PATH -ChildPath $pn))) {
        $payloadFound = $Nansh0uFound = $true
        Write-Output "[X] Malicious payload $pn was found in $PAYLOAD_BASE_PATH"
    }
}
if (!$payloadFound) {
    Write-Output "[V] No payload name was found in $PAYLOAD_BASE_PATH"
}

# Detect driver
$driverFound = $false
if (driverquery.exe | Select-String $DRIVER_NAME) {
    $driverFound = $Nansh0uFound = $true
    Write-Output "[X] Driver $DRIVER_NAME was found on this host"
}
if (!$driverFound) {
    Write-Output "[V] Nansh0u's malicious driver was not found on this host"
}

# Check run-keys in registry
$regkeyFound = $false
foreach ($pn in $PAYLOAD_NAMES) {
    $adslKey = Get-ItemProperty -Path "Registry::$REGISTRY_PATH_ADSL"
    $runKey = Get-ItemProperty -Path "Registry::$REGISTRY_PATH_RUN"
    if ($adslKey | Select-String $pn) {
		$regkeyFound = $Nansh0uFound = $true
		Write-Output "[X] Registry run key $REGISTRY_PATH_ADSL was found to run the malicious payload $pn on this host"
	}
	if ($runKey | Select-String $pn) {
		$regkeyFound = $Nansh0uFound = $true
		Write-Output "[X] Registry run key $REGISTRY_PATH_RUN was found to run the malicious payload $pn on this host"
	}
}
if (!$regkeyFound) {
    Write-Output "[V] No malicious runkey was found in this host's registry"
}

if ($Nansh0uFound) {
    Write-Output "[X] Evidence for Nansh0u campaign has been found on this host"
}
else {
    Write-Output "[V] No evidence for Nansh0u campaign has been found on this host"
}
