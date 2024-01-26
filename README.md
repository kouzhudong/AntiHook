# AntiHook
Enum and Remove Hook in Windows Kernel

设计目标：
1. 别的ARK工具没有的，或者很少有的，或者不开源的。
2. 自己喜欢的，常用的，避免自己繁琐的windbg操作。
3. procexp.exe和processhacker及SystemInformer.exe有的，这里一律不添加。
4. 应用层能实现的一般不添加，除非我喜欢，或者特别的嘎咕奇特。
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
7. 枚举WFP。  
   FwpsCalloutRegister + FwpsCalloutUnregisterById（有待测试）
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
14. 枚举SSDT
15. 枚举SSSDT
16. 枚举GDT
17. 枚举IDT
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
22. 枚举驱动对象。主要显示一些函数信息。
23. 枚举和反注册Ex回调。ExRegisterCallback + ExUnregisterCallback。(对象目录:\Callback)

考虑添加的功能：
1. 工作线程.    尽管生命周期很短。
2. 反汇编引擎，如：zydis。
3. 硬件虚拟化相关的。
4. 读写内核内存。
5. 本地内核调试。
6. 会话回调（IoRegisterContainerNotification，非SeRegisterLogonSessionTerminatedRoutine/Ex.)
7. IoRegisterPlugPlayNotification
8. KseRegisterShim
9. PcwRegister

确定不添加的功能：
1. 进程
2. 文件
3. 注册表
4. MBR
5. 端口
6. LSP
7. 系统线程
8. 系统热键
9. 句柄

2024-01-13

---

决定：
1. 不公布源码。  
2. 不公开裸体二进制。  
   所有自己写的二进制都加VMP壳。  
3. 加入许可认证验证机制。  
4. 支持更新。  
   需要访问github.  
   如果支持更新，不能加入二进制的签名认证，这可以自己制作证书验证。  
5. 

2024-01-21 
