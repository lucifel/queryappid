#Include json.ahk
#CommentFlag ;

DetectHiddenWindows,On
Run,%ComSpec% /k,,Hide UseErrorLevel,pid
if not ErrorLevel
{
	while !WinExist("ahk_pid" pid)
		Sleep,10
	DllCall("AttachConsole","UInt",pid)
	hCon:=DllCall("CreateFile","str","CONOUT$","uint",0xC0000000,"uint",7,"uint",0,"uint",3,"uint",0,"uint",0)
}

UrlPost(URL, data) {
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("POST", URL, false)
	WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	WebRequest.Send(data)
	return WebRequest.ResponseText
}

Decode(OriText) {
	IfExist, transtxt.tmp
		FileDelete transtxt.tmp
	FileAppend %OriText%, transtxt.tmp
	OriText := ""
	objShell := ComObjCreate("WScript.Shell")
	objExec := objShell.Exec("iconv -c -f java -t gbk transtxt.tmp")
	while, !objExec.StdOut.AtEndOfStream
		return objExec.StdOut.ReadAll()
}

IfNotExist , %A_ScriptDir%`\Temp
	FileCreateDir , %A_ScriptDir%`\Temp
Gui +Resize
Gui, Add, GroupBox, x12 y10 w620 h130 vBoxIn, 输入
Gui, Add, GroupBox, x12 y150 w620 h260 vBoxOut, 输出
Gui, Add, Edit, vKeyWords x42 y30 w350 h100, 请输入需要查询的APPID或应用名，如：411654863
Gui, Add, Button, x420 y30 w80 h30 gCheck Default, 查询
Gui, Add, Button, x520 y30 w80 h30 gTransfer, 转换
Gui, Add, Button, x420 y70 w80 h30 gSearch, 搜索
Gui, Add, Button, x520 y70 w80 h30 gCopy,  复制
Gui, Add, Radio, x420 y110 w80 h20 vJBType Checked, 查询正版
Gui, Add, Radio, x520 y110 w80 h20, 查询越狱
Gui, Add, ListView, x42 y180 w560 h210 vAppGrid gAppGrid, 应用图标|ID|应用名称|产品|类型|Bundle|大小|点评
Menu, MyContextMenu, Add, 清空表单, ContextClearRows
Gui, Show, AutoSize, PP助手应用信息查询工具V1.0
return


Check:
	Gui, Submit, NoHide
	GuiControl, Disable, 查询
	LV_Delete()
	IL_Destroy(himl)
	himl:=DllCall("ImageList_Create",Int,45,Int,45,UInt,0x21,Int,w,Int,w,UInt)
	LV_SetImageList(himl,1)
	URL := "http://pppc2.25pp.com/pp_api/ios.php"
	Loop, Parse, KeyWords, `,`n, `r%A_Space%
	{
		if JBType = 1
			data := "site=3&id=" . A_LoopField
		else if JBType = 2
			data := "site=1&id=" . A_LoopField
		ppjson := UrlPost(URL,data)
		ppName := json(ppjson,"name")
		AppName := Decode(ppName)
		ppeditor := json(ppjson,"editorRemark")
		editor := Decode(ppeditor)
		if AppName<>
		{
			AppBundle := json(ppjson,"buid")
			if JBType = 1
				ProductType = 正版
			else if JBType = 2
				ProductType = 越狱
			AppType := json(ppjson,"appType")
			StringReplace, AppType, AppType, soft, 软件, All
			StringReplace, AppType, AppType, game, 游戏, All
			AppSize := json(ppjson,"fileSize")
			iconURL := json(ppjson,"iconUrl")
			StringReplace , iconURL, iconURL, `\/,/,All
			picurl := A_ScriptDir . "`\Temp`\" . A_LoopField . ".jpg"
			IfNotExist ,%picurl%
				URLDownloadToFile , %iconURL%, %picurl%
			IL_Add(himl,picurl,0,1)
			LV_Add( "icon" . A_Index ,,A_LoopField, AppName, ProductType, AppType, AppBundle, AppSize, editor)
			LV_ModifyCol()
		}
		else
			MsgBox ,,警告,AppID:%A_LoopField%不能查询到任何匹配应用
	}
	GuiControl, Enable, 查询
