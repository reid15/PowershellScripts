
# Take the content of SQL scripts in the specified directory and combine into one file

param 
(
  [string] $directoryname
)

Get-ChildItem $directoryname -include *.sql -recurse | Get-Content | Out-File CombinedScripts.sql

write-host "Completed"
