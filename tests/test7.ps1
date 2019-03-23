function Write-Console {
    param(
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject,
        [alias('f')]
        [System.ConsoleColor]$ForegroundColor = $($Host.UI.RawUI.ForegroundColor),
        [alias('b')]
        [System.ConsoleColor]$BackgroundColor = $($Host.UI.RawUI.BackgroundColor)
    )
    # backup colors
    $OrigForegroundColor = $Host.UI.RawUI.ForegroundColor
    $OrigBackgroundColor = $Host.UI.RawUI.BackgroundColor

    # set colors
    $Host.UI.RawUI.ForegroundColor = $ForegroundColor
    $Host.UI.RawUI.BackgroundColor = $BackgroundColor
    
    # write object to console
    $InputObject | Out-Host

    # revert to backup colors
    $Host.UI.RawUI.ForegroundColor = $OrigForegroundColor
    $Host.UI.RawUI.BackgroundColor = $OrigBackgroundColor
}

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
    ConvertTo-DataString Function converts different datatypes into a hashtable like syntax string.

    [requires]
    ConvertTo-Hashtable

    [example1]
    ConvertTo-DataString -InputObject @{
        a = 1
        b = "abc"
        c = 1.45
        n = $true
        x = get-date
    }

    [example2]
    $table = [System.Data.DataTable]::new()
    $table.Columns.Add('a','double') | out-null
    $table.Columns.Add('b','int') | out-null
    $table.Columns.Add('c','string') | out-null
    $row = $table.NewRow()
    $row['a'] = 3.14
    $row['b'] = 42
    $row['c'] = 'abc'
    ConvertTo-DataString $row

#>
function ConvertTo-DataString {
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [psobject]$InputObject,
        [string[]]$Include,
        [string[]]$Exclude
    )
    [string]$OutputObject = '@{'


    # creates a new hashtable with filtered keys,values
    if ($InputObject -is [Hashtable]) {
        $KeyCount = $InputObject.Keys.Count 
        $Index = 0
        foreach ($Key in $InputObject.Keys) {
            $Value = $InputObject[$Key]
            if ($Include -and $Include -NotContains $Key) {
                continue
            }
            if ($Exclude -and $Exclude -Contains $Key) {
                continue
            }
            $OutputObject += "$Key = "
            # Type Switch
            if ( $Value -eq $null -or $value -is [dbnull]) {
                $OutputObject += "`$Null;"
            }
            elseif ( $Value -is [string] -or $Value -is [char]) {
                $OutputObject += "'$Value'"
            }
            elseif ( $Value -is [int] -or $Value -is [double]) {
                $OutputObject += "$Value"
            }
            elseif ( $Value -is [bool]) {
                $OutputObject += "`$$Value"
            }
            elseif ( $Value -is [datetime]) {
                $OutputObject += "'$( $Value.ToUniversalTime() )'"
            }
            else {
                $OutputObject += "$Value"
            }
            if ($Index++ -lt $KeyCount - 1) {
                $OutputObject += " ; "
            }
        }
        $OutputObject += '}'
        return $OutputObject
    }

    # convert all other types to hastable then perform recursive function.
    if ($InputObject -is [System.Data.Datarow]) {
        return ConvertTo-Hashtable $InputObject | ConvertTo-DataString
    }
}

<#
    [Description]
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

function ConvertTo-SqlStringType {
    param(
        [psobject]$Value
    )
    [string]$OuputObject = 'NULL'
    #type switch
    if ($Value -is [int] -or $value -is [double]) {
        [string]$OuputObject = $Value
    }
    elseif ($Value -is [bool]) {
        if ($Value -eq $true) {
            [string]$OuputObject = "1"
        }
        else {
            [string]$OuputObject = "0"
        }
    }
    elseif ($Value -is [scriptblock]) {
        $result = $Value.InvokeReturnAsIs()
        [string]$OuputObject = "$result"
    }
    else {
        [string]$OuputObject = "'$Value'"
    }
    return $OuputObject
}

function New-SqlWhere {
    param(
        [parameter(Mandatory)]
        [string]$Database,
        
        [string]$Schema = 'dbo',
        
        [parameter(Mandatory)]
        [string]$Table,

        [hashtable]$Conditions,
        $Tab = '    '
    )

    # WHERE
    [string]$SQL = "WHERE {{ EQ }}"
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
        [string]$EQ += "[$Database].[$Schema].[$Table].[$Column]$FirstTab$padding = "
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
    return $SQL -replace "{{ EQ }}", $EQ
}

