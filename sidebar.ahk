#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "Gdip_All.ahk"
global pToken := Gdip_Startup()
Esc::ExitApp

; 1. READ THE CONFIG FILE
; IniRead(DefaultValue, Filename, Section, Key)
cfgPosition := IniRead("config.ini", "Design", "Position", "Left") ; if we find nothing in config.ini to define it, use LEFT as fallback
cfgWidth := IniRead("config.ini", "Design",  "Width", 48) ; if we find nothing in config.ini to define it, use 48 as fallback
cfgColor := IniRead("config.ini", "Design", "BackgroundColor", "141414" )
cfgTop := IniRead("config.ini", "Design",  "TopOffset", 0)
; Read paths from config (No hardcoded C:\ fallbacks!)
global pathBase       := IniRead("config.ini", "Paths", "UserDirBase", "")
global pathEverything := IniRead("config.ini", "Paths", "EverythingExe", "")
global pathTerminal   := IniRead("config.ini", "Paths", "TerminalExe", "")

; Dynamically construct the folder targets
global targetDownloads := pathBase . "Downloads"
global targetDocuments := pathBase . "Documents"
global targetCode      := pathBase . "Documents\(02)Mycodeworks"
global targetShots     := pathBase . "Pictures\Screenshots"




; calculate the total height of the bar based on the top offset
BarHeight := A_ScreenHeight - cfgTop

; Do the math for the position
if (cfgPosition = "Right")
    posX := A_ScreenWidth - cfgWidth
else
    posX := 0


; sizing math for the widget containers
RowH := 13
ValH := 16
Gap := 6
BottomPad := 10

GroupH := RowH + (ValH - 3) + ValH
MicroSepH := 12
StatsContentH := (GroupH + Gap) * 4 - Gap + MicroSepH + (GroupH + Gap) * 3 - Gap
ContainerPadTop := 12
ContainerPadBot := BottomPad
global StatsBlockHeight := StatsContentH + ContainerPadTop + ContainerPadBot

global containerY := BarHeight - StatsBlockHeight
statStartY := containerY + ContainerPadTop

; Create and show the window

myBar := Gui("+AlwaysOnTop -Caption +ToolWindow", "MySidebar")
myBar.SetFont("s14 cWhite", "Segoe Fluent Icons")
myBar.Add("Text", "w" . cfgWidth . " h10 BackgroundTrans", "") ; Top padding
btnDownloads  := myBar.Add("Text", "w" . cfgWidth . " h36 x0 Center BackgroundTrans", Chr(0xE896))
btnDocuments  := myBar.Add("Text", "w" . cfgWidth . " h36 x0 Center BackgroundTrans", Chr(0xE8A5))
btnCode       := myBar.Add("Text", "w" . cfgWidth . " h36 x0 Center BackgroundTrans", Chr(0xE8B7))
btnShots      := myBar.Add("Text", "w" . cfgWidth . " h36 x0 Center BackgroundTrans", Chr(0xE8B9))
btnTerminal   := myBar.Add("Text", "w" . cfgWidth . " h36 x0 Center BackgroundTrans", Chr(0xE756))
btnEverything := myBar.Add("Text", "w" . cfgWidth . " h36 x0 Center BackgroundTrans", Chr(0xE721))

btnDownloads.OnEvent("Click",  (*) => OpenFolderInExplorer(targetDownloads))
btnDocuments.OnEvent("Click",  (*) => OpenFolderInExplorer(targetDocuments))
btnCode     .OnEvent("Click",  (*) => OpenFolderInExplorer(targetCode))
btnShots    .OnEvent("Click",  (*) => OpenFolderInExplorer(targetShots))
btnTerminal .OnEvent("Click",  OpenTerminalInCurrentDir)
btnEverything.OnEvent("Click", OpenEverythingInCurrentDir)





hContainerBmp := DrawStatsContainers()
global ctrlContainerBg := myBar.Add("Picture", "x0 y" . containerY . " w" . cfgWidth . " h" . StatsBlockHeight . " +0xE")
SendMessage(0x172, 0, hContainerBmp, , "ahk_id " ctrlContainerBg.Hwnd)
DeleteObject(hContainerBmp)

; ── Stat colours ─────────────────────────────────────────────────────────────
StatValueColor := "000000"
StatDimColor   := "333333"
global ContentX := 8
AccentSolid    := "000000" ; Thick black accent lines for neo-brutalism

