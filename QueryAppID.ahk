﻿#NoEnv
#Include json.ahk
#Include LVEDIT.ahk
#Include CSV.ahk
#CommentFlag ;
SetBatchLines, -1


IfNotExist , %A_ScriptDir%`\Temp
	FileCreateDir , %A_ScriptDir%`\Temp
Loop, %A_ScriptDir%`\Temp\*.*
{
	time := A_Now 
	EnvSub, time, %A_LoopFileTimeModified%, Days
	if time > 7
		FileDelete, %A_LoopFileFullPath%
}
Gui +LastFound +Resize +OwnDialogs
Gui, Add, Tab2, x5 y5 w630 h470 vMytabs,`  应用管理  |  运营后台  |
Gui, Add, GroupBox, x14 y35 w612 h130 vBoxIn, 输入
Gui, Add, GroupBox, x14 y170 w612 h295 vBoxOut, 输出
Gui, Add, Edit, vKeyWords x28 y55 w350 h100, 请输入需要查询的APPID或应用名，如：333206289
Gui, Add, Button, x400 y55 w90 h30 gQuery Default, 查ID
Gui, Add, Button, x510 y55 w90 h30 gTransfer, 转换
;Gui, Add, Button, x550 y55 w60 h30 gSubMode, 点评
Gui, Add, Button, x400 y95 w90 h30 gSearch, 搜索
Gui, Add, Button, x510 y95 w90 h30 gCopy,  复制
;Gui, Add, Button, x550 y95 w60 h30 gCollection, 专题
Gui, Add, Radio, x420 y135 w80 h20 vJBType Checked, 查询正版
Gui, Add, Radio, x520 y135 w80 h20, 查询越狱
Gui, Add, ListView, x28 y190 w582 h265 -Readonly r6 vAppGrid gAppGrid hwndHLV1, 应用图标|正版ID|越狱ID|正版名称|越狱名称|正版类型|越狱类型|Bundle|正版大小|越狱大小|正版点评|越狱点评|分类
Menu, MyContextMenu, Add, 查看简介, ContextCheckCon
Menu, MyContextMenu, Add, 复制内容, ContextCopyRows
Menu, MyContextMenu, Add, 清空表单, ContextClearRows
if !(LVEDIT_INIT(HLV1))
	MsgBox, %ErrorLevel%
Gui, Tab, 2
Gui, Add, Button, x25 y30 w70 h25 gLogin, 登录
Gui, Add, Text, x105 y36 w55 h25, 正版专题:
Gui, Add, Edit, vPPTopicID x170 y33 w60 h20
Gui, Add, Text, x240 y36 w55 h25, 越狱专题:
Gui, Add, Edit, vJBTopicID x305 y33 w60 h20
Gui, Add, Button, x375 y30 w70 h25 gCollection, 加专题
Gui, Add, Button, x455 y30 w70 h25 gSubMode, 加点评
Gui, Add, ActiveX, x14 y65 w612 h400 vWB hwndATLWinHWND, Shell.Explorer
IOleInPlaceActiveObject_Interface:="{00000117-0000-0000-C000-000000000046}"
pipa := ComObjQuery(WB, IOleInPlaceActiveObject_Interface)
OnMessage(WM_KEYDOWN:=0x0100, "WM_KEYDOWN")
OnMessage(WM_KEYUP:=0x0101, "WM_KEYDOWN")
OnMessage(11, "DisableSetRedraw")
Gui, Tab, 3
Gui, Show, w640 h480 Center, PP助手应用信息查询工具V1.5 20150727
GuiWinHWND:=WinExist()
wb.Navigate("about:blank")
wb.Visible := true
wb.silent := true

csvfile := A_ScriptDir . "`\LVContent.csv"
IfExist, %csvfile%
{
	CSV_Load(csvfile, ";")
	;MsgBox % CSV_TotalRows "`n" CSV_TotalCols
	himl:=DllCall("ImageList_Create",Int,45,Int,45,UInt,0x21,Int,10,Int,1)
	LV_SetImageList(himl,1)
	Loop, %CSV_TotalRows%
	{
		Row := A_Index
		Loop, %CSV_TotalCols%
		{
			if A_Index = 2
				PPAppID := CSV_ReadCell(Row,A_Index)
			if A_Index = 3
				JBAppID := CSV_ReadCell(Row,A_Index)
			if A_Index = 4
				PPAppName := CSV_ReadCell(Row,A_Index)
			if A_Index = 5
				JBAppName := CSV_ReadCell(Row,A_Index)
			if A_Index = 6
				PPAppType := CSV_ReadCell(Row,A_Index)
			if A_Index = 7
				JBAppType := CSV_ReadCell(Row,A_Index)
			if A_Index = 8
				AppBundle := CSV_ReadCell(Row,A_Index)
			if A_Index = 9
				PPAppSize := CSV_ReadCell(Row,A_Index)
			if A_Index = 10
				JBAppSize := CSV_ReadCell(Row,A_Index)
			if A_Index = 11
				PPEditor := CSV_ReadCell(Row,A_Index)
			if A_Index = 12
				JBEditor := CSV_ReadCell(Row,A_Index)
			if A_Index = 13
				JBCatID := CSV_ReadCell(Row,A_Index)
		}
		if PPAppID <>
			OPicURL := A_ScriptDir . "`\Temp`\" . PPAppID . "`.*"
		else
			OPicURL := A_ScriptDir . "`\Temp`\" . JBAppID . "`.*"
		Loop, %OPicURL%
			picurl := A_LoopFileLongPath
		;MsgBox % Row "`n" PPAppID ":" PPAppName "`n" JBAppID ":" JBAppName "`n" picurl
		IL_Add(himl,picurl,0,1)
		LV_Add( "icon" . Row ,, PPAppID, JBAppID, PPAppName, JBAppName, PPAppType, JBAppType, AppBundle, PPAppSize, JBAppSize, PPEditor, JBEditor, JBCatID)
	}
	LV_ModifyCol()
	LV_ModifyCol(4,80)
	LV_ModifyCol(5,80)
	LV_ModifyCol(8,70)
	LV_ModifyCol(13,0)
}
else
{
	LV_ModifyCol(3,0)
	LV_ModifyCol(5,0)
	LV_ModifyCol(7,0)
	LV_ModifyCol(10,0)
	LV_ModifyCol(12,0)
	LV_ModifyCol(13,0)
}
;GuiControl, Disable, 专题
return

