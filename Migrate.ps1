param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DBScriptFile,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$DBServer,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]$Database,

    [Parameter(Mandatory = $true, Position = 3)]
    [string]$CurrentDir,

    [Parameter(Mandatory = $true, Position = 4)]
    [string]$Env,

    [Parameter(Position = 5)]
    [string]$UserName,

    [Parameter(Position = 6)]
    [string]$Password,

    [Parameter(Mandatory = $true, Position = 7)]
    [string]$Authentication

)

try {
    $Filename = [io.path]::GetFileNameWithoutExtension("$DBScriptFile")
    $Filename = $Filename.Substring(5)
    $CurrentDir = $CurrentDir.ToString()
    $JSON = Get-Content $currentDir\"SSIS\config.json" | Out-String | ConvertFrom-Json
    $Jobname = "$Filename"
    $Path = $JSON.$Jobname
    
    If ($Path -like '*ENVS*') {
        $Path = $Path.ENVS.$Env
    }
    
    $FrequencyType = "FrequencyType = " + ($Path.FrequencyType)
    $FrequencyInterval = "FrequencyInterval = " + ($Path.FrequencyInterval)
    $FrequencySubdayType = "FrequencySubdayType = " + ($Path.FrequencySubdayType)
    $FrequencySubdayInterval = "FrequencySubdayInterval = " + ($Path.FrequencySubdayInterval)
    $FrequencyRecurrenceFactor = "FrequencyRecurrenceFactor = " + ($Path.FrequencyRecurrenceFactor)
    $ActiveStartDate = "ActiveStartDate = " + ($Path.ActiveStartDate)
    $ActiveStartTime = "ActiveStartTime = " + ($Path.ActiveStartTime)
    $RetryAttempts = "RetryAttempts = " + ($Path.RetryAttempts)
    $RetryInterval = "RetryInterval = " + ($Path.RetryInterval)

    
    If([string]::IsNullOrEmpty($Path) -and ($Authentication -eq "windows")) {
        Invoke-Sqlcmd -InputFile $DBScriptFile  -Serverinstance $DBServer -Database "$database" -Verbose
    }
    ElseIf([string]::IsNullOrEmpty($Path) -and ($Authentication -eq "sqlserver")) { 
        Invoke-Sqlcmd -InputFile $DBScriptFile  -Serverinstance $DBServer -Username $UserName -Password $Password -Database "$database" -Verbose
    }
    Else {
        $DBParams = $FrequencyType, $FrequencyInterval, $FrequencySubdayType, $FrequencySubdayInterval, $FrequencyRecurrenceFactor, $ActiveStartDate, $ActiveStartTime, $RetryAttempts, $RetryInterval
        Invoke-Sqlcmd -InputFile $DBScriptFile -Variable $DBParams -Serverinstance $DBServer -Database "$Database" -Verbose
    }
}
catch {
    throw $_
}