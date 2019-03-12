# Inquiry

A Light weight Sql Server ORM written in Powershell. The goal of this module is to make working with sql server *feel* like powershell.

- Tables should feel like [ArrayLists](https://docs.microsoft.com/en-us/dotnet/api/system.collections.arraylist)
- Rows should feel like [Hashtables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables)

## Getting Started
1) Connect to a Database

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

### `RowConnection`
A `RowConenction` **references** a row in a table using its primary key. they have Getters and Setters foreach column in the row.

#### Getters
using a column property without an assignment operator is a database request. A *SELECT* statement is generated and executed, then value is delivered back to the caller.

```powershell
$Row.Firstname | Out-Host   
#    |   ^    --->
#    |   |
#    |   |   MSSQL
#    |   +--[_____]
#    |      [_____]
#    +----> [_____]
```

We can also request multiple columns of data at once.

```powershell
# List of columns
[hashtable]$Values = $Row.get(@('Firstname','Lastname'))

# all columns
[hashtable]$Values = $Row.get()
```

#### Setters

When column properties are used with an assignment operator an *UPDATE* statment is generated and executed.

```powershell
$Row.Firstname = 'Jacob'
#    |       <---
#    |
#    |     MSSQL
#    |    [_____]
#    +--> [_____]
#         [_____]

```

We can also update multiple columns at once.
```powershell
$Row.Set(@{Firstname = 'Jacob'; Lastname = 'Ochoa'})
```
