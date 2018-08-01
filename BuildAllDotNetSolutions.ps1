
# Build all .Net solutions in this directory and sun-directories

$MsBuildPath = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
$BuildOptions = " /p:Configuration=Debug /t:Clean,Build /nologo /verbosity:minimal" 
# nologo = No splash and copyright info output
# verbosity = amount of info to output

$Solutions = get-childitem -filter "*.sln" -recurse 
foreach($Solution in $Solutions)
{
	$SolutionPath = $Solution.FullName
	Write-Host "Starting: $SolutionPath"
	$Arguments = $SolutionPath + $BuildOptions
	$Process = Start-Process -FilePath $MsBuildPath -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
	if($Process.ExitCode -ne 0)
	{
		Write-Host "Build Failed. Press any key to continue"
		Write-Host $SolutionPath
		Read-Host
	}
}

# -NoNewWindow : Don't open a new window for each process
# -Wait : Finish one build before starting the next one
# -PassThru : To return a process object so we can read the Exit Code
