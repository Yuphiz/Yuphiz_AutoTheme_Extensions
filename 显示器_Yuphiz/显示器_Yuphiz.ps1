<#
.声明
脚本：显示器_Yuphiz 
版本：v0.1
作者：Yuphiz
本脚本可以帮助 Windows10 自动切换深浅色主题下显示器的亮度/对比度
凡用此脚本从事法律不允许的事情的，均与本作者无关
此脚本许可采用 GPL-3.0-later 协议
#>



#脚本所在路径，如果为空则选择当前工作路径
$PathScriptWork = $PSScriptRoot;if ($PathScriptWork -eq "") {$PathScriptWork=(get-location).path}
$title = "显示器_Yuphiz"
$popup=new-object -comobject wscript.shell

$FileConfig = "$PathScriptWork\显示器_Yuphiz.Json"
if (!(Test-Path $FileConfig)){
      @'
      {
        "刷新时间_毫秒":100
  ,     "刷新梯度":5
  ,     "亮度选项":{
               "亮度开关":"开"
        ,      "浅色主题下的亮度":80
        ,      "深色主题下的亮度":40
        }
  ,     "对比度选项":{
              "对比度开关":"关"
       ,      "浅色主题下的对比度":65
       ,      "深色主题下的对比度":50
        }
  }
  
'@ | set-content $FileConfig
}
try {
      $Config=get-content $FileConfig | ConvertFrom-Json
}catch{
      $null = $popup.popup("      $FileConfig `n`r
$($error[0])",0,"配置文件出错",16);exit
}



# 设置 开始
#平缓过渡时间，毫秒,最低50，如果闪烁，请增加
[int]$refreshTime = $Config.刷新时间_毫秒
#平缓过渡亮度，最低5，如果闪烁，请增加
[int]$refreshFrame = $Config.刷新梯度

$TurnOn_Brightness = $Config.亮度选项.亮度开关
[int]$LightBrightness = $Config.亮度选项.浅色主题下的亮度
[int]$DarkBrightness = $Config.亮度选项.深色主题下的亮度

$TurnOn_Contrast = $Config.对比度选项.对比度开关
[int]$LightContrast = $Config.对比度选项.浅色主题下的对比度
[int]$DarkContrast = $Config.对比度选项.深色主题下的对比度
# 设置 结束

# 容错
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


# Get-WmiObject -Namespace "root\WMI" -Class "WmiMonitorBrightnessMethods" 设置亮度
# Get-WmiObject -Namespace "root\WMI" -Class "WmiMonitorid" 查看显示器名
# Get-Ciminstance -Namespace root/WMI -ClassName WmiMonitorBrightness 查看当前亮度

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

if ($TurnOn_Contrast -eq "开"){
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
}elseif ($TurnOn_Contrast -eq "关") {
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