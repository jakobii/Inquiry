#[System.Data.SqlClient.SqlConnection]$Connection
#[System.Data.SqlClient.SqlDataReader]$Reader
#[System.Data.SqlClient.SqlCommand]$Command

$Server = ''
$Database = ''


$Connection = [System.Data.SqlClient.SqlConnection]::new("server=$($Server);initial catalog=$($Database);Integrated Security=True")
$Command = [System.Data.SqlClient.SqlCommand]::new('Select top 10 * from stu', $Connection)

$Connection.Open()
$Reader = $Command.ExecuteReader()

$Reader.Read()

$Reader['id']
$Reader['sc']
$Reader[0..5]

$Reader -is [System.Data.IDataRecord]
# $Connection.Close()

Function New-SqlCommand {
    param(
        [string[]]$Select,
        [string]$Database,
        [string]$Schema,
        [string]$Table,
        [hashtable]$Where
    )

}


function Search-SqlTable {
    param(
        [SqlServerConnection]$Connection,
        [string]$Table,
        [string]$Schema,
        [string[]]$Columns,
        [scriptblock]$Filter
    )

    $SqlConnection = $Connection.SqlConnection()
    $Command = [System.Data.SqlClient.SqlCommand]::new( "SELECT * FROM" , $SqlConnection)
    $Connection.Open()
    $Reader = $Command.ExecuteReader()
    while($Reader.Read()){

    }
}


class RowConnection {

}

class TableConnection {

    #[RowConnection[]] Where() {

    #}
}