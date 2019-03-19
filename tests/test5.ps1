
Function New-SqlCommand {
    param(
        [string[]]$Select,
        [string]$Database,
        [string]$Schema,
        [string]$Table,
        [hashtable]$Where
    )

}


function New-SqlSelect {
    param(
        [parameter(Mandatory)]
        [string]$Database,
        
        [string]$Schema = 'dbo',
        
        [parameter(Mandatory)]
        [string]$Table,
        
        [string[]]$Columns
    )
    [string]$SQL = "SELECT {{ COLUMNS }}`r`nFROM [$Database].[$Schema].[$Table]"
    
    # SELECT ALL
    if ($null -eq $Columns -or $Columns[0] -eq '*') {
        return $SQL -Replace '{{ COLUMNS }}', '*'
    }

    # SELECT SOME
    return $SQL -Replace '{{ COLUMNS }}', "`r`n`t[$($Columns -join "],`r`n`t[")]"
}

# New-SqlSelect -Database 'Aeries' -Schema 'dbo' -Table 'STU' -Columns @('fn','bd')

# New-SqlSelect -Database 'Aeries' -Table 'STU'
Function Get-Max {
    param(
        [array]$Inputobjects
    )
    $GreatestIndex = 0
    $CurrentIndex = 0
    foreach($Value in $Inputobjects){
        [double]$Weight = 0
        if($Value -is [string]){
            $Weight = $Value.Length
        }
        elseif( $Value -is [int] -or $Value -is [double]){
            $Weight = $Value
        }
        if($Weight -gt $GreatestIndex){
            $GreatestIndex = $CurrentIndex
        }
        $CurrentIndex++
    }
    return $Inputobjects[$GreatestIndex]
}

Get-Max @('abc', 2)

'abc'.Length

function New-SqlWhere {
    param(
        [string]$Database,
        [string]$Schema,
        [string]$Table,
        [Hashtable]$Conditions
    )
    [string]$WHERE = "WHERE {{ EQ }}"
    
    $LongestKey = Get-Max $Conditions.keys
    $TabCount = $LongestKey.Length
    $TabCount | Write-Host

    if($Conditions.keys.Count -gt 1){
        $FirstTab = '    '
    }

    # EQ
    [string]$EQ = ''
    [int]$i = 0
    foreach ($Column in $Conditions.keys) {
        
        [string]$EQ += "`r`n`t"

        if($i++ -gt 0){
            [string]$EQ += 'AND '
        }

        $padding =  " " * [math]::Ceiling( $TabCount - $Column.Length )

        [string]$EQ += "$FirstTab[$Column]$padding = "
        [string]$FirstTab = ''
        
        #type switch
        $Value = $Conditions[$Column]
        if ($Value -is [int] -or $value -is [double]) {
            [string]$EQ += $Value
        }
        elseif($Value -is [bool]){
            if($Value -eq $true){
                [string]$EQ += "1"
            }
            else{
                [string]$EQ += "0"
            }
        }
        elseif($Value -is [scriptblock]){
            $result = $Value.InvokeReturnAsIs()
            [string]$EQ += "$result"
        }
        else {
            [string]$EQ += "'$Value'"
        }
    }
    $WHERE -Replace '{{ EQ }}', $EQ
}

# New-SqlSelect -Database 'Aeries' -Schema 'dbo' -Table 'STU' -Columns @('id','fn','bd')
<# 
New-SqlWhere -Conditions @{
    Blah = 123.1
    rar  = 'wow'
    omg  = $true
    zoom = {'GETDATE()'} 
}
#>
Get-SqlTable {
    param(
        [SqlServerConnection]$Connection,
        [string]$Schema,
        [string]$Table,
        [string[]]$Columns
    )
    $SqlConnection = $Connection.SqlConnection()
    $Adapter = [System.Data.SqlClient.SqlDataAdapter]::new( "SELECT * FROM" , $SqlConnection)
    $Table = [System.Data.DataTable]::new()
    $Adapter.Fill($Table)
    return $Table
}

function Search-SqlRows {
    param(
        [SqlServerConnection]$Connection,
        [string]$Schema,
        [string]$Table,
        [string[]]$Columns,
        [scriptblock]$Filter
    )
    $SqlTable = Get-SqlTable @{
        Connection = $Connection
        Schema     = $Schema
        Table      = $Table
        Columns    = $Columns
    }
    $SqlRows = Where-Object @{
        InputObject  = $SqlTable
        FilterScript = $Filter
    }
    return $SqlRows 
}


class RowConnection {

}

class TableConnection {

    #[RowConnection[]] Where() {

    #}
}