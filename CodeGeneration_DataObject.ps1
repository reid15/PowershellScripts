
# Generate a simple C# data object
# from the specified table

param 
(
  [string] $ServerName,
  [string] $DatabaseName,
  [string] $TableName	 
)

# Reference to Functions
. .\Functions.ps1

# --- Script

$OutputFileName = "DataObject_" + $TableName + ".txt"

Write-Host "ServerName = $ServerName"
Write-Host "DatabaseName = $DatabaseName"
Write-Host "TableName = $TableName"	
Write-Host "OutputFileName = $OutputFileName"

# Get column data
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$server=New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName 

$database = $server.Databases[$DatabaseName] 
if ($database -eq $null)
{
	write-host "Database does not exist"
	exit
}

$table = $database.Tables[$TableName]
if ($table -eq $null)
{
	write-host "Table does not exist"
	exit
}
	
$PublicProperties = ""
$CreateParameters = ""
$Initialize = ""

foreach ($column in $table.Columns) 
{
	$CDataType = ""
	$ColumnName = ""
	$DataTypeAndName = ""
	$ColumnNameCamel = ""
	$DataTypeAndNameCamel = ""

	# If the column is nullable, use SQL types
	if ($column.nullable){
		$CDataType = (GetCSharpSqlType $column.DataType.Name)
	} else {
		$CDataType = (GetDataTypeSqlToCSharp $column.DataType.Name)
	}
	$ColumnName = $column.name
	$DataTypeAndName = $CDataType + " " + $ColumnName
	$ColumnNameCamel = (GetCamelCase $ColumnName)
	$DataTypeAndNameCamel = $CDataType + " " + $ColumnNameCamel

	$PublicProperties += "public " + $DataTypeAndName + ";`r`n"

	if ($CreateParameters -ne ""){
		$CreateParameters += ",`r`n"
	}
	$CreateParameters += $DataTypeAndNameCamel

	$Initialize += $ColumnName + " = " + $ColumnNameCamel + ";`r`n"
}

# Compile output

$OutputString += "`r`n"
$OutputString += "[Serializable]`r`n"
$OutputString += "public class $TableName`r`n"
$OutputString += "{`r`n"
$OutputString += "$PublicProperties"
$OutputString += "`r`n"
$OutputString += "public $TableName(`r`n"
$OutputString += "$CreateParameters)`r`n"
$OutputString += "{`r`n"
$OutputString += "$Initialize"
$OutputString += "}`r`n"
$OutputString += "}`r`n"
$OutputString += "}`r`n"
$OutputString += "`r`n"

out-file -filepath $OutputFileName -inputobject $OutputString -encoding ASCII
