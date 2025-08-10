# AntiHook
Enum and Remove Hook in Windows Kernel

设计目标：
1. 别的ARK工具没有的，或者很少有的，或者不开源的。
2. 自己喜欢的，常用的，避免自己繁琐的windbg操作。
3. procexp.exe和processhacker及SystemInformer.exe有的，一般不添加。
4. 应用层能实现的一般不添加。
5. 不支持32位。
6. 不支持GUI。
7. 多使用符号文件，尽量减少硬编码。
8. 支持Windows 7 SP1(Windows Server 2008 R2)及以后的系统。  
9. 后期考虑支持ARM64。  

已经实现的功能：  
1. 枚举和移除进程回调。  
   PsSetCreateProcessNotifyRoutine + PsSetCreateProcessNotifyRoutineEx + PsSetCreateProcessNotifyRoutineEx2  
2. 枚举和移除线程回调。  
   PsSetCreateThreadNotifyRoutine + PsSetCreateThreadNotifyRoutineEx + PsRemoveCreateThreadNotifyRoutine  
3. 枚举和移除IMAGE回调。  
   PsSetLoadImageNotifyRoutine + PsSetLoadImageNotifyRoutineEx + PsRemoveLoadImageNotifyRoutine   
4. 枚举和移除注册表回调。  
   CmRegisterCallback + CmRegisterCallbackEx + CmUnRegisterCallback
5. 枚举和移除对象（进程，线程，桌面）回调。  
   ObRegisterCallbacks + ObUnRegisterCallbacks  
6. 枚举和移除MiniFilter。  
   包含Operations（PreOperation + PostOperation）  
   包含Contexts（ContextCleanupCallback + ContextType）  
   包含CommunicationPort（仅仅ServerPort）的信息，如：ConnectNotify + DisconnectNotify + MessageNotify。  
   FltRegisterFilter + FltUnregisterFilter（有待测试, 可能会卡）  
7. 枚举和反注册WFP的Callout。  
   FwpsCalloutRegister + FwpsCalloutUnregisterById  
   没有使用符号解析，没有使用硬编码，使用导出的函数。  
8. 枚举网络协议驱动。  
   NdisRegisterProtocolDriver + NdisRegisterProtocol
9. 枚举网络过滤驱动。  
   特指通过NdisFRegisterFilterDriver注册的。
10. 枚举小端口网卡驱动。注意：不是网卡个数。  
    NdisMRegisterMiniportDriver  
11. 枚举和删除DPC定时器。有待完善。  
    以Zw/Nt/Ex开头的定时器也属于这个。  
    KeCancelTimer。  
    用到了符号解析，如：结构体中成员的偏移，结构体中的数组的个数，全局且未导出的变量等。  
12. 枚举和停止IO定时器。  
    IoInitializeTimer + IoStopTimer 
13. 读写内核内存。  
    遍历内核内存待补。  
14. 枚举System Service Descriptor Table (SSDT)  
    KeServiceDescriptorTable  
15. 枚举System Service Shadow Descriptor Table (SSSDT)  
    KeServiceDescriptorTableShadow  
16. 枚举Global Descriptor Table (GDT)  
17. 枚举Interrupt Descriptor Table (IDT)  
    注意：Interrupt Vector Table (IVT)  
18. 枚举过滤设备。如：TDI，NPFS，MSFS，NSI等。  
    之所以说是设备而不是驱动，是因为  
    其一：IoAttachDevice(ByPointer) + IoAttachDeviceToDeviceStack(Safe)  
    其二：TDI的设备名不变，但是它所在的驱动在变。  
    其三：常规流程下，驱动的派遣函数只有基于设备的IRP才会被调用。  
19. 枚举和移除关机回调。  
    注册包括：IoRegisterShutdownNotification，IoRegisterLastChanceShutdownNotification，  
    反注册用：IoUnregisterShutdownNotification（Shutdown + LastChanceShutdown）。  
