#Requires -Modules SqlServer
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
function New-DatabaseConnection {
    param(
        [string]$ServerInstance,
        [string]$DatabaseName,
        [string]$Username,
        [string]$Password
    )
    return [DatabaseConnection]::new($ServerInstance, $DatabaseName, $Username, $Password)
}

class DatabaseConnection {
    [string]$ServerInstance
    [string]$DatabaseName
    [string]$Username
    [string]$Password
    [int]$ConnectionTimeout
    [int]$QueryTimeout
    [bool]$DebugQuery
    DatabaseConnection([string]$Server, [string]$Database, [string]$Username, [string]$Password) {
        $this.ServerInstance = $Server
        $this.DatabaseName = $Database
        $this.Username = $Username
        $this.Password = $Password
        $this.ConnectionTimeout = 0
        $this.QueryTimeout = 0
    } 
    [PSCredential] GetPSCredential() {
        $SecureString = ConvertTo-SecureString $this.Password -AsPlainText -Force
        return [PSCredential]::new($this.Username, $SecureString)
    }
    [PSObject] Query ([string]$SQL) {
        if ($this.DebugQuery) {
            $SQL | Write-Console -f Yellow
        }
        $Params = @{
            ServerInstance    = $this.ServerInstance
            Database          = $this.DatabaseName
            ConnectionTimeout = $this.ConnectionTimeout
            QueryTimeout      = $this.QueryTimeout
            Query             = $SQL
            ErrorAction       = 'stop'
        }
        if ($this.Username -and $this.Password) {
            $Params.Credential = $this.GetPSCredential()
        }
        try {
            $results = Invoke-Sqlcmd @Params
            return $results
        }
        catch {
            throw $psitem
        }
    }
    # ConvertDataRowToHashtable
    # although we can detirmine the columns from the datarow, it requires 
    # generating a new array, which is slow. 
    hidden [hashtable] ConvertDataRowToHashtable ([system.data.datarow]$row, [array]$Columns) {
        $ht = @{}
        foreach ($Col in $Columns) {
            $ht.Add($Col, $row."$Col")
        }
        return $ht
    }
    # only use this for one off conversions.
    hidden [hashtable] ConvertDataRowToHashtable ([system.data.datarow]$row) {
        $Columns = $row.Table.Columns.ColumnName
        $ht = @{}
        foreach ($Col in $Columns) {
            $ht.Add($Col, $row."$Col")
        }
        return $ht
    }
    hidden [hashtable[]] ConvertDataRowsToHashtableArray ([array]$rows) {
        $Columns = $rows.Table.Columns.ColumnName
        [System.Collections.ArrayList]$hts = @()
        foreach ($row in $rows) {
            $hts.Add($this.ConvertDataRowToHashtable($row, $Columns))
        }
        return $hts
    }

    [TableConnection] Table( [string]$Schema, [string]$Name, [string[]]$PrimaryKeys) {
        return [TableConnection]::new($this, $Schema, $Name, $PrimaryKeys)
    }
}


class ColumnDefinition {
    [int]$ColumnID
    [string]$ColumnName
    [string]$DataType
    [int]$MaxLength
    [int]$Percision
}









<#
    TableConnection stores information about a table and has methods for compiling sql cmds.
