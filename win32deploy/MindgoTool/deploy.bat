
xcopy /y ..\..\UserInterfaceLayer\release\UserInterfaceLayer.exe .\MindgoTool\UserInterfaceLayer.exe
D:\Qt\Qt5.9.0\5.9\msvc2015\bin\windeployqt.exe .\MindgoTool\UserInterfaceLayer.exe  --qmldir D:\Qt\Qt5.9.0\5.9\msvc2015\qml
xcopy /y ..\..\BussinessLayer\WorkflowProtocol\release\WorkflowProtocol.dll .\MindgoTool\WorkflowProtocol.dll
xcopy /y ..\..\InfrastructureLayer\Communication\release\Communication.dll .\MindgoTool\Communication.dll
xcopy /y /E ..\..\UserInterfaceLayer\config\*.* .\MindgoTool\config

pause