return

GuiContextMenu:
	if A_GuiControl <> AppGrid
		return
	Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
return

ContextClearRows:
	LV_Delete()
	IL_Destroy(himl)
	himl:=DllCall("ImageList_Create",Int,45,Int,45,UInt,0x21,Int,w,Int,w,UInt)
	LV_SetImageList(himl,1)
return

Search:
	Gui, Submit, NoHide
	GuiControl, Disable, 搜索
	LV_Delete()
	IL_Destroy(himl)
	himl:=DllCall("ImageList_Create",Int,45,Int,45,UInt,0x21,Int,w,Int,w,UInt)
	LV_SetImageList(himl,1)
	URL := "http://jsondata.25pp.com/index.html"
	if JBType = 1
		data = {"dcType": 0,"keyword": "%KeyWords%","clFlag": 3,"perCount": 10,"page": 0}
	else if JBType = 2
		data = {"dcType": 0,"keyword": "%KeyWords%","clFlag": 1,"perCount": 10,"page": 0}
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("Post", URL, false)
	WebRequest.SetRequestHeader("Referer", "http://jsondata.25pp.com/index.html?tunnel-command=4261421120")
	WebRequest.SetRequestHeader("Origin", "http://jsondata.25pp.com")
	WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3")
	WebRequest.SetRequestHeader("Tunnel-Command", "4262469686")
	WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	WebRequest.Send(data)
	searchjson := WebRequest.ResponseText
	Loop, 10
	{
		LoopTime := A_Index - 1
		searchname := "content[" . LoopTime . "].title"
		AppName := json(searchjson,searchname)
		searchbundel := "content[" . LoopTime . "].buid"
		AppBundle := json(searchjson,searchbundel)
		if JBType = 1
			ProductType = 正版
		else if JBType = 2
			ProductType = 越狱
		searchapptype := "content[" . LoopTime . "].resType"
		AppType := json(searchjson,searchapptype)
		StringReplace, AppType, AppType, 1, 软件, All
		StringReplace, AppType, AppType, 2, 游戏, All
		searchappsize := "content[" . LoopTime . "].fsize"
		AppSize := json(searchjson,searchappsize)
		searchiconurl := "content[" . LoopTime . "].thumb"
		iconURL := json(searchjson,searchiconurl)
		if JBType = 1
			searchappid := "content[" . LoopTime . "].itemId"
		else if JBType = 2
			searchappid := "content[" . LoopTime . "].id"
		AppID := json(searchjson,searchappid)
		picurl := A_ScriptDir . "`\Temp`\" . AppID . ".jpg"
		IfNotExist ,%picurl%
			URLDownloadToFile , %iconURL%, %picurl%
		IL_Add(himl,picurl,0,1)
		LV_Add( "icon" . A_Index ,, AppID, AppName, ProductType, AppType, AppBundle, AppSize)
		LV_ModifyCol()
	}
	GuiControl, Enable, 搜索
return

