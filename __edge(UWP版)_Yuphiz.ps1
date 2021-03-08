param (

)

$AppTheme=(Get-ItemProperty -path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme

$EdgeThemeValue = switch ($AppTheme) {
    1 { "0" }
    0 { "1" }
}

$null = reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" /v Theme /t REG_DWORD /d $EdgeThemeValue /f

exit

