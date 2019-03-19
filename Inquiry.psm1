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
function Convert-DBNull {
    param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject
    )
    if ($InputObject -is [DBNull]) {
        return $null
    }
    return $InputObject
}

function Invoke-Sql {
    param (
        [SqlServerConnection]$Connection,
        [string]$Command #does not accept 'GO' keyword
    )
    try {
        $SqlConnection = $SqlServerConnection.SqlConnection()
        $SqlCommand = [System.Data.SqlClient.SqlCommand]::New($Command, $SqlConnection)
        $SqlConnection.Open()
        $reader = $SqlCommand.ExecuteReader()
        $Columns = $reader.GetSchemaTable()
        [System.Collections.ArrayList]$table = @()
        while ($reader.Read()) {
            $Row = [ordered] @{}
            foreach ($Column in $Columns) {
                $Row.Add(
                    $Column.ColumnName, 
                    $reader[$Column.ColumnOrdinal]
                )
            }
            $table.Add($Row) | Out-Null
        }
        return $table
    }
    catch {
        throw $PSItem
    }
    finally {
        $SqlConnection.Close()
    }
}

# SqlServerConnection helps to simplify microsofts stupid API's
Class SqlServerConnection {
    [string]$Server
    [string]$Database
    [string]$Username
    [string]$Password
    [bool]$WindowsAuthentication
    
    [ValidateRange(0,2147483647)]
    [long]$ConnectTimeout

    SqlServerConnection([string]$Server,[string]$Database,[string]$Username,[string]$Password){
        $this.Server = $Server
        $this.Database = $Database
        $this.Username = $Username
        $this.Password = $Password
        $this.WindowsAuthentication = $false
        $this.ConnectTimeout = 0
    }
    SqlServerConnection([string]$Server,[string]$Database){
        $this.Server = $Server
        $this.Database = $Database
        $this.WindowsAuthentication = $true
        $this.ConnectTimeout = 0
    }
    SqlServerConnection([hashtable]$Splat){
        $this.Server = $Splat.Server
        $this.Database = $Splat.Database

        if($Splat.Username -and $Splat.Password){
            $this.Username = $Splat.Username
            $this.Password = $Splat.Password
        }
        else{
            $this.WindowsAuthentication = $true
        }
        if($Splat.ConnectTimeout -is [long] -or $Splat.ConnectTimeout -is [int]){
            $this.ConnectTimeout = $Splat.ConnectTimeout
        }
        else{
            $this.ConnectTimeout = 0
        }
    }
    # https://docs.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring
    # ConnectionString includes the username and password in plain text.
    [string] ConnectionString () {
        $b = $this.SqlConnectionStringBuilder()
        if($this.Username){
            $b['User ID'] = $this.Username
        }
        if($this.Password){
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
    [System.Data.SqlClient.SqlConnectionStringBuilder] SqlConnectionStringBuilder(){
        $b = [System.Data.SqlClient.SqlConnectionStringBuilder]::New()
        if($this.Server){
            $b["Server"]= $this.Server
        }
        if($this.Database){
            $b["Database"] = $this.Database
        }
        if($this.WindowsAuthentication){
            $b["Integrated Security"] = $true
        }
        if($this.ConnectTimeout){
            $b["Connect Timeout"] = $this.ConnectTimeout
        }
        if($this.Encrypt){
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
    [System.Data.SqlClient.SqlCredential] SqlCredential(){
        $SecureString = ConvertTo-SecureString $this.Password -AsPlainText -Force
        $SecureString.MakeReadOnly()
        return [System.Data.SqlClient.SqlCredential]::New($this.Username, $SecureString)
    }

    # SqlConnection returns a ready to use SqlConnection
    [System.Data.SqlClient.SqlConnection] SqlConnection(){
        $ConnectionString = $this.ConnectionStringSecure()
        $Connection = [System.Data.SqlClient.SqlConnection]::New($ConnectionString)
        if(!$this.WindowsAuthentication){
            $Connection.Credential = $this.SqlCredential()
        }
        return $Connection
    }
}
function New-DatabaseConnection {
    param(
        [string]$ServerInstance,
        [string]$DatabaseName,
        [string]$Username,
        [string]$Password
    )
    if($Username -and $Password){
        return [DatabaseConnection]::new($ServerInstance, $DatabaseName, $Username, $Password)
    }
    else{
        return [DatabaseConnection]::new($ServerInstance, $DatabaseName)
    }
}

class DatabaseConnection {
    [SqlServerConnection]$Connection
    
    # user and pass
    DatabaseConnection([string]$Server, [string]$Database, [string]$Username, [string]$Password) {
        $this.Connection = [SqlServerConnection]::New($Server,$Database,$Username,$Password)
    } 
    # windows auth
    DatabaseConnection([string]$Server, [string]$Database) {
        $this.Connection = [SqlServerConnection]::New($Server,$Database)
    } 

    # cmd does not accept the 'GO' keyword
    [psobject] Cmd ([string]$Command) {
        try {
            $SqlConnection = $this.Connection.SqlConnection()
            $SqlCommand = [System.Data.SqlClient.SqlCommand]::New($Command, $SqlConnection)
            $SqlConnection.Open()
            $reader = $SqlCommand.ExecuteReader()
            $Columns = $reader.GetSchemaTable()
            [System.Collections.ArrayList]$table = @()
            while ($reader.Read()) {
                $Row = [ordered] @{}
                foreach ($Column in $Columns) {
                    $Row.Add(
                        $Column.ColumnName, 
                        $reader[$Column.ColumnOrdinal]
                    )
                }
                $table.Add($Row) | Out-Null
            }
            return $table
        }
        catch {
            throw $PSItem
        }
        finally {
            $SqlConnection.Close()
        }
    }
    [TableConnection] Table( [string]$Schema, [string]$Name, [string[]]$PrimaryKeys) {
        return [TableConnection]::new($this, $Schema, $Name, $PrimaryKeys)
    }
}


<#
    TableConnection stores information about a table and has methods for compiling sql cmds.
#>
class TableConnection {
    [string]$TableName
    [string]$SchemaName
    [DatabaseConnection]$DB
    
    [hashtable[]]$Columns
    [string[]]$PrimaryKeys
    
    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table, [string[]]$PrimaryKeys) {
        $this.DB = $DB
        $this.TableName = $table
        $this.SchemaName = $schemaGetColumns
        $this.Columns = $this.GetColumns()
        $this.PrimaryKeys = $PrimaryKeys
    }
    hidden [string] sqlTableObjectName() {
        return "[$($this.db.DatabaseName)].[$($this.SchemaName)].[$($this.TableName)]"
    }
    hidden [string] SqlSelect([string[]]$Columns) {
        return "SELECT `r`n`t[$($Columns -join "],`r`n`t[")] `r`nFROM $($this.sqlTableObjectName())" 
    }
    hidden [string] SqlSelectAll() {
        return "SELECT *`r`nFROM $($this.sqlTableObjectName())" 
    }
    hidden [string] SqlUpdate([hashtable]$Columns) {
        [string]$sql = "UPDATE $($this.sqlTableObjectName())`r`nSET"
        $i = 0
        foreach ($Col in $Columns.Keys) {
            $val = $Columns["$Col"]
            if (++$i -ne $Columns.Keys.count) {
                [string]$sql += "`r`n`t[$Col] = '$val',"
            }
            else {
                [string]$sql += "`r`n`t[$Col] = '$val'"
            }
        }
        return $sql
    }
    hidden [string] SqlInsert([hashtable]$Row) {
        return "INSERT INTO $($this.sqlTableObjectName()) (`r`n`t[$($Row.Keys -join "],`r`n`t[")]`r`n)`r`nVALUES (`r`n`t'$($Row.Values -join "',`r`n`t'")'`r`n);"
    }
    hidden [string] SqlWhere([hashtable]$Constraints) {
        [string]$sql = "`r`nWHERE"
        $i = 0
        foreach ($key in $Constraints.Keys) {
            # might need a type switch eventually, like ToSqlSring() method.
            $val = $Constraints["$key"]
            if ($i++ -eq 0) {
                $sql += "`r`n`t[$key] = '$val'"
            }
            else {
                $sql += "`r`n`tAND [$key] = '$val'"
            }
        }
        return $sql
    }
    #!!!WARNING THIS METHOD REQUIRES A WHERE STATEMENT!!!
    hidden [string] SqlDelete () {
        return "DELETE FROM $($this.sqlTableObjectName())"
    }
    hidden GetColumns() {
        $Command  = "SELECT top 1 *`r`nFROM $($this.sqlTableObjectName())" 
        try {
            $SqlConnection = $this.DB.Connection.SqlConnection()
            $SqlCommand = [System.Data.SqlClient.SqlCommand]::New($Command, $SqlConnection)
            $SqlConnection.Open()
            $reader = $SqlCommand.ExecuteReader()
            $Table = $reader.GetSchemaTable()
            $this.Columns 
        }
        catch {
            throw $PSItem
        }
        finally {
            $SqlConnection.Close()
        }
    }
    hidden [string] MissingPrimaryKey([string[]]$Columns) {
        foreach ($pk in $this.PrimaryKeys) {
            if ($Columns -notcontains $pk) {
                return $pk
            }
        }
        return $null
    }
    hidden ThrowMissingPrimaryKey([string[]]$Columns) {
        $pk = $this.MissingPrimaryKey($Columns)
        if ($pk) {
            throw "Query Results missing Primary key Column '$pk'. [RowConnection] must know the primary values to make gets and sets."
        }
    }
    hidden [string[]] IncludePrimaryKeys([string[]]$Columns) {
        [system.collections.ArrayList]$NewColumns = $Columns
        foreach ($PrimaryKey in $this.PrimaryKeys) {
            if ($NewColumns -notcontains $PrimaryKey) {
                $NewColumns.add($PrimaryKey)
            }
        }
        return $NewColumns
    }
    # Query return an array of RowConnection's based on the results of sql.
    # the magor catch here is that the sql query must return the primary key columns
    [RowConnection[]] Query([string]$SQL) {
        [array]$table = $this.DB.Cmd($SQL)
        
        # check the result for PKs 
        [string[]]$ResultColumns = $table[0].Table.Columns.ColumnName
        $this.ThrowMissingPrimaryKey($ResultColumns)

        # create Row Connections.
        [system.collections.arraylist]$rows = @()
        foreach ($row in $table) {
            [hashtable]$pkDefs = @{}
            foreach ($pk in $this.PrimaryKeys) {
                $pkDefs.add($pk, $row."$pk")
            }
            $rowConn = [RowConnection]::new($this, $pkDefs)
            $rows.Add($rowConn)
        }
        return $rows
    }
    # creates RowConnections for all the rows in a table.
    [RowConnection[]] Select() {
        $sql = $this.SqlSelect($this.PrimaryKeys)
        $results = $this.DB.Cmd($sql)
        [system.collections.arraylist]$rows = @()
        foreach ($result in $results ) {
            $rows.add([RowConnection]::new($this, $result))
        }
        return $rows
    }
    # this is takes a ubiquidious array and uses the other overload mothods to do the heavy lifting.
    [RowConnection[]] Select([array]$PrimaryKeyDefinitions) {
        [system.collections.arraylist]$rows = @()
        foreach ($pkd in $PrimaryKeyDefinitions) {
            $rows.Add($this.Select($pkd))
        }
        return $rows
    }
    [RowConnection] Select([hashtable]$PrimaryKeyDefinition) {
        $this.ThrowMissingPrimaryKey($PrimaryKeyDefinition.Keys)
        return [RowConnection]::new($this, $PrimaryKeyDefinition)
    }
    [RowConnection] Select([System.Data.DataRow]$DataRow) {
        $this.ThrowMissingPrimaryKey($DataRow.Table.Columns.ColumnName)
        return [RowConnection]::new($this, $DataRow)
    }
    [RowConnection[]] Select([scriptblock]$Where) {
        $sql = $this.SqlSelectAll()
        [array]$results = $this.DB.Cmd($sql) | Where-Object -FilterScript $Where
        [system.collections.arraylist]$rows = @()
        foreach ($result in $results ) {
            $rows.add([RowConnection]::new($this, $result))
        }
        return $rows
    }
    [RowConnection[]] Select([array]$Column,[scriptblock]$Where) {
        $sql = $this.SqlSelect($this.IncludePrimaryKeys($Column))
        [array]$results = $this.DB.Cmd($sql) | Where-Object -FilterScript $Where
        [system.collections.arraylist]$rows = @()
        foreach ($result in $results ) {
            $rows.add([RowConnection]::new($this, $result))
        }
        return $rows
    }
    Insert ([System.Data.DataRow]$Row) {
        $this.Add($Row.PrimaryKeys)
    }
    Insert ([hashtable]$NewRow) {
        $this.ThrowMissingPrimaryKey($NewRow.Keys)
        $SQL = $this.SqlInsert($NewRow)
        $this.DB.Cmd($SQL)
    }
    Insert ([array]$NewRows) {
        foreach ($NewRow in $NewRows) {
            $this.Add($NewRow)
        }
    }
    Delete([hashtable]$Row) {
        $this.ThrowMissingPrimaryKey($Row.Keys)
        $sql = $this.SqlDelete() + $this.SqlWhere($Row) + ';'
        $this.DB.Cmd($sql)
    }
    Delete([RowConnection]$Row) {
        $this.Del($Row.PrimaryKeys)
    }
    Delete([array]$Rows) {
        foreach ($Row in $Rows) {
            $this.Del($Row)
        }
    }
    Update([hashtable]$Row) {
        $this.ThrowMissingPrimaryKey($Row)
        [string]$sql = $this.SqlUpdate($Row) + $this.SqlWhere() + ';'
        $this.DB.Cmd($sql)
    }
    Update([array]$Rows) {
        foreach ($Row in $Rows) {
            $this.Update($Row)
        }
    }
}