myBar.SetFont("s14 cWhite", "Segoe Fluent Icons")

; ── Helper: add a coloured section label, advance y ──────────────────────────
AddLabel(label, accent, &y) {
    global myBar, cfgWidth, RowH, ValH, StatValueColor, ContentX, GroupH
    myBar.Add("Progress", "x3 y" . y . " w2 h" . GroupH
        . " c" . accent . " Background" . accent . " -Smooth", 100)
    myBar.SetFont("s7 bold c000000", "Consolas")
    myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2)
        . " h" . RowH . " BackgroundTrans y" . y, label)
    y += RowH - 2
    myBar.SetFont("s9 bold c" . StatValueColor, "Consolas")
}

y := statStartY

; ── CPU ──────────────────────────────────────────────────────────────────────
AddLabel("CPU", AccentSolid, &y)
global txtCpuT := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--°")
y += ValH - 3
myBar.SetFont("s8 c" . StatDimColor, "Consolas")
global txtCpuW := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--W")
y += ValH + Gap

; ── GPU ──────────────────────────────────────────────────────────────────────
AddLabel("GPU", AccentSolid, &y)
global txtGpuT := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--°")
y += ValH - 3
myBar.SetFont("s8 c" . StatDimColor, "Consolas")
global txtGpuW := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--W")
y += ValH + Gap

; ── RAM ──────────────────────────────────────────────────────────────────────
AddLabel("RAM", AccentSolid, &y)
global txtRamU  := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--R")
y += ValH - 3
myBar.SetFont("s8 c" . StatDimColor, "Consolas")
global txtCommU := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--C")
y += ValH + Gap

; ── NET ──────────────────────────────────────────────────────────────────────
AddLabel("NET", AccentSolid, &y)
myBar.SetFont("s8 bold c" . StatValueColor, "Consolas")
global txtNetD  := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "-- ↓")
y += ValH - 3
myBar.SetFont("s8 c" . StatDimColor, "Consolas")
global txtNetU := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "-- ↑")
y += ValH

y += 4
y += MicroSepH - 4 + Gap

; ── INV ──────────────────────────────────────────────────────────────────────
AddLabel("INV", AccentSolid, &y)
global txtLoadPower  := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--kW")
y += ValH - 3
myBar.SetFont("s8 c" . StatDimColor, "Consolas")
global txtBatteryPct := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--%")
y += ValH + Gap

; ── PV1 ──────────────────────────────────────────────────────────────────────
AddLabel("PV1", AccentSolid, &y)
global txtPv1W := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--kW")
y += ValH - 3
myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "")
y += ValH + Gap

; ── GRD ──────────────────────────────────────────────────────────────────────
AddLabel("GRD", AccentSolid, &y)
global txtGridW := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--kW")
y += ValH - 3
myBar.SetFont("s8 c" . StatDimColor, "Consolas")
global txtBatteryW := myBar.Add("Text", "x" . ContentX . " w" . (cfgWidth - ContentX - 2) . " h" . ValH . " BackgroundTrans y" . y, "--kW")

myBar.BackColor := cfgColor
myBar.Show("x" . posX . " y" . cfgTop . " w" . cfgWidth . " h" . BarHeight . " NoActivate")
edgeCode := (cfgPosition ="Right") ? 2 : 0

