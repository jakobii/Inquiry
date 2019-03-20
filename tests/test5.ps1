<#
    return the Longest object passed to it.
#>
Function Get-Max {
    param(
        [array]$Inputobjects
    )
    $GreatestIndex = 0
    $GreatestWeight = 0
    $CurrentIndex = 0
    foreach ($Value in $Inputobjects) {
        [double]$Weight = 0
        if ($Value -is [string]) {
            [double]$Weight = $Value.Length
        }
        elseif ( $Value -is [int] -or $Value -is [double]) {
            [double]$Weight = $Value
        }
        if ($Weight -gt $GreatestWeight) {
            $GreatestIndex = $CurrentIndex
            $GreatestWeight = $Weight
        }
        $CurrentIndex++
    }
    return $Inputobjects[$GreatestIndex]
}

<#

    [example]
    Join-Array -Source1 @('a','b','c',1) -Source2 @('a',1,2,3)
#>
function Join-Array {
    param (
        [array]$Source1,
        [array]$Source2
    )
    [array]$Destination = @()
    [array]$Destination += $Source1
    foreach ($value in $Source2) {
        if ( $Destination -notcontains $value) {
            $Destination += $value 
        }
    }
    return $Destination
}
<#
    Compress-Array removes duplicates in an array

    [example]
    Compress-Array -InputObject @(1,1,2,2,3,3)
#>
function Compress-Array {
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [array]$InputObject
    )
    [array]$Destination = @()
    foreach ($value in $InputObject) {
        if ( $Destination -notcontains $value) {
            [array]$Destination += $value 
        }
    }
    return $Destination
}
<#
    ConvertTo-Hashtable converts key/value objects into hashtables

    [example 1]
    $table = [System.Data.DataTable]::new()
    $table.Columns.Add('a','int') | out-null
    $table.Columns.Add('b','int') | out-null
    $table.Columns.Add('c','int') | out-null
    $row = $table.NewRow()
    $row['a'] = 1
    $row['b'] = 2
    $row['c'] = 3

    ConvertTo-Hashtable $row -include @('a','c')  
    # returns @{a=1;c=3}

    [example 2]
    ConvertTo-Hashtable @{a=1;b=2;c=3} -include @('a','c')  
    # returns @{a=1;c=3}
#>
function ConvertTo-Hashtable {
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [psobject]$InputObject,
        [string[]]$Include,
        [string[]]$Exclude
    )
    [hashtable]$OutputObject = @{}
    # Datarow
    if ($InputObject -is [System.Data.Datarow]) {
        foreach ($Column in $InputObject.Table.Columns) {
            $Value = $InputObject[$Column]
            $Key = $Column.ColumnName
            if ($Include -and $Include -NotContains $Key) {
                continue
            }
            if ($Exclude -and $Exclude -Contains $Key) {
                continue
            }
            $OutputObject.Add($Key, $Value)
        }
        return $OutputObject
    }
    # Hashtable
    # creates a new hashtable with filtered keys,values
    if ($InputObject -is [Hashtable]) {
        foreach ($Key in $InputObject.Keys) {
            $Value = $InputObject[$Key]
            if ($Include -and $Include -NotContains $Key) {
                continue
            }
            if ($Exclude -and $Exclude -Contains $Key) {
                continue
            }
            $OutputObject.Add($Key, $Value)
        }
        return $OutputObject
    }
}

<#
    Assert-Array returns bool if Reference conatins Source values. 
    if Match = $true then the array must match exactly

    [example]
    Assert-Array -Source @('a','b','c') -Reference @('a','b','c') #true
    Assert-Array -Source @('a','b','d') -Reference @('a','b','c') #false
    Assert-Array -Source @('a','b','c') -Reference @('a','b','c') -Match #true
    Assert-Array -Source @('a','b','c') -Reference @('a','b') -Match #false
#>
function Assert-Array {
    param(
        [parameter(ValueFromPipeline, Mandatory)]
        [array]$Source,
        [parameter(Mandatory)]
        [array]$Reference,
        
        [switch]$Match
    )
    if (!$Match) {
        foreach ($Value in $Source) {
            if ($Reference -notcontains $Value ) {
                return $False
            }
        }
        return $true
    }
    else {
        foreach ($src in $Source) {
            [bool]$ValueIsPresent = $false
            foreach ($ref in $Reference) {
                if ($src -eq $ref) {
                    $ValueIsPresent = $true
                }
            }
            if (!$ValueIsPresent) {
                return $false
            }
        }
        return $true
    }
}