<#
    RowConnection is a lightwight object that stores the identity of a row in table.
#>
class RowConnection {
    [hashtable]$PrimaryKeys
    [TableConnection]$Table
    RowConnection([TableConnection]$table, [hashtable]$pks) {
        $this.Table = $table
        $this.PrimaryKeys = $pks
        $this.NewColumnProperties($this.Table.Columns.ColumnName)
    }
    RowConnection([TableConnection]$table, [System.Data.DataRow]$row) {
        $this.Table = $table
        $this.PrimaryKeys = @{}
        foreach ($col in $table.PrimaryKeys) {
            $this.PrimaryKeys.Add($col, $row."$col")
        }
        $this.NewColumnProperties($this.Table.Columns.ColumnName)
    }
    hidden NewColumnProperties([string[]]$Columns) {
        foreach ($Column in $Columns) {
            if ($this.PrimaryKeys.Keys -contains $Column) {
                $this.NewPrimaryKeyProperty($Column)
            }
            else {
                $NewMethod = @{
                    memberType  = 'ScriptProperty'
                    InputObject = $this
                    Name        = $Column
                    #get
                    Value       = Invoke-Expression "{return `$this.Select('$Column')}"
                    #set
                    SecondValue = Invoke-Expression "{Param([parameter(mandatory)][psobject]`$Value) `$this.Update('$Column', `$Value)}"
                }
                Add-Member @NewMethod
            }
        }
    }
    hidden NewPrimaryKeyProperty([string]$Column) {
        $NewMethod = @{
            memberType  = 'ScriptProperty'
            InputObject = $this
            Name        = $Column
            #get
            Value       = Invoke-Expression "{return `$this.Select('$Column')}"
            #set
            SecondValue = Invoke-Expression "{
                Param(
                    [parameter(mandatory)]
                    [psobject]
                    `$Value
                )
                try{
                   `$this.Update('$Column', `$Value)
                   `$this.PrimaryKeys['$Column'] = `$Value
                }
                catch{
                    throw `$psitem
                }
            }"
        }
        Add-Member @NewMethod
    }

