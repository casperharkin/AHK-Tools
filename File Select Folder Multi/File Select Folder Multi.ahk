	
	; Change the root folder to what ever you want. 
	Folder := A_MyDocuments

    Gui, Add, Button, x135 y255 w75 h23 gGetSelectedFolders, OK
    Gui, Add, Button, x216 y255 w75 h23 gGuiClose, Cancel
    Gui, Add, ListView, x22 y29 w270 h220 vMyListView +HWNDhLV AltSubmit , Name|In Folder|Size (KB)|Type|FullPath
    Gui, Add, Text, x22 y9 w280 h20 , % "Select Folders in: " Folder

    ; Create an ImageList so that the ListView can display some icons:
    ImageListID1 := IL_Create(10)
    ImageListID2 := IL_Create(10, 10, true)  ; A list of large icons to go with the small ones.

    ; Attach the ImageLists to the ListView so that it can later display the icons:
    LV_SetImageList(ImageListID1)

    ; Check if the last character of the folder name is a backslash, which happens for root
    ; directories such as C:\. If it is, remove it to prevent a double-backslash later on.
    LastChar := SubStr(Folder, 0)
    if (LastChar = "\")
        Folder := SubStr(Folder, 1, -1)  ; Remove the trailing backslash.

    ; Calculate buffer size required for SHFILEINFO structure.
    sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
    VarSetCapacity(sfi, sfi_size)

    ; Gather a list of file names from the selected folder and append them to the ListView:
    GuiControl, -Redraw, MyListView  ; Improve performance by disabling redrawing during load.

    Loop Files, %A_MyDocuments%\*.*, d ; folders.
    {
        FileName := A_LoopFileFullPath  ; Must save it to a writable variable for use below.

        ; Build a unique extension ID to avoid characters that are illegal in variable names,
        ; such as dashes. This unique ID method also performs better because finding an item
        ; in the array does not require search-loop.
        SplitPath, FileName,,, FileExt  ; Get the file's extension.
        if FileExt in EXE,ICO,ANI,CUR
        {
            ExtID := FileExt  ; Special ID as a placeholder.
            IconNumber := 0  ; Flag it as not found so that these types can each have a unique icon.
        }
        else  ; Some other extension/file-type, so calculate its unique ID.
        {
            ExtID := 0  ; Initialize to handle extensions that are shorter than others.
            Loop 7     ; Limit the extension to 7 characters so that it fits in a 64-bit value.
            {
                ExtChar := SubStr(FileExt, A_Index, 1)
                if not ExtChar  ; No more characters.
                    break
                ; Derive a Unique ID by assigning a different bit position to each character:
                ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
            }
            ; Check if this file extension already has an icon in the ImageLists. If it does,
            ; several calls can be avoided and loading performance is greatly improved,
            ; especially for a folder containing hundreds of files:
            IconNumber := IconArray%ExtID%
        }
        if not IconNumber  ; There is not yet any icon for this extension, so load it.
        {
            ; Get the high-quality small-icon associated with this file extension:
            if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "Str", FileName
                , "UInt", 0, "Ptr", &sfi, "UInt", sfi_size, "UInt", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
                IconNumber := 9999999  ; Set it out of bounds to display a blank icon.
            else ; Icon successfully loaded.
            {
                ; Extract the hIcon member from the structure:
                hIcon := NumGet(sfi, 0)
                ; Add the HICON directly to the small-icon and large-icon lists.
                ; Below uses +1 to convert the returned index from zero-based to one-based:
                IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID1, "Int", -1, "Ptr", hIcon) + 1
                DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID2, "Int", -1, "Ptr", hIcon)
                ; Now that it's been copied into the ImageLists, the original should be destroyed:
                DllCall("DestroyIcon", "Ptr", hIcon)
                ; Cache the icon to save memory and improve loading performance:
                IconArray%ExtID% := IconNumber
            }
        }

        ; Create the new row in the ListView and assign it the icon number determined above:
        LV_Add("Icon" . IconNumber, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, FileExt, A_LoopFileFullPath)
    }

    GuiControl, +Redraw, MyListView  ; Re-enable redrawing (it was disabled above).
    LV_ModifyCol()  ; Auto-size each column to fit its contents.
    LV_ModifyCol(3, 60) ; Make the Size column at little wider to reveal its header.

    Gui, Show, w312 h300, File Select Folder (Multi)
    return

    GetSelectedFolders:

    Selection := ""
    Loop
    {
        RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
        if not RowNumber  ; The above returned zero, so there are no more selected rows.
            break
        LV_GetText(Text, RowNumber)
        LV_GetText(Pathed, RowNumber, 5)
        Selection .= Pathed "`n"
    }

    OpenArr := StrSplit(Selection, "`n")
    OpenArr.RemoveAt(OpenArr.Length())

    for i, in OpenArr
        Run % OpenArr[i]

    Gui, Destroy
    return


    GuiClose:
    ExitApp