<#
    Compare-Array returns the differences in the array 
    $Source - $Reference
#>
function Compare-Array {
    param(
        [parameter(ValueFromPipeline, Mandatory)]
        [array]$Source,
        [parameter(Mandatory)]
        [array]$Reference
    )
    [array]$Differences = @()
    foreach ($Value in $Source) {
        if ($Reference -notcontains $Value ) {
            $Differences += $Value
        }
    }
    return $Differences
}

<#
    SqlCmdType Enumeration provides a list of sql command types.
#>
enum SqlCmdType {
    SELECT
    UPDATE
    INSERT
    DELETE
}

<#
    New-SqlCmd Generates basic sql select statements

    - Columns are applied to the SELECT statement.
    - Condidtions are applied to the WHERE statement.
    - Tab is the default tab size

    - valid sql is guaranteed.
    - formating happens but it is not guaranteed. 

    [example]
    New-SqlCmd -Database 'Aeries' -Schema 'dbo' -Table 'STU' -Columns @('fn', 'bd') -Conditions @{
        decimal = 123.1
        varchar = 'wow'
        bit     = $true
        func    = {'GETDATE()'} 
    }
#>
Function New-SqlCmd {
    param(
        [SqlCmdType]$Type = 'SELECT',
        [parameter(Mandatory)]
        [string]$Database,
        
        [string]$Schema = 'dbo',
        
        [parameter(Mandatory)]
        [string]$Table,

        [string[]]$Columns,
        [hashtable]$Conditions,
        $Tab = '    '
    )
    if ($type -eq [SqlCmdType]::SELECT) {
        [string]$SQL = "SELECT {{ COLUMNS }}`r`nFROM [$Database].[$Schema].[$Table]"
    
        # SELECT ALL
        if ($null -eq $Columns -or $Columns[0] -eq '*') {
            $SQL = $SQL -Replace '{{ COLUMNS }}', '*'
        }
        # SELECT SOME
        else {
            $SQL = $SQL -Replace '{{ COLUMNS }}', "`r`n$Tab[$($Columns -join "],`r`n$Tab[")]"
        }

        if (!$Conditions) {
            return $SQL
        }

        # WHERE
        [string]$SQL += "`r`nWHERE {{ EQ }}"
        [array]$Keys = $Conditions.keys
        $LongestKey = Get-Max $Keys
        $TabCount = $LongestKey.Length
        if ($Conditions.keys.Count -gt 1) {
            $FirstTab = '    '
        }

        [string]$EQ = ''
        [int]$i = 0
        foreach ($Column in $Conditions.keys) {
            $Value = $Conditions[$Column]
        
            [string]$EQ += "`r`n$Tab"
            if ($i++ -gt 0) {
                [string]$EQ += 'AND '
            }
            $padding = " " * [math]::Abs( [math]::Ceiling( $TabCount - $Column.Length ))
            [string]$EQ += "[$Column]$FirstTab$padding = "
            [string]$FirstTab = ''
        
            #type switch
            if ($Value -is [int] -or $value -is [double]) {
                [string]$EQ += $Value
            }
            elseif ($Value -is [bool]) {
                if ($Value -eq $true) {
                    [string]$EQ += "1"
                }
                else {
                    [string]$EQ += "0"
                }
            }
            elseif ($Value -is [scriptblock]) {
                $result = $Value.InvokeReturnAsIs()
                [string]$EQ += "$result"
            }
            else {
                [string]$EQ += "'$Value'"
            }
        }
        $SQL = $SQL -Replace '{{ EQ }}', $EQ
        return [System.Data.SqlClient.SqlCommand]::new($SQL)
    }
    elseif ($type -eq [SqlCmdType]::UPDATE) {}
    elseif ($type -eq [SqlCmdType]::INSERT) {}
    elseif ($type -eq [SqlCmdType]::DELETE) {}
}
<#

#>

function ConvertTo-SqlCmd {
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        [string]$Sql,
        [System.Data.SqlClient.SqlConnection]$Connection,
        [int]$CommandTimeout = 0
    )
    $Command = [System.Data.SqlClient.SqlCommand]::new($Sql)
    if($Connection){
        $Command.Connection = $Connection
    }
    $Command.CommandTimeout = $CommandTimeout
    return $Command
}

