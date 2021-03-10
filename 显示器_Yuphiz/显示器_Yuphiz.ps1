<#
.����
�ű�����ʾ��_Yuphiz 
�汾��v0.1
���ߣ�Yuphiz
���ű����԰��� Windows10 �Զ��л���ǳɫ��������ʾ��������/�Աȶ�
���ô˽ű����·��ɲ����������ģ����뱾�����޹�
�˽ű���ɲ��� GPL-3.0-later Э��
#>



#�ű�����·�������Ϊ����ѡ��ǰ����·��
$PathScriptWork = $PSScriptRoot;if ($PathScriptWork -eq "") {$PathScriptWork=(get-location).path}
$title = "��ʾ��_Yuphiz"
$popup=new-object -comobject wscript.shell

$FileConfig = "$PathScriptWork\��ʾ��_Yuphiz.Json"
if (!(Test-Path $FileConfig)){
      @'
      {
        "ˢ��ʱ��_����":100
  ,     "ˢ���ݶ�":5
  ,     "����ѡ��":{
               "���ȿ���":"��"
        ,      "ǳɫ�����µ�����":80
        ,      "��ɫ�����µ�����":40
        }
  ,     "�Աȶ�ѡ��":{
              "�Աȶȿ���":"��"
       ,      "ǳɫ�����µĶԱȶ�":65
       ,      "��ɫ�����µĶԱȶ�":50
        }
  }
  
'@ | set-content $FileConfig
}
try {
      $Config=get-content $FileConfig | ConvertFrom-Json
}catch{
      $null = $popup.popup("      $FileConfig `n`r
$($error[0])",0,"�����ļ�����",16);exit
}



# ���� ��ʼ
#ƽ������ʱ�䣬����,���50�������˸��������
[int]$refreshTime = $Config.ˢ��ʱ��_����
#ƽ���������ȣ����5�������˸��������
[int]$refreshFrame = $Config.ˢ���ݶ�

$TurnOn_Brightness = $Config.����ѡ��.���ȿ���
[int]$LightBrightness = $Config.����ѡ��.ǳɫ�����µ�����
[int]$DarkBrightness = $Config.����ѡ��.��ɫ�����µ�����

$TurnOn_Contrast = $Config.�Աȶ�ѡ��.�Աȶȿ���
[int]$LightContrast = $Config.�Աȶ�ѡ��.ǳɫ�����µĶԱȶ�
[int]$DarkContrast = $Config.�Աȶ�ѡ��.��ɫ�����µĶԱȶ�
# ���� ����

# �ݴ�
switch ($refreshTime) {
    {$refreshTime -lt 50} { $refreshTime = 100 }
}
switch ($refreshFrame) {
    {$refreshFrame -lt 5} { $refreshFrame = 5 }
}
switch ($true) {
    {$LightBrightness -lt 0} { $LightBrightness = 0 }
    {$LightBrightness -gt 100} { $LightBrightness = 100 }
    {$DarkBrightness -lt 0} { $DarkBrightness = 0 }
    {$DarkBrightness -gt 100} { $DarkBrightness = 100 }
}
switch ($true) {
    {$LightContrast -lt 5} { $LightContrast = 5 }
    {$LightContrast -gt 100} { $LightContrast = 100 }
    {$DarkContrast -lt 5} { $DarkContrast = 5 }
    {$DarkContrast -gt 100} { $DarkContrast = 100 }
}



$ddccli = "$PathScriptWork\ddccli.exe"

$AppTheme=(Get-ItemProperty -path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme


switch ($AppTheme){
    1 {
        $Brightness = $LightBrightness
        $Contrast = $LightContrast
    }
    0 {
        $Brightness = $DarkBrightness
        $Contrast = $DarkContrast
    }
}


# $Brightness = 80
# $Contrast = 70


# Get-WmiObject -Namespace "root\WMI" -Class "WmiMonitorBrightnessMethods" ��������
# Get-WmiObject -Namespace "root\WMI" -Class "WmiMonitorid" �鿴��ʾ����
# Get-Ciminstance -Namespace root/WMI -ClassName WmiMonitorBrightness �鿴��ǰ����

function get-Monitors {
    param (
        $Monitor
    )
    $IsBrightness = $IsContrast = 0
    if (.$ddccli -B -m $Monitor 2>$null) {
        $IsBrightness = 1
    }
    if (.$ddccli -C -m $Monitor 2>$null) {
        $IsContrast = 2
    }
    $Result = $IsBrightness + $IsContrast
return $Result
}

$Monitors = .$ddccli -l

$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, 4)
$RunspacePool.Open()
$jobObject=@()

if ($TurnOn_Contrast -eq "��"){
    foreach ($oneof in $Monitors){
        $IsDdc = get-Monitors $oneof
        switch ($IsDdc) {
            1 { 
                $OldBrightness = .$ddccli -B -m $oneof
                $Diff = $OldBrightness - $Brightness
                if ($Diff -gt 0){
                    $IsPositive = 1
                }else{
                    $IsPositive = -1
                }
                $count = [math]::abs($Diff)/$refreshFrame
        
                $Code = [scriptblock]::Create("
                    for (`$i=0;`$i -le $Count ;`$i++){
                        `$NewBrightness = $OldBrightness - (`$i * $refreshFrame * $IsPositive);
                        .'$ddccli' -b `$NewBrightness -m $oneof;
                        start-sleep -m $refreshTime;
                    }
                ")
                $PowerShell =[powershell]::Create()
                $PowerShell.Runspacepool = $Runspacepool
                [void]$PowerShell.AddScript($Code)
                $jobObject += $PowerShell.BeginInvoke()
                # Invoke-Command $Code
            }
            2 {
                $OldContrast = .$ddccli -C -m $oneof
                $Diff = $OldContrast - $Contrast
                if ($Diff -gt 0){
                    $IsPositive = 1
                }else{
                    $IsPositive = -1
                }
                $count = [math]::abs($Diff)/$refreshFrame
        
                $Code = [scriptblock]::Create("
                    for (`$i=0;`$i -le $Count ;`$i++){
                        `$NewContrast = $OldContrast - (`$i * $refreshFrame * $IsPositive);
                        .'$ddccli' -c `$NewContrast -m $oneof;
                        start-sleep -m $refreshTime;
                    }
                ")
                $PowerShell =[powershell]::Create()
                $PowerShell.Runspacepool = $Runspacepool
                [void]$PowerShell.AddScript($Code)
                $jobObject += $PowerShell.BeginInvoke()
            }
            3{
                $OldBrightness = .$ddccli -B -m $oneof
                $OldContrast = .$ddccli -C -m $oneof

                $DiffBrightness = $OldBrightness - $Brightness
                $DiffContrast = $OldContrast - $Contrast
                
                if ($DiffBrightness -gt 0){
                    $IsPositive_Brightness = 1
                }else{
                    $IsPositive_Brightness = -1
                }

                if ($DiffContrast -gt 0){
                    $IsPositive_Contrast = 1
                }else{
                    $IsPositive_Contrast = -1
                }

                if ([math]::abs($DiffBrightness) -gt [math]::abs($DiffContrast)){
                    $count = [math]::abs($DiffBrightness)/$refreshFrame
                }else{
                    $count = [math]::abs($DiffContrast)/$refreshFrame
                }
        
                $Code = [scriptblock]::Create("
                    for (`$i=0;`$i -le $Count ;`$i++){
                        if (`$NewBrightness -eq $Brightness ){
                            `$NewBrightness = $Brightness
                        }else{
                            `$NewBrightness = $OldBrightness - (`$i * $refreshFrame * $IsPositive_Brightness);
                        };
                        
                        if (`$NewContrast -eq $Contrast ){
                            `$NewContrast = $Contrast
                        }else{
                            `$NewContrast = $OldContrast - (`$i * $refreshFrame * $IsPositive_Contrast);
                        };

                        .'$ddccli' -b `$NewBrightness -c `$NewContrast -m $oneof;
                        start-sleep -m $refreshTime;
                    }
                ")
                $PowerShell =[powershell]::Create()
                $PowerShell.Runspacepool = $Runspacepool
                [void]$PowerShell.AddScript($Code)
                $jobObject += $PowerShell.BeginInvoke()
            }
        }
    }
}elseif ($TurnOn_Contrast -eq "��") {
    foreach ($oneof in $Monitors){
        $IsDdc = get-Monitors $oneof
        switch ($IsDdc) {
            {$IsDdc -eq 1 -or $IsDdc -eq 3} { 
                $OldBrightness = .$ddccli -B -m $oneof
                $Diff = $OldBrightness - $Brightness
                if ($Diff -gt 0){
                    $IsPositive = 1
                }else{
                    $IsPositive = -1
                }
                $count = [math]::abs($Diff)/$refreshFrame
        
                $Code = [scriptblock]::Create("
                    for (`$i=0;`$i -le $Count ;`$i++){
                        `$NewBrightness = $OldBrightness - (`$i * $refreshFrame * $IsPositive);
                        .'$ddccli' -b `$NewBrightness -m $oneof;
                        start-sleep -m $refreshTime;
                    }
                ")
                $PowerShell =[powershell]::Create()
                $PowerShell.Runspacepool = $Runspacepool
                [void]$PowerShell.AddScript($Code)
                $jobObject += $PowerShell.BeginInvoke()
                # Invoke-Command $Code
            }
        }
    }
}

foreach ($Oneof in $jobObject) {
    $null=$Oneof.AsyncWaitHandle.WaitOne()
}

$PowerShell.RunspacePool.close()
$PowerShell.Dispose()
$RunspacePool.close()
$RunspacePool.Dispose()
[System.GC]::Collect()
# write-host "Handles: $($(Get-Process -Id $PID).HandleCount) Memory: $($(Get-Process -Id $PID).PrivateMemorySize64 / 1mb) mb"
# read-host
exit