<#
    # Example
    New-SqlSelect -Database 'mhusd' -Schema 'dbo' -Table 'Employees' -Conditions @{EmployeeID = 12345}
#>
Function New-SqlSelect {
    param(
        [parameter(Mandatory)]
        [string]$Database,
        
        [string]$Schema = 'dbo',
        
        [parameter(Mandatory)]
        [string]$Table,

        [string[]]$Columns,
        [hashtable]$Conditions,
        $Tab = '    '
    )

    [string]$SQL = "SELECT {{ COLUMNS }}`r`nFROM [$Database].[$Schema].[$Table]"

    # SELECT ALL
    if ($null -eq $Columns -or $Columns[0] -eq '*') {
        $SQL = $SQL -Replace '{{ COLUMNS }}', '*'
    }
    # SELECT SOME
    else {
        $SQL = $SQL -Replace '{{ COLUMNS }}', "`r`n$Tab[$($Columns -join "],`r`n$Tab[")]"
    }
    
    # return early
    if (!$Conditions) {
        return $SQL
    }
    
    # build where statement
    $WhereParams = @{
        Database = $Database
        Schema = $Schema
        Table = $Table
        Conditions = $Conditions
        Tab = $Tab
    }
    $WHERE = New-SqlWhere @WhereParams
    return $SQL + "`r`n" + $WHERE
}


<#
    # Example
    New-SqlUpdate -Database 'mhusd' -Schema 'dbo' -Table 'Employees' -Conditions @{EmployeeID = 12345} -Set @{BargainingUnit = 22;Middlename = 'Regino'}

#>
function New-SqlUpdate {
    param(
        [parameter(Mandatory)]
        [string]$Database,
        
        [string]$Schema = 'dbo',
        
        [parameter(Mandatory)]
        [string]$Table,

        [parameter(Mandatory)]
        [hashtable]$Set,
        [hashtable]$Conditions,
        $Tab = '    '
    )

    $SQL = "UPDATE [$Database].[$Schema].[$Table]`r`nSET`r`n"
    $ColumnCount = $Set.Keys.Count
    foreach($Column in $Set.Keys){
        $Value = $Set[$Column]
        [string]$SqlStrValue = ConvertTo-SqlStringType $Value 
        $SQL += "$Tab[$Database].[$Schema].[$Table].[$Column] = $SqlStrValue"
        if($i++ -lt $ColumnCount -1){
            $sql += ",`r`n"
        }
    }
    $WhereParams = @{
        Database = $Database
        Schema = $Schema
        Table = $Table
        Conditions = $Conditions
        Tab = $Tab
    }
    $WHERE = New-SqlWhere @WhereParams
    return $SQL + "`r`n" + $WHERE
}




<#
    ConvertTo-SqlCmd wraps a sql statment in a statndard SqlConnection object
#>
function ConvertTo-SqlCmd {
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        [string]$Sql,
        [System.Data.SqlClient.SqlConnection]$Connection,
        [int]$CommandTimeout = 0
    )
    $Command = [System.Data.SqlClient.SqlCommand]::new($Sql)
    if ($Connection) {
        $Command.Connection = $Connection
    }
    $Command.CommandTimeout = $CommandTimeout
    return $Command
}

<#
    ConvertTo-TableName function Generates A standard table object name 
    for SQL Server.

    [example]
    ConvertTo-TableName -Database 'MYDB' -Schema 'HR' -Table 'Employees'
#>
function ConvertTo-TableName {
    param(
        [string]$Database,
        [string]$Schema = 'dbo',
        [parameter(Mandatory)][string]$Table
    )
    $Name = ''
    if ($Database) {
        $Name += "[$Database]."
    }
    $Name += "[$Schema]."
    $Name += "[$Table]"
    return $Name
}

<#

    [example]
    New-SqlComment -Comment 'Testing RowConnection Uniqueness'
#>
function New-SqlComment {
    Param(
        [parameter(ValueFromPipeline)]
        [string]$Comment,
        [guid]$GUID = $(New-Guid),
        [datetime]$Timestamp = $(Get-Date)
    )
    [string]$SqlLog = "/*"
    if ($Comment) {
        [string]$SqlLog += "`r`n`tComment: $Comment"
    }
    [string]$SqlLog += "`r`n`tGUID: $GUID"
    [string]$SqlLog += "`r`n`tTimestamp: $Timestamp"
    [string]$SqlLog += "`r`n*/`r`n"

    return $SqlLog
}



