
# Generate CRUD stored procedures code for the specified table
# Insert, Update, Delete, Select
#
# TODO - Skip Identity columns for insert 
#

param 
(
  [string] $ServerName,
  [string] $DatabaseName,
  [string] $TableName,
  [string] $ProcedureNamePrefix	
)

# Reference to Functions
. .\Functions.ps1

# --- Script

$OutputFileName = "CRUD_Procs_" + $TableName + ".sql"

Write-Host "ServerName = $ServerName"
Write-Host "DatabaseName = $DatabaseName"
Write-Host "TableName = $TableName"
Write-Host "OutputFileName = $OutputFileName"

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$server=New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName 
$database = $server.Databases[$DatabaseName] 

$ColumnList = ""
$ParameterDefinitionList = ""
$ParameterList = ""
$PrimaryKeyParameterList = ""
$PrimaryKeyWhereClause = ""
$UpdateColumnList = ""

$table = $database.Tables[$TableName]

foreach ($column in $table.columns) {

	$ParameterName = "@" + $column.name
	$ParameterDefinition = (ScriptColumnParameter $column.name $column.DataType.Name $column.DataType.MaximumLength $column.DataType.NumericPrecision $column.DataType.NumericScale)

	if ($column.InPrimaryKey) {
		if ($PrimaryKeyWhereClause -ne "") {
			$PrimaryKeyWhereClause += " and "
		}
		$PrimaryKeyWhereClause += "[" + $column.name + "] = " + $ParameterName

		if ($PrimaryKeyParameterList -ne "") {
			$PrimaryKeyParameterList += ",`r`n"
		}
		$PrimaryKeyParameterList += $ParameterDefinition
	} else {
		if ($UpdateColumnList -ne "") {
			$UpdateColumnList += ",`r`n"
		}
		$UpdateColumnList += "[" + $column.name + "] = " + $ParameterName
	}

	if ($ColumnList -ne "") 
	{
		$ColumnList += ", "
	}
	$ColumnList += "[" + $column.name + "]"

	if ($ParameterList -ne "") 
	{
		$ParameterList += ", "
	}
	$ParameterList += $ParameterName

	if ($ParameterDefinitionList -ne "") 
	{
		$ParameterDefinitionList += ",`r`n"
	}
	$ParameterDefinitionList += "`t" + $ParameterDefinition

}

$ProcSql = ""

# Insert Proc

$ProcedureName = $ProcedureNamePrefix + "Insert" + $TableName

$ProcSql += "`r`n"
$ProcSql += "if (object_id('" + $ProcedureName + "')) is not null`r`n"
$ProcSql += "	drop procedure [" + $ProcedureName + "]`r`n"
$ProcSql += "go`r`n"
$ProcSql += "create procedure [dbo].[" + $ProcedureName + "](`r`n"
$ProcSql += "$ParameterDefinitionList`r`n"
$ProcSql += ")`r`n"
$ProcSql += "as`r`n"
$ProcSql += "`r`n"
$ProcSql += "set nocount on`r`n"
$ProcSql += "`r`n"
$ProcSql += "insert into " + $TableName + "(" + $ColumnList + ")`r`n"
$ProcSql += "values (" + $ParameterList + ")`r`n"
$ProcSql += "`r`n"
$ProcSql += "return @@error`r`n"
$ProcSql += "go`r`n"
$ProcSql += "`r`n"

# Select Proc

$ProcedureName = $ProcedureNamePrefix + "Get" + $TableName

$ProcSql += "`r`n"
$ProcSql += "if (object_id('" + $ProcedureName + "')) is not null`r`n"
$ProcSql += "	drop procedure [" + $ProcedureName + "]`r`n"
$ProcSql += "go`r`n"
$ProcSql += "create procedure [dbo].[" + $ProcedureName + "](`r`n"
$ProcSql += "$PrimaryKeyParameterList`r`n"
$ProcSql += ")`r`n"
$ProcSql += "as`r`n"
$ProcSql += "`r`n"
$ProcSql += "set nocount on`r`n"
$ProcSql += "`r`n"
$ProcSql += "select " + $ColumnList + "`r`n"
$ProcSql += "from " + $TableName + "`r`n"
$ProcSql += "where " + $PrimaryKeyWhereClause + "`r`n"
$ProcSql += "`r`n"
$ProcSql += "return @@error`r`n"
$ProcSql += "go`r`n"
$ProcSql += "`r`n"

# Delete Proc

$ProcedureName = $ProcedureNamePrefix + "Delete" + $TableName

$ProcSql += "`r`n"
$ProcSql += "if (object_id('" + $ProcedureName + "')) is not null`r`n"
$ProcSql += "	drop procedure [" + $ProcedureName + "]`r`n"
$ProcSql += "go`r`n"
$ProcSql += "create procedure [dbo].[" + $ProcedureName + "](`r`n"
$ProcSql += "$PrimaryKeyParameterList`r`n"
$ProcSql += ")`r`n"
$ProcSql += "as`r`n"
$ProcSql += "`r`n"
$ProcSql += "set nocount on`r`n"
$ProcSql += "`r`n"
$ProcSql += "delete`r`n"
$ProcSql += "from " + $TableName + "`r`n"
$ProcSql += "where " + $PrimaryKeyWhereClause + "`r`n"
$ProcSql += "`r`n"
$ProcSql += "return @@error`r`n"
$ProcSql += "go`r`n"
$ProcSql += "`r`n"

# Update Proc

$ProcedureName = $ProcedureNamePrefix + "Update" + $TableName

$ProcSql += "`r`n"
$ProcSql += "if (object_id('" + $ProcedureName + "')) is not null`r`n"
$ProcSql += "	drop procedure [" + $ProcedureName + "]`r`n"
$ProcSql += "go`r`n"
$ProcSql += "create procedure [dbo].[" + $ProcedureName + "](`r`n"
$ProcSql += "$ParameterDefinitionList`r`n"
$ProcSql += ")`r`n"
$ProcSql += "as`r`n"
$ProcSql += "`r`n"
$ProcSql += "set nocount on`r`n"
$ProcSql += "`r`n"
$ProcSql += "update " + $TableName + "`r`n"
$ProcSql += "set `r`n"
$ProcSql += "$UpdateColumnList`r`n"
$ProcSql += "where " + $PrimaryKeyWhereClause + "`r`n"
$ProcSql += "`r`n"
$ProcSql += "return @@error`r`n"
$ProcSql += "go`r`n"
$ProcSql += "`r`n"

out-file -filepath $OutputFileName -inputobject $ProcSql -encoding ASCII

