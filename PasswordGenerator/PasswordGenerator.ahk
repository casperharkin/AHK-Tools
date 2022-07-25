#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Instance := New GUI()
Exit ; END OF AUTO-EXECUTE SECTION


/*


[PASSWORDSETTINGS]
Min= 10
Max= 12


*/


class GUI 
{
	
	__New(){
		This.GuiObj := {} 																				; All of the window handles will be stored in here.
		This.CreateToolbar()  
		This.CreateGUI()
		This.CreateBorders()
		OnMessage(0x200, ObjBindMethod(this,"WM_MOUSEMOVE"))
		OnMessage(0x202, ObjBindMethod(this,"WM_LBUTTONUP"))
		OnMessage(0x201, ObjBindMethod(this,"WM_LBUTTONDOWN"))
		OnMessage(0x0111, ObjBindMethod(this,"WM_COMMAND"))
	}
	
	MenuHandler() {
		If (A_ThisMenuItem = "Open Settings") || (A_ThisMenuItem = "Open Password Generator")
			This.TabSwap()
		If (A_ThisMenuItem = "Open Password Generator")
			This.TabSwap()
		If (A_ThisMenuItem = "Copy Password to Clipboard")
			Clipboard := This.ClipPassword()
		If (A_ThisMenuItem = "Exit")
			ExitApp
	}
	
	WM_LBUTTONUP(wParam, lParam, Msg, Hwnd) {
		MouseGetPos,,,, MouseCtrl, 2
		If (MouseCtrl = This.GuiObj["ButtonPasswordEdit", "Handle"])
			Clipboard := This.ClipPassword()
		If (MouseCtrl = This.GuiObj["ButtonPasswordGenerate", "Handle"]) and !instr(A_ScriptFullPath, "\\.\pipe"){
			IniRead, Min, % A_ScriptFullPath, PASSWORDSETTINGS, Min
			IniRead, Max, % A_ScriptFullPath, PASSWORDSETTINGS, Max
			GuiControl,, Edit1, % Generate.Password(Min,Max)
		}
		If (MouseCtrl = This.GuiObj["ButtonPasswordGenerate", "Handle"]) And instr(A_ScriptFullPath, "\\.\pipe"){
			GuiControlGet, Min, , % This.GuiObj["ButtonSettingsvMin", "Handle"]
			GuiControlGet, Max, , % This.GuiObj["ButtonSettingsvMax", "Handle"]
			GuiControl,, Edit1, % Generate.Password(Min,Max)
		}
		If (MouseCtrl = This.GuiObj["ButtonMenuSettingsT", "Handle"])
			This.TabSwap()	
		If (MouseCtrl = This.GuiObj["ButtonMenuAboutT", "Handle"])
			MsgBox 0x40040, About, The password generator was created by /u/0xB0BAFE77. `n`nThe GUI was created by /u/CasperHarkin
		If (MouseCtrl = This.GuiObj["ButtonMenuFileT"].Handle){
			ControlGetPos, ctlX, ctlY, ctlW, ctlH,, % "ahk_id " This.GuiObj["ButtonMenuFileT"].Handle
			Menu, % "Menu1", Show, % ctlX, % ctlY + ctlH+1
		}
	}
	
	ClipPassword(){
		GuiControlGet, r ,, % This.GuiObj["ButtonPasswordEdit", "Handle"]
		ToolTip, Password has been copied to the Clipboard.
		BoundTimer := ObjBindMethod(this, "RemoveToolTip")
		SetTimer, % BoundTimer, 2000
		Return r
	}

	TabSwap(){
		Static Toggle := 0
		Toggle := !Toggle
		If Toggle {
			Menu, Menu1, Rename, Open Settings, Open Password Generator
			GuiControl,, % This.GuiObj["ButtonMenuSettingsT", "Handle"], % "Password"
			for each, item in This.GuiObj {
				if InStr(each, "Settings") and !InStr(each, "ButtonMenuSettings")
					GuiControl, Show, % This.GuiObj[each].Handle
				if InStr(each, "Password") and (each != "")
					GuiControl, Hide, % This.GuiObj[each].Handle
			}
		}
		else {
			Menu, Menu1, Rename, Open Password Generator, Open Settings
			GuiControl,, % This.GuiObj["ButtonMenuSettingsT", "Handle"], % "Settings"
			for each, item in This.GuiObj {
				if InStr(each, "Settings") and !InStr(each, "ButtonMenuSettings")
					GuiControl, Hide, % This.GuiObj[each].Handle
				if InStr(each, "Password")
					GuiControl, Show, % This.GuiObj[each].Handle
			}
		}
	}

