
# Take all files in a directory, serialize to binary and insert into the database

$Path = "C:\Files"
$DBConnection = "<DB Connection String>"

function ByteArrayToHexString(
	[byte[]] $inputByteArray
) {
$OutputString = "0X"
foreach ($byte in $inputByteArray) {
	$OutputString = $OutputString + ($byte.ToString("X2"))
}
return $OutputString 
}

foreach ($File in Get-ChildItem $Path)
{
Write-Host $File
$FullPath = $Path + "\" + $File
$SqlFileName = $File -replace "'", "''"

[byte[]]$FileContent = Get-Content $FullPath -Encoding byte 

Write-Host "Start to byte"
$ByteString = ByteArrayToHexString($FileContent)
Write-Host "End byte"

$cn = new-object system.data.SqlClient.SqlConnection($DBConnection);
$cn.Open()
$sql = "insert into Z_DocumentImport (BinaryData) values ($ByteString)"
$cmd = new-object System.Data.SqlClient.SqlCommand ($sql, $cn)
$dr = $cmd.ExecuteNonQuery()
$cn.Close()

}
