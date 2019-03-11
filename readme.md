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
A `RowConenction` does not store the columns data inside it, it merely **references** a single row.

```powershell
[RowConnection]$Row = $Table.Get(@{ID = 123456})
```
We can get many row connections
```powershell

[RowConnection[]]$Rows = $Table.Get({$_.Firstname -like 'Jaco*'})
```
when a `RowConenction` is created, getters and setters are created for each column and they feel just like hashtables. 

### Getter
when we use a column property without an assignment operator we are requesting data from the database. A *SELECT* statement is generated and executed and the data is dilivered back to the caller.
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

We can also get a list of columns
```powershell
[hashtable]$Values = $Row.get(@('Firstname','Lastname'))
```
Or just get all the columns
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