global cbSize := A_PtrSize = 8 ? 48 : 36
global abd := Buffer(cbSize, 0)
OnExit(CleanupBar)
CleanupBar(*) {
    DllCall("Shell32\SHAppBarMessage", "UInt", 1, "Ptr", abd)
    Gdip_Shutdown(pToken)
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
; ---------------------------------------------------------------------------------------------------------------------
; break, next logic


; Drawing function

DrawStatsContainers() {
    global cfgWidth, StatsBlockHeight
    global GroupH, Gap, MicroSepH, ContainerPadTop

    pad := 4
    bmpH := StatsBlockHeight

    pcY := ContainerPadTop - 6
    pcH := (GroupH + Gap) * 4 - Gap + 6

    solarY := pcY + pcH + MicroSepH
    solarH := bmpH - solarY - 4

    pBitmap := Gdip_CreateBitmap(cfgWidth, bmpH)
    G := Gdip_GraphicsFromImage(pBitmap)
    
    ; Disable smoothing for sharp, jagged, raw edges
    Gdip_SetSmoothingMode(G, 1)

    ; Background color (matches your sidebar)
    pBgBrush := Gdip_BrushCreateSolid(0xFF141414)
    Gdip_FillRectangle(G, pBgBrush, 0, 0, cfgWidth, bmpH)
    Gdip_DeleteBrush(pBgBrush)

    ; --- NOIR NEWSPAPER STYLING ---
    pShadowBrush := Gdip_BrushCreateSolid(0xFF000000) ; Pitch black hard shadow
    pCardBrush1  := Gdip_BrushCreateSolid(0xFFAFA99E) ; Subtle, muted newsprint (PC stats)
    pCardBrush2  := Gdip_BrushCreateSolid(0xFF9E988D) ; Darker, weathered newsprint (Solar)
    pBorderPen   := Gdip_CreatePen(0xFF000000, 2)     ; 2px thick ink border

    ; Hard shadow offsets
    sx := 4
    sy := 4

    ; =========================================
    ; 1. PRE-CALCULATE VARIABLES FOR PC CARD
    ; =========================================
    cardX := pad
    cardY := pcY
    cardW := cfgWidth - (pad * 2) - sx
    cardH := pcH - sy
    
    shadowX := cardX + sx
    shadowY := cardY + sy

    ; Draw PC Stats Card (Shadow -> Card -> Border)
    Gdip_FillRectangle(G, pShadowBrush, shadowX, shadowY, cardW, cardH)
    Gdip_FillRectangle(G, pCardBrush1,  cardX,   cardY,   cardW, cardH)
    Gdip_DrawRectangle(G, pBorderPen,   cardX,   cardY,   cardW, cardH)

    ; =========================================
    ; 2. PRE-CALCULATE VARIABLES FOR SOLAR CARD
    ; =========================================
    cardY := solarY
    cardH := solarH - sy
    shadowY := cardY + sy

    ; Draw Solar Stats Card (Shadow -> Card -> Border)
    Gdip_FillRectangle(G, pShadowBrush, shadowX, shadowY, cardW, cardH)
    Gdip_FillRectangle(G, pCardBrush2,  cardX,   cardY,   cardW, cardH)
    Gdip_DrawRectangle(G, pBorderPen,   cardX,   cardY,   cardW, cardH)

    ; Cleanup
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap, 0xFF141414)
    Gdip_DeleteBrush(pShadowBrush)
    Gdip_DeleteBrush(pCardBrush1)
    Gdip_DeleteBrush(pCardBrush2)
    Gdip_DeletePen(pBorderPen)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)

    return hBitmap
}
    ; appearnace work done, now we poll for syst4em stats

    ; data polling timers
    SetTimer(UpdateHardwareStats, 2000)
    UpdateHardwareStats()

    ; data fetching functions
    UpdateHardwareStats() {
        global txtCpuT, txtCpuW, txtGpuT, txtGpuW, txtRamU, txtCommU, txtNetD, txtNetU
        try {
            req := ComObject("WinHttp.WinHttpRequest.5.1")
            req.SetTimeouts(500, 500, 500, 500)
            req.Open("GET", "http://localhost:8085/data.json", false)
            req.Send()
            if (req.Status != 200)
                return
            json := req.ResponseText
            if RegExMatch(json, '"Text":"CPU Package"[^}]+?"Value":"([0-9.]+)[^"]*u00B0C"', &m)
                txtCpuT.Value := Round(m[1]) "°"
            if RegExMatch(json, '"Text":"CPU Package"[^}]+?"Value":"([0-9.]+)[^"]*W"', &m)
                txtCpuW.Value := Round(m[1]) "W"
            if RegExMatch(json, '"Text":"GPU Core"[^}]+?"Value":"([0-9.]+)[^"]*u00B0C"', &m)
                txtGpuT.Value := Round(m[1]) "°"
            if RegExMatch(json, '"Text":"GPU Package"[^}]+?"Value":"([0-9.]+)[^"]*W"', &m)
                txtGpuW.Value := Round(m[1]) "W"
            if RegExMatch(json, 's)"Text":"Virtual Memory".*?"Text":"Memory Used"[^}]+?"Value":"([0-9.]+)[^"]*GB"', &m)
                txtCommU.Value := Round(m[1], 1) "C"
            if RegExMatch(json, 's)"Text":"Total Memory".*?"Text":"Memory Used"[^}]+?"Value":"([0-9.]+)[^"]*GB"', &m)
                txtRamU.Value := Round(m[1], 1) "R"
                
            dlSum := 0.0
            ulSum := 0.0
            pos := 1
            while (pos := RegExMatch(json, '"Text":"Download Speed"[^}]+?"Value":"([0-9.]+)\s*([KMG]?B/s)"', &m, pos)) {
                val := Float(m[1])
                unit := m[2]
                if (unit == "MB/s")
                    val *= 1024
                else if (unit == "GB/s")
                    val *= 1048576
                else if (unit == "B/s")
                    val /= 1024
                dlSum += val
                pos += m.Len[0]
            }
            pos := 1
            while (pos := RegExMatch(json, '"Text":"Upload Speed"[^}]+?"Value":"([0-9.]+)\s*([KMG]?B/s)"', &m, pos)) {
                val := Float(m[1])
                unit := m[2]
                if (unit == "MB/s")
                    val *= 1024
                else if (unit == "GB/s")
                    val *= 1048576
                else if (unit == "B/s")
                    val /= 1024
                ulSum += val
                pos += m.Len[0]
            }
            dlKbps := dlSum * 8
            ulKbps := ulSum * 8

            txtNetD.Value := (dlKbps >= 1000) ? Format("{:.1f}", dlKbps / 1000) "M↓" : Format("{:.1f}", dlKbps) "K↓"
            txtNetU.Value := (ulKbps >= 1000) ? Format("{:.1f}", ulKbps / 1000) "M↑" : Format("{:.1f}", ulKbps) "K↑"
        } catch {
            ; Fail silently if LibreHardwareMonitor is not running

        } 
}

