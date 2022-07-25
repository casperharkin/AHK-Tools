
/*
RunMoveResize(PathOrTitle, X, Y, W, H, WaitTime := "", Maximize := "", Active := "")
Optional Parameters: WaitTime, Maximize and Active. 

Example:

		RunMoveResize("C:\Windows\notepad.exe", 0,0,500,500,10,1)
*/

RunMoveResize(PathOrTitle, X, Y, W, H, WaitTime := "", Maximize := "", Active := "") {
SplitPath, PathOrTitle, PathOrTitle
Run % PathOrTitle
Prefix := "ahk_exe ", Suffix := InStr(PathOrTitle, ".exe")?PathOrTitle:PathOrTitle . ".exe"
WinWait, % Prefix . Suffix,, % WaitTime!=""?"WaitTime":"6"
WinMove, % Prefix . Suffix,, % X, % Y, % W, % H
Result := Maximize=1?WinMax(WinTitle):""
Result := Active=1?WinAct(WinTitle):""
}

WinMax(WinTitle) {
	WinMaximize % WinTitle
}
WinAct(WinTitle) {
	WinActivate % WinTitle
}