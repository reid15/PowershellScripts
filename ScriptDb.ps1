

# Script out database objects
# Tables, Stored Procedures, Functions, Table Types
# Didn't use 'ToFileOnly' option so that we could include header
# and because we need to add 'GO's to script 
# Batch Terminator option does not work 

param 
(
  [string] $server,
  [string] $database,
  [string] $OutputFileName
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null

$srv = New-Object "Microsoft.SqlServer.Management.SMO.Server" $server
$db = New-Object ("Microsoft.SqlServer.Management.SMO.Database")
$tbl = New-Object ("Microsoft.SqlServer.Management.SMO.Table")
$scripter = New-Object ("Microsoft.SqlServer.Management.SMO.Scripter") ($server)

# Set the scripting options
$db = $srv.Databases[$database]

$scripter.Server = $srv
$options = New-Object ("Microsoft.SqlServer.Management.SMO.ScriptingOptions")

$options.ClusteredIndexes = $True
$options.Default = $True
$options.DriAll = $True
$options.FullTextCatalogs = $True
$options.FullTextIndexes = $True
$options.NoCollation = $True
$options.NoFileGroup = $True
$options.NonClusteredIndexes = $True
$options.Permissions = $False
$options.PrimaryObject = $True
$options.ScriptData = $False # Set true to script out all data as well
$options.ScriptDrops = $False # Set to true to include SQL to drop object first
$options.Triggers = $True

$scripter.Options = $options

# Select which objects to script out

$DatabaseObjects = $db.Tables | where { -not($_.IsSystemObject)}
$DatabaseObjects += $db.UserDefinedTableTypes | where { -not($_.IsSystemObject)}
$DatabaseObjects += $db.UserDefinedFunctions | where { -not($_.IsSystemObject)}
$DatabaseObjects += $db.StoredProcedures | where { -not($_.IsSystemObject)}
$DatabaseObjects += $db.Views | where { -not($_.IsSystemObject)}

# Script Header
$OutputString = "-- Script Database`r`n"
$OutputString += "-- Server Name: $server`r`n"
$OutputString += "-- Database Name: $database`r`n"
$CurrentDate = Get-Date
$OutputString += "-- Date: $CurrentDate`r`n"
$OutputString += "`r`n"
  
#Script objects

foreach ($Object in $DatabaseObjects)  {
	Write-Host $Object.Name
	$Script = $scripter.Script($Object)
	foreach($s in $Script)
	{
		$OutputString += $s + "`r`n"
		$OutputString += "GO`r`n"
	}
}

out-file -filepath $OutputFileName -inputobject $OutputString -encoding ASCII