; --- QUICK ACTIONS LOGIC ---
GetActiveExplorerPath(window) {
    global pathBase
    currentPath := window.Document.Folder.Self.Path
    ; If the path doesn't have a drive letter (e.g. it just says "Documents")
    if !InStr(currentPath, ":") {
        currentPath := pathBase . currentPath
    }
    return currentPath
}

OpenEverythingInCurrentDir(*) {
    global pathEverything
    hwnd := WinActive("A")
    for window in ComObject("Shell.Application").Windows {
        if (window.hwnd == hwnd) {
            currentPath := GetActiveExplorerPath(window)
            Run('"' pathEverything '" -path "' currentPath '"')
            return
        }
    }
    Run('"' pathEverything '"')
}

OpenTerminalInCurrentDir(*) {
    global pathTerminal
    hwnd := WinActive("A")
    for window in ComObject("Shell.Application").Windows {
        if (window.hwnd == hwnd) {
            currentPath := GetActiveExplorerPath(window)
            Run('"' pathTerminal '" -d "' currentPath '"')
            return
        }
    }
    Run('"' pathTerminal '"')
}

OpenFolderInExplorer(path) {
    hwnd := WinExist("ahk_class CabinetWClass")
    if !hwnd {
        Run('"' path '"')
        return
    }
    WinActivate("ahk_id " hwnd)
    WinWaitActive("ahk_id " hwnd, , 1)
    Send("^t")
    Sleep(150)
    Explorer_Navigate_Tab(path, hwnd)
}

Explorer_Navigate_Tab(path, hwnd) {
    try activeTab := ControlGetHwnd("ShellTabWindowClass1", "ahk_id " hwnd)
    catch
        activeTab := 0

    for pExp in ComObject("Shell.Application").Windows {
        if (pExp.hwnd == hwnd) {
            if activeTab {
                static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
                try {
                    shellBrowser := ComObjQuery(pExp, IID_IShellBrowser, IID_IShellBrowser)
                    if shellBrowser {
                        ptr := shellBrowser.Ptr
                        vtbl := NumGet(ptr, "Ptr")
                        funcPtr := NumGet(vtbl, 3 * A_PtrSize, "Ptr")
                        DllCall(funcPtr, "Ptr", ptr, "Ptr*", &thisTab := 0)
                        if (thisTab != activeTab)
                            continue
                    }
                } catch {
                    continue
                }
            }
            try {
                pExp.Navigate("file:///" path)
                return
            }
        }
    }
    Run('"' path '"')
}