Login:
	NowURL := wb.LocationUrl
	StringGetPos, Pos1, NowURL, =, R
	Pos2 := Pos1 + 2
	Hash := SubStr(NowURL, Pos2)
	if Hash=
	{
		url:="http://192.168.102.102:8586/index.php?m=admin&c=index&a=login&pc_hash="
		wb.Navigate(url)
		While wb.readystate != 4 or WB.busy
			Sleep 10
		doc := wb.doc
		doc.getElementById("username").value := "robot"
		doc.getElementById("password").value := "XVd-aT7-dKD-8RZ"
	}
return

Collection:
	gosub, GetDetail
	Gui, Submit, NoHide
	;MsgBox % PPTopicID "`n" JBTopicID
	if PPTopicID=
		if JBTopicID=
		{
			MsgBox,0x2000,警告, 请至少输入一个专题ID
			return
		}
	if StayRun = 1
	{
		MsgBox,0x2000,警告,程序忙，请耐心等待前一个任务完成
		return
	}
	NowURL := wb.LocationUrl
	if !InStr(NowURL,"http://192.168.102.102:8586")
	{
		MsgBox,0x2000,警告,请先登录后台
		gosub, Login
		return
	}
	StayRun := 1
	GuiControl, Disable, 专题
	NowURL := wb.LocationUrl
	if InStr(NowURL,"http://192.168.102.102:8586/index.php?m=admin&c=index&a=login&pc_hash=")
	{
		MsgBox,0x2000,警告, 请先完成登录
		StayRun := 0
		GuiControl, Enable, 专题
		gosub, Login
		return
	}
	NowURL := wb.LocationUrl
	StringGetPos, Pos1, NowURL, =, R
	Pos2 := Pos1 + 2
	Hash := SubStr(NowURL, Pos2)
	Loop % LV_GetCount()
	{
		RowNumber := A_Index
		LV_GetText(itemid, RowNumber,2)
		LV_GetText(appid, RowNumber,3)
		LV_GetText(remark, RowNumber,11)
		;LV_GetText(catid, RowNumber,13)
		;MsgBox % itemid "`n" appid "`n" catid "`n" remark
		if PPTopicID =
			itemid := ""
		if itemid <>
		{
			URL := "http://192.168.102.102:8586/index.php?m=apple&c=special&a=edit_special_forid&from_api=1&speid=&cid=" . itemid . "&table=1&pc_hash=" . Hash
			wb.Navigate(URL)
			While wb.readystate != 4 or wb.busy
				Sleep 10
			doc := wb.doc
			InPPTpID := "id_" . PPTopicID
			doc.getElementById(InPPTpID).checked := true
			doc.getElementById(InPPTpID).id := InPPTpID . "_1"
			if doc.getElementById(InPPTpID) <>
				doc.getElementById(InPPTpID).checked := true
			Sleep 1000
			doc.getElementById("dosubmit").click()
			While wb.readystate != 4 or wb.busy
				Sleep 10
		}
		if JBTopicID =
			appid := ""
		if appid <>
		{
			URL := "http://192.168.102.102:8586/index.php?m=content&c=content&a=edit_special_forid&from_api=1&speid=&cid=" . appid . "&pc_hash=" . Hash
			wb.Navigate(URL)
			While wb.readystate != 4 or wb.busy
				Sleep 10
			doc := wb.doc
			InJBTpID := "id_" . JBTopicID
			doc.getElementById(InJBTpID).checked := true
			doc.getElementById(InJBTpID).id := InJBTpID . "_1"
			if doc.getElementById(InJBTpID) <>
				doc.getElementById(InJBTpID).checked := true
			Sleep 1000
			doc.getElementById("dosubmit").click()
			While wb.readystate != 4 or wb.busy
				Sleep 10
		}
	}
	URL := "http://192.168.102.102:8586/index.php?m=admin&c=index&pc_hash=" . Hash
	wb.Navigate(URL)
	StayRun := 0
	GuiControl, Enable, 专题
	MsgBox,0x2000,注意, 专题已经添加完成
return

