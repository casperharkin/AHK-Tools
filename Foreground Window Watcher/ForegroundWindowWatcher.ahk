#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
		
		; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		;       Foreground Window Watcher
		;		by Casper Harkin 19/10/2022 
		;
		;		Concepts Stolen from:
		;			MikeHotelOscar - https://github.com/MikeHotelOscar/AutoHotkey-WindowWatcher-Class
		;			anonymous1184 - https://www.reddit.com/r/AutoHotkey/comments/raa4a9/comment/hnkbm0w/?context=3&utm_source=reddit&utm_medium=usertext&utm_name=AutoHotkey&utm_content=t1_isfnoj6 
		;
		;		ForegroundWindowWatcher(WinTitle := "", OpenFunc := "", State := "Active")
		;		WinTitle: 	Full Window Title to Watch
		;		OpenFunc: 	Function to Call once the rule is met
		;		State:		Tracking the State of the Rule, When Adding a Rule the Default state is Active.
		;
		;		Notes: 
		;				Object(A_EventInfo) := this.(Instance)
		;				0x0003 := EVENT_SYSTEM_FOREGROUND
		; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		
		Class ForegroundWindowWatcher {
		
			WindowRules := {}
		
			AddRule(WinTitle := "", OpenFunc := "", State := "Active"){ 
				This.WindowRules[WinTitle] := {Title:WinTitle, OpenFunc:Func(OpenFunc), State:State}
			}
		
			DeleteRule(WinTitle){
				this.WindowRules.Delete(WinTitle)
			}
		
			ToggleRule(WinTitle, SelectState := ""){
				if SelectState 
					this.WindowRules[WinTitle]["State"] := SelectState
				Else
					this.WindowRules[WinTitle]["State"] := this.WindowRules[WinTitle]["State"] = "Active" ? ("Paused") : ("Active")
			}
		
			__new(callbackFunc){  
				(this.callbackFunc := isObject(callbackFunc)  ? callbackFunc : isFunc(callbackFunc) ? func(callbackFunc) : "")
				if !this.callbackFunc
					throw exception("Invalid")
			}
		
			EventHook(args*){   
				Critical Off
				WinGetTitle wTitle, A
				for each, Item in Object(A_EventInfo).WindowRules 
					If (each = wTitle) and If (Object(A_EventInfo).WindowRules[each]["State"] = "Active")
						Object(A_EventInfo).WindowRules[each]["OpenFunc"].Call()
			}
		
			Start(){ 
				if !This.WindowRules["hHook"]	 
					This.WindowRules["hHook"] := DllCall("User32\SetWinEventHook", "Int",0x0003, "Int",0x0003, "Ptr",0, "Ptr", this.regCallBack := RegisterCallback(this.EventHook,"F",4, &this), "Int",0, "Int",0, "Int",0)
			}
			
			Stop(){	
				if This.WindowRules["hHook"]
					DllCall("User32\UnhookWinEvent", "Ptr", This.WindowRules["hHook"])
				return This.WindowRules["hHook"] := ""
			}
		
			__Delete(){ 		
				this.Stop()
				if this.regCallBack
					DllCall("GlobalFree", "Ptr", this.regCallBack)
				return 
			}
		}