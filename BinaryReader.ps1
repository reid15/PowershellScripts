
# Read a binary record (image, pdf, etc) from the database and save it to a file

$DBConnection = "<DB Connection String>"
$sql = "select BinaryContent from Table where RecordId = 1"
$OutputFile = "Output.pdf"

$cn = new-object system.data.SqlClient.SqlConnection($DBConnection);
$cn.Open()
$cmd = new-object System.Data.SqlClient.SqlCommand ($sql, $cn)
[byte[]]$binary = $cmd.ExecuteScalar()
$cn.Close()

[System.IO.FileStream]$fs = New-Object System.IO.FileStream($OutputFile, [System.IO.FileMode]::OpenOrCreate)
$fs.Write($binary, 0, $binary.Length);
$fs.Close()




