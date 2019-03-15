

class TSQL {
    ToString(){ throw 'subclass has not implemented ToString() Method.' }
}


# SELECT
class SELECT : TSQL {}
class ColumnName : SELECT {
    [string]$Name
    ColumnName([string]$Name){
        $this.Name = $Name
    }
    [string] ToString(){
        return "'" + $this.Name + "'"
    }
}
class ColumnExpression : SELECT {
    [string]$Expression  
    ColumnExpression([string]$Expression ){
        $this.Expression = $Expression
    }
    [string] ToString(){
        return "(" + $this.Expression + ")"
    }
}


[ColumnName]$t = 'blah'

$t.ToString()


# FROM
class FROM : TSQL {}
class TableName : FROM {
    [string]$Database
    [string]$Schema
    [string]$Table
    TableName(){

    }

}
class TableExpression : FROM {}

# WHERE
class WHERE : TSQL {}
class ColumnCondition : WHERE {}