# Debian Packaging Release

## Building the Debian package

Execute the following command from the root directory of this repository:

``` bash
./release/debian/pipeline.sh
```

Output will be sent to `./output/debian`

## Dev Installation and Verification

``` bash
./release/debian/pipeline-test.sh
```

## Release Install/Update/Uninstall Steps

> **Note:** Replace `{{HOST}}` and `{{CLI_VERSION}}` with the appropriate values.

### Install go-mssqltools with apt (Ubuntu or Debian)

1. Get packages needed for the install process:

```bash
sudo apt-get update
sudo apt-get install gnupg ca-certificates curl apt-transport-https lsb-release
```

2. Download and install the signing key:

```bash
sudo curl -sL http://{{HOST}}/browse/repo/ubuntu/dpgswdist.v1.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/dpgswdist.v1.asc.gpg > /dev/null
```

3. Add the go-mssqltools repository information:

```bash
sudo echo "deb [trusted=yes arch=amd64] http://{{HOST}}/browse/repo/ubuntu/go-mssqltools mssql main" | tee /etc/apt/sources.list.d/go-mssqltools.list
```

4. Update repository information and install go-mssqltools:

```bash
sudo apt-get update
sudo apt-get install go-mssqltools
```

5. Verify installation success:

```bash
sqlcmd --version
```

### Update

1. Upgrade go-mssqltools only:

```bash
sudo apt-get update && sudo apt-get install --only-upgrade -y go-mssqltools
```

### Uninstall

1. Uninstall with apt-get remove:

```bash
sudo apt-get remove -y go-msqsltools
```

2. Remove the go-mssqltools repository information:

> Note: This step is not needed if you plan on installing go-mssqltools in the future

```bash
sudo rm /etc/apt/sources.list.d/go-mssqltools.list
```

3. Remove the signing key:

```bash
sudo rm /etc/apt/trusted.gpg.d/dpgswdist.v1.asc.gpg
```

4. Remove any unneeded dependencies that were installed with go-mssqltools:

```bash
sudo apt autoremove
```


