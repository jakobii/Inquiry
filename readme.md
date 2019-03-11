# Inquiry

A Light weight Sql Server ORM written in Powershell. The goal of this module is to make working with sql server *feel* like powershell.

- Tables should feel like [ArrayLists](https://docs.microsoft.com/en-us/dotnet/api/system.collections.arraylist) that are *easy* to filter, add to, and remove from.
- Rows should feel like [Hashtables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables) with properties that are *easy* to access and update.

## Getting Started
1) Connect to a Database
Connecting to a database is pretty standard.

```powershell
#Create A DatabaseConnection
[DatabaseConnection]$Database = New-DatabaseConnection -ServerInstance 'MySrv' -DatabaseName 'MyDb' -Username 'User' -Password 'pass' 

# Output generated SQL to the console.
$Database.DebugQuery = $true
```

2) Connect to a Table
   
```powershell
# Table( Schema, Table, PrimaryKey(s) 
[TableConnection]$Table = $Database.Table('dbo', 'Students', @('ID'))
```

3) Connect to a Row. 
```powershell
[RowConnection]$Row = $Table.Get(@{ID = 123456})

# or 
[RowConnection[]]$Rows = $Table.Get({$_.Firstname -like 'Jaco*'})
```
### `RowConenction`
A `RowConenction` **references** a row using its primary key. Getters and Setters are generated for each column in the row, they look like properties on an object. 

#### Getters
when we use a column property without an assignment operator we are requesting data from the database. A *SELECT* statement is generated and executed, then value is delivered back to the caller.

```powershell
$Row.Firstname | Out-Host   
#    |   ^    --->
#    |   |
#    |   |   MSSQL
#    |   +--[_____]
#    |      [_____]
#    +----> [_____]
```

We can also get a list of columns. The values are mapped to the column names in a hashtable.
```powershell
[hashtable]$Values = $Row.get(@('Firstname','Lastname'))
```
Getting the entire row as a hashtable.
```powershell
[hashtable]$Values = $Row.get()
```

#### Setters
When the `RowConnection` column properties are used with an assignment operator, an *UPDATE* statment is generated and executed.
```powershell
$Row.Firstname = 'Jacob'
#    |       <---
#    |
#    |     MSSQL
#    |    [_____]
#    +--> [_____]
#         [_____]

```
We can also update a row with a hashtable.
```powershell
$Row.Set(@{Firstname = 'Jacob'; Lastname = 'Ochoa'})
```