SubMode:
	Gui, Submit, NoHide
	if StayRun = 1
	{
		MsgBox,0x2000,警告,程序忙，请耐心等待前一个任务完成
		return
	}
	NowURL := wb.LocationUrl
	if !InStr(NowURL,"http://192.168.102.102:8586")
	{
		MsgBox,0x2000,警告,请先登录后台
		gosub, Login
		return
	}
	StayRun := 1
	GuiControl, Disable, 推荐
	NowURL := wb.LocationUrl
	if InStr(NowURL,"http://192.168.102.102:8586/index.php?m=admin&c=index&a=login&pc_hash=")
	{
		MsgBox,0x2000,警告,请先完成登录
		StayRun := 0
		GuiControl, Enable, 专题
		gosub, Login
		return
	}
	NowURL := wb.LocationUrl
	StringGetPos, Pos1, NowURL, =, R
	Pos2 := Pos1 + 2
	Hash := SubStr(NowURL, Pos2)
	;MsgBox % Hash
	StayLoop := 1
	Loop % LV_GetCount()
	{
		RowNumber := A_Index
		LV_GetText(itemid, RowNumber,2)
		LV_GetText(appid, RowNumber,3)
		LV_GetText(ppremark, RowNumber,11)
		LV_GetText(jbremark, RowNumber,12)
		LV_GetText(catid, RowNumber,13)
		;MsgBox % itemid "`n" appid "`n" catid "`n" remark
		;itemid := 405275136
		if itemid <>
		{
			URL := "http://192.168.102.102:8586/index.php?m=apple&c=apple&a=share_edit&itemid=" . itemid . "&pc_hash=" . Hash
			wb.Navigate(URL)
			While wb.readystate != 4 or wb.busy
				Sleep 10
			doc := wb.doc
			doc.getElementById("remark_on").value := ppremark
			Sleep 1000
			doc.getElementById("dosubmit").click()
			Loop
			{
			   doc := WB.doc
			   if doc.All[12].InnerHTML = 操作成功
				  break
			}
		}
		;appid := 337643
		;catid := 98
		if appid <>
		{
			URL := "http://192.168.102.102:8586/index.php?m=content&c=content&a=edit&catid=" . catid . "&id=" . appid . "&pc_hash=" . Hash
			wb.Navigate(URL)
			While wb.readystate != 4 or wb.busy
				Sleep 10
			doc := wb.doc
			doc.getElementById("remark_on").value := jbremark
			Sleep 1000
			doc.getElementById("dosubmit_continue").click()
			While wb.readystate != 4 or wb.busy
				Sleep 10
		}
	}
	URL := "http://192.168.102.102:8586/index.php?m=admin&c=index&pc_hash=" . Hash
	wb.Navigate(URL)
	StayRun := 0
	GuiControl, Enable, 推荐
	MsgBox,0x2000,注意, 点评已经添加完成
return