<#
    Invoke-Sql is like the officail Invoke-SqlCmd cmdlet. 
    
    [Description]
    - its intent is to remove the SqlServer powershell module dependancy.
    
    [TODO]
    - test
    - parse 'GO' keywords.
#>
function Invoke-Sql {
    param (
        [System.Data.SqlClient.SqlCommand]$Command
    )
    $Adapter = [System.Data.SqlClient.SqlDataAdapter]::new($Command)
    $Table = [System.Data.DataTable]::new()
    $Adapter.Fill($Table)
    return $Table.Rows 
}


class DatabaseConnection {
    $Connection
    [string]$DatabaseName
    [bool]$Debug
    [System.Data.Datarow[]] Query([System.Data.SqlClient.SqlCommand]$Command) {
        return Invoke-Sql @{
            Connection = $this.Connection
            Command    = $Command
        }
    }
}

<#
    TableConnection class reprsents a table in a sql server database.
    it manages the creation and deltetion of rows in the table. it
    also can create RowConnection object that are used for updating row values.
#>
class TableConnection {
    [DatabaseConnection]$DB
    [string]$SchemaName
    [string]$TableName
    [hashtable[]]$Columns
    [string[]]$PrimaryKeys



    [string] ObjectName(){
        return "[$this.DB.DatabaseName].[$this.SchemaName].[$this.TableName]"
    }


    <#
        Where() Methods creates RowConnections.

        [Description]
        - The overloads provide different options for filtering
        rows in the table before creating teh RowConnections. 
        - A little duplication is better then a little dependancy
        - Each overload is responsible for generating its own sql,
        filtering the datarows, and return RowConnections.
    #>
    [RowConnection[]] Where([scriptblock]$Filter) {
        $Command = New-SqlCmd @{
            Database = $this.GetDatabaseName()
            Schema   = $this.SchemaName
            Table    = $this.TableName
            Columns  = $this.PrimaryKeys
        }
        $Results = $this.DB.Query($Command)

        if (!$Results) { return $null }

        $Rows = Where-Object @{
            InputObject  = $Results
            FilterScript = $Filter
        }

        if (!$Rows) { return $null }
        
        [array]$RowConnections = 0..$Rows.Count
        foreach ($Row in $Rows) {
            $RowConnections += [RowConnection]::new($this, $Row)
        }
        return $RowConnections
    }
    [RowConnection[]] Where() {
        $Command = New-SqlCmd @{
            Database = $this.GetDatabaseName()
            Schema   = $this.SchemaName
            Table    = $this.TableName
            Columns  = $this.PrimaryKeys
        }
        $Results = $this.DB.Query($Command)

        if (!$Results) { return $null }
        
        [array]$RowConnections = 0..$Results.Count
        foreach ($Row in $Results) {
            $RowConnections += [RowConnection]::new($this, $Row)
        }
        return $RowConnections
    }
    [RowConnection[]] Where([Hashtable]$Values) {
        $Command = New-SqlCmd @{
            Database    = $this.GetDatabaseName()
            Schema      = $this.SchemaName
            Table       = $this.TableName
            Columns     = $this.PrimaryKeys
            Condidtions = $Values
        }

        $Results = $this.DB.Query($Command)

        if (!$Results) { return $null }
        
        [array]$RowConnections = 0..$Results.Count
        foreach ($Row in $Results) {
            $RowConnections += [RowConnection]::new($this, $Row)
        }
        return $RowConnections
    }
    [RowConnection[]] Where([System.Data.Datarow]$Row) {
        [hashtable]$HashTable = ConvertTo-Hashtable $Row
        return $this.Where($HashTable)
    }
    [RowConnection[]] Where([array]$Rows) {
        [RowConnection[]]$Connections = @()
        foreach ($Row in $Rows) {
            [RowConnection[]]$Connections += $this.Where($row)
        }
        return $Connections
    }
    [RowConnection[]] Where([System.Data.SqlClient.SqlCommand]$Command) {

        $Results = $this.DB.Query($Command)

        if (!$Results) { return $null }
        
        [array]$RowConnections = 0..$Results.Count
        foreach ($Row in $Results) {
            $RowConnections += [RowConnection]::new($this, $Row)
        }
        return $RowConnections
    }
    <#
        Query() method is unique in that it converts the output of a sql query
        to RowConnections. the Query must return the PrimaryKey columns.
    #>
    [RowConnection[]] Query([string]$Sql) {
        $Command = ConvertTo-SqlCmd $Sql
        return $this.Where($Command)
    }

