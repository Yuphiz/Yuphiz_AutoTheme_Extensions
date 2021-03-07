<#
.����
�ű�����ֽ�߼���_Yuphiz 
�汾��v0.1
���ߣ�Yuphiz
���ű����԰��� Windows10 �Զ��л���ǳɫ����ı�ֽ
���ô˽ű����·��ɲ����������ģ����뱾�����޹�
�˽ű���ɲ��� GPL-3.0-later Э��
#>

param (

)

function get-ScheduledTask-State {
      param (
            $TaskName,
            $RootPath = "\"
      )                  
      foreach ($OneOf in $TaskName) {
            $service = new-object -com("Schedule.Service")
            $service.connect()
            $rootFolder = $service.Getfolder($RootPath)
            $taskDefinition = $service.NewTask(0)
            if ($(try{$rootFolder.gettask($OneOf).enabled} catch{$false})){
                  return $True
            }
      }
      return $False   
}


$OthersTaskArray= "ʵʱ��ֽ\��¼",`
                  "ʵʱ��ֽ\����", `
                  "ʵʱ��ֽ\�ճ�ǰ��", 
                  "ʵʱ��ֽ\����ǰ��", `
                  "ʵʱ��ֽ\�ռ�", `
                  "ʵʱ��ֽ\ҹ��", `
                  "ʵʱ��ֽ\�����ļ���֧��", `
                  "Windows�۽���ֽ\Windows�۽���ֽ", `
                  "ÿ��bing��ֽ\ÿ��bing��ֽ", `
                  "ÿ��bing��ֽ\��¼", `
                  "ÿ��bing��ֽ\����"
$IsHaveOtherWallpaperScript = get-ScheduledTask-State $OthersTaskArray "\YuphizScript\$env:username"

if ($IsHaveOtherWallpaperScript) { exit } #�������������ֽģ�飬��ֱ���˳���ִ������ĸ�����ֽ

#�ű�����·�������Ϊ����ѡ��ǰ����·��
$PathScriptWork = $PSScriptRoot;if ($PathScriptWork -eq "") {$PathScriptWork=(get-location).path}
$title = "�Զ�������ɫ"
$popup=new-object -comobject wscript.shell

$FileConfig = "$PathScriptWork\��ֽ�߼���_Yuphiz.Json"
if (!(Test-Path $FileConfig)){
      @'
{
      "��ע":"��ַ·���ĵ�б��(\)Ҫд��˫б��(\\)"
,     "�滻ͼƬ��ʽ":"���ֽ��"
,     "����ֽ��ѡ��":{
             "ǳɫ�����ֽ":""
      ,      "��ɫ�����ֽ":""
      }
,     "���ֽ����ֲ�ѡ��":{
             "��ֽ��·��":""
      ,      "���ֽ��ѡ��":{
                  "�����ֽ��":"��"
            }
      ,      "�ֲ�ѡ��":{
                  "�ֲ�ʱ��_��":7200
            }
      }
,     "Ĭ�ϱ�ֽ���϶�":"����"
,     "�Զ����ֽ���϶�":{
            "untitle":"���"
      }
,     "֧��ͼƬ����":[".jpg",".jpeg",".png",".bmp"]
}
'@ | set-content $FileConfig
}
try {
      $Config=get-content $FileConfig | ConvertFrom-Json
}catch{
      $null = $popup.popup("      $FileConfig `n`r
$($error[0])",0,"�����ļ�����",16);exit
}

# �滻ͼƬ��ʽ��0Ϊ����ͼƬ��ֻ���ճ������滻����/ҹ��ͼƬ��1Ϊ��ֽ�飬ÿ���滻��ͬ���ͼƬ��2Ϊ����ֲ��������ֲ������ͼƬ��ҹ���ֲ�ҹ���ͼƬ������ֻ���´�����ʱ��Ч��Ҳ�����Ҽ�powershell����������Ч
$WallpaperRunBy = $Config.�滻ͼƬ��ʽ

# �滻ͼƬ��ʽ��Ϊ 0 ʱ��Ч�����ã�ֻ�����ճ�����ʱ���ճ�����ͼƬ
#����ǳɫ�����ֽ
$DayWallpaper = $Config.����ֽ��ѡ��.ǳɫ�����ֽ
#������ɫ�����ֽ
$NightWallpaper = $Config.����ֽ��ѡ��.��ɫ�����ֽ


# �滻ͼƬ��ʽ��Ϊ 1 ���� 2 ʱ��Ч�����ã��������ճ�����ʱ���ճ�����ͼƬ������:
# ����Ϊ 1 ʱ ÿ���һ���ճ�����ͼƬ���Զ�ѡ�񣬼��� 0 �Ļ����ϣ�ÿ�컻һ��ͼƬ����Ҫ�ļ���֧��
# ����Ϊ 2 ʱ �����ֲ������ͼƬ��ҹ���ֲ�ҹ���ͼƬ����Ҫ�ļ���֧��
# �ճ�����ͼƬ���ļ��У���ֵ��Ϊ��Ŀ¼
$WallpaperFolder = $Config.���ֽ����ֲ�ѡ��.��ֽ��·��

# ˳ʱ�ֲ��ļ��飬0Ϊ˳��1Ϊ���
$TurnOnRandomFolder = $Config.���ֽ����ֲ�ѡ��.���ֽ��ѡ��.�����ֽ��

# �滻ͼƬ��ʽ��Ϊ 2 ʱ��Ч������
#�ֲ����ڣ���λ���룬�������� 60 s
$CarouselTime = $Config.���ֽ����ֲ�ѡ��.�ֲ�ѡ��.�ֲ�ʱ��_��

#֧��ͼƬ����
$FormatSupported = $Config.֧��ͼƬ����

#Ĭ�ϱ�ֽ���϶�
$defaultWallpaperStyle = $Config.Ĭ�ϱ�ֽ���϶�

#�����ֽ���϶ȣ��������������ļ����µı�ֽ��������_1��_2���������Զ���ķ�ʽ��Ϊ��ֽ
$WallpaperStyle = $Config.�Զ����ֽ���϶�




$PathExtensionsLeaf = Split-Path $PathScriptWork
$VbsLauncher = "$PathExtensionsLeaf\�Զ�������ɫ_��������.vbs"
while ((Test-Path($VbsLauncher)) -eq $False) {
      $PathExtensionsLeaf = Split-Path $PathExtensionsLeaf
      $VbsLauncher = "$PathExtensionsLeaf\�Զ�������ɫ_��������.vbs"
}

switch ($WallpaperRunBy) {
      0 { 
            if ($DayWallpaper -eq ""){
                  $DayWallpaper = "$PathScriptWork\��ֽ��\surface\Surface_Laptop_3_03_1.jpg"
            }
            if ($NightWallpaper -eq ""){
                  $NightWallpaper = "$PathScriptWork\��ֽ��\surface\Surface-Wallpaper-4500x3000-67826_2.jpg"
            }
       }
      {$_ -eq 1 -or $_ -eq 2} {
            if ($carouselTime -le 60 ){ $carouselTime = 60 }
            if ($WallpaperFolder -eq "" ) {
                  $WallpaperFolder = "$PathScriptWork\��ֽ��"
                  if (!(Test-Path $WallpaperFolder)){
                        ni $WallpaperFolder -ItemType Directory -Force
                  }
            }else{
                  if (!(Test-Path $WallpaperFolder)){
                       $null = $popup.Popup("   �Ҳ���·�� ,���������� `n`r
    $WallpaperFolder ",0,"����",16 + 4096)
                        exit
                  }
            }
      }
      default {
            $null = $popup.popup("   �滻ͼƬ��ʽ��ֵֻ����0��1��2 `n`r
    0������ֽ�飬ֻ���ճ������滻����/ҹ��ͼƬ��`n`r
    1�����ֽ�飬ÿ���滻��ͬ���ͼƬ��`n`r
    2������ֲ��������ֲ������ͼƬ��ҹ���ֲ�ҹ���ͼƬ
    ",0,"����",16 + 4096)
            exit
      }
}



$SystemTheme=(Get-ItemProperty -path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize").SystemUsesLightTheme
$AppTheme=(Get-ItemProperty -path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme
$LastWallpaper = (Get-ItemProperty -path "registry::HKEY_CURRENT_USER\Control Panel\Desktop").wallpaper

      
function WirteOrReadDataFromSchtask {
      param (
            $WirteOrRead,
            $Data = $null,
            $RepetitionInterval = $null
      )
      
      $service = new-object -com("Schedule.Service")
      $service.connect()
      $rootFolder = $service.Getfolder("\YuphizScript")
                  
      $taskDefinition = $service.NewTask(0)
                  
      if ($WirteOrRead -eq "Write"){
            $Settings = $taskDefinition.Settings
            $Settings.StartWhenAvailable = $True
            $Settings.DisallowStartIfOnBatteries = $false
            $Settings.ExecutionTimeLimit= "PT5M"
            
            $triggers = $taskDefinition.Triggers
            $TriggerTypeLogin=9
            $trigger = $triggers.Create($TriggerTypeLogin)
            $trigger.UserId = $env:username
            $trigger.delay = "PT90S"
            $trigger.Repetition.Interval = $RepetitionInterval
            $trigger.Repetition.Duration = $null
            
            $InfoTask = $taskDefinition.RegistrationInfo
            $InfoTask.Description = $Data
            
            $Action = $taskDefinition.Actions.Create(0)
            $Action.Path = "wscript"
            $Action.Arguments= `
            "`"$VbsLauncher`" --Wallpaper"
            
            $CreateOrUpdateTask = 6
            $null=$rootFolder.RegisterTaskDefinition( `
            "$env:username\$title\��ֽ�ֲ�",`
            $taskDefinition,$CreateOrUpdateTask,$null,$null, 3)
            
      }elseif($WirteOrRead -eq "Read"){
            if (schtasks /query /tn YuphizScript\$env:username\$title\��ֽ�ֲ� 2>$null){
                  $XmlTasks= `
                  [xml]($rootFolder.gettask("$env:username\$title\��ֽ�ֲ�").xml)
                  $DescriptionTasks=$XmlTasks.Task.RegistrationInfo.Description
                  return $DescriptionTasks
            }
      }
      
}



