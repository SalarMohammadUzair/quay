#Requires AutoHotkey v2.0
#Include "Gdip_All.ahk"

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
RegisterAppBar(mybar.Hwnd, cfgWidth, cfgTop, A_ScreenHeight, edgeCode)
 ; 
 RegisterAppBar(hwnd, width, topOffset, screenHeight, edgeCode) {
    cbSize := A_PtrSize = 8 ? 48 : 36
    abd := Buffer(cbSize, 0)
    NumPut("UInt", cbSize, abd, 0)
    NumPut("Ptr", hwnd, abd, A_PtrSize = 8 ? 8 : 4 )

    ; tell windows what coordinates to curve out and reserver for our sidebar
    rcOffset := A_PtrSize = 8 ? 24 : 16
    if (edgeCode = 2) {
        NumPut("Int", 0, abd, rcOffset)
        Numput("Int", topOffset, abd, rcOffset + 4)
        NumPut("Int", width, abd, rcOffset + 8)
        NumPut("Int", screenHeight, abd, rcOffset + 12)
    }
    else{
        NumPut("Int", A_ScreenWidth - width, abd, rcOffset)
        NumPut("Int", topOffset, abd, rcOffset + 4)
        NumPut("Int", A_ScreenWidth, abd, rcOffset + 8)
        NumPut("Int", screenHeight, abd, rcOffset + 12)
        
    }
    

    ; send the message to windows
    DllCall("Shell32\SHAppBarMessage", "UInt", 0, "Ptr", abd) ; ABM_NEW (register the bar)
    DllCall("Shell32\SHAppBarMessage", "UInt", 3, "Ptr", abd) ; ABM_QUERYPOS (reserver space)
    ; if the script crashes, un reserver the space
    OnExit((*) => DllCall("Shell32\SHAppBarMessage", "UInt", 1, "Ptr", abd)) 
}