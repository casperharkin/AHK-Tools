#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, LocalSameAsGlobal, Off  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; Vars and Stuff for testing (Hotkey q to check global vars, Ctrl+)
Loop 25
A%A_Index% := A_Index

911 = 
(
Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, 
eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, 
sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, 
sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, 
nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, 
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?
)

a0 := {1:"Hello", A2:"World"}
b1 := ["a","b","c","d"]

New SimpleVariableEditor
Exit

q::
   
   Loop 25
   r .= A%A_Index% "`n"
   
   For Var, Contents in a0
   r .= "`nObject`nVar: " Var "`nContents: " Contents
   
   For index, in b1
   r .= "`nArray`nContents: " b1[index]
   
   MsgBox % r
   
   r := ""
Return


; ======================================================================================================================
; AHK v1.1.33.02
; ======================================================================================================================
; Function:          View and Edit Variable in the Global Space
;                    Control+F12 Will Show / Hide the GUI 
;                    
; Namespace:         SimpleVariableEditor 
; Tested with:       v1.1.33.02
; ======================================================================================================================

Class SimpleVariableEditor {
   __New(){
      ;------------------------------------------
      ;----------------[Settings]----------------
      ;------------------------------------------
      This.GuiHotkey := "^F12"
      This.AutoRefresh := False
      This.RefreshRate := 1000
      ;------------------------------------------
      ;------------------------------------------
      This.MainGui()
   }
   
   MainGui(){
      Gui Main: +LastFound -Resize +Caption +Border -ToolWindow +SysMenu +HwndhMainGUI
      Gui Main: Color, FFFFFF
      Gui Main: Font, s15 cFFFFFF +Bold, Segoe UI  
      Gui Main: Add, Picture, x0  y-5 w280 h65 +0x4E +HWNDhTitleN Hidden0
      DllCall("SendMessage", "Ptr", hTitleN, "UInt", 0x172, "Ptr", 0, "Ptr", This.CreateDIB("0173C7", 1, 1))
      Gui Main: Add, Text, x0 y0 w280 h60 +HWNDhTitleText +BackgroundTrans +0x201, Simple Variable Editor 
      This.Bind(hTitleText, "MoveGui")
      
      Gui Main: Font, 	 
      Gui Main: Font, s8 cBlack
      Gui Main: Add, Button, x15 w250 h30 +hwndhRefresh , Refresh
      This.Bind(hRefresh, "RefreshListView")
      
      Gui Main: Add, ListView, wp h250 +hwndhMainListview +readonly r100 -Multi AltSubmit -E0x200, Variable Names:|Variable Contents:
      This.Bind(This.MainListview := hMainListview, "ListViewSelectionMain")
      
      Gui Main: Add, ListView, xp yp wp h250 +hwndhObjectListview +readonly r100 -Multi AltSubmit -E0x200 +Hidden1, Object Names:|Variable Contents:
      This.Bind(This.ObjectListview := hObjectListview, "ListViewSelectionObject")
      
      Gui Main: Add, Button, wp  h30 +hwndhClose, Close
      This.Bind(This.hClose := hClose, "GuiClose", hMainGUI)
      
      Gui Main: Add, Button, xp yp wp  h30 +hwndhBack Hidden1, Back
      This.Bind(This.hBack := hBack, "Back")
      
      Gui Main: Font, 
      Gui Main: Margin , % x := 0, % y := 5
      
      handler := ObjBindmethod(this, "HotkeyHandler")
      Hotkey, % This.GuiHotkey, % handler, On
      
      If (This.AutoRefresh = True){
         FuncRef := ObjBindMethod(This, "RefreshListView")
         SetTimer, % FuncRef , % This.RefreshRate
      }
      
      This.RefreshListView()
      This.GuiShow(This.MainGUI := hMainGUI)
   }
   
   MoveGui(){
      PostMessage, 0xA1, 2,
   }
   
   ModalGui(RowVariable, RowText, ObjectName := ""){
      If ObjectName and if (RowVariable != "") {
         RV := this._[ObjectName][RowVariable]
      }else  {
         RV := %RowVariable%
      }
      
      Gui Modal: New, hwndhModalGui +AlwaysOnTop
      Gui Modal: Add, Edit, hwndhEditControl  w300 r10, % RV
      
      Gui Modal: Add, Button, wp hwndhSaveBtn, &Save
      This.Bind(hSaveBtn, "Save", hEditControl, RowVariable, RowText, ObjectCheck)
      
      Gui Modal: Add, Button, wp hwndhCancelBtn, &Cancel
      This.Bind(hCancelBtn, "Cancel")
      
      Gui Main: +Disabled		 
      Gui Modal: +OwnerMain   		 
      Gui Main: +Lastfound	
      This.GuiShow(hModalGui)
   }
   
   GuiShow(GuiHwnd){
      Gui, % GuiHwnd ": Show"
   }
   
   GuiClose(GuiHwnd){
      Gui, % GuiHwnd ": Hide"
   }
   
   Back(){
      GuiControl, Show, % This.MainListview
      GuiControl, Hide, % This.ObjectListview 
      Gui, ListView, % This.MainListview
      GuiControl, Show, % This.hClose
      GuiControl, Hide, % This.hBack
      This.RefreshListView()
   }
   
   HotkeyHandler(){
      If !WinExist("ahk_id " This.MainGUI)
      	This.GuiShow(This.MainGUI)
      Else
         This.GuiClose(This.MainGUI)
   }
   
   Cancel(){
      Gui Main: -Disabled		 
      Gui Modal: -OwnerMain   		 
      Gui Main: +Lastfound	
      Gui Modal: hide
   }
   
   Save(EditControlHwnd, RowVariable, RowText, ObjectName := ""){
      Gui, Main:Default
      ControlGetText, EditControl,, % " ahk_id " EditControlHwnd
      ControlGet, BackVisible, visible,,, % " ahk_id " This.hBack
      
      If (IsObject(%ObjectName%) = 0) and if (BackVisible = 0){
         try
         (%RowVariable%) := EditControl
         Catch
         MsgBox % "Error: " RowVariable " Not Updated."
         
         This.RefreshListView()
      }
      
      If (IsObject(%ObjectName%) = 1) or if (BackVisible = 1){
         If (ObjectName = ""){
            for each, item in This._{
               if (IsObject(%each%) = 1){
                  for e, i in This._[each]
                  if (i = RowText){
                     ObjectName := each
                     RowVariable := e 
                     %ObjectName%[RowVariable] := EditControl
                     break
                  }}}}else  {
            %ObjectName%[RowVariable] := EditControl
         }
         
         This.BuildVarDB()
         
         Gui, Main:Default
         LV_Delete()
         GuiControl, -Redraw, % " ahk_id " This.MainjListview
         for each, item in This._[ObjectName]{
            LV_Add("", each, item)
         }
         
         LV_ModifyCol(1, "AutoHdr")   
         LV_ModifyCol(2, "AutoHdr")
         GuiControl, +Redraw,  % " ahk_id " This.MainListview
      }
      
      Gui Main: -Disabled		 
      Gui Modal: -OwnerMain   		 
      Gui Main: +Lastfound	
      Gui Modal: Destroy
   }
   
   Bind(Hwnd, Method, Params*){
      BoundFunc := ObjBindMethod(This, Method, Params*)
      GuiControl +g, % Hwnd, % BoundFunc
   }
   
   ListViewSelectionObject(){
      LV_GetText(RowVariable, A_EventInfo)
      LV_GetText(RowText, A_EventInfo, 2)  
      
      if (A_GuiEvent = "DoubleClick"){
         for each, item in This._ {
            if (IsObject(%each%) = 1){
               for e, i in This._[each]
               if (i = RowText){
                  ObjectName := each
                  RowVariable := e 
                  break
               }}}
         
         This.ModalGui(RowVariable, RowText, ObjectName)
      }}
   
   ListViewSelectionMain(){
      if (A_GuiEvent = "DoubleClick"){
         LV_GetText(RowVariable, A_EventInfo)
         LV_GetText(RowText, A_EventInfo, 2)  
         
         If (RowText != "Object"){
            This.ModalGui(RowVariable, RowText)
         }else  If (RowText = "Object") {
            GuiControl, Hide, % This.MainListview
            GuiControl, Show, % This.ObjectListview 
            Gui, ListView, % This.ObjectListview 
            
            This.CurrentObjectLV := RowVariable
            
            Gui, Main:Default
            GuiControl, Show, Back
            GuiControl, Hide, Close
            LV_Delete()
            GuiControl, -Redraw, % " ahk_id " This.ObjectListview 
            for each, item in This._[RowVariable]
            LV_Add("", each, item)
         }}}
   
   BuildVarDB(){
      for i, in RawListArray := StrSplit(RawList := This.ListGlobalVars(), "`n"){
         if instr(RawListArray[i], "Object") and !instr(RawListArray[i], "_: Object object"){
            a := StrSplit(rString := RegExReplace(StrReplace(RawListArray[i], "`r`n"), "U)\[.*\]:"), ":").1
            This._[a] := %a%.Clone()
         }
         else if instr(RawListArray[i], ":") and !instr(RawListArray[i], "_: Object object") {
            rString := RegExReplace(StrReplace(RawListArray[i], "`r`n"), "U)\[.*\]:")
            a := StrSplit(rString, A_Space) 
            This._[a.1] := LTrim(StrReplace(rString, a.1))
         }}
      
      This._.Delete("A_Args")
      This._.Delete("ErrorLevel")
      This._.Delete("SVE")
      This._.Delete(0)
      This._.Delete("intVarTemp")
   }
   
   RefreshListView(){
      This.BuildVarDB()
      
      if (A_DefaultListView = This.MainListview) or if (A_DefaultListView = ""){
         Gui, Main:Default
         Gui, ListView, % This.MainListview
         
         LV_Delete()
         GuiControl, -Redraw, % " ahk_id " This.MainListview
         for each, item in This._ {
            try 
            If IsObject(%each%)
            LV_Add("", each, "Object")
            Else
               LV_Add("", each, item)
         }
         
         LV_ModifyCol(1, "AutoHdr")   
         LV_ModifyCol(2, "AutoHdr")
         GuiControl, +Redraw,  % " ahk_id " This.MainListview
      }}
   
   ListGlobalVars(){
      ; Lexikos' ListGlobalVars() https://www.autohotkey.com/board/topic/31049-solvedexpose-variable-with-a-function-listglobalvars/
      static hwndEdit := "", pSFW, pSW, bkpSFW, bkpSW
      
      if !hwndEdit {
         dhw := A_DetectHiddenWindows
         DetectHiddenWindows, On
         Process, Exist
         ControlGet, hwndEdit, Hwnd,, Edit1, ahk_class AutoHotkey ahk_pid %ErrorLevel%
         DetectHiddenWindows, %dhw%
         
         astr := A_IsUnicode ? "astr":"str"
         ptr := A_PtrSize=8 ? "ptr":"uint"
         hmod := DllCall("GetModuleHandle", "str", "user32.dll", ptr)
         pSFW := DllCall("GetProcAddress", ptr, hmod, astr, "SetForegroundWindow", ptr)
         pSW := DllCall("GetProcAddress", ptr, hmod, astr, "ShowWindow", ptr)
         DllCall("VirtualProtect", ptr, pSFW, ptr, 8, "uint", 0x40, "uint*", 0)
         DllCall("VirtualProtect", ptr, pSW, ptr, 8, "uint", 0x40, "uint*", 0)
         bkpSFW := NumGet(pSFW+0, 0, "int64")
         bkpSW := NumGet(pSW+0, 0, "int64")
      }
      
      if (A_PtrSize=8) {
         NumPut(0x0000C300000001B8, pSFW+0, 0, "int64")  ; return TRUE
         NumPut(0x0000C300000001B8, pSW+0, 0, "int64")   ; return TRUE
      }else  {
         NumPut(0x0004C200000001B8, pSFW+0, 0, "int64")  ; return TRUE
         NumPut(0x0008C200000001B8, pSW+0, 0, "int64")   ; return TRUE
      }
      
      ListVars
      
      NumPut(bkpSFW, pSFW+0, 0, "int64")
      NumPut(bkpSW, pSW+0, 0, "int64")
      
      ControlGetText, text,, ahk_id %hwndEdit%
      RegExMatch(text, "sm)(?<=^Global Variables \(alphabetical\)`r`n-{50}`r`n).*", text)
      return text
   }
   
   CreateDIB(Input, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1 ) {
      WB := Ceil((W * 3) / 2) * 2, VarSetCapacity(BMBITS, (WB * H) + 1, 0), P := &BMBITS
      Loop, Parse, Input, |
      {
         P := Numput("0x" . A_LoopField, P + 0, 0, "UInt") - (W & 1 && Mod(A_Index * 3, W * 3) = 0 ? 0 : 1)
      }
      hBM := DllCall("CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
      hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
      DllCall("SetBitmapBits", "Ptr", hBM, "UInt", WB * H, "Ptr", &BMBITS)
      If (Gradient != 1) {
         hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x0008, "Ptr")
      }
      return DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "Int", 0x200C, "UPtr")
   }}              