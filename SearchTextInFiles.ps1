
# Search for a string in files
# -SimpleMatch -Pattern
# -include *.*

Get-ChildItem "C:\dev-project\CastIronIntegrations" -exclude *.par -recurse | Select-String -SimpleMatch "CommunityRestService" | Out-File SearchResults.txt