    Update([string]$Column, [psobject]$Value) {
        $t = @{$Column = $Value}
        [string]$sql = $this.Table.SqlUpdate($t) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $this.Table.DB.Cmd($sql)
    }

    Update([hashtable]$Row) {
        [string]$sql = $this.Table.SqlUpdate($Row) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $this.Table.DB.Cmd($sql)
    }
    
    [psobject] Select([string]$Column) {
        [string]$sql = $this.Table.SqlSelect($Column) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $Results = $this.Table.DB.Cmd($sql)
        if ($Results -isnot [system.data.datarow] -and $Results) {throw "Multiple Results Returned on Row.Get() Method! please check you Primary Key Constraints."}
        return $Results."$Column" | Convert-DBNull
    }
    [hashtable] Select([array]$Columns) {
        [string]$sql = $this.Table.SqlSelect($Columns) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $Results = $this.Table.DB.Cmd($sql)
        if ($Results -isnot [system.data.datarow] -and $Results) {throw "Multiple Results Returned on Row.Get() Method! please check you Primary Key Constraints."}
        [hashtable]$ht = @{}
        foreach ($Column in $Columns) {
            $value = $Results."$Column" | Convert-DBNull
            $ht.Add($Column, $value )
        }
        return $ht 
    }
    [hashtable] Select() {
        $sql = $this.Table.SqlSelectAll() + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $results = $this.Table.DB.Cmd($sql)
        return $this.Table.DB.ConvertDataRowToHashtable($results)
    }
    Delete() {
        $this.Table.Del($this)
    }
}