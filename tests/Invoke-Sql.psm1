function Invoke-Sql {
    param (
        [string]$Server,
        [string]$Database,
        [string]$Username,
        [string]$Password,
        [string]$Command #does not accept 'GO' keyword
    )
    [string]$ConnectionString = @(
        "server=$($Server);"
        "user id=$($Username);"
        "password= $($Password);"
        "initial catalog=$($Database)"
    ) -join ''
    try {
        $Connection = [System.Data.SqlClient.SqlConnection]::New($ConnectionString)
        $SqlCommand = [System.Data.SqlClient.SqlCommand]::New($Command, $Connection)
        $Connection.Open()
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
        $Connection.Close()
    }
}

#$b= [System.Data.SqlClient.SqlConnectionStringBuilder]::New()
#$b.UserID



