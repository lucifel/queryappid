; AutoHotkey Version: 1.0.48
; Author:         trueski <trueski@gmail.com>
;
;##################################################    CSV    FUNCTIONS     ###############################################
;CSV_Load(FileName, Delimiter)                                        ;Load CSV file into memory
;CSV_TotalRows()                                                      ;Return total number of rows
;CSV_TotalCols()                                                      ;Return total number of columns
;CSV_Delimiter()                                                      ;Return the delimiter used
;CSV_FileName()                                                       ;Return the filename
;CSV_Path()                                                           ;Return the path
;CSV_FileNamePath()                                                   ;Return the filename with the full path
;CSV_Save(FileName, OverWrite?)                                       ;Save CSV file
;CSV_DeleteRow(RowNumber)                                             ;Delete a row
;CSV_AddRow("Cell1, Cell2...")                                        ;Add a row
;CSV_DeleteColumn(ColNumber)                                          ;Delete a column
;CSV_AddColumn("Cell1, Cell2...")                                     ;Add a column
;CSV_ModifyCell(NewValue, Row, Col)                                   ;Modify an existing cell
;CSV_ModifyRow("NewValue1, NewValue2...", RowNumber)                  ;Modify an existing row
;CSV_ModifyColumn("NewValue1, NewValue2...", ColNumber)               ;Modify an existing column
;CSV_Search(SearchText, Instance)                                     ;Search for text within
;CSV_SearchRow(SearchText, RowNumber, Instance)                       ;Search for text within a cell within a specific row
;CSV_SearchColumn(SearchText, ColNumber, Instance)                    ;Search for text within a cell within a specific column
;CSV_MatchCell(SearchText, Instance)                                  ;Search for a cell containing exactly the data specified
;CSV_MatchRow("SearchText1, SearchText2", Instance)                   ;Search for a row containing exactly the data specified
;CSV_MatchCol("SearchText1, SearchText2", Instance)                   ;Search for a column containing exactly the data specified
;CSV_ReadCell(Row, Column)                                            ;Read data from the specified cell
;CSV_ReadRow(RowNumber)                                               ;Read data from the specified row
;CSV_ReadCol(ColNumber)                                               ;Read data from the specified column
;CSV_LVLoad(Gui, x, y, w, h, header, Sort?, RowIdentification?, AutoAdjustCol?)         ;Load data into a listview in the specified gui window
;CSV_LVSave(FileName, Delimiter, OverWrite?, Gui)                                       ;Save the specified listview as a CSV file
;####################################################################################################################
CSV_Load(FileName, Delimiter="`,")
  {
	Local Row
	Local Col
	
	Loop, Read, %FileName%
	  {
		Row := A_Index
		Loop, Parse, A_LoopReadLine, %Delimiter%
		  {
			Col := A_Index
			CSV_Row%Row%_Col%Col% := A_LoopField
		  }
	  }
	    CSV_TotalRows := Row
		CSV_TotalCols := Col
		CSV_Delimiter := Delimiter
		SplitPath, FileName, CSV_FileName, CSV_Path
		
		IfNotInString, FileName, `\
		  {
			CSV_FileName := FileName
			CSV_Path := A_ScriptDir
	  }
	  
		CSV_FileNamePath = %CSV_Path%\%CSV_FileName%
    }
;####################################################################################################################
CSV_TotalRows()
  { 
    global	
	Return %CSV_TotalRows%
  }
;####################################################################################################################
CSV_TotalCols()
  { 
    global	
	Return %CSV_TotalCols%
  }
;####################################################################################################################
CSV_Delimiter()
  { 
    global	
	Return %CSV_Delimiter%
  }
;####################################################################################################################
CSV_FileName()
  { 
    global	
	Return %CSV_FileName%
  }
;####################################################################################################################
CSV_Path()
  { 
    global	
	Return %CSV_Path%
  }
;####################################################################################################################
CSV_FileNamePath()
  { 
    global	
	Return %CSV_FileNamePath%
  }
;####################################################################################################################
CSV_Save(FileName, OverWrite="1")
  {
	Local Row
	Local Col
	
	If OverWrite = 0
	  IfExist, %FileName%
	    Return
		
	FileDelete, %FileName%

    EntireFile = 
	Loop, %CSV_TotalRows%
	  {
		  Row := A_Index
	      Loop, %CSV_TotalCols%
		    {
				Col := A_Index
				EntireFile .= CSV_Row%Row%_Col%Col%
				If Col <> %CSV_TotalCols%
				  EntireFile .= CSV_Delimiter
		    }
		      If Row <> %CSV_TotalRows%
			  EntireFile .= "`n"
	   }
		  FileAppend, %EntireFile%, %FileName%
  }
