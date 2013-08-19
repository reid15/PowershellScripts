
# Generate C# code for the data access layer
# to call a stored procedure
#
# AccessMode: 1 = NonQuery : 2 = Scalar
param 
(
  [string] $ServerName,
  [string] $DatabaseName,
  [string] $ProcedureName,
  [string] $MethodName,
  [int] $AccessMode	 
)

# Reference to Functions
. .\Functions.ps1

# --- Script

$OutputFileName = "DataAccessProc_" + $MethodName + ".txt"

Write-Host "ServerName = $ServerName"
Write-Host "DatabaseName = $DatabaseName"
Write-Host "ProcedureName = $ProcedureName"
Write-Host "OutputFileName = $OutputFileName"
Write-Host "MethodName = $MethodName"

# Get column data
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$server=New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName 

# Validate Database Name
$database = $server.Databases[$DatabaseName] 
if ($database -eq $null)
{
	write-host "Database does not exist"
	exit
}

# Validate Proc name
$proc = $database.StoredProcedures[$ProcedureName]
if ($proc -eq $null)
{
	write-host "Procedure does not exist"
	exit
}

if ($AccessMode -eq "")
{
	write-host "Invalid AccessMode entry"
	exit
}

$InputParameters = ""
$ParameterList = ""

# Process each parameter

foreach ($Parameter in $proc.Parameters)
{
	$CDataType = (GetDataTypeSqlToCSharp $Parameter.DataType.Name)
	$ColumnName = $Parameter.name
	$ColumnName = $ColumnName -replace "@", ""
	$DataTypeAndName = $CDataType + " " + $ColumnName
	$ColumnNameCamel = (GetCamelCase $ColumnName)
	$DataTypeAndNameCamel = $CDataType + " " + $ColumnNameCamel

	if ($InputParameters -ne ""){
		$InputParameters += ",`r`n"
	}

	$InputParameters += $DataTypeAndNameCamel

	$ParameterList += "sqlCommand.Parameters.AddWithValue(`""
	$ParameterList += $Parameter.Name + "`", " + $ColumnNameCamel + ")"
	$ParameterList += ".SqlDbType = SqlDbType." + (GetSqlDbTypeFromSqlDataType $Parameter.DataType.Name) + ";`r`n"
}

# Access mode

$DataAccessCode = ""

switch ($AccessMode)
{
"1" # NonQuery
{
	$DataAccessCode = "sqlCommand.ExecuteNonQuery();"
}	
"2" 
{
$DataAccessCode = "object result = SqlHelper.ExecuteScalar(connectionString, CommandType.StoredProcedure, storedProcName, parameters.SqlParameters);`r`n"
	$DataAccessCode += "if (result == null)`r`n"
        $DataAccessCode += "{`r`n"
        $DataAccessCode += "throw new CasMidTierException(`"No Result`");`r`n"
     	$DataAccessCode += "}`r`n"    
	$DataAccessCode += "else`r`n"  
        $DataAccessCode += "{`r`n"
        $DataAccessCode += "return Convert.ToInt16(result);`r`n"
        $DataAccessCode += "}`r`n"   
}

default 
{
	write-host "Invalid AccessMode entry"
	exit
}

}

# Compile output

$OutputString += "public static void " + $MethodName + "(`r`n"
$OutputString += "$InputParameters`r`n"
$OutputString += ")`r`n"
$OutputString += "{`r`n"
$OutputString += "string connectionString = `"`";`r`n"
$OutputString += "string storedProcName = `"" + $ProcedureName + "`";`r`n"
$OutputString += "using (SqlConnection sqlConnection = new SqlConnection(connectionString))`r`n"
$OutputString += "{`r`n"
$OutputString += "sqlConnection.Open();`r`n"
$OutputString += "using (SqlCommand sqlCommand = new SqlCommand(storedProcName, sqlConnection))`r`n"
$OutputString += "{`r`n"
$OutputString += "sqlCommand.CommandType = CommandType.StoredProcedure;`r`n"
$OutputString += "sqlCommand.Parameters.Clear();`r`n"
$OutputString += "`r`n"

$OutputString += "$ParameterList"
$OutputString += "`r`n"
$OutputString += $DataAccessCode + "`r`n"
$OutputString += "}`r`n"
$OutputString += "}`r`n"
$OutputString += "}`r`n"
$OutputString += "`r`n"

out-file -filepath $OutputFileName -inputobject $OutputString -encoding ASCII