Query:
	Gui, Submit, NoHide
	if StayRun = 1
	{
		MsgBox,0x2000,警告,程序忙，请耐心等待前一个任务完成
		return
	}
	StayRun := 1
	FalseList=
	GuiControl, Disable, 查ID
	LV_Delete()
	IL_Destroy(himl)
	himl:=DllCall("ImageList_Create",Int,45,Int,45,UInt,0x21,Int,10,Int,1)
	LV_SetImageList(himl,1)
	URL := "http://pppc2.25pp.com/pp_api/ios.php"
	Loop, Parse, KeyWords, `,`n, `r%A_Space%
	{
		if A_LoopField =
			break
		RowNumber := A_Index
		AppListID := A_LoopField
		SearchTime := 0
		Loop, 2
		{
			if JBType = 1
				data := "site=3&id=" . AppListID
			if JBType = 2
				data := "site=1&id=" . AppListID
			PPJson := UrlPost(URL,data)
			ppName := json(PPJson,"name")
			AppName := JavaEscapedToUnicode(ppName)
			if AppName<>
			{
				LVWrite(RowNumber,AppListID,JBType,himl,PPJson)
				if JBType = 1
					LV_GetText(AppListName, RowNumber,4)
				if JBType = 2
					LV_GetText(AppListName, RowNumber,5)
				LV_GetText(AppListBundle, RowNumber,8)
				PosN := RegExMatch(AppListName, ".?[\s|-|\(|（|－]")
				StringLeft, PPSearchWord, AppListName, PosN
				if PosN = 0
					PPSearchWord := AppListName
				;MsgBox % AppListName "`n" PosN "`n" SearchWord
				if JBType = 1
					SearchWord := PPSearchWord
				if JBType = 2
					SearchWord := AppListName
				searchjson := PPSearch(SearchWord,2)
				;MsgBox % KeyWord "`n" JBType "`n" searchjson
				Loop, 10
				{
					LoopTime := A_Index - 1
					searchname := "content[" . LoopTime . "].title"
					AppName := json(searchjson,searchname)
					if AppName =
						break
					searchappid := "content[" . LoopTime . "].id"
					AppID := json(searchjson,searchappid)
					searchappitid := "content[" . LoopTime . "].itemId"
					AppITID := json(searchjson,searchappitid)
					if JBType = 1
						AppSID := AppITID
					if JBType = 2
						AppSID := AppID
					;MsgBox % "原始ID：" AppListID "`n匹配ID：" AppSID
					if AppListID = %AppSID%
					{
						URL := "http://pppc2.25pp.com/pp_api/ios.php"
						if JBType = 1
							data := "site=1&id=" . AppID
						if JBType = 2
							data := "site=3&id=" . AppITID
						PPJson := UrlPost(URL,data)
						;MsgBox % PPJson
						ppName := json(PPJson,"name")
						AppName := JavaEscapedToUnicode(ppName)
						;MsgBox % AppName
						if AppName =
							break
						if JBType = 1
							LVWrite(RowNumber,AppID,JBType,himl,PPJson,1)
						if JBType = 2
							LVWrite(RowNumber,AppITID,JBType,himl,PPJson,1)
						SearchTime := 1
						break
					}
				}
				if SearchTime <> 1
				{
					if JBType = 1
						SType := 2
					if JBType = 2
						SType := 1
					searchjson := PPSearch(SearchWord,SType,20)
					;MsgBox % searchjson
					Loop, 20
					{
						LoopTime := A_Index - 1
						searchname := "content[" . LoopTime . "].title"
						AppName := json(searchjson,searchname)
						if AppName =
							break
						searchbundel := "content[" . LoopTime . "].buid"
						AppBundle := json(searchjson,searchbundel)
						;MsgBox % "原：" AppListBundle "`n新：" AppBundle
						if AppListBundle = %AppBundle%
						{
							searchappid := "content[" . LoopTime . "].id"
							AppID := json(searchjson,searchappid)
							searchappitid := "content[" . LoopTime . "].itemId"
							AppITID := json(searchjson,searchappitid)
							URL := "http://pppc2.25pp.com/pp_api/ios.php"
							if JBType = 1
								data := "site=1&id=" . AppID
							if JBType = 2
								data := "site=3&id=" . AppITID
							PPJson := UrlPost(URL,data)
							if JBType = 1
								LVWrite(RowNumber,AppID,JBType,himl,PPJson,1)
							if JBType = 2
								LVWrite(RowNumber,AppITID,JBType,himl,PPJson,1)
							SearchTime := 2
							break
						}
					}
				}
				if SearchTime <> 0 
					break
			}
			else
			{
				if A_Index = 1
				{
					if JBType = 1
						GuiControl, , 查询越狱, 1
					if JBType = 2
						GuiControl, , 查询正版, 1
					Gui, Submit, NoHide
				}
				if A_Index = 2
					if SearchTime = 0
						FalseList .= A_LoopField "`n"
				;~ if JBType = 1
					;~ data := "site=3&id=" . A_LoopField
				;~ if JBType = 2
					;~ data := "site=1&id=" . A_LoopField
				;~ PPJson := UrlPost(URL,data)
				;~ ppName := json(PPJson,"name")
				;~ AppName := JavaEscapedToUnicode(ppName)
				;~ if AppName<>
					;~ LVWrite(A_index,A_LoopField,JBType,himl,PPJson)
			}
		}
	}
	if FalseList <>
		MsgBox,0x2000,警告,以下AppID:`n%FalseList% 不能查询到任何匹配应用
	;~ Loop % LV_GetCount()
	;~ {
		;~ RowNumber := A_Index
		;~ SearchJB := 0
		;~ LV_GetText(AppID, RowNumber,3)
		;~ if AppID <>
		;~ {
			;~ GuiControl, , 查询越狱, 1
			;~ Gui, Submit, NoHide
		;~ }
		;~ if JBType = 1
		;~ {
			;~ LV_GetText(AppListName, RowNumber,4)
			;~ LV_GetText(AppListID, RowNumber,2)
		;~ }
		;~ if JBType = 2
		;~ {
			;~ LV_GetText(AppListName, RowNumber,5)
			;~ LV_GetText(AppListID, RowNumber,3)
		;~ }
		;~ LV_GetText(AppListBundle, RowNumber,8)
		;~ PosN := RegExMatch(AppListName, ".?[\s|-|\(|（|－]")
		;~ StringLeft, PPSearchWord, AppListName, PosN
		;~ if PosN = 0
			;~ PPSearchWord := AppListName
		;~ ;MsgBox % AppListName "`n" PosN "`n" SearchWord
		;~ if JBType = 1
			;~ SearchWord := PPSearchWord
		;~ if JBType = 2
			;~ SearchWord := AppListName
		;~ searchjson := PPSearch(SearchWord,2)
		;~ ;MsgBox % KeyWord "`n" JBType "`n" searchjson
		;~ Loop, 10
		;~ {
			;~ ;break
			;~ LoopTime := A_Index - 1
			;~ searchname := "content[" . LoopTime . "].title"
			;~ AppName := json(searchjson,searchname)
			;~ if AppName =
				;~ break
			;~ searchappid := "content[" . LoopTime . "].id"
			;~ AppID := json(searchjson,searchappid)
			;~ searchappitid := "content[" . LoopTime . "].itemId"
			;~ AppITID := json(searchjson,searchappitid)
			;~ if JBType = 1
				;~ AppSID := AppITID
			;~ if JBType = 2
				;~ AppSID := AppID
			;~ ;MsgBox % "原始ID：" AppListID "`n匹配ID：" AppSID
			;~ if AppListID = %AppSID%
			;~ {
				;~ URL := "http://pppc2.25pp.com/pp_api/ios.php"
				;~ if JBType = 1
					;~ data := "site=1&id=" . AppID
				;~ if JBType = 2
					;~ data := "site=3&id=" . AppITID
				;~ PPJson := UrlPost(URL,data)
				;~ ;MsgBox % PPJson
				;~ ppName := json(PPJson,"name")
				;~ AppName := JavaEscapedToUnicode(ppName)
				;~ ;MsgBox % AppName
				;~ if AppName =
					;~ break
				;~ if JBType = 1
					;~ LVWrite(RowNumber,AppID,JBType,himl,PPJson,1)
				;~ if JBType = 2
					;~ LVWrite(RowNumber,AppITID,JBType,himl,PPJson,1)
				;~ SearchJB := 1
				;~ break
			;~ }
		;~ }
		;~ if SearchJB <> 1
		;~ {
			;~ if JBType = 1
				;~ SType := 2
			;~ if JBType = 2
				;~ SType := 1
			;~ searchjson := PPSearch(SearchWord,SType,20)
			;~ ;MsgBox % searchjson
			;~ Loop, 20
			;~ {
				;~ LoopTime := A_Index - 1
				;~ searchname := "content[" . LoopTime . "].title"
				;~ AppName := json(searchjson,searchname)
				;~ if AppName =
					;~ break
				;~ searchbundel := "content[" . LoopTime . "].buid"
				;~ AppBundle := json(searchjson,searchbundel)
				;~ ;MsgBox % "原：" AppListBundle "`n新：" AppBundle
				;~ if AppListBundle = %AppBundle%
				;~ {
					;~ searchappid := "content[" . LoopTime . "].id"
					;~ AppID := json(searchjson,searchappid)
					;~ searchappitid := "content[" . LoopTime . "].itemId"
					;~ AppITID := json(searchjson,searchappitid)
					;~ URL := "http://pppc2.25pp.com/pp_api/ios.php"
					;~ if JBType = 1
						;~ data := "site=1&id=" . AppID
					;~ if JBType = 2
						;~ data := "site=3&id=" . AppITID
					;~ PPJson := UrlPost(URL,data)
					;~ if JBType = 1
						;~ LVWrite(RowNumber,AppID,JBType,himl,PPJson,1)
					;~ if JBType = 2
						;~ LVWrite(RowNumber,AppITID,JBType,himl,PPJson,1)
					;~ break
				;~ }
			;~ }
		;~ }
	;~ }
	if JBType = 1
		GuiControl, , 查询越狱, 1
	if JBType = 2
		GuiControl, , 查询正版, 1
	LV_ModifyCol()
	LV_ModifyCol(4,80)
	LV_ModifyCol(5,80)
	LV_ModifyCol(8,70)
	LV_ModifyCol(13,0)
	StayRun := 0
	GuiControl, Enable, 查ID
