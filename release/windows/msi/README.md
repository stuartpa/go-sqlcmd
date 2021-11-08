# Windows MSI

This document provides instructions on creating the MSI.

## Prerequisites

1. WIX Toolset
2. Turn on the '.NET Framework 3.5' Windows Feature (required for WIX Toolset)
3. Install [WIX Toolset build tools](http://wixtoolset.org/releases/) if not already installed
4. Install [Microsoft Build Tools 2015](https://www.microsoft.com/en-us/download/details.aspx?id=48159)

## Building

1. Set the `CLI_VERSION` and `GO_MSSQLTOOLS_PACKAGE_VERSION` environment variable
2. Run `release\windows\scripts\build.cmd`
3. The unsigned MSI will be in the `.\release\windows\out` folder

> **Note:** For `building step 1.` above set both env-vars to the same version-tag for the immediate, this will consolidated in the future.

## Release Install/Update/Uninstall Steps

> **Note:** Replace `{{HOST}}` and `{{CLI_VERSION}}` with the appropriate values.

### Install GO MSSQL TOOLS CLI on Windows

The MSI distributable is used for installing or updating the Go MSSQL Tools CLI on Windows. 

[Download the MSI Installer](http://{{HOST}}/go-mssqltools-{{CLI_VERSION}}.msi)

When the installer asks if it can make changes to your computer, click the `Yes` box.

### Update

Once removed, [Install Go MSSQL Tools CLI on Windows](#install-go-mssqltools-on-windows)

### Uninstall

You can uninstall the Go MSSQL Tools CLI from the Windows _Apps and Features_ list. To uninstall:

| Platform      | Instructions                                           |
| ------------- |--------------------------------------------------------|
| Windows 10	| Start > Settings > Apps                                |
| Windows 8     | Start > Control Panel > Programs > Uninstall a program |


The program to uninstall is listed as **Go MSSQL Tools CLI** . Select this application, then click the `Uninstall` button.