<#
    [Description]
    Invoke-Sql is like the officail Invoke-SqlCmd cmdlet. 
    
    - its intent is to remove the SqlServer powershell module dependancy.
    
    [TODO]
    - test
    - parse 'GO' keywords.
#>
function Invoke-Sql {
    param (
        [System.Data.SqlClient.SqlCommand]$Command,
        [System.Data.SqlClient.SqlConnection]$Connection
    )
    $Adapter = [System.Data.SqlClient.SqlDataAdapter]::new($Command.CommandText, $Connection)
    $Table = [System.Data.DataTable]::new()
    $Adapter.Fill($Table) | Out-Null
    return $Table
}

<#
    Get-SchemaTable function returns an array of DataRows that decribe the tables schema

    [example]
    $Auth = [SqlServerAuthentication]::new('mhu-dbwh-02','Enrollment')
    $table = Get-SchemaTable -Schema 'dbo' -Table 'JotFormTransferRequests' -Connection $Auth.SqlConnection()
    $table | Out-Host    
#>
function Get-SchemaTable {
    param(
        [parameter(Mandatory)]
        [System.Data.SqlClient.SqlConnection]$Connection,

        [string]$Schema = 'dbo',

        [parameter(Mandatory)]
        [string]$Table
    )
    [string]$TableName = ConvertTo-TableName -Database $Connection.Database -Schema $Schema -Table $Table
    [string]$Command = "/* Getting SchemaTable */"
    [string]$Command += "SELECT TOP 1 *`r`nFROM $TableName"
    $Adapter = [System.Data.SqlClient.SqlDataAdapter]::new($Command, $Connection)
    $Adapter.MissingSchemaAction = [System.Data.MissingSchemaAction]::AddWithKey
    $DataTable = [System.Data.DataTable]::New($Table) 
    $Adapter.Fill($DataTable) | Out-Null
    [System.Data.DataTable]$SchemaTable = $DataTable.CreateDataReader().GetSchemaTable()
    return $SchemaTable.Rows
}



<#
    SqlServerAuthentication Class helps to simplify microsofts stupid database Auth API's
#>
Class SqlServerAuthentication {
    [string]$Server
    [string]$Database
    [string]$Username
    [string]$Password
    [bool]$WindowsAuthentication
    
    [ValidateRange(0, 2147483647)]
    [long]$ConnectTimeout

    SqlServerAuthentication([string]$Server, [string]$Database, [string]$Username, [string]$Password) {
        $this.Server = $Server
        $this.Database = $Database
        $this.Username = $Username
        $this.Password = $Password
        $this.WindowsAuthentication = $false
        $this.ConnectTimeout = 0
    }
    SqlServerAuthentication([string]$Server, [string]$Database) {
        $this.Server = $Server
        $this.Database = $Database
        $this.WindowsAuthentication = $true
        $this.ConnectTimeout = 0
    }
    SqlServerAuthentication([hashtable]$Splat) {
        $this.Server = $Splat.Server
        $this.Database = $Splat.Database

        if ($Splat.Username -and $Splat.Password) {
            $this.Username = $Splat.Username
            $this.Password = $Splat.Password
        }
        else {
            $this.WindowsAuthentication = $true
        }
        if ($Splat.ConnectTimeout -is [long] -or $Splat.ConnectTimeout -is [int]) {
            $this.ConnectTimeout = $Splat.ConnectTimeout
        }
        else {
            $this.ConnectTimeout = 0
        }
    }
    # https://docs.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring
    # ConnectionString includes the username and password in plain text.
    [string] ConnectionString () {
        $b = $this.SqlConnectionStringBuilder()
        if ($this.Username) {
            $b['User ID'] = $this.Username
        }
        if ($this.Password) {
            $b['Password'] = $this.Password
        }
        return $b.ConnectionString
    }
    # ConnectionStringSecure does not include the username and password. and assumes you will use some other authentication method.
    [string] ConnectionStringSecure () {
        $b = $this.SqlConnectionStringBuilder()
        return $b.ConnectionString
    }
    # SqlConnectionStringBuilder returns a ready to user SqlConnectionStringBuilder of the propeties already added.
    [System.Data.SqlClient.SqlConnectionStringBuilder] SqlConnectionStringBuilder() {
        $b = [System.Data.SqlClient.SqlConnectionStringBuilder]::New()
        if ($this.Server) {
            $b["Server"] = $this.Server
        }
        if ($this.Database) {
            $b["Database"] = $this.Database
        }
        if ($this.WindowsAuthentication) {
            $b["Integrated Security"] = $true
        }
        if ($this.ConnectTimeout) {
            $b["Connect Timeout"] = $this.ConnectTimeout
        }
        if ($this.Encrypt) {
            $b['Encrypt'] = $true
        }
        return $b
    }
    # PSCredential encrypts username and password
    [PSCredential] PSCredential() {
        $SecureString = ConvertTo-SecureString $this.Password -AsPlainText -Force
        return [PSCredential]::new($this.Username, $SecureString)
    }

    # SqlCredential encrypts username and password
    [System.Data.SqlClient.SqlCredential] SqlCredential() {
        $SecureString = ConvertTo-SecureString $this.Password -AsPlainText -Force
        $SecureString.MakeReadOnly()
        return [System.Data.SqlClient.SqlCredential]::New($this.Username, $SecureString)
    }

    # SqlConnection returns a ready to use SqlConnection
    [System.Data.SqlClient.SqlConnection] SqlConnection() {
        $ConnectionString = $this.ConnectionStringSecure()
        $Connection = [System.Data.SqlClient.SqlConnection]::New($ConnectionString)
        if (!$this.WindowsAuthentication) {
            $Connection.Credential = $this.SqlCredential()
        }
        return $Connection
    }
    [string] ToString() {
        return $this.ConnectionString()
    }
}

