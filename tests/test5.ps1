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
        [System.Data.SqlClient.SqlCommand]$Command
    )
    $Adapter = [System.Data.SqlClient.SqlDataAdapter]::new($Command.CommandText,$Command.Connection)
    $Table = [System.Data.DataTable]::new()
    $Adapter.Fill($Table)
    return $Table.Rows 
}

<#
    Get-SchemaTable function returns an array of DataRows that decribe the tables schema

    [example]
    $Auth = [SqlServerAuthentication]::new('mhu-dbwh-02','Enrollment')
    $table = Get-SchemaTable -Schema 'dbo' -Table 'JotFormTransferRequests' -Connection $Auth.SqlConnection()
    $table.Rows[0] | Out-Host    
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
    [string] ToString(){
        return $this.ConnectionString()
    }
}

<#

#>
class DatabaseConnection {
    [string]$ServerName
    [string]$DatabaseName
    
    [SqlServerAuthentication]$Authentication
    [System.IO.DirectoryInfo]$Log
    [bool]$Debug
    
    <#
        the standard query mechanism for all child objects
    #>
    [System.Data.Datarow[]] Query([System.Data.SqlClient.SqlCommand]$Command) {
        $Command.Connection = $this.Authentication.SqlConnection()
        return Invoke-Sql $Command
    }

    <#
        From() method creates table connections and is synomymous with the SQL FROM keyword.
    #>
    [TableConnection] Table($SchemaName, $TableName) {
        return [TableConnection]::new($this, $SchemaName, $TableName)
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

    [RowCacheUseLevels]$CacheMode = 1
    [int]$CacheTTL = 180

    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table) {
    }
    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table, [string[]]$PrimaryKeys) {
    }

    [string] ObjectName() {
        return "[$($this.DB.DatabaseName)].[$($this.SchemaName)].[$($this.TableName)]"
    }

    hidden [bool] TestPrimaryKey([System.Data.DataColumn]$Column) {
        if ($Column.IsKey) {
            return $true
        }
        else {
            return $false
        }
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

enum RowCacheUseLevels {
    Never = 1
    Time = 2
    Always = 3
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
    [hashtable]$Cache
    hidden [hashtable]$CacheTimes

    [RowCacheUseLevels]$CacheMode = 1
    [int]$CacheTTL = 180

    hidden [psobject]$UnsafeCache
    hidden [bool]$Unique
    hidden [bool]$Connected
    hidden [nullable[datetime]]$Deleted
    hidden [bool]$AutoCreate = $true

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
    <#
        [Decription]
        Bread and Butter of this module. Runtime generated Getters and Setters for each columns.
    #>
    hidden BuildColumnProperties() {
        foreach ($Column in $this.table.Columns) {
            if ( $this.table.IsPrimaryKey($Column) ) {
                [string]$Getter = "{return `$this.PrimaryKeys['$Column']}"
                [string]$Setter = "{
                    Param(
                        [parameter(mandatory)]
                        [psobject]
                        `$Value
                    ) 
                    `$this.Update('$Column', `$Value)
                    `$this.PrimaryKeys['$Column'] = `$Value
                }"
            }
            else {
                [string]$Getter = "{
                    if(`$this.CacheMode -eq 'Never'){
                        return `$this.Select('$Column')
                    }
                    elseif(`$this.CacheMode -eq 'Always'){
                        `$Value = `$this.Cache['$Column']
                        if(`$Value){
                            return `$Value
                        }
                        else{
                            `$this.Cache['$Column'] = `$this.Select('$Column')
                            return `$this.Cache['$Column']
                        }
                    }
                    elseif(`$this.CacheMode -eq 'Time'){
                        `$Value = `$this.Cache['$Column']
                        `$Time = `$this.CacheTimes['$Column']
                        if(`$Value -and `$Time -and `$time.AddSeconds(`$this.TTL) -lt `$(Get-date) ){
                            return `$Value
                        }
                        else{
                            `$this.Cache['$Column'] = `$this.Select('$Column')
                            `$this.CacheTimes['$Column'] = Get-date
                            return `$this.Cache['$Column']
                        }
                    }
                }"
    
                
                [string]$Setter = "{
                    Param(
                        [parameter(mandatory)]
                        [psobject]
                        `$Value
                    )
                    try{
                       `$this.Update('$Column', `$Value)
                       `$this.Cache['$Column'] = `$Value
                       `$this.CacheTimes['$Column'] = Get-Date
                    }
                    catch{
                        throw `$psitem
                    }
                }"
            }

            $NewMethod = @{
                memberType  = 'ScriptProperty'
                InputObject = $this
                Name        = $Column
                Value       = Invoke-Expression $Getter
                SecondValue = Invoke-Expression $Setter
            }
            Add-Member @NewMethod
        }
    }

    <#
        used for house keeping purposes
    #>
    hidden UpdateUnsafeCache () {
        $this.UnsafeCache = $this.UnsafeSelect($this.Table.PrimaryKeys)
    }   

    # Checks the rows PrimaryKeys hashtable against the tables PrimaryKey array.
    hidden [bool] TestPrimaryKeys() {
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
        return $true
    }
    # simples confirms a row contains the rowconnections PrimaryKeys
    hidden [bool] TestConnection() {
        if (!$this.UnsafeCache) {
            $this.Connected = $false
            #Throw "PrimaryKeys are not Unique in $TB: $PKs"
        }
        # test existance
        elseif ($this.UnsafeCache) {
            $this.Connected = $true
        }
        return $this.Connected
    }
    hidden ConnectionError() {
        throw "Could not establish a RowConnection with PrimaryKeys: $(ConvertTo-DataString $this.PrimaryKeys)"
    }

    # Test that the RowConnections PrimaryKeys only Reference a single row
    hidden [bool] TestUnique() {
        if ($this.UnsafeCache -is [System.Data.Datarow]) {
            $this.Unique = $True
        }
        else {
            $this.Unique = $False
        }
        return $this.Unique
    }
    hidden UniqueError() {
        throw "The RowConnection's PrimaryKeys: $(ConvertTo-DataString $this.PrimaryKeys) do not uniquely identify a row in the table: $($this.Table.ObjectName())"
    }
    <#
        [Description]
        test() method forces standard tests. which is slow, but essencial.
    #>
    [void] Test() {
        $this.UpdateUnsafeCache()
        if (!$this.TestConnection()) {
            $this.ConnectionError()
        }
        if (!$this.TestUnique()) {
            $this.UniqueError()
        }
    }
    <# 
        [Description]
        Check() method is like the Test() method, but it only performs tests 
        that have previously failed or are untested.
    #>
    [void] Check() {
        if (!$this.UnsafeCache) {
            $this.UpdateUnsafeCache()
        }
        if (!$this.Connected) {
            if (!$this.TestConnection()) {
                $this.ConnectionError()
            }
        }
        if (!$this.Unique) {
            if (!$this.TestUnique()) {
                $this.UniqueError()
            }
        }
    }


    <#
        [Description]
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
        [Description]
        Select() Methods gets the rows column values and returns 
        them as a hastable.
        
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


    Update([hashtable]$Row) {}
    Update([string]$Column, [psobject]$Value) {}

    <#
        Delete() method deletes the row from the table that it is referencing.
        
    #>
    Delete() {
        $this.Check()
    }

    <#
        Insert() method ReInserts Primarykeys into the table.
        This usefull if you call use the delete() method and then 
        decide to use the row afterwards

        Insert() should be safe to call at anytime


    #>
    Insert() {
        $this.Check()
    }
}


