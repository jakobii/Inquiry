#$ScriptPath = Get-Item -Path $PSScriptRoot
#$ModuleRoot = $ScriptPath.Parent.FullName
#$FlossPath = Join-Path -Path $ModuleRoot -ChildPath 'Inquiry.psm1'
#Import-Module $FlossPath -Verbose
#

function Write-Console {
    param(
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject,
        [alias('f')]
        [System.ConsoleColor]$ForegroundColor = $($Host.UI.RawUI.ForegroundColor),
        [alias('b')]
        [System.ConsoleColor]$BackgroundColor = $($Host.UI.RawUI.BackgroundColor)
    )
    # backup
    $OrigForegroundColor = $Host.UI.RawUI.ForegroundColor
    $OrigBackgroundColor = $Host.UI.RawUI.BackgroundColor

    #set
    $Host.UI.RawUI.ForegroundColor = $ForegroundColor
    $Host.UI.RawUI.BackgroundColor = $BackgroundColor
    
    $InputObject | Out-Host
    $Host.UI.RawUI.ForegroundColor = $OrigForegroundColor
    $Host.UI.RawUI.BackgroundColor = $OrigBackgroundColor
}
Function Split-SqlScript {
    param(
        [string[]]$Content
    )
    [string]$Buffer = ''
    [array]$Commands = @()
    $reg = [regex]::New('^GO$')
    foreach($line in $Content){
        if($reg.Match($line).Success){
            [array]$Commands += $Buffer
            [string]$Buffer = ''
        }
        else{
            [string]$Buffer += "`n"
            [string]$Buffer += $line
        }
    }
    if($Buffer){
        [string]$Buffer += "`n"
        [array]$Commands += $Buffer
    }
    return $Commands
}
function Invoke-Sql {
    param (
        [string]$Server,
        [string]$Database,
        [string]$Username,
        [string]$Password,
        [string[]]$Query
    )
    $ConnectionString = "server=$($Server);user id=$($Username);password= $($Password);initial catalog=$($Database)"
    try {
        $Connection = [System.Data.SqlClient.SqlConnection]::New($ConnectionString)
        $Commands = Split-SqlScript -Content $Query
        foreach ($Command in $Commands) {
            #$Command | Write-Console -f Yellow
            $SqlCommand = [System.Data.SqlClient.SqlCommand]::New($Command, $Connection)
            $Connection.Open()
            $reader = $SqlCommand.ExecuteReader()
            $Columns = $reader.GetSchemaTable()
            [System.Collections.ArrayList]$table = @()
            while ($reader.Read()) {
                #$reader | Write-console -f Yellow
                #$reader[1] | Write-Console -f Magenta
                $Row = [ordered] @{}
                foreach($Column in $Columns){
                    $Row.Add($Column.ColumnName, $reader[$Column.ColumnOrdinal])
                }
                $table.Add($Row) | Out-Null
            }
            $Connection.Close()
        }
        return $table
    }
    catch {
        throw $PSItem
    }
    finally {
        $Connection.Close()
    }
}

$ConfPath = Join-Path -Path $PSScriptRoot -ChildPath 'conf.secure.psd1'
$Conf = Import-PowerShellDataFile -Path $ConfPath

$SqlPath = Join-Path -Path $PSScriptRoot -ChildPath 'test.sql'
[array]$sql = Get-Content $SqlPath -Delimiter "`n"


Invoke-Sql @Conf -Query $sql

