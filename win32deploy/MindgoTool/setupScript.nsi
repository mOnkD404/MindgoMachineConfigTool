; 该脚本使用 HM VNISEdit 脚本编辑器向导产生

; 安装程序初始定义常量
!define PRODUCT_NAME "Mindgo"
!define PRODUCT_VERSION "1.7"
!define PRODUCT_PUBLISHER "Mindgo"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor lzma

; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI.nsh"

; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; 语言选择窗口常量设置
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; 欢迎页面
!insertmacro MUI_PAGE_WELCOME
; 安装目录选择页面
!insertmacro MUI_PAGE_DIRECTORY
; 安装过程页面
!insertmacro MUI_PAGE_INSTFILES
; 安装完成页面
!insertmacro MUI_PAGE_FINISH

; 安装卸载过程页面
!insertmacro MUI_UNPAGE_INSTFILES

; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

; 安装预释放文件
!insertmacro MUI_RESERVEFILE_LANGDLL
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI 现代界面定义结束 ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "Setup.exe"
InstallDir "$PROGRAMFILES\Mindgo"
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File /r "D:\MindGo\MindgoMachineConfigTool\win32deploy\MindgoTool\MindgoTool\*.*"

  CreateShortCut "$DESKTOP\Mindgo.lnk" "$INSTDIR\MindGoTool_AllInOne.exe"
  CreateShortCut "$STARTMENU\Mindgo.lnk" "$INSTDIR\MindGoTool_AllInOne.exe"
SectionEnd

Section -AdditionalIcons
  CreateDirectory "$SMPROGRAMS\Mindgo"
  CreateShortCut "$SMPROGRAMS\Mindgo\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

#-- 根据 NSIS 脚本编辑规则，所有 Function 区段必须放置在 Section 区段之后编写，以避免安装程序出现未可预知的问题。--#

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

/******************************
 *  以下是安装程序的卸载部分  *
 ******************************/

Section Uninstall
  Delete "$INSTDIR\uninst.exe"

  Delete "$SMPROGRAMS\Mindgo\Uninstall.lnk"
  Delete "$STARTMENU.lnk"
  Delete "$DESKTOP.lnk"

  RMDir "$SMPROGRAMS\Mindgo"
  RMDir ""

  RMDir /r "$INSTDIR\Universal"
  RMDir /r "$INSTDIR\translations"
  RMDir /r "$INSTDIR\scenegraph"
  RMDir /r "$INSTDIR\QtWinExtras"
  RMDir /r "$INSTDIR\QtTest"
  RMDir /r "$INSTDIR\QtQuick.2"
  RMDir /r "$INSTDIR\QtQuick"
  RMDir /r "$INSTDIR\QtQml"
  RMDir /r "$INSTDIR\QtMultimedia"
  RMDir /r "$INSTDIR\QtGraphicalEffects"
  RMDir /r "$INSTDIR\Qt"
  RMDir /r "$INSTDIR\qmltooling"
  RMDir /r "$INSTDIR\playlistformats"
  RMDir /r "$INSTDIR\platforms"
  RMDir /r "$INSTDIR\platforminputcontexts"
  RMDir /r "$INSTDIR\mediaservice"
  RMDir /r "$INSTDIR\Material"
  RMDir /r "$INSTDIR\imageformats"
  RMDir /r "$INSTDIR\iconengines"
  RMDir /r "$INSTDIR\UserInterfaceLayer"
  RMDir /r "$INSTDIR\bearer"
  RMDir /r "$INSTDIR\audio"

  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd

#-- 根据 NSIS 脚本编辑规则，所有 Function 区段必须放置在 Section 区段之后编写，以避免安装程序出现未可预知的问题。--#

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你确实要完全移除 $(^Name) ，及其所有的组件？" IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) 已成功地从你的计算机移除。"
FunctionEnd
