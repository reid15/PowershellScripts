
# Common Functions for Powershell scripts

# --------------------------------------------------------------------------------------------
# Determine if a column should be nullable when generating Consolidation and Datamart tables -
# --------------------------------------------------------------------------------------------

function ColumnIsNullable
	([string] $ColumnName, [bool] $InPrimaryKey)
{
	if ($InPrimaryKey) {
		return $false
	}
	if ($ColumnName -eq "ModifiedBy") {
		return $false
	}
	if ($ColumnName -eq "ModifiedAt") {
		return $false
	}
	return $true
}

# --------------------------------------------------------------------------------------------
# Get the equivalent C# data type for a SQL data type ----------------------------------------
# --------------------------------------------------------------------------------------------

function GetDataTypeSqlToCSharp
	([string] $SqlDataType) 
{
	$OutputValue = $SqlDataType
	if ((IsSqlStringDataType $SqlDataType) -eq $true) {
		$OutputValue = "string"
	}
	if (($SqlDataType -eq "bit")) {
		$OutputValue = "bool"
	}
	if (($SqlDataType -eq "datetime") -or ($SqlDataType -eq "date")) {
		$OutputValue = "DateTime"
	}
	if (($SqlDataType -eq "smallint")) {
		$OutputValue = "short"
	}
	if (($SqlDataType -eq "uniqueidentifier")) {
		$OutputValue = "Guid"
	}
	if (($SqlDataType -eq "varbinary")) {
		$OutputValue = "byte[]"
	}
	return $OutputValue
}

# --------------------------------------------------------------------------------------------
# Get the C# SQL Type for a specified SQL data type ------------------------------------------
# --------------------------------------------------------------------------------------------

function GetCSharpSqlType
	([string] $SqlDataType) 
{
	$OutputValue = $SqlDataType
	if ((IsSqlStringDataType $SqlDataType) -eq $true) {
		$OutputValue = "SqlString"
	}
	if (($SqlDataType -eq "int")) {
		$OutputValue = "SqlInt32"
	}
	if (($SqlDataType -eq "bit")) {
		$OutputValue = "SqlBoolean"
	}
	if (($SqlDataType -eq "datetime") -or ($SqlDataType -eq "date")) {
		$OutputValue = "SqlDateTime"
	}
	if (($SqlDataType -eq "smallint")) {
		$OutputValue = "SqlInt16"
	}
	if (($SqlDataType -eq "uniqueidentifier")) {
		$OutputValue = "SqlGuid"
	}
	return $OutputValue
}

# --------------------------------------------------------------------------------------------
# Get the equivalent C# data type for a data object property ---------------------------------
# for a specified database column (data type and nullability) --------------------------------
# --------------------------------------------------------------------------------------------

function GetCSharpDataTypeFromSqlColumn
	([string] $SqlDataType, [bool] $IsNullable) 
{
	$OutputValue = $SqlDataType
	$NonNullableDataType = $false
	if (($SqlDataType -eq "nvarchar") -or ($SqlDataType -eq "nchar")) {
		$OutputValue = "string"
	}
	if (($SqlDataType -eq "bit")) {
		$OutputValue = "bool"
	}
	if (($SqlDataType -eq "datetime")) {
		$OutputValue = "DateTime"
		$NonNullableDataType = $true
	}
	if (($SqlDataType -eq "int")) {
		$OutputValue = "int"
		$NonNullableDataType = $true
	}
	if (($SqlDataType -eq "smallint")) {
		$OutputValue = "short"
		$NonNullableDataType = $true
	}
	if (($SqlDataType -eq "float")) {
		$OutputValue = "Double"
		$NonNullableDataType = $true
	}
	if (($SqlDataType -eq "uniqueidentifier")) {
		$OutputValue = "Guid"
	}
	if (($SqlDataType -eq "varbinary")) {
		$OutputValue = "byte[]"
	}
	if ($IsNullable -and $NonNullableDataType){
			$OutputValue = "Nullable<" + $OutputValue + ">"
		} 
	return $OutputValue
}