	WM_COMMAND(wParam, lParam, Msg, Hwnd){
	    static EM_SETSEL := 0x00B1, EN_SETFOCUS := 0x0100
	    critical
	    if ((wParam >> 16) = EN_SETFOCUS) {
	        DllCall("user32\HideCaret", "ptr", lParam)
	        DllCall("user32\PostMessage", "ptr", lParam, "uint", EM_SETSEL, "ptr", -1, "ptr", 0)
    	}
	}

	WM_MOUSEMOVE(wParam, lParam, Msg, Hwnd) {
		MouseGetPos,,,, MouseCtrl, 2
		GuiControl, % (This.GuiObj["ButtonMenuFileT"]["Handle"] = MouseCtrl) ? "Show" : "Hide", % This.GuiObj["ButtonMenuFileH"]["Handle"]
		GuiControl, % (This.GuiObj["ButtonMenuSettingsT"]["Handle"] = MouseCtrl) ? "Show" : "Hide", % This.GuiObj["ButtonMenuSettingsH"]["Handle"]
		GuiControl, % (This.GuiObj["ButtonMenuAboutT"]["Handle"] = MouseCtrl) ? "Show" : "Hide", % This.GuiObj["ButtonMenuAboutH"]["Handle"]
	}
	
	WM_LBUTTONDOWN(wParam, lParam, Msg, Hwnd) {
		MouseGetPos,,,, MouseCtrl, 2
		If (MouseCtrl = This.GuiObj["ButtonMainTitle", "Handle"])
			PostMessage, 0xA1, 2, ;0xA1 is the click and drag flag
		If (MouseCtrl = This.GuiObj["ButtonSettingsSave", "Handle"]) {
			GuiControlGet, Min, , % This.GuiObj["ButtonSettingsvMin", "Handle"]
			GuiControlGet, Max, , % This.GuiObj["ButtonSettingsvMax", "Handle"]
			IniWrite, % Min, % A_ScriptFullPath, PASSWORDSETTINGS, Min
			IniWrite, % Max, % A_ScriptFullPath, PASSWORDSETTINGS, Max
			This.TabSwap()
		}
	}

	CreateToolbar() {
		Static
		Gui, +HwndhGui
		This.hGui := hGui
		Gui Color, FFFFFF
		Gui, +LastFound -Resize -Caption -Border -ToolWindow -SysMenu +AlwaysOnTop 
		Gui Font, s9 cFFFFFF, Segoe UI  
		This.AddControl("Picture", "ButtonMenuBandLeft", " x0 y30 w15 h24 Hidden0 +0x4E ", "", "","0173C7")
		Toolbar := ["File", "Settings", "About"]
		Loop % Toolbar.Length() {
			This.AddControl("Picture", "ButtonMenu" . Toolbar[A_Index] . "N", " x+ yp w60 h24 Hidden0 +0x4E ", "", "","0173C7")
			This.AddControl("Picture", "ButtonMenu" . Toolbar[A_Index] . "H", " xp yp wp hp Hidden1 +0x4E ", "", "","2A8AD4")
			This.AddControl("Text"	 , "ButtonMenu" . Toolbar[A_Index] . "T", " xp yp wp hp  +BackgroundTrans +0x201 ","", Toolbar[A_Index])
		}
		This.AddControl("Picture", "ButtonMenuBandRight", " x195 y30 w30 h24 Hidden0 +0x4E ", "", "","0173C7")
		This.AddControl("Picture", "ButtonMenuBandBottom", " x0 y0 w220 h30 Hidden0 +0x4E ", "", "","0173C7")
		this.Menus := 
		( LTrim Join Comments
			{
				"Menu1": {
					"Title": "File",
					"SubMenus": "Open Settings,Copy Password to Clipboard,,Exit"
				},
			
				"Menu2": {
					"Title": "Settings",
					"SubMenus": "Undo,,Cut,Copy,Paste,Delete"
				},
			
				"Menu3":{
					"Title": "About",
					"SubMenus": "Font,Word Wrap"
				}
			}
		)
		; Menus seem to require a plain variable reference? 
		MenuHandler := ObjBindMethod(this, "MenuHandler")
 		For each, Item in this.Menus {
			Array := StrSplit(this.Menus[each]["SubMenus"] , ",")
				Loop % Array.Length()
					Menu, % each, Add, % Array[A_Index], % MenuHandler
		}
	}
	
