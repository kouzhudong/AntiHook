# AntiHook
Enum and Remove Hook in Windows Kernel

设计目标：
1. 别的ARK工具没有的，或者很少有的，或者不开源的。
2. 自己喜欢的，常用的，避免自己繁琐的windbg操作。
3. procexp.exe和processhacker及SystemInformer.exe有的，这里一律不添加。
4. 应用层能实现的一般不添加，除非我喜欢，或者特别的奇特。
5. 不支持32位。
6. 不支持GUI。
7. 多使用符号文件，尽量减少硬编码。

已经实现的功能：
1. 枚举和移除进程回调。  
   PsSetCreateProcessNotifyRoutine + PsSetCreateProcessNotifyRoutineEx + PsSetCreateProcessNotifyRoutineEx2  
2. 枚举和移除线程回调。  
   PsSetCreateThreadNotifyRoutine + PsSetCreateThreadNotifyRoutineEx + PsRemoveCreateThreadNotifyRoutine  
3. 枚举和移除IMAGE回调。  
   PsSetLoadImageNotifyRoutine + PsSetLoadImageNotifyRoutineEx + PsRemoveLoadImageNotifyRoutine  
   暂时不支持：SeRegisterImageVerificationCallback + SeUnregisterImageVerificationCallback  
4. 枚举和移除注册表回调。  
   CmRegisterCallback + CmRegisterCallbackEx + CmUnRegisterCallback
5. 枚举和移除对象（进程，线程，桌面）回调。  
   ObRegisterCallbacks + ObUnRegisterCallbacks  
6. 枚举和移除MiniFilter。  
   FltRegisterFilter + FltUnregisterFilter（有待测试）  
7. 枚举和反注册WFP的Callout。  
   FwpsCalloutRegister + FwpsCalloutUnregisterById（有待测试）  
   没有使用符号解析，没有使用硬编码，使用导出的函数。  
8. 枚举网络协议驱动。  
   NdisRegisterProtocolDriver + NdisRegisterProtocol
9. 枚举网络过滤驱动。  
   特指通过NdisFRegisterFilterDriver注册的。
10. 枚举小端口网卡驱动。注意：不是网卡个数。  
    NdisMRegisterMiniportDriver  
11. 枚举和删除DPC定时器。有待完善。  
    以Zw/Nt开头的定时器也属于这个。  
    KeCancelTimer。
12. 枚举和停止IO定时器。  
    IoInitializeTimer + IoStopTimer 
13. 枚举EX定时器。有待分析。  
    ExAllocateTimer  
14. 枚举System Service Descriptor Table (SSDT)
15. 枚举System Service Shadow Descriptor Table (SSSDT)
16. 枚举Global Descriptor Table (GDT)
17. 枚举Interrupt Descriptor Table (IDT) 注意区别：Interrupt Vector Table (IVT)  
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
22. 枚举驱动对象。主要显示一些函数信息，如：MajorFunction，FastIoDispatch等。  
23. 枚举和反注册Ex回调。ExRegisterCallback + ExUnregisterCallback。(对象目录:\Callback)
24. 枚举和反注册会话回调（IoRegisterContainerNotification，非SeRegisterLogonSessionTerminatedRoutine/Ex.)
25. Dump HalDispatchTable  
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
    没有使用符号解析，没有使用特征码。  
    有待验证是否会触发系统的保护机制（PG/KPP).  
30. Dump PiDDBCache  
31. Dump HalAcpiDispatchTable  
32. Dump HalSubComponents  

考虑添加的功能：
1. 工作线程.    尽管生命周期很短。
2. 反汇编引擎，如：zydis。
3. 硬件虚拟化相关的。
4. 读写内核内存。
5. 本地内核调试。
6. EtwRegister EtwUnregister
7. IoRegisterPlugPlayNotification
8. KseRegisterShim KseRegisterShimEx KseUnregisterShim
9. PcwRegister PcwUnregister
10. NmrpRegisterModule == NmrRegisterClient + NmrRegisterProvider + WskRegister。
11. PsRegisterSiloMonitor
12. PsRegisterPicoProvider
13. 系统热键
14. Unified Extensible Firmware Interface (UEFI)
15. Root System Description Table (RSDT)
16. Fixed ACPI Description Table (FADT)
17. Multiple APIC Description Table (MADT)
18. Generic Timer Description Table (GTDT)
19. Core System Resources Table (CSRT)
20. Debug Port Table 2 (DBG2)
21. Differentiated System Description Table (DSDT)
22. Windows SMM Security Mitigations Table (WSMT)
23. iSCSI Boot Firmware Table (iBFT)
24. Boot Graphics Resource Table (BGRT)
25. Firmware Performance Data Table (FPDT)

确定不添加的功能：
1. 进程
2. 文件
3. 注册表
4. MBR      已经过时了。
5. 端口     因为有netstat和tcpview.exe。
6. LSP
7. 系统线程     因为有procexp.exe。
8. 句柄         因为有procexp.exe。
9. 启动项       因为有Autoruns.exe。
10. 驱动模块    driverquery等工具都有。
11. 系统服务    系统自带的功能。
12. 计划任务    系统自带的功能。
13. 防火墙规则  系统自带的功能。

2024-01-13