return

GuiContextMenu:
	if A_GuiControl <> AppGrid
		return
	Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
return

ContextCheckCon:
	Gui, Submit, NoHide
	RowNumber := LV_GetNext(0)
	LV_GetText(AppID, RowNumber,3)
	if AppID <>
	{
		GuiControl, , 查询越狱, 1
		Gui, Submit, NoHide
	}
	if JBType = 1
		LV_GetText(RetrievedID, RowNumber, 2)
	if JBType = 2
		LV_GetText(RetrievedID, RowNumber, 3)
	;MsgBox % RetrievedID
	;~ WinGetPos, x, y, w, , ahk_id %GuiWinHWND%
	;~ if x+w+2GuiW > A_ScreenWidth
		;~ if x-2GuiW-5 > 0
			;~ 2GuiX := x-2GuiW-5
		;~ else
			;~ 2GuiX := 10
	;~ else
		;~ 2GuiX := x+w+5
	;WinMove, % "ahk_id" 2GUIhwnd,, %2GuiX%, %y%, %2GuiW%, %2GuiH%
	;WinMove, % "ahk_id" 2GUIhwnd,, (x+w+2GuiW > A_ScreenWidth? x-2GuiW-5:x+w+5), %y%, %2GuiW%, %2GuiH%
	;WinShow, % "ahk_id" 2GUIhwnd
	wb.Visible := true
	url := A_ScriptDir . "`\Temp`\" . RetrievedID . ".html"
	wb.Navigate(url)
	While wb.readystate != 4 or wb.busy
		Sleep 10
	doc := WB.doc
	DisplayDoc := doc.all[0].innerText
	GuiControl,, KeyWords, %DisplayDoc%
return


ContextCopyRows:
	Gui 1: Default
	Gui, Submit, NoHide
	SelectContent :=
	RowNumber := 0
	Loop % LV_GetCount("S")
	{
		RowNumber := LV_GetNext(RowNumber)
		if JBType = 1
			LV_GetText(RetrievedText, RowNumber, 2)
		if JBType = 2
			LV_GetText(RetrievedText, RowNumber, 3)
		SelectContent := SelectContent . RetrievedText . "`r`n"
	}
	Clipboard := SelectContent
return

ContextClearRows:
	Gui 1: Default
	LV_Delete()
	IL_Destroy(himl)
return

AppGrid:
	if A_GuiEvent = K  ; 脚本还可以检查许多其他的可能值.
		;if A_EventInfo = 32
		MsgBox % "检测到" Chr(A_EventInfo)
			;gosub, ContextCheckCon
;{
;    LV_GetText(itemid, A_EventInfo, 2) ; 从首个字段中获取文本.
;    LV_GetText(id, A_EventInfo, 3)  ; 从第二个字段中获取文本.
;	MsgBox % itemid "`n" id
;	URL := "http://pppc2.25pp.com/pp_api/ios.php"
;	if JBType = 1
;		data := "site=3&id=" . itemid
;	if JBType = 2
;		data := "site=1&id=" . id
;	ppjson := UrlPost(URL,data)
;	ppcontent := json(ppjson,"content")
;	content := JavaEscapedToUnicode(ppcontent)
;	ToolTip, content
;}
return

