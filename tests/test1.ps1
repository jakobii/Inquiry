$ScriptPath = Get-Item -Path $PSScriptRoot
$ModuleRoot = $ScriptPath.Parent.FullName
$FlossPath = Join-Path -Path $ModuleRoot -ChildPath 'Inquiry.psm1'
Import-Module $FlossPath -Verbose


$ConfPath = Join-Path -Path $PSScriptRoot -ChildPath 'conf.secure.psd1'
$Conf = Import-PowerShellDataFile -Path $ConfPath

$DBParams = $Conf.SqlServerParams
$db = New-DatabaseConnection @DBParams

$db.DebugQuery = $true

$tb = $db.Table('dbo', 'stu', @('SC', 'SN'))


#$row = $tb.get(@{SC = 2; SN = 1666; })
#$backup = $row.get()
#$row.Del()
#$tb.Add($backup)
#$row = $tb.get(@{SC = 2; SN = 1666; })
#$row.Get() | ConvertTo-Xml
#$row.FN
#$row.FN = 'Sophia'

$rows = $tb.get({$psitem.FN -like 'Jacob*' -and $psitem.DEL -eq $false},@('FN','DEL'))
$rows[0].SN
$rows[0].SN = 290