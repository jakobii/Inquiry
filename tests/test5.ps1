Import-Module "$psscriptroot\..\Inquiry.psm1" -Verbose

$db = [DatabaseConnection]::New('localhost','MHUSD')
$db.Debug = $true
$tb = $db.Table('dbo','Employees')
$row = $tb.Where(@{EmployeeID = 842975})
$row.BargainingUnit = 33