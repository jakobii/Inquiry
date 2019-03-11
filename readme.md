![GitHub Logo](/docs/floss.png)
# Floss

A Light weight Sql Server ORM written in Powershell. The goal of this module is to make working with sql server feel like powershell.

## 1) Connect to a Database
Connecting to a database is pretty standard.

```powershell
#Create A DatabaseConnection
[DatabaseConnection]$Database = New-DatabaseConnection -ServerInstance 'MySrv' -DatabaseName 'MyDb' -Username 'User' -Password 'pass' 

# Outputs all SQL to the console.
$Database.DebugQuery = $true
```

## 2) Connect to a Table
Table( Schema, Table, PrimaryKey(s) )             
```powershell
[TableConnection]$Table = $Database.Table('dbo', 'Students', @('ID'))
```

## 3) Connect to a Row
A `RowConenction` does not store the entire rows data, it merely **references** the row using its primary key.

```powershell
[RowConnection]$Row = $Table.Get(@{ID = 123456})
```

We can create many row connections at once.

```powershell
[RowConnection[]]$Rows = $Table.Get({$_.Firstname -like 'Jaco*'})
```
when a `RowConenction` is created, getters and setters are created for each column, they look like properties on an object. 

### Getter
when we use a column property without an assignment operator we are requesting data from the database. A *SELECT* statement is generated and executed and the value is delivered back to the caller.
```powershell
$Row.Firstname | Out-Host   
#     |     +--->
#     S     |
#     E     +--------+
#     L              |
#     E              |
#     C      MSSQL   |
#     T     [_____]  |
#     +---> [_____] -+
#           [_____]
```

We can also get a list of columns. Their values are mapped to the column names in a hashtable.
```powershell
[hashtable]$Values = $Row.get(@('Firstname','Lastname'))
```
Getting the entire row as a hashtable.
```powershell
[hashtable]$Values = $Row.get()
```

### Setter
When the `RowConnection` column properties are used with an assignment operator then an *UPDATE* statment is generated and executed.
```powershell
$Row.Firstname = 'Jimmy'
#     |       <---
#     U 
#     P   
#     D 
#     A
#     T     MSSQL
#     E    [_____]
#     +--> [_____]
#          [_____]

```
We can also update a row with a hashtable.
```powershell
$Row.Set(@{Firstname = 'Jacob';Lastname = 'Ochoa'})
```
