#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include ForegroundWindowWatcher.ahk

		#Persistent
		ActiveRules := new ForegroundWindowWatcher()
		ActiveRules.Start()
		ActiveRules.AddRule("Untitled - Notepad","Notepad")
		ActiveRules.AddRule("Calculator",,"Calculator")
		
		return ; EOAES
		
		
		Notepad(){
			Static Count := 1
			ToolTip % "Notepad: " Count++
		}
		
		Calculator(){
			Static Count := 1
			ToolTip % "Calculator: " Count++
		}
		
