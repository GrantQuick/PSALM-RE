# Import the module
Import-Module .\psalm.psm1

# Connect to the API
Connect-SkyApi

# Get all actions for a specific lookup id (RE constituent id)
Get-ConstituentFromLookup 100637 | Select-Object @{Name="constituent_id";Expression={$_.id}} | Get-ActionListSingle

# View profile pics for specific lookup id (RE constituent id)
Get-ConstituentFromLookup 100604 | Select-Object @{Name="constituent_id";Expression={$_.id}} |  Get-ProfilePicture -view_image $true

# Get the communication preferences for a specific lookup id (RE constituent id)
Get-ConstituentFromLookup 100604 | Select-Object @{Name="constituent_id";Expression={$_.id}} | Get-CommunicationPreferenceListSingle

# Get all the aliases for a specific lookup id (RE constituent id)
Get-ConstituentFromLookup 100604 | Select-Object @{Name="constituent_id";Expression={$_.id}} | Get-AliasListSingle

# Get online presences
Get-ConstituentFromLookup 103156 | Select-Object @{Name="constituent_id";Expression={$_.id}} | Get-OnlinePresenceListSingle

# Add a new online presence
Get-ConstituentFromLookup 103156 | Select-Object @{Name="constituent_id";Expression={$_.id}} | New-OnlinePresence -address "https://www.linkedin.com/in/grant-quick-9195a9132/" -type "LinkedIn" -primary 1

# Add a new phone
Get-ConstituentFromLookup 103156 | Select-Object @{Name="constituent_id";Expression={$_.id}} | New-Phone -number "01234-56-7890" -type "Phone"

# Add a new email
Get-ConstituentFromLookup 103156 | Select-Object @{Name="constituent_id";Expression={$_.id}} | New-Email -address "quickie@outlook.com" -type "Email"

# Add a new alias
Get-ConstituentFromLookup 103156 | Select-Object @{Name="constituent_id";Expression={$_.id}} | New-Alias -name "1" -type "Registration Number"

# Delete a specific alias 
Get-ConstituentFromLookup 100604 | 
    Select-Object @{Name="constituent_id";Expression={$_.id}} | 
    Get-AliasListSingle | 
    Where-Object -Property "type" -Match "Alumni Email" |
    Select-Object @{Name="alias_id";Expression={$_.id}} |
    Remove-Alias
