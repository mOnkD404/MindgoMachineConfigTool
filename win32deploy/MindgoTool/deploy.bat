
xcopy /y ..\..\UserInterfaceLayer\release\UserInterfaceLayer.exe .\MindgoTool\UserInterfaceLayer.exe
D:\Qt\Qt5.8.0\5.8\msvc2015_64\bin\windeployqt.exe .\MindgoTool\UserInterfaceLayer.exe  --qmldir D:\Qt\Qt5.8.0\5.8\msvc2015_64\qml
xcopy /y ..\..\BussinessLayer\WorkflowProtocol\release\WorkflowProtocol.dll .\MindgoTool\WorkflowProtocol.dll
xcopy /y ..\..\InfrastructureLayer\Communication\release\Communication.dll .\MindgoTool\Communication.dll
xcopy /y /E ..\..\UserInterfaceLayer\config\*.* .\MindgoTool\config

pause