<#
    # Description
    DatabaseConnection class manages a connection with a database. 
    all child objects use this class to make database sql calls.

    # Example 1
    $db = [DatabaseConnection]::New('localhost','Employees')
    $db
#>
class DatabaseConnection {
    [string]$ServerName
    [string]$DatabaseName
    
    [SqlServerAuthentication]$Authentication
    [System.IO.DirectoryInfo]$Log
    [bool]$Debug
    
    DatabaseConnection ([string]$Server, [string]$Database) {
        $this.Authentication = [SqlServerAuthentication]::new($Server, $Database)
        $this.ServerName = $Server
        $this.DatabaseName = $Database
    }

    DatabaseConnection ([string]$Server, [string]$Database, [string]$Username, [string]$Password) {
        $this.Authentication = [SqlServerAuthentication]::new($Server, $Database, $Username, $Password)
        $this.ServerName = $Server
        $this.DatabaseName = $Database
    }

    <#
        the standard query mechanism for all child objects
    #>
    [System.Data.Datarow[]] Query([System.Data.SqlClient.SqlCommand]$Command) {
        if($this.Debug){
            write-console $Command.CommandText -f Yellow
        }
        $Params = @{
            Command    = $Command
            Connection = $this.Authentication.SqlConnection()
        }
        return Invoke-Sql @Params
    }
    [System.Data.Datarow] QueryOne([System.Data.SqlClient.SqlCommand]$Command) {
        if($this.Debug){
            write-console $Command.CommandText -f Yellow
        }
        $Params = @{
            Command    = $Command
            Connection = $this.Authentication.SqlConnection()
        }
        return Invoke-Sql @Params
    }

    <#
        From() method creates table connections and is synomymous with the SQL FROM keyword.
    #>
    [TableConnection] Table([string]$SchemaName, [string]$TableName) {
        return [TableConnection]::new($this, $SchemaName, $TableName)
    }

    [TableConnection] Table([string]$SchemaName, [string]$TableName,[string[]]$PrimaryKeys) {
        return [TableConnection]::new($this, $SchemaName, $TableName,$PrimaryKeys)
    }
}

# New-DatabaseConnection -Server -Database


<#
    TableConnection class reprsents a table in a sql server database.
    it manages the creation and deltetion of rows in the table. it
    also can create RowConnection object that are used for updating row values.

    # Example
    $db = [DatabaseConnection]::New('localhost','MHUSD')
    $db.Debug = $true
    $tb = $db.Table('dbo','Employees')
    $row = $tb.Where(@{EmployeeID = 842975})
    $row
#>
class TableConnection {
    [DatabaseConnection]$Database
    [string]$SchemaName
    [string]$TableName
    [hashtable[]]$Columns
    [string[]]$PrimaryKeys

