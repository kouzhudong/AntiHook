regsvr32 /s msdia140.dll rem 尽管程序已经实现了，这里明确下。

AntiHook.exe install
AntiHook.exe VerifySignature
AntiHook.exe init

mkdir log

AntiHook.exe EnumProcessNotifyRoutine > .\log\EnumProcessNotifyRoutine.txt
AntiHook.exe EnumThreadNotifyRoutine > .\log\EnumThreadNotifyRoutine.txt
AntiHook.exe EnumLoadImageNotifyRoutine > .\log\EnumLoadImageNotifyRoutine.txt
AntiHook.exe EnumRegistryCallback > .\log\EnumRegistryCallback.txt
AntiHook.exe EnumObjectCallback > .\log\EnumObjectCallback.txt
AntiHook.exe EnumShutdownNotification > .\log\EnumShutdownNotification.txt
AntiHook.exe EnumBugCheckCallback > .\log\EnumBugCheckCallback.txt
AntiHook.exe EnumExCallback > .\log\EnumExCallback.txt
AntiHook.exe EnumContainerNotification > .\log\EnumContainerNotification.txt
AntiHook.exe EnumGlobalDescriptorTable > .\log\EnumGlobalDescriptorTable.txt
AntiHook.exe EnumInterruptDescriptorTable > .\log\EnumInterruptDescriptorTable.txt
AntiHook.exe EnumKeServiceDescriptorTable > .\log\EnumKeServiceDescriptorTable.txt
AntiHook.exe EnumKeServiceDescriptorTableShadow > .\log\EnumKeServiceDescriptorTableShadow.txt
AntiHook.exe EnumKeServiceDescriptorTableFilter > .\log\EnumKeServiceDescriptorTableFilter.txt
AntiHook.exe DumpHalDispatchTable > .\log\DumpHalDispatchTable.txt
AntiHook.exe DumpHalAcpiDispatchTable > .\log\DumpHalAcpiDispatchTable.txt
AntiHook.exe DumpHalSubComponents > .\log\DumpHalSubComponents.txt
AntiHook.exe DumpHalIommuDispatchTable > .\log\DumpHalIommuDispatchTable.txt
AntiHook.exe DumpHalPrivateDispatchTable > .\log\DumpHalPrivateDispatchTable.txt
AntiHook.exe EnumProtocolDriver > .\log\EnumProtocolDriver.txt
AntiHook.exe EnumFilterDriver > .\log\EnumFilterDriver.txt
AntiHook.exe EnumMiniPortDriver > .\log\EnumMiniPortDriver.txt
AntiHook.exe EnumDpcTimer > .\log\EnumDpcTimer.txt
AntiHook.exe EnumIoTimer > .\log\EnumIoTimer.txt
AntiHook.exe EnumExTimer > .\log\EnumExTimer.txt
AntiHook.exe EnumMiniFilter > .\log\EnumMiniFilter.txt
AntiHook.exe EnumWfpCallout > .\log\EnumWfpCallout.txt
AntiHook.exe EnumFilterDevice \Device\nsi > .\log\EnumFilterDevice.txt
AntiHook.exe EnumTypeObject > .\log\EnumTypeObject.txt
AntiHook.exe EnumDriverObject > .\log\EnumDriverObject.txt
AntiHook.exe DumpUnloadedDrivers > .\log\DumpUnloadedDrivers.txt
AntiHook.exe DumpPiDDBCache > .\log\DumpPiDDBCache.txt
