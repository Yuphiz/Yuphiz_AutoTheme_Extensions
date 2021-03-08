param (

)

$AppTheme=(Get-ItemProperty -path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme

$officevalue = switch ($AppTheme) {
    1 { "00000000" }
    0 { "04000000" }
}


$null = reg add "HKCU\Software\Microsoft\Office\16.0\Common\Roaming\Identities\38acb39eb9ec16b1_LiveId\Settings\1186\{00000000-0000-0000-0000-000000000000}" /v Data /t REG_BINARY /d $officevalue /f
exit

