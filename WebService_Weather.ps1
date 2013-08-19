
# Call Web service to get weather information
# Go to http://w1.weather.gov/xml/current_obs/
# to lookup the code for an area
# KATL = Atlanta, GA, USA

$address= "http://www.weather.gov/xml/current_obs/KATL.xml"

$wc = new-object system.net.webclient
$result = $wc.DownloadString($address)
$xmlresult = [xml]$result

# To list all properties
#$xmlresult.current_observation | Get-Member -MemberType Property

Write-Host "Location: " $xmlresult.current_observation.location
Write-Host "Observation Time: " $xmlresult.current_observation.observation_time
Write-Host "Weather: " $xmlresult.current_observation.weather
Write-Host "Temperature: " $xmlresult.current_observation.temperature_string
Write-Host "Wind: " $xmlresult.current_observation.wind_string