20. 枚举和移除蓝屏回调。  
    注册支持：KeRegisterBugCheckCallback， KeRegisterBugCheckReasonCallback。  
    反注册支持：KeDeregisterBugCheckCallback，KeDeregisterBugCheckReasonCallback  
21. 枚举类型对象。  
    即：对象目录\ObjectTypes下的成员及信息。  
    驱动可创建，也可修改（系统有保护）。  
22. 枚举驱动对象。  
    主要显示一些函数信息，如：MajorFunction，FastIoDispatch等。  
23. 枚举和反注册Ex回调。  
    ExRegisterCallback + ExUnregisterCallback。(对象目录:\Callback)  
24. 枚举和反注册会话回调  
   （IoRegisterContainerNotification，非SeRegisterLogonSessionTerminatedRoutine/Ex.)  
25. 枚举HalDispatchTable  
    没有使用符号解析，没有使用特征码。  
26. 枚举已经卸载的驱动
27. 给进程赋予System的Token权限，相当于NT AUTHORITY\SYSTEM。  
    没有使用符号解析，没有使用特征码。  
    有待验证是否会触发系统的保护机制（PG/KPP).  
28. 设置进程的ProcessProtectionLevel。  
    没有使用符号解析，没有使用特征码。  
    有待验证是否会触发系统的保护机制（PG/KPP).  
29. 修改进程的句柄的权限。  
    如：0x1fffff,这个可以和ObRegisterCallbacks对抗，逃避监控。  
    验证：先切换到目标进程（.process /r /p 0xXXXXXX），然后运行!handle 0xxx。  
    危险：谨慎使用，弄不好会卡系统。  
    有待验证是否会触发系统的保护机制（PG/KPP).  
30. 枚举PiDDBCache  
31. 枚举HalAcpiDispatchTable  
32. 枚举HalSubComponents  
33. 枚举HalIommuDispatchTable  
    没有定义数据结构。结构的大小，以及成员的名字，类型，偏移等都是解析符号文件得出。  
    相当于：r $t1 = nt!HalIommuDispatchTable;dt nt!_HAL_IOMMU_DISPATCH @$t1 的加强版  
34. 枚举HalPrivateDispatchTable
35. 枚举KeServiceDescriptorTableFilter。  
    win32k!W32pServiceTableFilter = win32k!SysEntryGetW32pServiceTableFilter()  
    KeAddSystemServiceTable(W32pServiceTableFilter, 0i64, W32pServiceLimitFilter, &W32pArgumentTableFilter, 2);  
36. 枚举和反注册不可屏蔽中断(NMI:nonmaskable interrupt)回调。  
    KeRegisterNmiCallback + KeDeregisterNmiCallback  
37. 枚举LookasideList信息。  
    ExNPagedLookasideListHead + ExPagedLookasideListHead + ExSystemLookasideListHead + ExPoolLookasideListHead  
38. 枚举执行体资源（_ERESOURCE）信息。  
    ExpSystemResourcesList + ExpResourceSpinLock
39. 物理内存相关。  
    枚举物理内存，当前是分块进行的，也可以按照页进行的。MmGetPhysicalMemoryRanges + MmIsIoSpaceActive  
    读写物理内存。MmMapIoSpace + MmUnmapIoSpace + MmProbeAndLockPages 又改为在驱动调用KdSystemDebugControl实现  
    物理内存与虚拟内存（必须是内核内存且非分页）的互转。MmGetVirtualForPhysical + MmGetPhysicalAddress  
40. 枚举和反注册PNP通知。  
    PnpProfileNotifyList + PnpDeviceClassNotifyList + PnpDeferredRegistrationList + PnpKsrNotifyList  
    IoUnregisterPlugPlayNotificationEx  
41. 枚举和反注册电源设置回调。  
    PopRegisteredPowerSettingCallbacks + PopSettingLock + PoUnregisterPowerSettingCallback  
