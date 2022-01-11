$private:WriteHostPrefix = "<OTTER-LUMBERJACK>"

# Start-OtterLog
function Start-OtterLog {

    [CmdletBinding()]
    param(
        [string]$LogName = "Log",
        [switch]$OmitDatePrefix,
        [switch]$OmitLogStartText,
        [string]$LogDirectory = "C:\IT\Logs",
        [int]$private:DuplicateMax = 100 
    )

     # Check/create log directory
     if (-not(Test-Path -Path $LogDirectory)) {
        New-Item -Type Directory $LogDirectory -Force
        if ($?) {
            Write-Host "$private:WriteHostPrefix Log directory did not exit" -ForegroundColor Yellow
        } else {
            Throw $Error[0]
        }
    }

    # Get date
    $LogDate = Get-Date -Format "dd-MM-yyyy_"

    # Get log name
    if ($UseScriptFileAsName) {
        $LogName = $MyInvocation.MyCommand.Name
    }

    # Create global variable
    $LogFullName = "$LogDirectory\$LogDate$LogName.log"
    $global:OtterLog = $LogFullName

    # Finalise log name
    $DuplicateCount = 2
    :DuplicateLoop while (Test-Path -Path $global:OtterLog) {
        $global:OtterLog = "$LogDirectory\$LogDate$LogName"+"_$DuplicateCount.log"
        $DuplicateCount++
        # Break above 1000
        if ($DuplicateCount -gt $private:DuplicateMax) {
            Throw "Unable to initialise new log file. Log file [$LogFullName] duplicate count of $private:DuplicateMax has been detected. This function will not create any more log file duplicates. Use the switch -ByPassDuplicateError to bypass this stop."
        }
    }

    # Create log file
    New-Item $global:OtterLog -Type File
    if ($? -eq $false) {
        Throw $Error[0]
    }

    # Log start text
    if (-not($OmitLogStartText)) {
        Write-OtterLogStart
    }

    Write-Host "$private:WriteHostPrefix Log file created [$global:OtterLog]" -ForegroundColor Yellow
    Write-Host ""
    return

}

function Stop-OtterLog {

    [CmdletBinding()]
    param(
        [switch]$OmitLogSummary
    )

    # Check for global var
    if ($null -eq $global:OtterLog) {
        Throw "Unable to stop log. A log file has not been initialised."
    }

    # Check for log file existance
    if (-not(Test-Path -Path $global:OtterLog)) {
        Throw "Unable to stop log. The log file [$global:OtterLog] does not exist or cannot be read."
    }

    # Add Summary
    if (-not($OmitLogSummary)) {
        Write-OtterLogEnd
    }

}

# Write-OtterLog
function Write-OtterLog {

    [CmdletBinding()]
    param(
        [string]$LogString,
        [switch]$AddEmptyLine,
        [switch]$OmitDatePrefix
    )

    # Check for global var
    if ($null -eq $global:OtterLog) {
        Throw "Unable to write log. A log file has not been initialised."
    }

    # Check for log file existance
    if (-not(Test-Path -Path $global:OtterLog)) {
        Throw "Unable to write log. The log file [$global:OtterLog] does not exist or cannot be read."
    }

    # Write to log 
    if ($OmitDatePrefix) {
        $WriteLogString = $LogString
    } else {
        $WriteLogDate = Get-Date -Format "[dd-MM-yyyy hh:mm:ss.fff]  "
        $WriteLogString = "$WriteLogDate$LogString"
    }

    # Add Empty line?
    if ($AddEmptyLine) {
        $WriteLogString += "`n"
    }

    # Add to log file
    try {
        Add-Content -Path $global:OtterLog -Value $WriteLogString -Force
    } catch {
        Throw "Unable to write log. Unexpected error $Error[0]"
    }

}

function Write-OtterLogStart {

    [CmdletBinding()]
    param(
        [switch]$OmitBanner
    )

    # Add Banner
    $private:OtterLogBanner = `
"     ____  _   _            _                     _               _             _   
    / __ \| |_| |_ ___ _ __| |    _   _ _ __ ___ | |__   ___ _ __(_) __ _  ___| | __
   | |  | | __| __/ _ \ '__| |   | | | | '_ ' _ \| '_ \ / _ \ '__| |/ _' |/ __| |/ /
   | |__| | |_| ||  __/ |  | |___| |_| | | | | | | |_) |  __/ |  | | (_| | (__|   < 
    \____/ \__|\__\___|_|  |______\__,_|_| |_| |_|_.__/ \___|_| _| |\__._|\___|_|\_\                
     github.com/LincolnOtter/LumberjackPS                      |___/  
=======================================================================================" 
    if (-not($OmitBanner)) {
        Write-OtterLog -LogString $private:OtterLogBanner -AddEmptyLine -OmitDatePrefix
    }
    
    # Add script stats
    $global:OtterLogStart = Get-Date
    $LogStartString = Get-Date -Format "dd-MM-yyyy hh:mm:ss.fff"
    Write-OtterLog "   Script stats" -OmitDatePrefix
    Write-OtterLog "     Log started:     $LogStartString" -OmitDatePrefix
    Write-OtterLog "     Ran as         : $env:USERNAME" -OmitDatePrefix -AddEmptyLine
    Write-OtterLog "=======================================================================================" -OmitDatePrefix -AddEmptyLine

}

function Write-OtterLogEnd {

    [CmdletBinding()]
    param(
    )

    # Add Banner
    if (-not($OmitBanner)) {
        Write-OtterLog "" -OmitDatePrefix
        Write-OtterLog "" -OmitDatePrefix
        Write-OtterLog "=======================================================================================" -AddEmptyLine -OmitDatePrefix
    }
    
    # Script duration
    $global:OtterLogEnd = Get-Date
    $ScriptDuration = $global:OtterLogEnd.Subtract($global:OtterLogStart)
    $DurationDays = $ScriptDuration.Days
    $DurationHours = $ScriptDuration.Hours
    $DurationMins = $ScriptDuration.Minutes
    $DurationSecs = $ScriptDuration.Seconds
    $DurationMSecs = $ScriptDuration.Milliseconds

    $DurationString = ""
    if ($DurationDays -gt 0) { $DurationString += "$DurationDays days, " }
    if ($DurationHours -gt 0) { $DurationString += "$DurationHours hours, " }
    if ($DurationMins -gt 0) { $DurationString += "$DurationMins minutes, " }
    $DurationString += "$DurationSecs seconds, "
    $DurationString += "and $DurationMSecs millseconds. "


    # Add script stats
    $LogStartString = Get-Date -Format "dd-MM-yyyy hh:mm:ss.fff"
    Write-OtterLog "   Script stats" -OmitDatePrefix
    Write-OtterLog "     Log ended:       $LogStartString" -OmitDatePrefix
    Write-OtterLog "     Script duration: $DurationString" -OmitDatePrefix -AddEmptyLine
    Write-OtterLog "Log file closed."

}