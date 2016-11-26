
# Script out database objects

param 
(
  [string] $InstanceName,
  [string] $DatabaseName,
  [string] $SchemaName,
  [string] $TableName
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null

$srv = New-Object "Microsoft.SqlServer.Management.SMO.Server" $InstanceName
$scripter = New-Object ("Microsoft.SqlServer.Management.SMO.Scripter")

# Set the scripting options
$Database = $srv.Databases[$DatabaseName]
$Table = $Database.Tables[$TableName, $SchemaName]

$scripter.Server = $srv
$options = New-Object ("Microsoft.SqlServer.Management.SMO.ScriptingOptions")

$options.ClusteredIndexes = $True
$options.Default = $True
$options.DriAll = $True
$options.FullTextCatalogs = $True
$options.FullTextIndexes = $True
$options.IncludeHeaders = $False
$options.NoCollation = $True
$options.NoFileGroup = $True
$options.NonClusteredIndexes = $True
$options.Permissions = $False
$options.PrimaryObject = $True
$options.ScriptData = $True 
$options.ScriptDrops = $False 
$options.ToFileOnly = $True
$options.Triggers = $True

$scripter.Options = $options

Write-Host $Table.Name
$OutputFileName = "Reference_" + $TableName + ".sql"
$scripter.Options.FileName = $OutputFileName
$scripter.EnumScript($Table)
