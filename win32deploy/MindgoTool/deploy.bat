
xcopy /y ..\..\release\MindGoTool_AllInOne.exe .\MindgoTool\MindGoTool_AllInOne.exe
D:\Qt\Qt5.9.0\5.9\msvc2015\bin\windeployqt.exe .\MindgoTool\MindGoTool_AllInOne.exe  --qmldir D:\Qt\Qt5.9.0\5.9\msvc2015\qml
xcopy /y /E ..\..\UserInterfaceLayer\config\*.* .\MindgoTool\UserInterfaceLayer\config

pause