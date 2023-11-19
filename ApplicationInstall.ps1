# Create an array whose elements are hashtables.
$appArray = (
  @{
    App         = ($thisApp = 'Firefox')
    App_source  = 'https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US'
    Destination = "c:\Deploy\$thisApp.exe"
    Argument    = '/S'
  },
  @{
    App         = ($thisApp = 'Chrome')
    App_source  = 'https://dl.google.com/tag/s/defaultbrowser/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi'
    Destination = "c:\Deploy\$thisApp.exe"
    Argument    = '/norestart /qn'
  }
)

foreach ($app in $appArray) {
  # Note how $app.<key> is used to refer to the entries of the hashtable at hand,
  # e.g. $app.App yields "Firefox" for the first hashtable.
  $installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -Match $app.App }
  $installed.displayname
  if ($installed.displayname -Match $app.App) {
    Write-Host "$($app.App) already installed."
  }
  else {
    if ((Test-Path $app.Destination) -eq $false) {
      New-Item -ItemType File -Path $app.Destination -Force
    }
    #install software
    Invoke-WebRequest $app.App_source -OutFile $app.Destination
    Start-Process -FilePath $app.Destination -ArgumentList $app.Argument -Wait
    #Delete installer
    Remove-Item -Recurse $app.Destination
  }
}