## registering as an AppBar
- RegisterAppBar calls the Windows Shell API (`SHAppBarMessage`) to reserve
  screen space so other windows don't overlap the bar
- edge parameter tells Windows which side of the screen to dock against:

| Value | Constant     | Edge   |
|-------|--------------|--------|
| 0     | ABE_LEFT     | Left   |
| 1     | ABE_TOP      | Top    |
| 2     | ABE_RIGHT    | Right  |
| 3     | ABE_BOTTOM   | Bottom |

# does it finally work? is wakatime working?
why not detecto? vcf
### DWM ( desktop windows managaer ) API
DLL call : dwmapi\DwmGetWindowAttribute
 Why we use it: Windows 10/11 is notorious for leaving UWP apps (like Calculator, Settings, or Cortana) running silently
in the background. If you just ask Windows for a list of open windows, it will give you dozens of invisible ones. We
call this DLL and pass 14 (which stands for DWMWA_CLOAKED) to check if the window is currently being "cloaked" by the
OS. If it is, we skip it so it doesn't show up in the dock.

### Core User32 DLLs (Filtering out the junk)
To get the clean list of actual, usable apps (like Alt+Tab does), we use a few strict filters from User32.dll:

• IsWindowVisible: The first line of defense; if the window is fundamentally hidden, ignore it.
• GetWindowLongPtr: We pass -20 to check the Extended Styles of the window. If it has WS_EX_TOOLWINDOW (0x80), it means
it's a tiny floating widget or tooltip, so we ignore it.
• GetWindow (with GW_OWNER = 4): This checks if the window is a child dialog box (like a "Save As" window). If a window
has an owner, we usually don't want to show it in the dock as its own separate app.
### The `WinHttp.WinHttpRequest.5.1` COM Object
Why we use it: AutoHotkey v2 doesn't have a native fetch() command like JavaScript. We instantiate this old-school
Windows COM object to make HTTP requests to LibreHardwareMonitor and Home Assistant.
We enforce strict 500ms timeouts (req.SetTimeouts(500, 500, 500, 500)). Without this, if our Home Assistant
server goes offline, the sidebar would completely freeze while waiting for a response
### The Shell.Application COM Object (Quick Actions Magic)
Why we use it: This is what powers the Quick Actions (opening Terminal or Everything Search). We hook into
Shell.Application.Windows, find the exact File Explorer window you currently have active, and query
window.Document.Folder.Self.Path. This allows the sidebar to instantly grab the folder path you are currently looking
at, and inject it as a command line argument into wt.exe or Everything.exe.
sure man, this should work and i just want to yap