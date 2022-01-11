# LumberjackPS
> github.com/LincolnOtter/LumberjackPS

### Contents
  - [What is it?](#what-is-it)
  - [Function List](#function-list)
 
 ---

## What is it?
Lumberjack is a PowerShell module designed for script logging. It is designed primarily for use with InTune (Endpoint Manager), but can be used for many cases of Powershell logging.

# Cmdlet List
- `Start-OtterLog`
Creates a new log file and initialises it as a target for future logging cmdlets.

  **Parameters**
      
      -LogName [string] -default "Log"
      Determines the prefix of the log file. (example: <Your-Logfile-Name.log>)

      -OmitLogStartText [switch] 
      Removes the default banner and script info printed by the Write-OtterLogStart cmdlet.

      -LogDirectory [string] -default "C:\IT\Logs"
      Sets the directory where the log files will be stored.
  
- `Write-OtterLog`
Writes a new log line to the initialised log file.
  
  **Parameters**

      -LogString [string]
      The string that will be written to the log file.

      -OmitDatePrefix [switch]
      Removes the standard date prefix to log lines.

      -AddEmptyLine [switch]
      Adds a blank empty line below the log file line added.

- `Stop-OtterLog`
Writes a new log line to the initialised log file.
  
  **Parameters**

      -LogString [string]
      The string that will be written to the log file.

      -OmitDatePrefix [switch]
      Removes the standard date prefix to log lines.

      -AddEmptyLine [switch]
      Adds a blank empty line below the log file line added.