#>
class TableConnection {
    [string]$TableName
    [string]$SchemaName
    [DatabaseConnection]$DB
    [ColumnDefinition[]]$Columns
    [string[]]$PrimaryKeys
    TableConnection([DatabaseConnection]$DB, [string]$schema, [string]$table, [string[]]$PrimaryKeys) {
        $this.DB = $DB
        $this.TableName = $table
        $this.SchemaName = $schema
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
    hidden [ColumnDefinition[]] GetColumns() {
        $sql = "
        /* Get Column Information Information */
        SELECT * 
        FROM ( 
        	SELECT 
        		schema_name(tab.schema_id) as [SchemaName],
        	    tab.name                   as [TableName], 
        	    col.column_id              as [ColumnID],
        	    col.name                   as [ColumnName], 
        	    typ.name                   as [DataType],    
        	    col.max_length             as [MaxLength],
        	    col.precision              as [Percision]

        	FROM sys.tables as tab
        	INNER JOIN sys.columns as col
        	    on tab.object_id = col.object_id
        	LEFT JOIN sys.types as typ
        		on col.user_type_id = typ.user_type_id
        ) as x 
        where 
            [SchemaName] = '$($this.SchemaName)'
        	and [TableName] = '$($this.TableName)'
        order by 
        	[SchemaName],
            [TableName], 
            [ColumnID];
        "
        $table = $this.DB.Query($sql)
        #$table | ft -AutoSize | Out-Host
        [system.collections.arraylist]$Cols = @()
        foreach ($row in $table) {
            $ColDef = [ColumnDefinition]::new()
            $ColDef.ColumnID = $row.ColumnID
            $ColDef.ColumnName = $row.ColumnName
            $ColDef.DataType = $row.DataType
            $ColDef.MaxLength = $row.MaxLength
            $ColDef.Percision = $row.Percision
            $Cols.Add($ColDef)
        }
        return $Cols
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
    # creates RowConnections for all the rows in a table.
    [RowConnection[]] Get() {
        $sql = $this.SqlSelect($this.PrimaryKeys.keys)
        $results = $this.DB.Query($sql)
        [system.collections.arraylist]$rows = @()
        foreach ($result in $results ) {
            $rows.add([RowConnection]::new($this, $result))
        }
        return $rows
    }
    # this is takes a ubiquidious array and uses the other overload mothods to do the heavy lifting.
    [RowConnection[]] Get([array]$PrimaryKeyDefinitions) {
        [system.collections.arraylist]$rows = @()
        foreach ($pkd in $PrimaryKeyDefinitions) {
            $rows.Add($this.Get($pkd))
        }
        return $rows
    }
    [RowConnection] Get([hashtable]$PrimaryKeyDefinition) {
        $this.ThrowMissingPrimaryKey($PrimaryKeyDefinition.Keys)
        return [RowConnection]::new($this, $PrimaryKeyDefinition)
    }
    [RowConnection] Get([System.Data.DataRow]$DataRow) {
        $this.ThrowMissingPrimaryKey($DataRow.Table.Columns.ColumnName)
        return [RowConnection]::new($this, $DataRow)
    }
    [RowConnection[]] Get([scriptblock]$Filter) {
        $sql = $this.SqlSelectAll()
        [array]$results = $this.DB.Query($sql) | Where-Object -FilterScript $Filter
        [system.collections.arraylist]$rows = @()
        foreach ($result in $results ) {
            $rows.add([RowConnection]::new($this, $result))
        }
        return $rows
    }
    [RowConnection[]] Get([scriptblock]$Filter, [array]$Column) {
        $sql = $this.SqlSelect($this.IncludePrimaryKeys($Column))
        [array]$results = $this.DB.Query($sql) | Where-Object -FilterScript $Filter
        [system.collections.arraylist]$rows = @()
        foreach ($result in $results ) {
            $rows.add([RowConnection]::new($this, $result))
        }
        return $rows
    }
    # Query return an array of RowConnection's based on the results of sql.
    # the magor catch here is that the sql query must return the primary key columns
    [RowConnection[]] Query([string]$SQL) {
        [array]$table = $this.DB.Query($SQL)
        
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
    Add ([System.Data.DataRow]$Row) {
        $this.Add($Row.PrimaryKeys)
    }
    Add ([hashtable]$NewRow) {
        $this.ThrowMissingPrimaryKey($NewRow.Keys)
        $SQL = $this.SqlInsert($NewRow)
        $this.DB.Query($SQL)
    }
    Add ([array]$NewRows) {
        foreach ($NewRow in $NewRows) {
            $this.Add($NewRow)
        }
    }
    Del([hashtable]$Row) {
        $this.ThrowMissingPrimaryKey($Row.Keys)
        $sql = $this.SqlDelete() + $this.SqlWhere($Row) + ';'
        $this.DB.Query($sql)
    }
    Del([RowConnection]$Row) {
        $this.Del($Row.PrimaryKeys)
    }
    Del([array]$Rows) {
        foreach ($Row in $Rows) {
            $this.Del($Row)
        }
    }
    Set([hashtable]$Row) {
        $this.ThrowMissingPrimaryKey($Row)
        [string]$sql = $this.SqlUpdate($Row) + $this.SqlWhere() + ';'
        $this.Table.DB.Query($sql)
    }
    Set([array]$Rows) {
        foreach ($Row in $Rows) {
            $this.Set($Row)
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
                    Value       = Invoke-Expression "{return `$this.Get('$Column')}"
                    #set
                    SecondValue = Invoke-Expression "{Param([parameter(mandatory)][psobject]`$Value) `$this.Set('$Column', `$Value)}"
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
            Value       = Invoke-Expression "{return `$this.Get('$Column')}"
            #set
            SecondValue = Invoke-Expression "{
                Param(
                    [parameter(mandatory)]
                    [psobject]
                    `$Value
                )
                try{
                   `$this.Set('$Column', `$Value)
                   `$this.PrimaryKeys['$Column'] = `$Value
                }
                catch{
                    throw `$psitem
                }
            }"
        }
        Add-Member @NewMethod
    }
    Set([string]$Column, [psobject]$Value) {
        $t = @{$Column = $Value}
        [string]$sql = $this.Table.SqlUpdate($t) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $this.Table.DB.Query($sql)
    }
    Set([hashtable]$Row) {
        [string]$sql = $this.Table.SqlUpdate($Row) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $this.Table.DB.Query($sql)
    }
    [psobject] Get([string]$Column) {
        [string]$sql = $this.Table.SqlSelect($Column) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $Results = $this.Table.DB.Query($sql)
        if ($Results -isnot [system.data.datarow] -and $Results) {throw "Multiple Results Returned on Row.Get() Method! please check you Primary Key Constraints."}
        return $Results."$Column" | Convert-DBNull
    }
    [hashtable] Get([array]$Columns) {
        [string]$sql = $this.Table.SqlSelect($Columns) + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $Results = $this.Table.DB.Query($sql)
        if ($Results -isnot [system.data.datarow] -and $Results) {throw "Multiple Results Returned on Row.Get() Method! please check you Primary Key Constraints."}
        [hashtable]$ht = @{}
        foreach ($Column in $Columns) {
            $value = $Results."$Column" | Convert-DBNull
            $ht.Add($Column, $value )
        }
        return $ht 
    }
    [hashtable] Get() {
        $sql = $this.Table.SqlSelectAll() + $this.Table.SqlWhere($this.PrimaryKeys) + ';'
        $results = $this.Table.DB.Query($sql)
        return $this.Table.DB.ConvertDataRowToHashtable($results)
    }
    Del() {
        $this.Table.Del($this)
    }
}