Search:
	Gui, Submit, NoHide
	if StayRun = 1
	{
		MsgBox,0x2000,警告,程序忙，请耐心等待前一个任务完成
		return
	}
	StayRun := 1
	GuiControl, Disable, 搜索
	LV_Delete()
	IL_Destroy(himl)
	himl:=DllCall("ImageList_Create",Int,45,Int,45,UInt,0x21,Int,w,Int,w,UInt)
	LV_SetImageList(himl,1)
	searchjson := PPSearch(KeyWords,JBType,15)
	;MsgBox % searchjson
	Loop, 15
	{
		RowNumber := A_Index
		LoopTime := A_Index - 1
		searchappid := "content[" . LoopTime . "].id"
		AppID := json(searchjson,searchappid)
		searchappitid := "content[" . LoopTime . "].itemId"
		AppITID := json(searchjson,searchappitid)
		URL := "http://pppc2.25pp.com/pp_api/ios.php"
		if JBType = 1
			data := "site=3&id=" . AppITID
		if JBType = 2
			data := "site=1&id=" . AppID
		PPJson := UrlPost(URL,data)
		;MsgBox % PPJson
		ppName := json(PPJson,"name")
		AppName := JavaEscapedToUnicode(ppName)
		;MsgBox % AppName
		if AppName<>
		{
			if JBType = 1
				LVWrite(A_Index,AppITID,JBType,himl,PPJson)
			if JBType = 2
				LVWrite(A_Index,AppID,JBType,himl,PPJson)
		}
		else
			break
	}
	LV_ModifyCol()
	if JBType = 1
	{
		LV_ModifyCol(3,0)
		LV_ModifyCol(4,80)
		LV_ModifyCol(5,0)
		LV_ModifyCol(7,0)
		LV_ModifyCol(8,70)
		LV_ModifyCol(10,0)
		LV_ModifyCol(12,0)
		LV_ModifyCol(13,0)
	}
	if JBType = 2
	{
		LV_ModifyCol(2,0)
		LV_ModifyCol(4,0)
		LV_ModifyCol(5,80)
		LV_ModifyCol(6,0)
		LV_ModifyCol(8,70)
		LV_ModifyCol(9,0)
		LV_ModifyCol(11,0)
		LV_ModifyCol(13,0)
	}
	StayRun := 0
	GuiControl, Enable, 搜索
return