function Get-Folder {
      param (
            $PathOfFolder
      )
      $FilterFolders = (ls $PathOfFolder -Directory -Depth 1) | ?{$_.Name.IndexOf("__") -ne 0}
      $AllFolders = @()
      $AllFolders += $PathOfFolder
      foreach ($Oneof in $FilterFolders) {
            $path = ($Oneof.FullName.split("\"))[-1,-2,-3] | ?{ $_.indexof("__") -eq 0}
            if ($path.count -eq 0) {
                  $AllFolders += $Oneof
            }
      }
      
      $Folders=@()
      foreach ($Oneof in $AllFolders) {
            $Filter=(ls $Oneof.fullname -File | ?{$FormatSupported -contains $_.Extension})
            if ($Filter.count -ge 1){
            $i=$ii=0
            foreach ($oneof2 in $Filter.basename) {
                  if ($oneof2.indexof("_1") -eq "$OneOf2".length-2 -and "$OneOf2".length -ge 2){
                        $i++
                        if ($i -gt 1){ break }
                  }elseif ($oneof2.indexof("_2") -eq "$OneOf2".length-2 -and "$OneOf2".length -ge 2) {
                        $ii++
                        if ($i -gt 1){ break }
                  }
            }
            $FolderName = Split-Path ($Oneof.fullname) -leaf
            if ( $i -eq 1 -and $ii -eq 1 -and $FolderName.IndexOf("__") -ne 0) {
                  $Folders += $Oneof.fullname
            }
            }
      }
return $Folders
}


Function Get-NewWallpaperFolder {
      $OldWallpaperFolder = Split-Path -parent $LastWallpaper
      # $IsHavaLastWallpaper = (Test-Path $OldWallpaperFolder)

      [object[]]$Folders = Get-Folder $WallpaperFolder
      if ($Folders.Count -eq 0) {
            $null = $popup.Popup("   �Ҳ������ϵ�ͼƬ�ļ� `n`r
    $WallpaperFolder `n`r
    �����˳���ֽ�߼���",0,"����",16 + 4096)
            exit
      }
      
      $DateOld = (WirteOrReadDataFromSchtask "Read").split(",")[0]
      $Today = (Get-Date -Format "yyyy-MM-dd")
      try {$null=(get-date $DateOld)}catch{if ($error[0] -match "Date"){$DateOld = 0}}
      if ($DateOld -eq $null -or (New-TimeSpan $DateOld $Today).Days -ge 1) {
            WirteOrReadDataFromSchtask "Write" "$Today,$CarouselTime"

            for ($i=0;$i -lt $Folders.count;$i++) { 
                  if ($OldWallpaperFolder -eq $Folders[$i]){
                        break
                  }
            }
            if ($TurnOnRandomFolder -eq "��" -and $Folders.count -gt 1) {
                  do {
                        $newI=random(0..$($Folders.count-1))
                  } until ( $newI -ne $i )
            }elseif ($TurnOnRandomFolder -eq "��" -or $Folders.count -le 1) {
                  if ($newI++ -gt $Folders.count) {
                        $newI = 0
                  }else {
                        $newI++
                  }
            }
            
            $newWallpaper = $Folders[$newI]
            
      }else{
            foreach ($oneof in $Folders){
                  if ($oneof -eq $OldWallpaperFolder) {
                        $newWallpaper = $OldWallpaperFolder
                        break
                  }
            }
            if ($newWallpaper -eq $null){
                  $newWallpaper = $Folders[0]
            }
      }
Return $newWallpaper
}



function Get-NewWallpaper {
      param (
            $FolderPath,
            $Theme
      )
      $NewWallpaper = switch ($Theme) {
            1 {
                  ((ls $FolderPath -file) | ?{$_.BaseName.IndexOf("_1") -eq $_.BaseName.Length-2 -and $_.basename.length -ge 2}).FullName 
            }
            0 { 
                  ((ls $FolderPath -file) | ?{$_.BaseName.IndexOf("_2") -eq $_.BaseName.Length-2 -and $_.basename.length -ge 2}).FullName
            }
      }
return $NewWallpaper
}



function Get-NewWallpaperFromAll {
      param (
            $FolderPath,
            $Theme,
            $allwallpapers=@(),
            $FormatSupported =@( ".jpg",".jpeg",".png",".bmp")
      )
      [object[]]$AllPictureFile = (ls $FolderPath -Depth 2) | ?{$FormatSupported -contains $_.Extension }

      foreach ($Oneof in $AllPictureFile) {
            $path = ($Oneof.FullName.split("\"))[-1,-2,-3] | ?{ $_.indexof("__") -eq 0}
            if ($path.count -eq 0) {
                  $allwallpapers += $Oneof
            }
      }

      if ($Theme -eq 1) {
            [object[]]$DayWallpapers = $allwallpapers | ? {$_.basename.indexof("_1") -eq $_.basename.length-2 -and $_.basename.length -ge 2}
            
            switch ($DayWallpapers.count) {
                  {$_ -gt 1} { 
                        do {
                        $Number = Random(0..$($DayWallpapers.Count-1))
                        } until ($DayWallpapers.fullname[$Number] -ne $LastWallpaper)
                        $NewWallpaperFromAll = $DayWallpapers.fullname[$Number] 
                  }
                  1 {
                        $NewWallpaperFromAll = $DayWallpapers[0].fullname
                  }
                  {$_ -lt 1} {
                        $null = $popup.Popup("   �Ҳ������ϵ�ͼƬ�ļ� `n`r
    $WallpaperFolder `n`r
    �����˳���ֽ�߼���",0,"����",16 + 4096)
                  exit
                  }
            }

      }elseif ($Theme -eq 0) {
            [object[]]$NightWallpapers = $allwallpapers | ? {$_.basename.indexof("_2") -eq $_.basename.length-2 -and $_.basename.length -ge 2}

            switch ($NightWallpapers.count) {
                  {$_ -gt 1} { 
                        do {
                              $Number = Random(0..$($NightWallpapers.Count-1))
                        } until ($NightWallpapers.fullname[$Number] -ne $LastWallpaper)
                        $NewWallpaperFromAll = $NightWallpapers.fullname[$Number]
                   }
                  1 {
                        $NewWallpaperFromAll = $NightWallpapers[0].fullname
                   }
                  {$_ -lt 1} {
                        $null = $popup.Popup("   �Ҳ������ϵ�ͼƬ�ļ� `n`r
    $WallpaperFolder `n`r
    �����˳���ֽ�߼���",0,"����",16 + 4096)
                  exit
                   }
            }
      }
return $NewWallpaperFromAll
}



switch ($WallpaperRunBy) {
      0 {
            $Wallpaper = switch ($AppTheme) {
                  1 { $DayWallpaper }
                  0 { $NightWallpaper }
            }
            $null = schtasks /change /disable /tn YuphizScript\$env:username\$title\��ֽ�ֲ�
      }
      1 {
            $NewWallpaperFolder = Get-NewWallpaperFolder
            $Wallpaper = Get-NewWallpaper $NewWallpaperFolder $AppTheme
            $null = schtasks /change /disable /tn YuphizScript\$env:username\$title\��ֽ�ֲ�
      }
      2 {
            $CarouselTimeData =  (WirteOrReadDataFromSchtask "Read").split(",")[1]
            $IsEnabled = get-ScheduledTask-State "\YuphizScript\$env:username\$title\��ֽ�ֲ�"
            if ($CarouselTimeData -eq $null -or $CarouselTimeData -ne $CarouselTime -or $IsEnabled -eq $False) {
                  $Today = (Get-Date -Format "yyyy-MM-dd")
                  WirteOrReadDataFromSchtask "Write" "$Today,$CarouselTime" "PT$($CarouselTime)S"
            }
            $Wallpaper = Get-NewWallpaperFromAll $WallpaperFolder $AppTheme
      }
}



Function UpdateWallpaper {
      param (
            $Wallpaper,
            $Style = $defaultWallpaperStyle
      )
      if ($LastWallpaper -ne $Wallpaper) {
            If (test-path $Wallpaper) {
Add-Type @"
using System;
using System.Runtime.InteropServices;
namespace Wallpaper
{
      public class Setter {
            [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
            private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
            public static void SetWallpaper ( string path) {
                  SystemParametersInfo( 20, 0, path, 1 | 2 );
            }
      }
}
"@
                  switch ($Style) {
                        "���" {
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 0 /f;
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 10 /f;
                        }
                        "��Ӧ" {
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 0 /f;
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 6 /f;
                        }
                        "����" {
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 0 /f;
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 2 /f;
                        }
                        "ƽ��" {
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 1 /f;
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 0 /f;
                        }
                        "����" {
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 0 /f;
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 0 /f;
                        }
                        "����" {
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 0 /f;
                              $null = reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 22 /f;
                        }
                  }
                  [Wallpaper.Setter]::SetWallpaper($Wallpaper)
            }else{
                  $null=$popup.Popup("��ֽ����ʧ�ܣ������ļ��Ƿ����",0,$null,4096)
            }
      }else{
            "ͼƬ��ͬ������Ҫ��"
      }
}

$WallpaperFit = $Wallpaper
for ($i=0;$i -lt 3; $i++){
      $WallpaperFolderName = Split-Path $WallpaperFit -leaf
      $WallpaperFit = Split-Path $WallpaperFit
      if ($WallpaperStyle[$WallpaperFolderName] -ne $null){
            $defaultWallpaperStyle = $WallpaperStyle[$WallpaperFolderName]
            break
      }
}

UpdateWallpaper $Wallpaper $defaultWallpaperStyle
# $null=$popup.Popup("������ֽ",1,$null,4096)