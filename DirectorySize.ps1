
#Return all directories under a specified directory that are over a certain size

$Directory = "c:\Windows"
$dir = get-childitem $Directory 
foreach ($SubDir in $Dir) {
	$SubDir = $Directory + "\" + $SubDir
	$a = get-childitem $SubDir -recurse
	$Size = 0
	foreach ($i in $a) {
		$Size = $Size + $i.length
	}
	$Size = $Size / 1024
	$Size = [int] $Size
	if ($Size -gt 1000000) {
		write-host "Directory: " $SubDir " Size: " $Size "KB"
	}
}


