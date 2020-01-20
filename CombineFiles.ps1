
# Take the content of files in the specified directory and combine into one file

param 
(
  [string] $directoryname
)

Write-Host $directoryname

Get-ChildItem $directoryname -include *.txt -recurse | Get-Content | Out-File combined.txt2