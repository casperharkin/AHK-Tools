
MsgBox % MultipleFolders.Select(A_MyDocuments)

Exit ; EOAES



	Class MultipleFolders { 
	
		Select(Folder){
			Static
	
            ;------------------------------------------
            ;----------------[Settings]----------------
            ;------------------------------------------

            This.ReturnSelectionAsObject := False ; False to have a list returned, true to have an object returned. 

            ;------------------------------------------
            ;------------------------------------------
	
		    Gui, Add, Button, x135 y255 w75 h23 +HwndhOkay, OK
	            BoundFunc := ObjBindMethod(This, "GetSelection")
	            GuiControl +g, % hOkay, % BoundFunc
	
		    Gui, Add, Button, x216 y255 w75 h23 +HwndhClose, Cancel
	            BoundFunc := ObjBindMethod(This, "GuiClose")
	            GuiControl +g, % hClose, % BoundFunc
	
		    Gui, Add, ListView, x22 y29 w270 h220 vMyListView +HWNDhLV AltSubmit , Name|In Folder|Size (KB)|Type|FullPath
		    Gui, Add, Text, x22 y9 w280 h20 , % "Select Folders in: " Folder
		
		    ImageListID1 := IL_Create(10)
		    ImageListID2 := IL_Create(10, 10, true) 
		
		    LV_SetImageList(ImageListID1)
		    LV_SetImageList(ImageListID2)
		
		    LastChar := SubStr(Folder, 0)
		    if (LastChar = "\")
		        Folder := SubStr(Folder, 1, -1) 
		
		    sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340) 
		    VarSetCapacity(sfi, sfi_size)
		
		    GuiControl, -Redraw, MyListView 
		
		    Loop Files, %A_MyDocuments%\*.*, d 
		    {
		        FileName := A_LoopFileFullPath   
		        SplitPath, FileName,,, FileExt  
		        if FileExt in EXE,ICO,ANI,CUR
		        {
		            ExtID := FileExt   
		            IconNumber := 0   
		        }
		        else  
		        {
		            ExtID := 0  
		            Loop 7  
		            {
		                ExtChar := SubStr(FileExt, A_Index, 1)
		                if not ExtChar   
		                    break
		                ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
		            }
		            IconNumber := IconArray%ExtID%
		        }
		        if not IconNumber  
		        {
		            if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "Str", FileName
		                , "UInt", 0, "Ptr", &sfi, "UInt", sfi_size, "UInt", 0x101)   
		                IconNumber := 9999999   
		            else 
		            {
		                hIcon := NumGet(sfi, 0)
		                IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID1, "Int", -1, "Ptr", hIcon) + 1
		                DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID2, "Int", -1, "Ptr", hIcon)
		                DllCall("DestroyIcon", "Ptr", hIcon)
		                IconArray%ExtID% := IconNumber
		            }
		        }
		        LV_Add("Icon" . IconNumber, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, FileExt, A_LoopFileFullPath)
		    }
		
		    GuiControl, +Redraw, MyListView  
		    LV_ModifyCol()   
		    LV_ModifyCol(3, 60) 
		
		    Gui, Show, w312 h300, File Select Folder (Multi)
		   	WinWaitClose, File Select Folder (Multi)
			Return This.Selection
			}
		
		    GetSelection(){
				Static
			    Loop {
			        RowNumber := LV_GetNext(RowNumber)  
			        if not RowNumber  
			            break
			        LV_GetText(Text, RowNumber), LV_GetText(Pathed, RowNumber, 5)
			        Selection .= Pathed "`n"
			    }
	
			    OpenArr := StrSplit(Selection, "`n")
			    OpenArr.RemoveAt(OpenArr.Length())
			
				If This.ReturnSelectionAsObject {
				    Gui, Destroy
				    This.Selection := OpenArr
				}
				else {
				    This.Selection := Selection
					This.GuiClose()
				}
			}
	
		    GuiClose(){
		    	 Gui, Destroy
			}
	}