;####################################################################################################################
CSV_DeleteRow(RowNumber)
  {
	Local Row
	Local Col
	Local NewRow
	
	Loop, %CSV_TotalRows%
	  {
		Row := A_Index
	    NewRow := Row + 1
		If Row < %RowNumber%
		  Continue
		  
		Else
	      Loop, %CSV_TotalCols%
		    {
				Col := A_Index
				CSV_Row%Row%_Col%Col% := CSV_Row%NewRow%_Col%Col%
		    }
	  }
	CSV_TotalRows --
  }
;####################################################################################################################
CSV_AddRow(RowData)
  {
    global
	CSV_TotalRows ++
	Loop, Parse, RowData, `,
		CSV_Row%CSV_TotalRows%_Col%A_Index% := A_LoopField
	}
;####################################################################################################################
CSV_DeleteColumn(ColNumber)
  {
	Local Row
	Local Col
	Local NewCol

	Loop, %CSV_TotalRows%
	  {
		  Row := A_Index
	      Loop, %CSV_TotalCols%
		    {
				Col := A_Index
				NewCol := Col + 1

				If Col < %ColNumber%
				  Continue
				  
				Else
				  CSV_Row%Row%_Col%Col% := CSV_Row%Row%_Col%NewCol%
		    }
      }
    CSV_TotalCols --
  }
;####################################################################################################################
CSV_AddColumn(ColData)
  {
    global
	CSV_TotalCols ++
	Loop, Parse, ColData, `,
		CSV_Row%A_Index%_Col%CSV_TotalCols% := A_LoopField
  }
;####################################################################################################################
CSV_ModifyCell(Value, Row, Col)
  {
	global
	CSV_Row%Row%_Col%Col% := Value
  }
;####################################################################################################################
CSV_ModifyRow(Value, RowNumber)
  {
	Loop, Parse, Value, `,
	  CSV_Row%RowNumber%_Col%A_Index% := A_LoopField
   }
;####################################################################################################################	
CSV_ModifyColumn(Value, ColNumber)
  {
	Loop, Parse, Value, `,
	  CSV_Row%A_Index%_Col%ColNumber% := A_LoopField
  }
;####################################################################################################################
CSV_Search(SearchText, Instance=1)
  {
	Local Row
	Local Col
	Local FoundInstance
	
	Loop, %CSV_TotalRows%
	  {
		  Row := A_Index
	      Loop, %CSV_TotalCols%
		    {
				  Col := A_Index
                  CurrentString := CSV_Row%Row%_Col%Col%
				  IfInString, CurrentString, %SearchText%
				    {
				      FoundInstance ++
					  CurrentCell = %Row%`,%Col%
					  
					  If FoundInstance = %Instance%
					    Return %CurrentCell%
					}
			}
	  }
    Return 0
  }
;####################################################################################################################
CSV_SearchRow(SearchText, RowNumber, Instance=1)
  {
	Local Col
	Local FoundInstance
	
	Loop, %CSV_TotalCols%
		{
			Col := A_Index
			CurrentString := CSV_Row%RowNumber%_Col%Col%
			IfInString, CurrentString, %SearchText%
				{
					FoundInstance ++
					  
					If FoundInstance = %Instance%
					  Return %Col%
				}
	    }
	  Return 0
  }
;####################################################################################################################
CSV_SearchColumn(SearchText, ColNumber, Instance=1)
  {
	Local Row
	Local FoundInstance
	
	Loop, %CSV_TotalRows%
		{
			Row := A_Index
			CurrentString := CSV_Row%Row%_Col%ColNumber%
			IfInString, CurrentString, %SearchText%
				{
					FoundInstance ++
					  
					If FoundInstance = %Instance%
					  Return %Row%
				}
	    }
	  Return 0
  }
;####################################################################################################################
CSV_MatchCell(SearchText, Instance=1)
  {
	Local Row
	Local Col
	Local FoundInstance
	
	Loop, %CSV_TotalRows%
	  {
		  Row := A_Index
	      Loop, %CSV_TotalCols%
		    {
				  Col := A_Index
                  CurrentString := CSV_Row%Row%_Col%Col%
				  IfEqual, CurrentString, %SearchText%
				    {
				      FoundInstance ++
					  CurrentCell = %Row%`,%Col%
					  
					  If FoundInstance = %Instance%
					    Return %CurrentCell%
					}
			}
	  }
    Return 0
  }