    hidden [bool]$ValidPrimaryKeys

    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table) {
        $this.Database = $DB
        $this.SchemaName = $schema
        $this.TableName = $table
        $this.GetColumns()
        $this.PrimaryKeys = $this.ParseColumnsForPrimaryKeys()
        if (!$this.PrimaryKeys) {
            $this.AutoPrimaryKeyError()
        }
        else{
            $this.ValidPrimaryKeys = $true
        }
    }
    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table, [string[]]$PrimaryKeys) {
        $this.Database = $DB
        $this.SchemaName = $schema
        $this.TableName = $table
        $this.GetColumns()
        $this.PrimaryKeys = $PrimaryKeys
    }
    [string] ObjectName() {
        return "[$($this.Database.DatabaseName)].[$($this.SchemaName)].[$($this.TableName)]"
    }
    hidden AutoPrimaryKeyError () {
        throw "The TableConnection PrimaryKey property could not be automatically set.$($this.ObjectName()) does not have a PrimaryKeys or a Unique constraints."
    }
    hidden GetColumns() {
        $params = @{
            Connection = $this.Database.Authentication.SqlConnection()
            Schema     = $this.SchemaName
            Table      = $this.TableName
        }
        $SchemaTable = Get-SchemaTable @params
        $this.Columns = @()
        foreach ($row in $SchemaTable) {
            $this.Columns += ConvertTo-Hashtable $row
        }
    }
    hidden [string[]] ParseColumnsForPrimaryKeys() {
        [System.Collections.ArrayList]$PKs = @()
        
        # first hunt for IsKey
        foreach ($Column in $this.Columns) {
            if ($Column.IsKey) {
                $PKs.Add($Column.ColumnName)
            }
        }

        # then check for Uniques 
        if (!$PKs) {
            foreach ($Column in $this.Columns) {
                if ($Column.Unique) {
                    $PKs.Add($Column.ColumnName)
                }
            }
        }

        return $PKs
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
            Database = $this.Database.DatabaseName
            Schema   = $this.SchemaName
            Table    = $this.TableName
            Columns  = '*'
        }
        $Results = $this.Database.Query($Command)

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
    [RowConnection[]] Where([scriptblock]$Filter, [string[]]$Columns) {
        $SqlCmd = @{
            Database = $this.Database.DatabaseName
            Schema   = $this.SchemaName
            Table    = $this.TableName
            Columns  = Join-Array -Source1 $this.PrimaryKeys -Source2 $Columns
        }
        $Command = New-SqlCmd @SqlCmd
        $Results = $this.Database.Query($Command)

        if (!$Results) { return $null }

        $Rows = Where-Object @{
            InputObject        = $Results
            FilterScrSqlCmdipt = $Filter
        }

        if (!$Rows) { return $null }
        
        [array]$RowConnections = 0..$Rows.Count
        foreach ($Row in $Rows) {
            $RowConnections += [RowConnection]::new($this, $Row)
        }
        return $RowConnections
    }
    [RowConnection[]] Where() {
        $Params = @{
            Database = $this.Database.DatabaseName
            Schema   = $this.SchemaName
            Table    = $this.TableName
            Columns  = $this.PrimaryKeys
        }

        $Command = New-SqlCmd @Params

        $Results = $this.Database.Query($Command)

        if (!$Results) { return $null }
        
        [array]$RowConnections = 0..$Results.Count
        foreach ($Row in $Results) {
            $RowConnections += [RowConnection]::new($this, $Row)
        }
        return $RowConnections
    }
    [RowConnection[]] Where([Hashtable]$Values) {
        $Params = @{
            Database    = $this.Database.DatabaseName
            Schema      = $this.SchemaName
            Table       = $this.TableName
            Columns     = $this.PrimaryKeys
            Conditions  = $Values
        }
        $Command = New-SqlCmd @Params

        $Results = $this.Database.Query($Command)

        if (!$Results) { return $null }
        
        [array]$RowConnections = @()
        foreach ($Row in $Results) {
            [array]$RowConnections += [RowConnection]::new($this, $Row)
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

        $Results = $this.Database.Query($Command)

        if (!$Results) { return $null }
        
        [array]$RowConnections = @()
        foreach ($Row in $Results) {
            [array]$RowConnections += [RowConnection]::new($this, $Row)
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

# New-TableConnection -DatabaseConnection -Schema -Table -PrimaryKeys
# New-TableConnection -Server -Database -Username -Password -Schema -Table -PrimaryKeys


enum CacheModes {
    Never = 1
    Time = 2
    Always = 3
}

<#
    # Description
    RowConnection class is a lightweight reference to a row in a 
    table. It's main purpose it to provide an easy to use interface 
    for updaing row values.
    - It uses the rows unique constraints to reference the row.
    - unique constraints as stored in the PrimaryKeys Hashtable.
    
    # Example

    $db = [DatabaseConnection]::New('localhost','MHUSD')
    $db.Debug = $true
    $tb = $db.Table('dbo','Employees')
    $row = $tb.Where(@{EmployeeID = 842975})
    $row.Firstname
#>
class RowConnection {
    hidden [TableConnection]$Table
    hidden [hashtable]$Cache

    RowConnection ($Table, [System.Data.Datarow]$Cache) {
        $this.Table = $Table
        $this.Cache = ConvertTo-Hashtable $Cache
        $this.CreateColumnProperties($this.table.Columns.ColumnName)
    }
    RowConnection ($Table, [Hashtable]$Cache) {
        $this.Table = $Table
        $this.Cache = $Cache
        $this.CreateColumnProperties($this.table.Columns.ColumnName)
    }
    hidden CreateColumnProperties([string[]]$Columns) {
        foreach ($Column in $Columns) {
            $NewMethod = @{
                memberType  = 'ScriptProperty'
                InputObject = $this
                Name        = $Column
                Value       = Invoke-Expression "{return `$this.Select('$Column')}"
                SecondValue = Invoke-Expression "{Param([parameter(mandatory)]`$Value);Write-Host `$Value -f Green }"
            }
            try{
                Add-Member @NewMethod
            }
            catch{
                throw $PSItem
            }
        }
    }
    hidden UpdateChache($Values){
        foreach($key in $Values.Keys){
            $this.Cache.Remove($key)
            $this.Cache.Add($key,$Values[$key])
        }
    }
    [hashtable] PrimaryKeys() {
        return ConvertTo-Hashtable $this.cache -Include $this.Table.PrimaryKeys
    }
    [hashtable] Select([array]$Columns) {

        [hashtable]$OuputObject = @{}

        # check cache for values
        [array]$ColumnsNotCached = @()
        foreach($Column in $Columns){
            if($this.Cache[$Column]){
                [hashtable]$OuputObject += @{$Column=$this.Cache[$Column]}
            }
            else{
                [array]$ColumnsNotCached += $Column
            }
        }

        if(!$ColumnsNotCached){
            return $OuputObject
        }

        # build select statement
        $params = @{
            Database   = $this.Table.Database.DatabaseName
            Schema     = $this.Table.SchemaName
            Table      = $this.Table.Tablename
            Columns    = $ColumnsNotCached
            Conditions = $this.PrimaryKeys()
            Type       = [SqlCmdType]::SELECT 
        }
        $SqlCmd = New-SqlCmd @params

        # query database for none cached values
        $Results = $this.Table.Database.QueryOne($SqlCmd) 
        $NewValues = ConvertTo-Hashtable $Results

        # udpate chache
        $this.UpdateChache($NewValues)

        # merge cache with new values
        $OuputObject += $NewValues 

        return $OuputObject
    }
    [hashtable] Select() {
        return $this.Select(@('*'))
    }
    [psobject] Select([string]$Column) {
        return $this.Select(@($Column))[$Column]
    }
    
    Update([hashtable]$Row) {
        $Params = @{
            Database   = $this.Table.Database.DatabaseName
            Schema     = $this.Table.SchemaName
            Table      = $this.table.TableName
            Conditions = $this.PrimaryKeys()
            Set        = $Row
        }
        $Sql = New-SqlUpdate @Params

        # udpate database
        $this.table.Database.QueryOne($Sql) | Out-Null

        # update cache
        $this.UpdateChache($Row)
    }


    Update([string]$Column, [psobject]$Value) {
        $this.Update(@{$Column=$Value})
    }
}


$db = [DatabaseConnection]::New('localhost','MHUSD')
$db.Debug = $true
$tb = $db.Table('dbo','Employees')
$row = $tb.Where(@{EmployeeID = 842975})
$row.select('birthdate')
$row.FTE = 2

$row.catch.FTE