	CreateGUI(){
		Static
		IniRead, Min, % A_ScriptFullPath, PASSWORDSETTINGS, Min
		IniRead, Max, % A_ScriptFullPath, PASSWORDSETTINGS, Max
		Min := Min="Error" ? "12" : Min, Max := Max="Error" ? "12" : Max
		; Main / Toolbar
		Gui Font, s12 cFFFFFF Bold, Segoe UI 
		This.AddControl("Text","ButtonMainTitle", " x0 y8 w215  +Center +BackgroundTrans +0x201  ", "", "The Password Generator")
		This.AddControl("text","ButtonMainLineBottom", " x0 y53 w215 h1 0x7", "", "")
		Gui Font, 
		; Password
		This.AddControl("Groupbox","ButtonPasswordGroupbox", " x5 y55 w199 h75 Hidden0", "", "Password:")
		This.AddControl("Edit", "ButtonPasswordEdit", " x16 yp+15 w180  +Center +readonly +BackgroundTrans +0x201", "", generate.password(Min,Max))
		This.AddControl("Button", "ButtonPasswordGenerate", " x16 yp+24 w180 h30 +Center   +BackgroundTrans +0x201 ", "", "Generate New Password")
		; Settings
		This.AddControl("Groupbox","ButtonSettingsGroupbox", " x5 y55 w199 h75 Hidden1", "", "Settings:")
		This.AddControl("Text","ButtonSettingsMin","x12 y75 w20 h20 Hidden1", "", "Min:")
		This.AddControl("Text","ButtonSettingsMax","x12 y105 w40 h20 Hidden1", "", "Max:")
		This.AddControl("Edit","ButtonSettingsvMin","x42 y72 w100 h20 vMin Number Hidden1", "", Min)
		This.AddControl("Edit","ButtonSettingsvMax","x42 y102 w100 h20 vMax Number Hidden1", "", Max)
		This.AddControl("Button","ButtonSettingsSave","x147 y71 h52 w52 Hidden1", "", "Save")
		Gui, Show, w209 h135 , Password Generator
		;This is to stop the edit control starting with focus, not sure how to fix this correctly, 
		;you would think there would be a way to specify what control has focus at the creation of the GUI
		; but I cant seem to find an option like that. 
		ControlFocus,, % "ahk_id " This.GuiObj["ButtonPasswordGenerate", "Handle"] 		
	}

	CreateBorders(){ 
       	VarSetCapacity(rc, 16), DllCall("GetClientRect", "uint", This.hGui, "uint", &rc)
        This.GuiWidth := NumGet(rc, 8, "int"), This.GuiHeight := NumGet(rc, 12, "int")
		Gui, Add, Text, % " x" 0 " y" 0 " w" 1 " h" This.GuiHeight " +0x4E +HWNDhBorderLeft "  
		DllCall("SendMessage", "Ptr", hBorderLeft, "UInt", 0x172, "Ptr", 0, "Ptr", This.CreateDIB("0072C6", 1, 1))
		Gui, Add, Text, % " x" This.GuiWidth-1 " y" 0 " w" 1 " h" This.GuiHeight " +0x4E +HWNDhBorderRight " 
		DllCall("SendMessage", "Ptr", hBorderRight, "UInt", 0x172, "Ptr", 0, "Ptr", This.CreateDIB("0072C6", 1, 1))
		Gui, Add, Text, % "x" 0 " y" 0 " w" This.GuiWidth-1 " h" 1 " +0x4E +HWNDhBorderTop"  
		DllCall("SendMessage", "Ptr", hBorderTop, "UInt", 0x172, "Ptr", 0, "Ptr", This.CreateDIB("0072C6", 1, 1))
		Gui, Add, Text, % "x" 0 " y" This.GuiHeight-1 " w" This.GuiWidth-1 " h" 1 " +0x4E +HWNDhBorderBottom"  
		DllCall("SendMessage", "Ptr", hBorderBottom, "UInt", 0x172, "Ptr", 0, "Ptr", This.CreateDIB("0072C6", 1, 1))
	}

