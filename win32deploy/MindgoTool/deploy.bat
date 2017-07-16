
xcopy /y ..\..\release\MindGoTool_AllInOne.exe .\MindgoTool\MindGoTool_AllInOne.exe
D:\Qt\Qt5.8.0_x86\5.8\msvc2015\bin\windeployqt.exe .\MindgoTool\MindGoTool_AllInOne.exe  --qmldir D:\Qt\Qt5.8.0_x86\5.8\msvc2015\qml
xcopy /y /E ..\..\UserInterfaceLayer\config\*.* .\MindgoTool\UserInterfaceLayer\config

pause