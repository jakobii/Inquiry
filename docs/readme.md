![GitHub Logo](/docs/floss.png)
# Floss

A Light weight Sql Server ORM written in Powershell. The goal of this module is to make working with sql server feel like powershell.

## Dependencies
- [SqlServer](https://docs.microsoft.com/en-us/sql/powershell/download-sql-server-ps-module)


## Connect To A Database
start by creating a `DatabaseConnection`.
- ServerInstance: the IPAddress or DNS name of the server
- DatabaseName: The name of the database
- Username: A user that has at least *SELECT* privilages to the table you will be accessing
- Password: your super secret password
```powershell
$Db = New-DatabaseConnection -ServerInstance 'MySrv' -DatabaseName 'MyDb' -Username 'User' -Password 'pass' 

#or 

$Db = [DatabaseConnection]::New('MySrv','MyDb','User','pass')
```

## Connect To A Table
Then you need to create a `TableConnection`.
- SchemaName: namespace or owner of the table
- TableName: the name of the table
- PrimaryKeys: **IMPORTANT!** the column(s) that are used to uniquely identify rows in this table.

```powershell
[TableConnection]$Tb = $Db.Table('schema','table', @('primary','key','columns') )
```

```powershell
$TB = $DB.Table('dbo','Students', @('School','ID') )
```

## Connect To A Row
This is where the fun begins! we can create `RowConnection`'s in different ways, which will allow us to opertate on a single row without actually storing all its data in memory.

You can create new `RowConnection`'s by specifying the value of the rows primary keys in a `hashtable`.

```powershell
[RowConnection]$Row = $Tb.Get(@{School = 32; ID = 123456})
```

### Getting Many Rows
you can call the `Get()` method without any arguments. this will create a `RowConnection` for each row in the table.

```powershell
$Rows = $Tb.Get()
```
another option is to use your own sql scripts to filter the rows with the `Query()` method. it can be really fast because the filtering is being done server side.

The only small catch to using the `Query()` method is that the sql query must return the primary keys required to make a successful `RowConnection`. Infact your query *only needs* to return the primary keys becuase the `RowConnection` does not actually store the entire rows data in memory. see the *RowConnection* subheading under *More Advanced Stuff* for more info about what a `RowConnection` actually is.

*An error will be thrown if your query does not return the primary keys you specified durring the `tableConnection`'s creation.*

```powershell
$Studnets = @"
SELECT 
    [School], --PrimaryKey
    [ID]      --PrimaryKey

FROM [dbo].[Students]
WHERE
    [Active] = 1
    AND [Grade] > 5
"@
$Rows = $Tb.Query($Studnets)
```

We can also create `RowConnection`s with `scriptblock`'s! the sql query above and this `scriptblock` produce the same `RowConnection`'s

```powershell
$Rows = $Tb.Get({ $psitem.Active -eq $true -and $psitem.Grade -gt 5 })
```

the only downside is that unlike our `Query()` Method the `scriptblock` runs client side (in powershell) and not server side (Sql Server). By using `scriptblock`'s we trade speed for clearity, but also `scriptblock`'s can do things that are often very difficult to do in sql alone.

We can speed this process up by telling sql server to only forward the minimum columns required for our filter script to do its job. The `tableConnection`'s primary keys will be added to the list of columns automatically, but including them to the list won't cause an error.

```powershell
$Rows = $Tb.Get({ $psitem.Active -eq $true -and $psitem.Grade -gt 5 }, @('Active','Grade'))
```

The `Get()` method can also take an `array` of any suppoted standalone type, and returns an `array` of `RowConnection` respectively.

```powershell
$Studnets = @(
    # [hashtable]
    @{School = 32; ID = 100001}

    # [scriptblock]
    { $psitem.Active -eq $true -and $psitem.Grade -gt 5 }

    # [system.data.datarow]
    $( invoke-sqlcmd -query 'Select [School],[ID] FROM...' | where 'You' | Get-TheIdea )
)
$Rows = $Tb.Get($Studnets)
```

## Lets See Some Data Already!
Once you have a `RowConnection` you can ask for a single column of data with the `Get()` method and it will return only the value in that column.
```powershell
$value = $Row.Get('MyColumnName')
```

or you can use an `array` of column names and it will return a `hashtable`.
```powershell
$columns = @(
    'Firstname'
    'Lastname'
    'Birthdate'
    'Grade'
    'Teacher'
)
[hashtable]$values = $Row.Get($columns)

# do something with your hashtable
$values.Firstname + ' ' + $values.Lastname | out-host
```

Or you can leave the `Get()` method empty with no arguments and it will get the all the columns in the row!
```powershell
[hashtable]$value = $Row.Get()
```

Note that when you pass a `string` to the `Get()` method it will only return the value that is stored in a column. but when you pass the `Get()` method an `array` or *nothing at all* it will always return a `hashtable`.

## More Advanced Stuff
before we talk about things that can actually make changes to our database. lets make sure we understand what exactly this module is doing under the hood.

### Types
There are four main types in this module: 
- DatabaseConnection
- TableConnection
- ColumnDefinition
- RowConnection

When Creating a new `TableConnection` the `DatabaseConnection` object adds a refernce to itself inside the `TableConnection`. this means the `TableConnection` object does not store a unique/redundant copy of the `DatabaseConnection` object, which helps to keep it light weight and fast! 

The same applies to the `RowConnection` objects. when a `TableConnection` object creates a new `RowConnection` object it adds a referrence to itself inside to the `RowConnection`. 

the disagram below help to illistrate how these objects are related to each other in memory.
```
       [Db]
        /\
       /  \
      /    \
  [Tb]      [Tb]
   /\        /\
[Rw][Rw]  [Rw][Rw]

```

This means that if you edit a `DatabasConnection`'s properties, any child `TableConnection` or `RowConnection` will also see those changes.


### RowConnection
Note that the `RowConnection` is very lightwieght and does not actually store the entire row in memory. To illistrate this, if we pipe a `RowConnection` to `Out-host` we get something that looks like this.

```
[RowConnection]$Row | Out-Host

PrimaryKeys     Table
-----------     -----
{School, ID}    TableConnection
```
the only thing the `RowConnection` stores is a `hashtable` containing the rows primary keys, and a reference to its parent `TableConnection`.

So how does a `RowConnection` get data? well when we call a `Get()` on a RowConnection, it **generates sql** under the hood and querys the sql server and then returns the results to you. You can veiw the sql being generated by setting the `RowConnection`'s parent `DatabaseConnection` property `DebugQuery` to `$true`, which will cause the `DatabaseConnection` to output every sql command to the console before running them.

```powershell
$Db.DebugQuery = $true
$Row.Get(@('Firstname','Lastname')
```

The resulting sql that will be output to the console might look something like this.
```sql
SELECT 
    [Firstname], --columns requested
    [Lastname]
FROM [MyDb].[dbo].[Students] --parent db and tb
WHERE
    [School] = '32'     --primary keys
    AND [ID] = '123456';
```

### ColumnDefinition
when you create a `TableConnection` a sql query is performed which gets all the column information for that table. this information is stored in an `array` of `ColumnDefinition` objects. This information is mostly used for internal checks but you can view this information by calling the `Columns` property on the `TableConnection`.

```powershell
$Tb.Columns
```

This makes the `TableConnection` objects a little more heavy then te `RowConnection` objects. buts its a necessary step to ensure safe sql compilation under the hood.

## **SUPER IMPORTANT!** PrimaryKeys 
`RowConnection`'s have methods that generate sql under the hood which allows it to find, update, and delete data in the row. **Its success completely depends on *YOU* defining the primary keys correctly!** Before performing any operations on a table you need to be sure that the primary keys you specify when creating a `TableConnection` will **unique identify a single row**. 

Every generated query gets double checked to ensure that the column names you specified as primary keys are include in the sql `WHERE` statements. but it's still up to **YOU** to specify the primary keys correctly!

There are so many different techniques for creating unique constaints on a table that its difficult to imigine automating this proccess.

```powershell
#                                      IMPORTANT!
#                                        /   \
#                                       v     v
$Tb = $DB.Table('dbo','Students', @('School','ID') )
```

You can view the primary keys at any time by calling the `PrimaryKeys` property on the `TableConnection` or `RowConnection`.
```powershell
[array]$PKs = $Tb.PrimaryKeys # PK column names
[hashtable]$PKs = $Row.PrimaryKeys # PK column names and values
```


## Updating a Row
You can simplely pass just the name of a column and its new value to a `RowConnection` objects `Set()` method and it will generate and run the appropriate sql `UPDATE` statement under the hood.

```powershell
$Row.Set('MyColumnName','MyNewValue')
```

Or you can pass a hashtable of new values. the `Set()` method will handle the details for you!
```powershell
$Row.Set(@{Firstname = 'jimmy' ; Birthdate = '2000-01-01'})
```

# Inserting New Rows
You can use a `TableConnection` objects `Add()` method to add new rows to a table. You must at minimum include the primary keys for the new row.
```powershell
$Tb.Add(@{School = 32; ID = 100004})
```

Of course you can pass an `array` as well and include any other valid column inforation while doing so.
```powershell
$Studnets = @(
    @{School = 32; ID = 100001; Firstname = 'Bobby'}
    @{School = 32; ID = 100002; Firstname = 'Jen'}
    @{School = 32; ID = 100003; Firstname = 'Alex'}
)
$Tb.Add($Studnets)
```
keep in mind that you still have to fullfill any other constraint that your sql table may have in addition to unique constaints (e.g foreign key constraints). The `DatabaseConnection` object will throw any errors Sql Server forwards to it regarding this.


# Deleting Rows
You can Simply call the `DEl()` method on the `RowConnection`. Just remember to stop using the `RowConnection` afterwards, since the row it is configured to point to will no longer exist.

```powershell
$Row.Del()
```

You can also pass an `array` of `RowConnection`'s to a `TableConnection` objects `Del()` method for deletion.

```powershell
$Rows = $tb.Query("SELECT [ID] FROM [dbo].[Attendance] WHERE [Present] = 0 ") # :P
$Tb.Del($Rows) 
```

You can also pass an `array` of `hashtable`'s to a `TableConnection` objects `Del()` method(which could be the result of a privious `Get()`) as long as they contain the rows primary keys in them somewere.
```powershell
$Studnets = @(
    @{School = 32; ID = 100001}
    @{School = 32; ID = 100002}
    @{School = 32; ID = 100003}
)
$Tb.Del($Studnets) 
```