# --------------------------------------------------------------------------------------------
# Return the Camel Case version of a column name (ex. SiteTypeId => siteTypeId) --------------
# --------------------------------------------------------------------------------------------

function GetCamelCase
	([string] $ColumnName)
{
	$Length = $ColumnName.Length
	$FirstLetter = $ColumnName.substring(0, 1)
	$CamelCase = $FirstLetter.ToLower() + $ColumnName.substring(1)
	return $CamelCase
}

# --------------------------------------------------------------------------------------------
# When declaring a variable, return a value to use as the initial value ----------------------
# --------------------------------------------------------------------------------------------

function GetInitializationValue
	([string] $DataType)
{
	if ($DataType -eq "Guid")
	{
		return "Guid.NewGuid()"
	}
	if (($DataType -eq "int") -or ($DataType -eq "short"))
	{
		return "0"
	}
	if ($DataType -eq "bool")
	{
		return "true"
	}
	return "`"`"";
}


# --------------------------------------------------------------------------------------------
# Return the SqlDbType enum for the specified SQL Server data type ---------------------------
# To use for stored procedure parameter access code
# --------------------------------------------------------------------------------------------

function GetSqlDbTypeFromSqlDataType
	([string] $SqlDataType) 
{
	$OutputValue = $SqlDataType

	if (($SqlDataType -eq "nchar")) {
		$OutputValue = "NChar"
	}
	if (($SqlDataType -eq "nvarchar")) {
		$OutputValue = "NVarChar"
	}
	if (($SqlDataType -eq "int")) {
		$OutputValue = "Int"
	}
	if (($SqlDataType -eq "bit")) {
		$OutputValue = "Boolean"
	}
	if (($SqlDataType -eq "datetime") -or ($SqlDataType -eq "date")) {
		$OutputValue = "DateTime"
	}
	if (($SqlDataType -eq "smallint")) {
		$OutputValue = "Int16"
	}
	if (($SqlDataType -eq "uniqueidentifier")) {
		$OutputValue = "Guid"
	}
	return $OutputValue
}

# --------------------------------------------------------------------------------------------
# For the given SQL Data Type, return true if it is a string type (like nvarchar, char, etc.) 
# --------------------------------------------------------------------------------------------

function IsSqlStringDataType
	([string] $DataType)
{
	if (($DataType -eq "nvarchar") -or ($DataType -eq "nchar") -or ($DataType -eq "varchar") -or ($DataType -eq "char")) 
	{
		return $true
	}
	return $false
}

# --------------------------------------------------------------------------------------------
# Build the SQL to create the specified column -----------------------------------------------
# --------------------------------------------------------------------------------------------

function ScriptColumn 
	([string] $ColumnName, [string] $DataType, [int] $DataLength, [bool] $Nullable, [int] $NumericPrecision, [int] $NumericScale) 
{
	$OutputString = "[" + $ColumnName + "] " + $DataType
	if (($DataType -eq "nvarchar") -or ($DataType -eq "varbinary")) {
		if ($DataLength -eq -1) {
			$OutputString += "(max)"
		} else {
			$OutputString += "(" + $DataLength + ")"
		}
	}
	if ($Nullable -eq $true) {
		$OutputString += " null"
	} else {
		$OutputString += " not null"
	}
	return $OutputString
}

# --------------------------------------------------------------------------------------------
# Build the SQL to create a parameter for the specified column -------------------------------
# --------------------------------------------------------------------------------------------

function ScriptColumnParameter
	([string] $ColumnName, [string] $DataType, [int] $DataLength, [int] $NumericPrecision, [int] $NumericScale) 
{
	$OutputString = "@" + $ColumnName + " " + $DataType
	if (((IsSqlStringDataType $DataType) -eq $true) -or ($DataType -eq "varbinary")) {
		if ($DataLength -eq -1) {
			$OutputString += "(max)"
		} else {
			$OutputString += "(" + $DataLength + ")"
		}
	}
	
	return $OutputString
}