42. 读写nt!PspNotifyEnableMask。
43. 枚举和反注册ImageVerificationCallback。  
    SeRegisterImageVerificationCallback + SeUnregisterImageVerificationCallback  
44. 枚举和反注册FsNotifyChange。  
    IoRegisterFsRegistrationChange + IoRegisterFsRegistrationChangeEx + IoRegisterFsRegistrationChangeMountAware + IoUnregisterFsRegistrationChange  
45. 枚举和反注册LogonSessionTerminatedRoutine。  
    SeRegisterLogonSessionTerminatedRoutine + SeUnregisterLogonSessionTerminatedRoutine  
46. 枚举和反注册LogonSessionTerminatedRoutineEx。  
    SeRegisterLogonSessionTerminatedRoutineEx + SeUnregisterLogonSessionTerminatedRoutineEx  
47. 枚举和反注册SiloMonitor。  
    PsRegisterSiloMonitor + PsUnregisterSiloMonitor。  
48. 枚举nt!HalpRegisteredInterruptControllers。  
    !list -t nt!_LIST_ENTRY.Flink -x "dx -r2 (nt!_REGISTERED_INTERRUPT_CONTROLLER *)" -e -m poi(nt!HalpInterruptControllerCount) poi(nt!HalpRegisteredInterruptControllers)  
