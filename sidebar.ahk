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