;####################################################################################################################
CSV_MatchRow(SearchText, Instance=1)
 {
	Local Col
	Local Row
	Local CurrentRow
	Local FoundInstance
	
	Loop, %CSV_TotalRows%
	  {
		  Row := A_Index
		  CurrentRow =
	      Loop, %CSV_TotalCols%
		    {
			    Col := A_Index
			    CurrentRow .= CSV_Row%Row%_Col%Col%
				If Col <> %CSV_TotalCols%
				  CurrentRow .= "`,"
				  
			    IfEqual, CurrentRow, %SearchText%
				  {
					FoundInstance ++
					  
					If FoundInstance = %Instance%
					  Return %Row%
				  }
	        }
        }
    Return 0
  }
;####################################################################################################################
CSV_MatchCol(SearchText, Instance=1)
  {
	Local Col
	Local Row
	Local CurrentCol
	Local FoundInstance
	
    Loop, %CSV_TotalCols%
	  {	
		  Col := A_Index
		  CurrentCol =
	      Loop, %CSV_TotalRows%
		    {
			    Row := A_Index
			    CurrentCol .= CSV_Row%Row%_Col%Col%
				If Row <> %CSV_TotalRows%
				  CurrentCol .= "`,"
				  
			    IfEqual, CurrentCol, %SearchText%
				  {
					FoundInstance ++
					  
					If FoundInstance = %Instance%
					  Return %Col%
				  }
	        }
      }
  Return 0
}
;####################################################################################################################
CSV_ReadCell(Row, Col)
  {
	Local CellData
	CellData := CSV_Row%Row%_Col%Col%
	Return %CellData%
  }
;####################################################################################################################
CSV_ReadRow(RowNumber)
  {
	Local CellData
	
	Loop, %CSV_TotalCols%
	  {
	    RowData .= CSV_Row%RowNumber%_Col%A_Index%
		If A_Index <> %CSV_TotalCols%
		   RowData .= "`,"
	  }
	Return %RowData%
  }
;####################################################################################################################
CSV_ReadCol(ColNumber)
  {
	Local CellData
	
	Loop, %CSV_TotalRows%
	  {
	    ColData .= CSV_Row%A_Index%_Col%ColNumber%
		If A_Index <> %CSV_TotalRows%
		   ColData .= "`,"
	  }
	Return %ColData%
  }
;####################################################################################################################
CSV_LVLoad(Gui=1, x=10, y=10, w="", h="", header="", Sort=0, AutoAdjustCol=1)
  {
	Local Row

	 If CSV_LVAlreadyCreated =
	   {
	    Gui, %Gui%:Add, ListView, vListView%Gui% x%x% y%y% w%w% h%h%, %header%
		CSV_LVAlreadyCreated = 1
	    }
	
	;Set GUI window, clear any existing data
	Gui, %Gui%:Default
    GuiControl, -Redraw, ListView%Gui%
    Sleep, 200
	LV_Delete()
	
	;Add Data
	Loop, %CSV_TotalRows%
	  LV_Add("", "")
	
	Loop, %CSV_TotalRows%
	  {
		Row := A_Index
		Loop, %CSV_TotalCols%
	        LV_Modify(Row, "Col" . A_Index, CSV_Row%Row%_Col%A_Index%)
	  }

	
	;Display Data
	If Sort <> 0
	  LV_ModifyCol(Sort, "Sort")
      
      
     If AutoAdjustCol = 1
     LV_ModifyCol()
     GuiControl, +Redraw, ListView%Gui%
  }
;####################################################################################################################
CSV_LVSave(FileName, Delimiter=",",OverWrite=1, Gui=1)
  {
	Gui, %Gui%:Default
	Rows := LV_GetCount()
	Cols := LV_GetCount("Col")
	
	IfExist, %FileName%
	  If OverWrite = 0
	    Return 0
	
	FileDelete, %FileName%
	
	Loop, %Rows%
	  {
		  FullRow =
		  Row := A_Index
		  
		  Loop, %Cols%
		    {
	          LV_GetText(CellData, Row, A_Index)
			  ;CellData = "%CellData%"
			  FullRow .= CellData
			  
			  If A_Index <> %Cols%
			    FullRow .= Delimiter
		    }
		
			If Row <> %Rows%
			  FullRow .= "`n"
			  
			EntireFile .= FullRow
		}
    FileAppend, %EntireFile%, %FileName%
  }