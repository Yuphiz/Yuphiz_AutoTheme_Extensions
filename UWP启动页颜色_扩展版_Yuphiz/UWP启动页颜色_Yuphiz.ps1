<#
.����
�ű���UWP����ҳ��ɫ_��չ��
�汾��v0.2
���ߣ�Yuphiz
���ű����԰��� Windows10 �Զ��л�UWP����ҳ����ɫ
���ô˽ű����·��ɲ����������ģ����뱾�����޹�
�˽ű���ɲ��� GPL-3.0-later Э��
#>

param ($Color,$ReStore,$TurnOnStayBackstage=0,$IsTips="NoTips")


#�ű�����·�������Ϊ����ѡ��ǰ����·��
$PathScriptWork = $PSScriptRoot;if ($PathScriptWork -eq "") {$PathScriptWork=(get-location).path}
$title="UWP����ҳ��ɫ"
$titleEN="SplashScreen"
$Popup=new-object -Comobject Wscript.Shell
write-host "�������� UWP ����ҳ��ɫ ����"

$FileConfig = "$PathScriptWork\UWP����ҳ��ɫ_Yuphiz.Json"
if (!(Test-Path $FileConfig)){
      @'
{
      "��ɫ��Դ":"�Զ���"
,     "�Զ�����Դѡ��":{
            "ǳɫ������ɫ":"#F8F8FF"
,           "��ɫ������ɫ":"#303033"
      }
,     "�ų�Ӧ��":[
      ]
,     "����":"��_��ʱ����ѡ"
}
'@ | set-content $FileConfig
}
try {
      $Config=get-content $FileConfig | ConvertFrom-Json
}catch{
      $null = $popup.popup("      $FileConfig `n`r
$($error[0])",0,"�����ļ�����",16);exit
}

#�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T ���� ģ�鿪ʼ �T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T
# ��ɫ��Դ��"Custom"�Զ��壬"System"����ϵͳ����ɫ��"Random"��ɫ�������ʱ��Ч��
$ColorFrom = $Config.��ɫ��Դ

#ǳɫ������ɫ
$ColorOfLight = $Config.�Զ�����Դѡ��.ǳɫ������ɫ
#��ɫ������ɫ
$ColorOfDark = $Config.�Զ�����Դѡ��.��ɫ������ɫ

#�������ݣ����鿪��
$TurnOnBackup = $Config.����


#�ų�Ӧ�ã�ע�����ȫ�������š�����
$Exclude = $Config.�ų�Ӧ��
#�������������������������� ���� ģ����� ����������������������������



#�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T �ָ� ģ�鿪ʼ �T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T
if ($ReStore -eq "ReStoreFromUpdate" -or $ReStore -eq "ReStoreFromOriginal") {
   
#�T�T�T�T�T�T�T�T �ָ���ɫ���� ��ʼ
      function RunReStoreColor{
            param(
                  $PackageFamilyName,
                  $nameid,
                  $color
      )
            $null=reg add "$regROOT\$PackageFamilyName\SplashScreen\$nameid" /v BackgroundColor /t REG_SZ /d $color /f

            $key=$regROOT+"\$PackageFamilyName\SplashScreen\$nameid"
            $BackgroundColor=$color

            $NameIDHash=@{}
      return $NameIDHash  | Select-Object -Property  @{label="����";expression={$nameid}},@{label="ע���·��";expression={$key}},@{label="����������ɫ";expression={$BackgroundColor}}
      }
#������������ �ָ���ɫ���� ����

#�T�T�T�T�T�T�T�T�T ��ȡ�ָ���ɫ ��ʼ
      function ReStoreColor{
            param(
                  $WhereFileRestore
            )
            $FileJsonToRestore = switch ($WhereFileRestore) {
                  "ReStoreFromUpdate" {
                        "$PathScriptWork\��ɫ����\UWPSplashScreenColor_Ĭ�ϱ���_����_"+`
                        $env:userdomain+"_"+$env:username+".json" 
                   }
                  "ReStoreFromOriginal" {
                        "$PathScriptWork\��ɫ����\UWPSplashScreenColor_Ĭ�ϱ���_ԭʼ_��ɾ_"+`
                        $env:userdomain+"_"+$env:username+".json"
                  }
            }

            $RestoreSplashScreen=get-content $FileJsonToRestore |
                  ConvertFrom-Json
            if($Popup.popup("      �� �� �� Դ �ǡ���`n`
      $FileJsonToRestore`n`
      ȷ �� Ҫ �� �� ��",0,"��ȷ�ϡ���",1+32+256+4096) -eq 2) {
                  $Popup.popup("��ȡ���˻ָ�����")
                  exit
            }

$regROOT="HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData"
            $result=@()
            foreach ($i in $RestoreSplashScreen.nameID){
                  $namei=$RestoreSplashScreen.contents.$i.name
                  $colori=$RestoreSplashScreen.contents.$i.color
                  if (test-path ( `
                        "registry::"+$RegROOT+"\$namei\SplashScreen\$i")){
                        $result+=$(RunReStoreColor $namei $i $colori)
                  }
            }

            $result | Out-GridView -title "��ԭ������£�����ֱ�Ӹ��ƽ��" -wait
      }
#��������������ȡ�ָ���ɫ ����

      ReStoreColor $ReStore
      exit
}
#�������������������������� �ָ� ģ����� ����������������������������




#�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T ��ȡ��ɫ ��ʼ �T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T
Function getColor($AppTheme){
      $Color = switch ($ColorFrom){
            "��ֽ"{
                  "transparent"
                  # "#"+("{0:x}" -f ((Get-ItemProperty -path "registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM").ColorizationColor)).SubString(2,("{0:x}" -f ((Get-ItemProperty -path "registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM").ColorizationColor)).Length-2)
               }
            "�Զ���"{
                  switch ($AppTheme) {
                        1 { $ColorOfLight }
                        0 { $ColorOfDark }
                  }
               }
            "ϵͳ"{
                  "transparent"
               }
            "���"{}
      }
Return $Color
}
#�������������������������� ��ȡ��ɫ ���� ��������������������������

$AppTheme=(Get-ItemProperty -path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme
$Color=(getColor $AppTheme)
#�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T ������ɫ ��ʼ �T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T
function RunChangeColor{
      param(
            $PackageFamilyName,
            $id
      )
$null = reg add "$regROOT\$PackageFamilyName\SplashScreen\$PackageFamilyName!$id" /v BackgroundColor /t REG_SZ /d $Color /f
}
#�������������������������� ������ɫ ���� ��������������������������



#�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T ����UWP ��ʼ �T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T
Function CheckColor{
#$containsUWP+=$Exclude
$JsonSplashScreen=@()
$JsonNameID=@()
$UWPNameID=@()
$NameArray=@()
$regROOT="HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData"
#$PathRegROOT="HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData"

$AllAppx = get-appxpackage -PackageTypeFilter main | ?{$_.name -notmatch "Microsoft.LanguageExperiencePack"}
foreach ($i in $AllAppx){
      $NameUWP=$i.PackageFamilyName
      $PathUWP=$i.InstallLocation
      $XML =[xml](Get-Content "$PathUWP\AppxManifest.xml")
      [string[]]$ApplicationID=$xml.Package.Applications.Application.id
      if (($NameUWP -ne $null) -and ($ApplicationID -ne $null) `
          -and ($Exclude -notcontains $i.name) -and ($NameUWP -notlike "Microsoft.*Extension*") -and ($NameUWP -notlike "Microsoft.LanguageExperiencePack*")){
#            $NameUWP
#            $ApplicationID
            for ($i=0;$i -lt $ApplicationID.count; $i++){
                  if (test-path ("registry::"+$regROOT+"\$NameUWP\SplashScreen\$NameUWP!$($ApplicationID[$i])")){
                        $BackgroundColor= ( Get-ItemProperty -path ("registry::"+$regROOT+"\$NameUWP\SplashScreen\$NameUWP!$($ApplicationID[$i])")).BackgroundColor
                        if ($NameUWP -ne $null -and $BackgroundColor -ne $null) {
                              $JsonSplashScreen+=@"
{"$NameUWP!$($ApplicationID[$i])":{"name":"$NameUWP","id":"$($ApplicationID[$i])","color":"$BackgroundColor"}},
"@
$JsonNameID+=@"
"$NameUWP!$($ApplicationID[$i])",
"@
                              $UWPNameID+="$NameUWP!$($ApplicationID[$i])"
                              RunChangeColor $NameUWP $ApplicationID[$i]
                        }
                  }
#                  $count=$count+1
            }
      }
}

#$count;$count=0
$JsonSplashScreen="$JsonSplashScreen".Trim(" .-`t`n`r,")
$JsonNameID="$JsonNameID".Trim(" .-`t`n`r,")
$JsonSplashScreen="{""contents"":[$JsonSplashScreen],""NameID"":[$JsonNameID]}"

if (!(test-path "$PathScriptWork\��ɫ����")) {
      new-item "$PathScriptWork\��ɫ����"  -itemtype "directory"
}
$FileJsonBakOrig="$PathScriptWork\��ɫ����\UWPSplashScreenColor_Ĭ�ϱ���_ԭʼ_��ɾ_"+$env:userdomain+"_"+$env:username+".json"
$FileJsonBak="$PathScriptWork\��ɫ����\UWPSplashScreenColor_Ĭ�ϱ���_����_"+$env:userdomain+"_"+$env:username+".json"

if (!(test-path $FileJsonBakOrig)){
      $JsonSplashScreen >$FileJsonBakOrig
}

if (!(test-path $FileJsonBak)){
      $JsonSplashScreen >$FileJsonBak
}else{
      $ScriptSplashScreen=$JsonSplashScreen | ConvertFrom-Json

      $BakSplashScreen=get-content $FileJsonBak | ConvertFrom-Json

      $isexist=0
      foreach ($i in $UWPNameID){
            if ($BakSplashScreen.NameID -notcontains $i) {
                  $BakSplashScreen.NameID+=,$i
                  $jsoni=@{}
                  $jsoni.name=$ScriptSplashScreen.contents.$i.name
                  $jsoni.id=$ScriptSplashScreen.contents.$i.id
                  $jsoni.color=$ScriptSplashScreen.contents.$i.color
                  $jsonis=@{}
                  $jsonis.$i=$jsoni
                  $BakSplashScreen.contents+=,$jsonis
                  $isexist++
            }
      }

      if ($isexist -ne 0 ) {
            $BakSplashScreen | ConvertTo-Json -Depth 10 | set-content      $FileJsonBak
            "�в�ͬ"
            $isexist
      } else{
            "����ͬ"
            #$isexist
      }
}
}
#�������������������������� ����UWP ���� ��������������������������

CheckColor

#�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T �������� ��ʼ �T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T�T
function debugpopup {
      $debugAppTheme=(Get-ItemProperty -path "registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme
      if ($debugAppTheme -eq 1) {
            $deapptheme="ǳɫ"
      }else{
            $deapptheme="��ɫ"
      }
$null=$Popup.popup("������ "+$deapptheme+"`n��ɫ�� "+$color+"`n��ɫ���� "+$colorfrom+"`n������ɫ "+$ColorOfLight+"`nҹ����ɫ "+$ColorOfDark,3,$null,4096)
}
#�������������������������� �������� ���� ��������������������������
# debugpopup