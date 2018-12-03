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
2. Import the module
```PowerShell
Import-Module .\psalm.psm1
```
3. Edit the Config.json file and complete each field, eg:
```json
{
  "key_dir":  "C:\\Users\\your_username\\Scripts\\SkyApi\\Key.json",
  "api_subscription_key":  "your api_subscription_key",    
  "client_id":  "your client_id",
  "client_secret":  "your client_secret"
}
```

### Using PSALM
* To connect to the API, in a PowerShell window, run 
```PowerShell
Connect-SkyApi
```
* Only a handful of endpoints have been implemented so far.
* To update an existing education record (for example), you will need the unique system ID of the record(s) you wish to change. Using PSALM, you can update one education record, or multiple education records at once if all records require the same change.
* For example, in order to update the Department and Campus for two education records, you can either pipe a group of IDs to the cmdlet or use:
```PowerShell
Update-Education -ID 102034,76688 -Department 'Aberystwyth Business School' -Campus 'Awesome Campus'
```

## Known Issues
The configuration file containing the api_subscription_key, client_id and client_secret is not secured and is a plain text file. It is advisable not to keep this file in an insecure location.

## Authors
* **Grant Quick** - *Initial work* - [GrantQuick](https://github.com/GrantQuick)

## Acknowledgments
* Thanks to [Stephen Owen](https://github.com/1RedOne) for the [PSWordPress](https://github.com/1RedOne/PSWordPress) repo and [blog](https://foxdeploy.com/2015/11/02/using-powershell-and-oauth/) for his excellent tutorial and examples of using PowerShell and oAuth.
