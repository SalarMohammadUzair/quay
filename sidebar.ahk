#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "Gdip_All.ahk"
Esc::ExitApp

; 1. READ THE CONFIG FILE
; IniRead(DefaultValue, Filename, Section, Key)
cfgPosition := IniRead("config.ini", "Design", "Position", "Left") ; if we find nothing in config.ini to define it, use LEFT as fallback
cfgWidth := IniRead("config.ini", "Design",  "Width", 48) ; if we find nothing in config.ini to define it, use 48 as fallback
cfgColor := IniRead("config.ini", "Design", "BackgroundColor", "141414" )
cfgTop := IniRead("config.ini", "Design",  "TopOffset", 0)

; calculate the total height of the bar based on the top offset
BarHeight := A_ScreenHeight - cfgTop

; Do the math for the position
if (cfgPosition = "Right")
    posX := A_ScreenWidth - cfgWidth
else
    posX := 0


; Create and show the window

myBar := Gui("+AlwaysOnTop -Caption +ToolWindow", "MySidebar")

myBar.BackColor := cfgColor
myBar.Show("x" . posX . " y" . cfgTop . " w" . cfgWidth . " h" . BarHeight . " NoActivate")
edgeCode := (cfgPosition ="Right") ? 2 : 0

global cbSize := A_PtrSize = 8 ? 48 : 36
global abd := Buffer(cbSize, 0)
OnExit(CleanupBar)
CleanupBar(*) {
    DllCall("Shell32\SHAppBarMessage", "UInt", 1, "Ptr", abd)
    return 0
}

RegisterAppBar(mybar.Hwnd, cfgWidth, cfgTop, A_ScreenHeight, edgeCode)
WM_TASKBARCREATED := DllCall("RegisterWindowMessage", "Str", "TaskbarCreated")
OnMessage(WM_TASKBARCREATED, OnTaskbarRestart)
OnTaskbarRestart(wParam, lParam, msg, hwnd) {
    global myBar, cfgWidth, cfgTop, edgeCode
    RegisterAppBar(myBar.Hwnd, cfgWidth, cfgTop, A_ScreenHeight, edgeCode)
}
 ;
RegisterAppBar(hwnd, width, topOffset, screenHeight, edgeCode) {
    global abd, cbSize
    NumPut("UInt", cbSize, abd, 0)
    NumPut("Ptr", hwnd, abd, A_PtrSize = 8 ? 8 : 4)
    NumPut("UInt", edgeCode, abd, A_PtrSize = 8 ? 20 : 12) 

    rcOffset := A_PtrSize = 8 ? 24 : 16
    if (edgeCode = 2) {
        ; Right Side
        NumPut("Int", A_ScreenWidth - width, abd, rcOffset)
        NumPut("Int", topOffset, abd, rcOffset + 4)
        NumPut("Int", A_ScreenWidth, abd, rcOffset + 8)
        NumPut("Int", screenHeight, abd, rcOffset + 12)
    }
    else {
        ; Left Side
        NumPut("Int", 0, abd, rcOffset)
        NumPut("Int", topOffset, abd, rcOffset + 4)
        NumPut("Int", width, abd, rcOffset + 8)
        NumPut("Int", screenHeight, abd, rcOffset + 12)
    }

    DllCall("Shell32\SHAppBarMessage", "UInt", 0, "Ptr", abd)
    DllCall("Shell32\SHAppBarMessage", "UInt", 3, "Ptr", abd)
}

global BarVisible := true
    SetTimer(CheckFullscreen, 200)

    CheckFullscreen() {
        global BarVisible, myBar
        if IsRealFullscreen() {
            if BarVisible {
                myBar.Hide()
                BarVisible := false
            }
        } else {
            if !BarVisible {
                myBar.Show("NoActivate")
                BarVisible := true
            }
        }
    }

    IsRealFullscreen() {
        global myBar
        hwnd := DllCall("GetForegroundWindow", "Ptr")
        if (!hwnd || hwnd = myBar.Hwnd)
            return false
        if !DllCall("IsWindow", "Ptr", hwnd)
            return false
        try {
            className := WinGetClass("ahk_id " hwnd)
            if (className = "Progman" || className = "WorkerW")
                return false
        } catch {
        }
        exStyle := DllCall("GetWindowLong", "Ptr", hwnd, "Int", -20, "Int")
        if (exStyle & 0x8)
            return false
        rc := Buffer(16, 0)
        if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rc)
            return false
        if !(NumGet(rc, 0, "Int") = 0 && NumGet(rc, 4, "Int") = 0
          && NumGet(rc, 8, "Int") = A_ScreenWidth && NumGet(rc, 12, "Int") = A_ScreenHeight)
            return false
        crc := Buffer(16, 0)
        if !DllCall("GetClientRect", "Ptr", hwnd, "Ptr", crc)
            return false
        return (NumGet(crc, 8, "Int") = A_ScreenWidth && NumGet(crc, 12, "Int") = A_ScreenHeight)
    }