	AddControl(ControlType, Name_Control, Options := "", Function := "", Value := "", DIB := ""){
		Static
		Gui, Add, %ControlType%, HWNDh%Name_Control% v%Name_Control% %Options%, %Value%
		Handle_Control := h%Name_Control%
		This.GuiObj[Name_Control, "Handle"] := Handle_Control
		ControlHandler := Func(Function).Bind(This.GuiObj[Name_Control, "Handle"])
		GuiControl +g, %Handle_Control%, %ControlHandler%
		If (DIB != "")
			DllCall("SendMessage", "Ptr", This.GuiObj[Name_Control, "Handle"], "UInt", 0x172, "Ptr", 0, "Ptr", This.CreateDIB(DIB, 1, 1))
	}
	
	CreateDIB(Input, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1 ) {
		_WB := Ceil((W * 3) / 2) * 2, VarSetCapacity(BMBITS, (_WB * H) + 1, 0), _P := &BMBITS
		Loop, Parse, Input, |
			_P := Numput("0x" . A_LoopField, _P + 0, 0, "UInt") - (W & 1 && Mod(A_Index * 3, W * 3) = 0 ? 0 : 1)
		hBM := DllCall("CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
		hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
		DllCall("SetBitmapBits", "Ptr", hBM, "UInt", _WB * H, "Ptr", &BMBITS)
		If (Gradient != 1) 
			hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x0008, "Ptr")
		return DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "Int", 0x200C, "UPtr")
	}

	RemoveToolTip(){
		ToolTip
	}
}

;AHK Password Generator By 0xB0BAFE77
;https://old.reddit.com/r/AutoHotkey/comments/ulkmzx/ahk_password_generator/

Class generate 
{
    password(min:=12, max:=24) {
        Static r_min := 32                                              ; Start of ASCII (after control chars)
             , r_max := 126                                             ; End of ASCII (delete char omitted)

        p_len := this.rand(min, max)                                    ; Generate random pass length
        , arr := []                                                     ; Array to store pass chars
        , str := ""                                                     ; String to build final pass

        this.get_symbols(p_len * this.rand(0.1, 0.2), arr)              ; Fill array with 10-20%: Symbols
        Loop, Parse, % "dul"                                            ; And digits/upper/lower
            this.get_dul(A_LoopField, p_len * this.rand(0.1, 0.2), arr)

        While (arr.MaxIndex() < p_len)                                  ; While pass length not met
            arr.Push(Chr(this.rand(r_min, r_max)))                      ; Keep adding random chars

        While (arr.Count() > 0)                                         ; While chars remain in array
            i := this.rand(arr.MinIndex(), arr.MaxIndex())              ; Pick random char to remove
            , str .= arr.RemoveAt(i)                                    ; And add it to string

        Return str                                                      ; Return generated password
    }

    get_symbols(num, arr) {
        Static _sym := [[33,47], [58,64], [91,96], [123,126]]           ; Symbol ranges grouped
        min := _sym.MinIndex(), max := _sym.MaxIndex()                  ; Min/max group index
        Loop, % num
            i := this.rand(min, max)                                    ; Pick random group index
            , si := this.rand(_sym[i].1, _sym[i].2)                     ; Pick random num from group range
            , arr.Push(Chr(_sym[i][si]))                                ; Add symbol to array
    }

    get_dul(type, num, arr) {
        Static arr_d := [48, 57]                                        ; Digit range
             , arr_u := [65, 90]                                        ; Upper alpha range
             , arr_l := [97, 122]                                       ; Lower alpha range

        Loop, % num
            arr.Push(Chr(this.rand(arr_%type%.1, arr_%type%.2)))        ; Add random char using d/u/l ranges
    }

    rand(min, max) {                                                    ; Random as a callable method
        Random, r, % min, % max
        Return r
    }
}