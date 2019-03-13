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
emun SqlOutputTypes {
    OrderedDictionary
    HashTable
    PSCustomObject
    DataRow
    DataTable
    DataSet
}

class SqlInvoker {
    [SqlServerConnection]$Connection
    [string]$Command

    [Hashtable] ReaderToHashtable([System.Data.SqlClient.SqlDataReader]$Reader){
            $Columns = $Reader.GetSchemaTable()
            $Row = @{}
            foreach ($Column in $Columns) {
                $Row.Add(
                    $Column.ColumnName, 
                    $reader[$Column.ColumnOrdinal]
                )
            }
            return $Row
    }
    [System.Data.DataRow] ReaderToDataRow([System.Data.SqlClient.SqlDataReader]$Reader){

    }

    [PSCustomObject] ReaderToPSCustomObject([System.Data.SqlClient.SqlDataReader]$Reader){

    }
}

class SqlTable {
    $Columns
    $Rows
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


#[SqlServerConnection]::New('mhu-dbwh-02','dbwh').SqlConnection()

#[SqlServerConnection]::New('mhu-dbwh-02','dbwh','JACOB','MYPASS').ConnectionString()

#[SqlServerConnection]::New('mhu-dbwh-02','dbwh','JACOB','MYPASS').SqlConnection()

$conf = Import-PowerShellDataFile -Path ".\DigitalOcean.secure.psd1"

$table = Invoke-Sql -Connection $conf -Command 'select top 10 * from stu'

foreach($row in $table){
    $row.FN + ' ' + $row.LN
}