Transfer:
	Gui, Submit, NoHide
	GuiControl, Disable, 转换
	Loop % LV_GetCount()
	{
		RowNumber := A_Index
		LV_GetText(AppListName, RowNumber,3)
		LV_GetText(AppListBundle, RowNumber,6)
		Pos1 := InStr(AppListName, A_Space)
		Pos2 := InStr(AppListName, "-")
		;MsgBox % Pos1 A_Tab Pos2
		if Pos1 * Pos2 = 0
		{
			if Pos1 = 0
			{
				PosS := Pos2 - 1
				if Pos2 = 0
					PosS := StrLen(AppListName)
			}
			else
				PoSS := Pos1 - 1
		}
		else if Pos1 >= Pos2
			PosS := Pos2 - 1
		else
			PosS := Pos1 - 1
		StringLeft, SearchName, AppListName, PosS
		;MsgBox %  AppListName "`n" PosS "`n" SearchName
		URL := "http://jsondata.25pp.com/index.html"
		if JBType = 1
			data = {"dcType": 0,"keyword": "%SearchName%","clFlag": 1,"perCount": 10,"page": 0}
		else if JBType = 2
			data = {"dcType": 0,"keyword": "%SearchName%","clFlag": 3,"perCount": 10,"page": 0}
		;MsgBox % URl "`n" data
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("Post", URL, false)
		WebRequest.SetRequestHeader("Referer", "http://jsondata.25pp.com/index.html?tunnel-command=4261421120")
		WebRequest.SetRequestHeader("Origin", "http://jsondata.25pp.com")
		WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/600.6.3 (KHTML, like Gecko) Version/8.0.6 Safari/600.6.3")
		if JBType = 1
			WebRequest.SetRequestHeader("Tunnel-Command", "4262469664")
		else if JBType = 2
			WebRequest.SetRequestHeader("Tunnel-Command", "4262469686")
		WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		WebRequest.Send(data)
		searchjson := WebRequest.ResponseText
		;MsgBox % searchjson
		Loop, 10
		{
			LoopTime := A_Index - 1
			searchname := "content[" . LoopTime . "].title"
			AppName := json(searchjson,searchname)
			searchbundel := "content[" . LoopTime . "].buid"
			AppBundle := json(searchjson,searchbundel)
			if JBType = 1
				ProductType = 越狱
			else if JBType = 2
				ProductType = 正版
			searchapptype := "content[" . LoopTime . "].resType"
			AppType := json(searchjson,searchapptype)
			StringReplace, AppType, AppType, 1, 软件, All
			StringReplace, AppType, AppType, 2, 游戏, All
			searchappsize := "content[" . LoopTime . "].fsize"
			AppSize := json(searchjson,searchappsize)
			searchiconurl := "content[" . LoopTime . "].thumb"
			iconURL := json(searchjson,searchiconurl)
			if JBType = 1
				searchappid := "content[" . LoopTime . "].id"
			else if JBType = 2
				searchappid := "content[" . LoopTime . "].itemId"
			AppID := json(searchjson,searchappid)
			picurl := A_ScriptDir . "`\Temp`\" . AppID . ".jpg"
			if AppListBundle := AppBundle
			{
				;MsgBox %  RowNumber A_Tab AppID A_Tab AppName A_Tab ProductType A_Tab AppType A_Tab AppBundle A_Tab AppSize
				LV_Modify( RowNumber,,, AppID, AppName, ProductType, AppType, AppBundle, AppSize)
				LV_ModifyCol()
				break
			}
		}
	}
	if JBType = 1
		GuiControl, , 查询越狱, 1
	else if JBType = 2
		GuiControl, , 查询正版, 1
	GuiControl, Enable, 转换
return

Copy:
	AppIDContent :=
	Loop % LV_GetCount()
	{
		LV_GetText(RetrievedText, A_Index,2)
		AppIDContent := AppIDContent . RetrievedText . "`r`n"
	}
	Clipboard := AppIDContent
return

AppGrid:
return

GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, BoxIn, % "W" . (A_GuiWidth - 23)
	GuiControl, Move, BoxOut, % "W" . (A_GuiWidth - 23) . " H" . (A_GuiHeight - 156)
	GuiControl, Move, AppGrid, % "W" . (A_GuiWidth - 83) . " H" . (A_GuiHeight - 206)
return


GuiClose:
	DllCall("CloseHandle", "uint", hCon)
	DllCall("FreeConsole")
	Process, Close, %pid%
	IfExist, transtxt.tmp
		FileDelete transtxt.tmp
	ExitApp