Transfer:
	Gui, Submit, NoHide
	if StayRun = 1
	{
		MsgBox,0x2000,警告,程序忙，请耐心等待前一个任务完成
		return
	}
	StayRun := 1
	GuiControl, Disable, 转换
	Loop % LV_GetCount()
	{
		RowNumber := A_Index
		SearchJB := 0
		LV_GetText(AppID, RowNumber,3)
		if AppID <>
		{
			GuiControl, , 查询越狱, 1
			Gui, Submit, NoHide
		}
		if JBType = 1
		{
			LV_GetText(AppListName, RowNumber,4)
			LV_GetText(AppListID, RowNumber,2)
		}
		if JBType = 2
		{
			LV_GetText(AppListName, RowNumber,5)
			LV_GetText(AppListID, RowNumber,3)
		}
		LV_GetText(AppListBundle, RowNumber,8)
		PosN := RegExMatch(AppListName, ".?[\s|-|\(|（|－]")
		StringLeft, SearchName, AppListName, PosN
		if PosN = 0
			SearchName := AppListName
		;MsgBox % AppListName "`n" PosN "`n" SearchName
		URL := "http://jsondata.25pp.com/index.html"
		if JBType = 1
			data = {"dcType": 0,"keyword": "%SearchName%","clFlag": 1,"perCount": 10,"page": 0}
		if JBType = 2
			data = {"dcType": 0,"keyword": "%AppListName%","clFlag": 1,"perCount": 10,"page": 0}
		;MsgBox % URl "`n" data
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("Post", URL, true)
		WebRequest.SetRequestHeader("Referer", "http://jsondata.25pp.com/index.html?tunnel-command=4261421120")
		WebRequest.SetRequestHeader("Origin", "http://jsondata.25pp.com")
		WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3")
		WebRequest.SetRequestHeader("Tunnel-Command", "4262469664")
		WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		WebRequest.Send(data)
		WebRequest.WaitForResponse(-1)
		searchjson := WebRequest.ResponseText
		;MsgBox % searchjson
		Loop, 10
		{
			;break
			LoopTime := A_Index - 1
			searchname := "content[" . LoopTime . "].title"
			AppName := json(searchjson,searchname)
			if AppName =
				break
			searchappid := "content[" . LoopTime . "].id"
			AppID := json(searchjson,searchappid)
			searchappitid := "content[" . LoopTime . "].itemId"
			AppITID := json(searchjson,searchappitid)
			if JBType = 1
				AppSID := AppITID
			if JBType = 2
				AppSID := AppID
			;MsgBox % "原始ID：" AppListID "`n匹配ID：" AppSID
			if AppListID = %AppSID%
			{
				URL := "http://pppc2.25pp.com/pp_api/ios.php"
				if JBType = 1
					data := "site=1&id=" . AppID
				if JBType = 2
					data := "site=3&id=" . AppITID
				PPJson := UrlPost(URL,data)
				ppName := json(PPJson,"name")
				AppName := JavaEscapedToUnicode(ppName)
				if AppName =
				{
					SearchJB := 1
					break
				}
				if JBType = 1
					LVWrite(RowNumber,AppID,JBType,himl,PPJson,1)
				if JBType = 2
					LVWrite(RowNumber,AppITID,JBType,himl,PPJson,1)
				SearchJB := 1
				break
			}
		}
		if SearchJB <> 1
		{
			URL := "http://jsondata.25pp.com/index.html"
			if JBType = 1
				data = {"dcType": 0,"keyword": "%SearchName%","clFlag": 1,"perCount": 20,"page": 0}
			if JBType = 2
				data = {"dcType": 0,"keyword": "%SearchName%","clFlag": 3,"perCount": 20,"page": 0}
			;MsgBox % URl "`n" data
			WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			WebRequest.Open("Post", URL, true)
			WebRequest.SetRequestHeader("Referer", "http://jsondata.25pp.com/index.html?tunnel-command=4261421120")
			WebRequest.SetRequestHeader("Origin", "http://jsondata.25pp.com")
			WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3")
			if JBType = 1
				WebRequest.SetRequestHeader("Tunnel-Command", "4262469664")
			if JBType = 2
				WebRequest.SetRequestHeader("Tunnel-Command", "4262469686")
			WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
			WebRequest.Send(data)
			WebRequest.WaitForResponse(-1)
			searchjson := WebRequest.ResponseText
			;MsgBox % searchjson
			Loop, 20
			{
				LoopTime := A_Index - 1
				searchname := "content[" . LoopTime . "].title"
				AppName := json(searchjson,searchname)
				if AppName =
					break
				searchbundel := "content[" . LoopTime . "].buid"
				AppBundle := json(searchjson,searchbundel)
				;MsgBox % "原：" AppListBundle "`n新：" AppBundle
				if AppListBundle = %AppBundle%
				{
					searchappid := "content[" . LoopTime . "].id"
					AppID := json(searchjson,searchappid)
					searchappitid := "content[" . LoopTime . "].itemId"
					AppITID := json(searchjson,searchappitid)
					URL := "http://pppc2.25pp.com/pp_api/ios.php"
					if JBType = 1
						data := "site=1&id=" . AppID
					if JBType = 2
						data := "site=3&id=" . AppITID
					PPJson := UrlPost(URL,data)
					if JBType = 1
						LVWrite(RowNumber,AppID,JBType,himl,PPJson,1)
					if JBType = 2
						LVWrite(RowNumber,AppITID,JBType,himl,PPJson,1)
					break
				}
			}
		}
	}
	if JBType = 1
		GuiControl, , 查询越狱, 1
	if JBType = 2
		GuiControl, , 查询正版, 1
	LV_ModifyCol()
	LV_ModifyCol(4,80)
	LV_ModifyCol(5,80)
	LV_ModifyCol(8,70)
	LV_ModifyCol(13,0)
	StayRun := 0
	GuiControl, Enable, 转换
return

Copy:
	Gui, Submit, NoHide
	AppIDContent :=
	Loop % LV_GetCount()
	{
		if JBType = 1
			LV_GetText(RetrievedText, A_Index,2)
		if JBType = 2
			LV_GetText(RetrievedText, A_Index,3)
		if RetrievedText<>
			AppIDContent := AppIDContent . RetrievedText . "`r`n"
	}
	StringGetPos, Pos1, AppIDContent, `r`n, R
	Pos2 := Pos1 + 1
	StringLeft, AppIDContent, AppIDContent, Pos2
	Clipboard := AppIDContent
return


GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, BoxIn, % "W" . (A_GuiWidth - 28)
	GuiControl, Move, BoxOut, % "W" . (A_GuiWidth - 28) . " H" . (A_GuiHeight - 185)
	GuiControl, Move, AppGrid, % "W" . (A_GuiWidth - 58) . " H" . (A_GuiHeight - 215)
	GuiControl, Move, Mytabs, % "W" . (A_GuiWidth - 10) . " H" . (A_GuiHeight - 10)
	GuiControl, Move, WB, % "W" . (A_GuiWidth - 28) . " H" . (A_GuiHeight - 80)
return


GuiClose:
	CSV_LVSave("LVContent.csv", ";", 1, 1)
	Gui, Destroy
	ObjRelease(pipa)
	ExitApp

GetDetail:
	KeyWord := 刀塔
	URL := "http://jsondata.25pp.com/index.html"
	wb.Open("Post", URL, true)
	data = {"dcType": 0,"keyword": "%KeyWord%","clFlag": 3,"perCount": 10,"page": 0}
	wb.SetRequestHeader("Referer", "http://jsondata.25pp.com/index.html?tunnel-command=4261421120")
	wb.SetRequestHeader("Origin", "http://jsondata.25pp.com")
	wb.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3")
	wb.SetRequestHeader("Tunnel-Command", "4262469686")
	wb.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	wb.Send(data)
	wb.WaitForResponse(-1)
	MsgBox % wb.ResponseText
	
	if JBType = 1 
		URL := "http://pppc2.25pp.com/zb_pp_v3/#u_home"
	if JBType = 2
		URL := "http://pppc2.25pp.com/jb_app_v2/#u_home"
	wb.Navigate(URL)
	Sleep 1000
	While wb.readystate != 4 or wb.busy
		Sleep 10
	doc := wb.doc
	doc.getElementById("selectionSoft").all.tags("li")[0].childNodes[0].setAttribute("data-appid","444934666")
	doc.getElementById("selectionSoft").all.tags("li")[0].childNodes[0].Click()
	Sleep 1000
	While wb.readystate != 4 or wb.busy
		Sleep 10
	doc := wb.doc
	picurl := doc.getElementById("popDiv").all.tags("img")[0].src
	;MsgBox % picurl
