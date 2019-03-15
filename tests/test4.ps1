<#
    THE RULES:
    1) functions are created when all object may need access to logic
    2) classes are created Spearingly to reduce end user learning curve
    2) classes can be created to manage other classes to make them more automagical
    3) methods are created to operate on itself or to return data to the user
    4) methods are created when a class needs some internal custom logic
    5) methods overloads created used to make interfaces more flexable to the user
    6) datatypes should always be explicity defined
#>

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

Function Get-SqlTableSchema {
    param(
        [string]$Table,
        [string]$Schema,
        [SqlServerConnection]$Connection
    )
    # create a SqlDataAdapter that is primed to use the sql statement
    $SQL = "SELECT TOP 1 * FROM [$($Connection.Database)].[$SchemaName].[$TableName] "
    $adapter = [System.Data.SqlClient.SqlDataAdapter]::new($SQL, $Connection.SqlConnection() )

    # get extra schema info
    $adapter.MissingSchemaAction = [System.Data.MissingSchemaAction]::AddWithKey

    # create a datatable to store the sql results
    $table = [System.Data.DataTable]::new()
    $adapter.Fill($table) | Out-Null

    # get table schema
    $Rows = $table.CreateDataReader().GetSchemaTable().Rows
    
    # convert to [hashtable[]]
    $ColumnNames = $Rows[0].Table.Columns.ColumnName
    [System.Collections.ArrayList]$Schema = @()
    foreach($Row in $Rows){
        $Columns = @{}
        foreach($ColumnName in $ColumnNames){
            $Columns.Add($ColumnName,$Row.Item($ColumnName) ) | Out-Null
        }   
        $Schema.add($Columns) |  Out-Null
    }
    return $Schema
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

    # parent database connection
    [DatabaseConnection]$DB

    # the tables column schema as defined
    # by DataTableReader.GetSchemaTable()
    [hashtable[]]$Columns

    # the column names of the primary keys
    # this property can be maually set or
    # it can be set from details in the 
    # table schema
    [string[]]$PrimaryKeys 
    
    # Dynamically Get Primary Keys
    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table) {
        $this.DB = $DB
        $this.TableName = $table
        $this.SchemaName = $schema
        $this.SetColumnsFromTableSchema()
        $this.SetPrimaryKeysFromColumns()
    }

    # Manually set Primary Keys
    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table, [string[]]$PrimaryKeys) {
        $this.DB = $DB
        $this.TableName = $table
        $this.SchemaName = $schema
        $this.SetColumnsFromTableSchema()
        $this.SetPrimaryKeyManually($PrimaryKeys)
    }

    # query table for column information
    hidden SetColumnsFromTableSchema(){
        $this.Columns = Get-SqlTableSchema -Schema $this.SchemaName -Table $this.TableName -Connection $this.DB.Connection
    }

    # extract primary key ColumnsNames from column information.
    hidden SetPrimaryKeysFromColumns(){
        $this.PrimaryKeys = $this.Columns | Where-Object { $psitem.IsKey -eq $True } | Select-Object -ExpandProperty 'ColumnName'
    }

    # Sets PrimeryKeys manually 
    # PrimeryKeys must be valid columns
    hidden SetPrimaryKeyManually([string[]]$PrimaryKeys){
        foreach($PrimaryKey in $PrimaryKeys){
            $ColumnNames = $this.Columns.ColumnName
            if($ColumnNames -notcontains $PrimaryKey){
                throw "Invalid ColumnName for PrimaryKey: '$PrimaryKey'"
            }
            $this.PrimaryKeys += $PrimaryKey
        }
    }
}




class RowConnection {

}


# a device that filters rows quickly server side.
class RowIterator : System.Collections.IEnumerator {
    [TableConnection]$Table
    [ScriptBlock]$Filter
    [string[]]$Columns

    [System.Data.SqlClient.SqlConnection]$Connection
    [System.Data.SqlClient.SqlDataReader]$Reader
    [System.Data.SqlClient.SqlCommand]$Command

    $Get_Current
    
    RowIterator () {
        ([System.Collections.IEnumerator]$this).Get_Current
    }

    BuildCurrentProperty(){
        $NewMethod = @{
            memberType  = 'ScriptProperty'
            InputObject = $this
            Name        = 'Current'
            Value       = {
                return $this.GetCurrentRowConnection()
            }
        }
        Add-Member @NewMethod
    }


    hidden NewConnection(){
        # close old connection
        $this.Connection.Close()
        # create a new connection
        $ConnectionString = $this.Table.DB.Connection.ConnectionStringSecure()
        $this.Connection = [System.Data.SqlClient.SqlConnection]::new($ConnectionString)
        $this.Connection.Credential = $this.Table.DB.Connection.SqlCredential()
    }

    hidden NewReader(){
        # close any prior running reader
        $this.ready.close()
        # make a new reader
        $this.Reader = [System.Data.SqlClient.SqlDataReader]::new($this.Command, $this.Connection)
    }


    # IEnumerable Properties && Methods
    # $Current property needs to be added at runtime becuase powershell does not support getters.
    [RowConnection]$Current
    [int]$Cursor = -1
    [int]$Count

    [bool] MoveNext() {
        $this.Cursor++
        $this.GetCurrentRowConnection()
        if($this.Cursor -lt $this.Count){
            return $true
        }
        return $false
    }

    [void] Reset() {
        $this.position = -1;
        $this.NewConnection()
        $this.NewReader()
    }

    [RowConnection] GetCurrentRowConnection(){
        $this.Reader.Read()
        [hashtable]$RowPrimaryKeys = @{}
        foreach($PrimaryKey in $this.table.PrimaryKeys){
            $RowPrimaryKeys.Add($PrimaryKey, $this.Reader[$PrimaryKey])
        }
        return [RowConnection]::new($this.table,$RowPrimaryKeys)
    }
}













#$config = Import-PowerShellDataFile "$PSScriptRoot\virtualbox.secure.psd1"

#$sql = Get-Content "$PSScriptRoot\test.sql" -Raw

#$schema = Get-SqlTableSchema -TableName 'Employees' -SchemaName 'dbo' -Connection $config
     
#$schema[0]