    <#
        Insert() methods create new rows in the sql table.
    #>
    Insert([hashtable]$Row) {}
    Insert([hashtable[]]$Rows) {}
    Insert([System.Data.Datarow]$Rows) {}
    Insert([System.Data.Datarow[]]$Rows) {}
    Delete() {}
}

<#
    RowConnection class is a lightweight reference to a row in a 
    table. It's main purpose it to provide an easy to use interface 
    for updaing row values.

    [Description]
    - It uses the rows unique constraints to reference the row.
    - unique constraints as stored in the PrimaryKeys Hashtable.
#>
class RowConnection {
    [TableConnection]$Table
    [hashtable]$PrimaryKeys

    hidden [bool]$ProvenToBeUnique
    hidden [bool]$ContainsTablePrimaryKeys

    RowConnection ($Table, [System.Data.Datarow]$PrimaryKeys) {
        $this.Table = $Table
        $this.PrimaryKeys = ConvertTo-Hashtable $PrimaryKeys -Include $this.Table.PrimaryKeys
        $this.ValidatePrimaryKeys()
    }
    RowConnection ($Table, [Hashtable]$PrimaryKeys) {
        $this.Table = $Table
        $this.PrimaryKeys = ConvertTo-Hashtable $PrimaryKeys -Include $this.Table.PrimaryKeys
        $this.ValidatePrimaryKeys()
    }

    # Checks the rows PrimaryKeys hashtable against the tables PrimaryKey array.
    hidden ValidatePrimaryKeys() {
        $Diffs = @{
            Source    = $this.Table.PrimaryKeys
            Reference = $this.PrimaryKeys.Keys 
        }
        [bool]$Match = Assert-Array @Diffs
        if (!$Match) {
            [array]$differences = Compare-Array @Diffs
            # [array]$differences = @('a','b','c')
            throw "Could Not Create RowConnection due to missing PrimaryKey: '$($differences -join "', '")'"
        }
        $this.ContainsTablePrimaryKeys = $true
    }
    # performs a select statement on the table to ensure only one row is returned.
    hidden ValidateIdentity(){
        $results = $this.UnsafeSelect($this.Table.PrimaryKeys)
        if($results -is [System.Data.Datarow[]]){
            [string]$InvalidPks = $this.PrimaryKeys | ft -AutoSize | out-string
            # [string]$InvalidPks = @{a=1;b=2} | ft -AutoSize | out-string  
            Throw "PrimaryKeys are not Unique in $($this.ObjectName()): $InvalidPks"
        }
        $this.ProvenToBeUnique = $true
    }

    <#
        Performs standard tests to ensure the Rowconnection is working as intended
    #>
    [void] Test() {
        $this.ValidatePrimaryKeys()
        $this.ValidateIdentity()
    }
    <# 
        Check() is like test, but is designed to efficient in loops by not rerunning 
        the same passing tests again. all Write operations should perform this test.
    #>
    [void] Check() {
        if(!$this.ProvenToBeUnique){
            $this.ValidateIdentity()
        }
        if(!$this.ContainsTablePrimaryKeys){
            $this.ValidatePrimaryKeys()
        }
    }


    <#
        UnsafeSelect() method returns raw Datarows.
        It provides no identity guarantees on the values returned.
    #>
    hidden [psobject] UnsafeSelect([string[]]$Columns) {
        $params = @{
            Database   = $this.Table.Db.DatabaseName
            Schema     = $this.Table.SchemaName
            Table      = $this.Table.Tablename
            Columns    = $Columns
            Conditions = $this.PrimaryKeys
            Type       = [SqlCmdType]::SELECT 
        }
        $SqlCmd = New-SqlCmd @params
        return  $this.Table.DB.Query($SqlCmd)
    }

    <#
        Select() Methods gets the rows column values and returns 
        them as a hastable.
        
        [Description]
        - The overload methods provide different ways to 
        specifying columns to return.
    #>
    [hashtable] Select([string[]]$Columns) {
        $this.Check()
        $Results = $this.UnsafeSelect($Columns)
        return ConvertTo-Hashtable $Results
    }
    [hashtable] Select() {
        $this.Check()
        $Results = $this.UnsafeSelect("*")
        return ConvertTo-Hashtable $Results 
    }
    [hashtable] Select([string]$Column) {
        $this.Check()
        $Results = $this.UnsafeSelect($Column)
        return $Results.Item[$Column] 
    }


    Update() {}
}


