# Azure Stack Hub Installation Tools
This tool helps automate a few tasks during Azure Stack Hub deployment

## Installation

Clone the repo
Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'PEP_ip'

## Usage

Pupulate details.json file with your specific information. This is just for deployment purposes assuming deployment is being done with some default credentials.
Customer must change credentials on successful deployment.
Reset values of details.json file at the end of each deployment.
All data security rules apply.

Run powershell script './main.ps1
Follow prompt to execute required task

## Contributing

Pull Requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Credits
AzureStack-Tools-az is provided [Here](https://github.com/Azure/AzureStack-Tools). Please ensure you are using the latest tool.

## License
[MIT](https://choosealicense.com/licenses/mit/)