49. 在应用层枚举 POOL TAG 和 BIG POOL。  
50. 在应用层枚举 NamedPipe。  
51. 枚举ndis!ndisGlobalOpenList.  
    .for (r $t0 = poi(ndis!ndisGlobalOpenList); @$t0 != 0; r $t0 = poi(@$t0 + @@(#FIELD_OFFSET(ndis!_NDIS_COMMON_OPEN_BLOCK, NextGlobalOpen)))) { dt ndis!_NDIS_OPEN_BLOCK @$t0 }  
52. 枚举ndis!ndisGlobalFilterList.  
    .for (r $t0 = poi(ndis!ndisGlobalFilterList); @$t0 != 0; r $t0 = poi(@$t0 + @@(#FIELD_OFFSET(ndis!_NDIS_FILTER_BLOCK, NextGlobalFilter)))) { dt ndis!_NDIS_FILTER_BLOCK @$t0 }  
53. 在应用层枚举进程的KernelCallbackTable。  
    自己确保以读权限打开目标进程，如：干掉ObRegisterCallbacks的保护，去掉PPL标志等。  
54. 枚举ndis!ndisMiniportList  
    .for (r $t0 = poi(ndis!ndisMiniportList); @$t0 != 0; r $t0 = poi(@$t0 + @@(#FIELD_OFFSET(ndis!_NDIS_MINIPORT_BLOCK, NextGlobalMiniport)))) { dt ndis!_NDIS_MINIPORT_BLOCK @$t0 }  
55. 注入DLL到目标进程。  
    驱动实现，更加隐蔽和不易（被宿主进程）察觉。  
    不支持的进程有：Minimal processes，Pico processes，Protected processes。  
    支持的进程有：Native processes，WOW64进程，托管的进程（估计也支持）。  
    考虑加入注入PPL进程：使被注入的（无签名和认证）DLL让Windows认为是KnownDlls/KnownDlls32下的DLL。  
56. Dump SharedUserData  
    !kuser + dt nt!_KUSER_SHARED_DATA fffff78000000000  
57. 读写 NtGlobalFlag + NtGlobalFlag2  
    !gflag  
    另一思路：NtQuerySystemInformation/NtSetSystemInformation + SystemFlagsInformation/SystemFlags2Information  
58. Dump nt!KdDebuggerDataBlock(nt!_KDDEBUGGER_DATA64)  
59. 在应用层枚举当前会话的WindowStations/Desktop/Window/ChildWindow。  
60. 在应用层生成LiveKernelDump（调用NtSystemDebugControl实现）  
61. 在应用层枚举Firmware。  
    暂时不支持修改和删除等操作。  
62. 在应用层枚举SMBIOS  
63. AlpcPort  
    枚举所有:ALPC_CONNECTION_PORT + ALPC_CLIENT_COMMUNICATION_PORT + ALPC_SERVER_COMMUNICATION_PORT。  
    阻断通讯:修改ALPC_CLIENT_COMMUNICATION_PORT/ALPC_SERVER_COMMUNICATION_PORT的State，也可恢复  
    断开连接:ZwAlpcDisconnectPort/AlpcpDisconnectPort(ALPC_CONNECTION_PORT)  
    日志开关:即读写nt!AlpcpLogEnabled。  
    监控收发:尚未实现，有待继续。  
    !list -t nt!_LIST_ENTRY.Flink -x "dx (nt!_ALPC_PORT *)" -e poi(nt!AlpcpPortList)  
64. 枚举 Job 内核对象  
    nt!PspJobList nt!PspJobListLock nt!_EJOB  
    暂时没有添加删除和修改的操作。  
65. 调用（任意）内核的函数 和 run kernel shellcode  
    前者是便于开发，内部使用，说是任意，其实有好多限制；后者是供攻防人员使用。  
    本驱动除了安装和启动需要管理员的权限，任意用户都可以打开本驱动。  
66. ETW  
    枚举 Provider（包括ClassicProvider）：EtwRegister/EtwRegisterClassicProvider  
    反注册 Provider（包括ClassicProvider）：EtwUnregister  
    枚举 Consumer : _ETW_REALTIME_CONSUMER + _WMI_LOGGER_CONTEXT  
    断开/删除 Consumer : EtwpRealtimeDisconnectConsumer/EtwpDeleteRealTimeConnectionObject  
67. 枚举和反注册Shim  
    KseRegisterShim KseRegisterShimEx KseUnregisterShim  
68. 枚举CiCallback(g_CiCallbacks/SeCiCallbacks)和读写g_CiOptions。  

考虑添加的功能：
* 工作线程.    尽管生命周期很短。  
* 反汇编引擎，如：zydis。  
* 反编译引擎，如：retdec。  
* 脚本引擎：lua  
* 硬件虚拟化相关的。  
* 系统热键 和 消息钩子。  
* 本地内核调试。  
* ApiSet 应用层枚举 驱动修改（有PG/KPP保护）  
* PsRegisterPicoProvider  
* PcwRegister PcwUnregister  
* NmrpRegisterModule == NmrRegisterClient + NmrRegisterProvider + WskRegister。  
* ExRegisterHost + ExRegisterExtension + ExUnregisterExtension  
* Boot Graphics Resource Table (BGRT)  
  Firmware Performance Data Table (FPDT)  
  Unified Extensible Firmware Interface (UEFI)  
  Root System Description Table (RSDT)  
  Fixed ACPI Description Table (FADT)  
  Multiple APIC Description Table (MADT)  
  Generic Timer Description Table (GTDT)  
  Core System Resources Table (CSRT)  
  Debug Port Table 2 (DBG2)  
  Differentiated System Description Table (DSDT)  
  Windows SMM Security Mitigations Table (WSMT)  
  iSCSI Boot Firmware Table (iBFT)  

确定不添加的功能：
1. 进程
2. 文件
3. 注册表
4. MBR      已经过时了。
5. 端口     因为有netstat和tcpview.exe。
6. LSP      参见 https://github.com/kouzhudong/libnet
7. 系统线程     因为有procexp.exe。
8. 句柄         因为有procexp.exe。
9. 启动项       因为有Autoruns.exe。
10. 驱动模块    driverquery等工具都有。
11. 系统服务    系统自带的功能。
12. 计划任务    系统自带的功能。
13. 防火墙规则  系统自带的功能。
14. 设备管理器  系统自带的功能。
15. 证书管理器  系统自带的功能。

2024-01-13