return

PPsearch(KeyWord, JBType, SCount:=10) {
	URL := "http://jsondata.25pp.com/index.html"
	if JBType = 1
		data = {"dcType": 0,"keyword": "%KeyWord%","clFlag": 3,"perCount": %SCount%,"page": 0}
	if JBType = 2
		data = {"dcType": 0,"keyword": "%KeyWord%","clFlag": 1,"perCount": %SCount%,"page": 0}
	;MsgBox % URl "`n" data
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("Post", URL, true)
	WebRequest.SetRequestHeader("Referer", "http://jsondata.25pp.com/index.html?tunnel-command=4261421120")
	WebRequest.SetRequestHeader("Origin", "http://jsondata.25pp.com")
	WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3")
	if JBType = 1
		WebRequest.SetRequestHeader("Tunnel-Command", "4262469686")
	if JBType = 2
		WebRequest.SetRequestHeader("Tunnel-Command", "4262469664")
	WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	WebRequest.Send(data)
	WebRequest.WaitForResponse(-1)
	return  WebRequest.ResponseText
}


DisableSetRedraw() {
    return 0
}

UrlPost(URL, data) {
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("POST", URL, true)
	WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	WebRequest.Send(data)
	WebRequest.WaitForResponse(-1)
	return WebRequest.ResponseText
}

JavaEscapedToUnicode(s) {
    i := 1
    while j := RegExMatch(s, "\\u[A-Fa-f0-9]{1,4}", m, i)
        e .= SubStr(s, i, j-i) Chr("0x" SubStr(m, 3)), i := j + StrLen(m)
    return e . SubStr(s, i)
}

LVWrite(RowNumber,AppID,JBType,himl,PPJson,Mode:=0) {
	ppName := json(PPJson,"name")
	AppName := JavaEscapedToUnicode(ppName)
	ppeditor := json(PPJson,"editorRemark")
	editor := JavaEscapedToUnicode(ppeditor)
	catid := json(PPJson,"catId")
	AppBundle := json(PPJson,"buid")
	AppType := json(PPJson,"appType")
	StringReplace, AppType, AppType, soft, 软件, All
	StringReplace, AppType, AppType, game, 游戏, All
	AppSize := json(PPJson,"fileSize")
	ppcontent := json(PPJson,"content")
	content := JavaEscapedToUnicode(ppcontent)
	StringReplace , content, content, `\/,/,All
	contenturl := A_ScriptDir . "`\Temp`\" . AppID . ".html"
	IfExist, %contenturl%
		FileDelete, %contenturl%
	FileAppend, %content%, %contenturl%
	iconURL := json(PPJson,"iconUrl")
	StringReplace , iconURL, iconURL, `\/,/,All
	StringGetPos, Pos1, iconURL, `., R
	Pos2 := Pos1 + 1
	Ext := SubStr(iconURL, Pos2)
	picurl := A_ScriptDir . "`\Temp`\" . AppID . Ext
	IfNotExist ,%picurl%
		URLDownloadToFile , %iconURL%, %picurl%
	;MsgBox % picurl "`n" RowNumber "`n" AppID "`n" AppName "`n" AppType "`n" AppBundle "`n" AppSize "`n" editor "`n" catid
	if Mode = 0
	{
		IL_Add(himl,picurl,0,1)
		if JBType = 1
			LV_Add( "icon" . RowNumber ,,AppID,, AppName,, AppType,, AppBundle, AppSize,, editor)	
		if JBType = 2
			LV_Add( "icon" . RowNumber ,,,AppID,, AppName,, AppType, AppBundle,, AppSize,, editor,catid)
	}
	if Mode = 1
	{
		if JBType = 1
			LV_Modify( RowNumber,,,, AppID,, AppName,, AppType, AppBundle,, AppSize,, editor, catid)	
		if JBType = 2
			LV_Modify( RowNumber,,, AppID,, AppName,, AppType,, AppBundle, AppSize,, editor)
	}
	return
}


WM_KEYDOWN(wParam, lParam, nMsg, hWnd)
{
   global pipa
   static keys:={9:"tab", 13:"enter", 46:"delete", 38:"up", 40:"down"}
   if keys.HasKey(wParam)
   {
      WinGetClass, ClassName, ahk_id %hWnd%
      if  (ClassName = "Internet Explorer_Server")
      {
      ;// Build MSG Structure
         VarSetCapacity(Msg, 48)
         for i,val in [hWnd, nMsg, wParam, lParam, A_EventInfo, A_GuiX, A_GuiY]
            NumPut(val, Msg, (i-1)*A_PtrSize)
      ;// Call Translate Accelerator Method
         TranslateAccelerator := NumGet(NumGet(1*pipa)+5*A_PtrSize)
         DllCall(TranslateAccelerator, "Ptr",pipa, "Ptr",&Msg)
         return, 0
      }
   }
}