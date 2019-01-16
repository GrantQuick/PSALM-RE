## PowerShell Sky API Library Module
A set of PowerShell cmdlets for interacting with the Blackbaud Sky API. Currently in early development.

## Getting Started
These instructions will describe how to set up and configure PSALM.

You will need to create and register an application with SKY API for the purpose of generating the requisite IDs used when making a connection to your data. A Blackbaud developer account is required in order to create an application. Once an application has been created, you will need the **client_id** of the application, the **client_secret** of your application, and your developer account's **api_subscription_key**.

### Setting up a Blackbaud developer account
Follow the instructions at https://apidocs.sky.blackbaud.com/docs/getting-started/ to create a developer account and acquire your **api_subscription key**.

### Creating an app
Follow the instructions at https://apidocs.sky.blackbaud.com/docs/createapp/ to register and activate your app. Registering your app will generate a **client_id** and **client_secret** for the app. Ensure that at least one of the Redirect URLs for the app you create is set to http://localhost/5000

### Configuring PSALM
1. Clone/Download the repo
2. Edit the Config.json file and complete each field, eg:
```json
{
  "key_dir":  "C:\\Users\\your_username\\Scripts\\SkyApi\\Key.json",
  "api_subscription_key":  "your api_subscription_key",    
  "client_id":  "your client_id",
  "client_secret":  "your client_secret"
}
```

### Using PSALM
1. In a PowerShell window, navigate to the psalm folder
2. Import the module
```PowerShell
Import-Module .\psalm.psm1
```
3. To connect to the API, in a PowerShell window, run 
```PowerShell
Connect-SkyApi
```
4. On first run, this cmdlet will prompt for your credentials and ask you to authorise PSALM for use with your data, and will download a key file with the authentication codes for later use. On subsequent runnings, the cmdlet will either refresh the authentication codes, or ask you to re-authorise if they have expired. You can force PSALM to aquire new keys by running:
```PowerShell
Connect-SkyApi -Force
```
5. You can now run any of the cmdlets, eg in order to update the Department and Campus for two education records, you can either pipe a group of IDs to the cmdlet or use:
```PowerShell
Update-Education -education_id 102034,76688 -Department 'Aberystwyth Business School' -Campus 'Awesome Campus'
```
6. You can also pipe the results of one cmdlet to another, useful for circumstances where you may have the lookup id (i.e. the RE constituent id) but not the unique system record id. So if you wanted to return the emails for a particular individual and only have the lookup id, you could use the following where 100604 is the lookup id (constituent id in the RE front end):
```PowerShell
Get-ConstituentFromLookup -search_text 100604 | Select-Object @{Name="constituent_id";Expression={$_.id}} | Get-EmailListSingle
```

## Supported Endpoints
| PS Cmdlet | Endpoint Implemented |
| --- | --- |
| Get-Action | Get Action |
| Get-ActionListSingle | Get Action list (Single constituent) |
| Get-AddressListSingle | Get Address list (Single constituent) |
| Get-AliasListSingle | Get Alias list (Single constituent) |
| Get-CommunicationPreferenceListSingle | Get Communication preference list (Single constituent) |
| Get-Constituent | Get Constituent |
| Get-ConstituentCodeListSingle | Get Constituent code list (Single constituent) |
| Get-ConstituentConsentList | Constituent consent list |
| Get-ConstituentFromLookup | Get Constituent (Search) |
| Get-ConstituentList | Get Constituent list |
| Get-EducationListSingle | Get Education list (Single constituent) |
| Get-EmailListSingle | Get Email address list (Single constituent) |
| Get-Note | Get Note |
| Get-NoteListSingle | Get Note list (Single constituent) |
| Get-OnlinePresenceListSingle | Online presence list (Single constituent) |
| Get-PhoneListSingle | Get Phone list (Single constituent) |
| Get-ProfilePicture | Get Profile picture |
| Get-RelationshipListSingle | Relationship list (Single constituent) |
| New-Alias | Post Alias |
| New-Email | Post Email address |
| New-OnlinePresence | Post Online presence |
| New-Phone | Post Phone |
| Update-Action | Patch Action |
| Update-Address | Patch Address |
| Update-Alias | Patch Alias |
| Update-CommunicationPreference | Patch Communication preference |
| Update-Constituent | Patch Constituent |
| Update-ConstituentCode | Patch Constituent code |
| Update-Education | Patch Education |
| Update-EmailAddress| Patch EmailAddress |
| Update-Phone | Patch Phone |

## Known Issues
The configuration file containing the api_subscription_key, client_id and client_secret is not secured and is a plain text file. It is advisable not to keep this file in an insecure location.

## Authors
* **Grant Quick** - *Initial work* - [GrantQuick](https://github.com/GrantQuick)

## Acknowledgments
* Thanks to [Stephen Owen](https://github.com/1RedOne) for the [PSWordPress](https://github.com/1RedOne/PSWordPress) repo and [blog](https://foxdeploy.com/2015/11/02/using-powershell-and-oauth/) for his excellent tutorial and examples of using PowerShell and oAuth.
