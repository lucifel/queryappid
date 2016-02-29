#NoEnv
#Include json.ahk
#Include Class_LV_InCellEdit.ahk
#Include WinHttpRequest.ahk
#CommentFlag ;
SetBatchLines, -1


Gui +LastFound +Resize +OwnDialogs
Gui, Add, Tab2, x5 y5 w630 h470 vMytabs,`  应用管理  |  运营后台  |
Gui, Add, GroupBox, x14 y35 w612 h130 vBoxIn, 输入
Gui, Add, GroupBox, x14 y170 w612 h295 vBoxOut, 输出
Gui, Add, Edit, vKeyWords x28 y55 w350 h100, 请输入需要查询的APPID或应用名，如：333206289
Gui, Add, Button, x400 y55 w90 h30 gQuery Default, 查ID
Gui, Add, Button, x510 y55 w90 h30 gSave, 保存
Gui, Add, Button, x400 y95 w90 h30 gSearch, 搜索
Gui, Add, Button, x510 y95 w90 h30 gSync,  同步
Gui, Add, Radio, x420 y135 w80 h20 vJBType Checked, 查询正版
Gui, Add, Radio, x520 y135 w80 h20, 查询越狱
Gui, Add, ListView, x28 y190 w582 h265 -Readonly r6 vAppRecomm gAppRecomm hwndHLV1 AltSubmit, 应用图标|权重|应用ID|推荐ID|推荐名称|下载量|推荐版位|素材ID|素材类型|版本区间|开始投放时间|结束投放时间
ICELV1 := New LV_InCellEdit(HLV1)
ICELV1.SetColumns(2, 3)
Menu, MyContextMenu, Add, 查看简介, ContextCheckCon
Menu, MyContextMenu, Add, 复制内容, ContextCopyRows
Menu, MyContextMenu, Add, 清空表单, ContextClearRows
Menu, MyContextMenu, Add, 测试功能, ContextTest

Gui, Tab, 2
Gui, Add, Button, x25 y30 w70 h25 gLogin, 登录
Gui, Add, Text, x105 y36 w55 h25, 正版专题:
Gui, Add, Edit, vPPTopicID x170 y33 w60 h20
Gui, Add, Text, x240 y36 w55 h25, 越狱专题:
Gui, Add, Edit, vJBTopicID x305 y33 w60 h20
Gui, Add, Button, x375 y30 w70 h25 gCollection, 加专题
Gui, Add, Button, x455 y30 w70 h25 gSubMode, 加点评

Gui, Show, w640 h480 Center, PP助手应用信息查询工具V1.6 20160217

return

Login:

return

Sync:
	Gui, Submit, NoHide
	GuiControl, Disable, 同步
	IniRead, Cookie2, Settings.ini, WA统计, Cookie
	;~ WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	URL := "http://wa.ucdns.uc.cn:8888"
	RespHeader := HttpRequestWC(URL,InOutData := "",Cookie2)
	;~ WebRequest.Open("GET", URL, true)
	;~ WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	;~ WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
	;~ WebRequest.SetRequestHeader("Cookie",Cookie2)
	;~ WebRequest.Option(6) := False
	;~ WebRequest.Send()
	;~ WebRequest.WaitForResponse(-1)
	;~ RespHeader := WebRequest.Status()
	MsgBox % RespHeader
	if RespHeader <> 200
	{
		IniDelete, Settings.ini, WA统计, Cookie
		Cookie2 = ERROR
	}
	if Cookie2 = ERROR
	{
		URL := "http://uae.ucweb.local/login?rank=z2AnMvJ4&service=wa.ucdns.uc.cn:8888/login"
		HttpRequestWC(URL,InOutData := "",Cookie1 := "")
		;~ WebRequest.Open("GET", URL, true)
		;~ WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		;~ WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
		;~ WebRequest.Option(6) := False
		;~ WebRequest.Send()
		;~ WebRequest.WaitForResponse(-1)
		;~ InOutData := WebRequest.ResponseText
		;~ CookieMore := WebRequest.GetResponseHeader("Set-Cookie")
		;~ RegExMatch(CookieMore,"^[^;]*",Cookie1)
		wb := ComObjCreate("HTMLfile")
		wb.write(InOutData)
		token := wb.getElementsByName("csrf-token")[0].content
		;StringReplace, token, token, =
		MsgBox, % "Cookie1:`n" Cookie1
		MsgBox, % "token:`n" token
		
		URL := "http://uae.ucweb.local/sign_in"
		token := UriEncode(token)
		data := "utf8=%E2%9C%93&authenticity_token=" . token . "&user%5Bemail%5D=changkai.ck%40alibaba-inc.com&user%5Bpassword%5D=zerg2438&user%5Btoken%5D=&user%5Bservice%5D=wa.ucdns.uc.cn%3A8888%2Flogin&commit=%E7%99%BB%E5%BD%95"
		HttpRequestWC(URL,InOutData := data,Cookie1)
		;~ WebRequest.Open("POST", URL, true)
		;~ WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		;~ WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
		;~ WebRequest.SetRequestHeader("Host","uae.ucweb.local")
		;~ WebRequest.SetRequestHeader("Cookie",Cookie1)
		;~ WebRequest.SetRequestHeader("Content-Length", StrLen(data))
		;~ WebRequest.Option(6) := False
		;~ WebRequest.Send(data)
		;~ WebRequest.WaitForResponse(-1)
		;~ URL1 := WebRequest.GetResponseHeader("Location")
		;~ CookieMore := WebRequest.GetResponseHeader("Set-Cookie")
		;~ if CookieMore =
		;~ {
			;~ MsgBox 登录失败，请重试
			;~ return
		;~ }
		;~ RegExMatch(CookieMore,"^.*?;",Cookie1)
		MsgBox % "URL1:`n" URL "`nCookie1:`n" Cookie1
		
		HttpRequestWC(URL,InOutData := "",Cookie2 := "")
		;~ WebRequest.Open("GET", URL1, true)
		;~ WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		;~ WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
		;~ WebRequest.SetRequestHeader("Cookie",Cookie2)
		;~ WebRequest.Option(6) := False
		;~ WebRequest.Send()
		;~ WebRequest.WaitForResponse(-1)
		;~ URL2 := WebRequest.GetResponseHeader("Location")
		;~ Resp := WebRequest.GetAllResponseHeaders
		;~ ;MsgBox % Resp
		;~ p := 1
		;~ while (p := RegExMatch(Resp,"(?<=Set-Cookie: ).*?;",Cookies, p+StrLen(Cookies)))
			;~ Cookie2 .= Cookies . " "
		;~ ;RegExMatch(Resp,"ig)(?<=Set-Cookie: )(.*?)(?=;)",Cookies)
		MsgBox % "URL2:`n" URL "`nCookie2:`n" Cookie2
		
		HttpRequestWC(URL,InOutData := "",Cookie1)
		;~ WebRequest.Open("GET", URL2, true)
		;~ WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		;~ WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
		;~ WebRequest.SetRequestHeader("Cookie",Cookie1)
		;~ WebRequest.Option(6) := False
		;~ WebRequest.Send()
		;~ WebRequest.WaitForResponse(-1)
		;~ URL3 := WebRequest.GetResponseHeader("Location")	
		MsgBox % "URL3:" URL "`nCookie1:`n" Cookie1
		
		HttpRequestWC(URL,InOutData := "",Cookie2)
		;~ WebRequest.Open("GET", URL3, true)
		;~ WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		;~ WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
		;~ WebRequest.SetRequestHeader("Cookie",Cookie2)
		;~ WebRequest.Option(6) := False
		;~ WebRequest.Send()
		;~ WebRequest.WaitForResponse(-1)
		;~ ;URL4 := WebRequest.GetResponseHeader("Location")
		;~ Resp := WebRequest.GetAllResponseHeaders
		;~ Cookie2 := ""
		;~ p := 1
		;~ while (p := RegExMatch(Resp,"(?<=Set-Cookie: ).*?;",Cookies, p+StrLen(Cookies)))
			;~ Cookie2 .= Cookies . " "
		MsgBox % "Cookie2:`n" Cookie2
		IniWrite, %Cookie2%, Settings.ini, WA统计, cookie
	}
	
	SyncRecom(3,Cookie2)
	GuiControl, Enable, 同步
return

SyncRecom(RecomType:=3, Cookie:="") {
	Headers = 
	( LTrim
		User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4
		Content-Type: application/x-www-form-urlencoded
	)
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	r := WinHttpRequest("http://192.168.102.102:8588/index.php?c=login&m=do_login", InOutData := "name=changkai&password=ppcms2014", InOutHeaders := Headers, "Timeout: 10`nNO_AUTO_REDIRECT")
	Loop, %RecomType%
	{
		if A_Index = 1
			r := WinHttpRequest("http://192.168.102.102:8588/index.php?d=recommend&c=recommend_manage&m=index&time_kind=enabled&platform=8&version=7&page_source=167&recommend_position=244", InOutData := "", InOutHeaders := Headers, "Timeout: 10`nNO_AUTO_REDIRECT`nCharset: UTF-8")
		if A_Index = 2
			r := WinHttpRequest("http://192.168.102.102:8588/index.php?d=recommend&c=recommend_manage&m=index&time_kind=enabled&platform=8&version=7&page_source=168&recommend_position=245", InOutData := "", InOutHeaders := Headers, "Timeout: 10`nNO_AUTO_REDIRECT`nCharset: UTF-8")
		if A_Index = 3
			r := WinHttpRequest("http://192.168.102.102:8588/index.php?d=recommend&c=recommend_manage&m=index&time_kind=enabled&platform=8&version=7&page_source=172&recommend_position=246", InOutData := "", InOutHeaders := Headers, "Timeout: 10`nNO_AUTO_REDIRECT`nCharset: UTF-8")
		wb := ComObjCreate("HTMLfile")
		wb.write(InOutData)
		item := wb.getElementByID("recommend-list").getElementsByTagName("tr")
		if A_Index = 1
		{
			LoopNumber = 20
			con1id := UriEncode("精选")
			con2id := UriEncode("精选_热门推荐区域")
		}
		if A_Index =2
		{
			LoopNumber = 10
			con1id := UriEncode("软件")
			con2id := UriEncode("软件_推荐版块")
		}
		if A_Index =3
		{
			LoopNumber = 10
			con1id := UriEncode("游戏")
			con2id := UriEncode("游戏_推荐版块")
		}
		Loop, %LoopNumber%
		{
			i := A_Index
			QIndex := item[i].getElementsByTagName("td")[1].getElementsByTagName("input")[1].value
			AppID := item[i].getElementsByTagName("td")[2].innerText
			RecomID := item[i].getElementsByTagName("td")[3].innerText
			AppName := item[i].getElementsByTagName("td")[4].innerText
			RecomZone := item[i].getElementsByTagName("td")[5].innerText
			MateID := item[i].getElementsByTagName("td")[6].innerText
			MateType := item[i].getElementsByTagName("td")[7].innerText
			RecomVersion := item[i].getElementsByTagName("td")[8].innerText
			StartTime := item[i].getElementsByTagName("td")[9].innerText
			EndTime := item[i].getElementsByTagName("td")[10].innerText
			FormatTime, NowDate, A_Now, yyyy-MM-dd
			QuerryTime := "&from=" . NowDate . "+00%3A00%3A00&to=" . NowDate . "+23%3A59%3A59"
			URL := "http://wa.ucdns.uc.cn:8888/10086/statquery/querystat?reportKey=60134&statKey=60134&statId=60134_dim_2&reportName=60134&app=10086&interval=hourly&indicator=ind_1&template=custom&groupDimensions=time%2Ccon_1_id%2Ccon_2_id%2Cres_id%2Cwa_res_name" . QuerryTime . "&needOriginDimValue=false&indDataFilters=%5B%5D&viewType=0&chartType=0&withoutTime=false&noLoading=false&dataFilters=%5B%7B%22field%22%3A%22con_1_id%22%2C%22operator%22%3A%22str_eq_ignorecase%22%2C%22value%22%3A%22" . con1id . "%22%7D%2C%7B%22field%22%3A%22con_2_id%22%2C%22operator%22%3A%22str_eq_ignorecase%22%2C%22value%22%3A%22" . con2id . "%22%7D%2C%7B%22field%22%3A%22res_id%22%2C%22operator%22%3A%22str_in_ignorecase%22%2C%22value%22%3A%22" . AppID . "%22%7D%5D&pageSize=100&pageNumber=1&withTotalRow=true"
			WebRequest.Open("GET", URL, true)
			WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
			WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
			WebRequest.SetRequestHeader("Cookie",Cookie)
			WebRequest.Option(6) := False
			WebRequest.Send()
			WebRequest.WaitForResponse(-1)
			;MsgBox % WebRequest.GetAllResponseHeaders
			RespBody := WebRequest.ResponseText
			;MsgBox % RespBody
			AppData := parseJson(RespBody)
			AppDLAll := AppData.data.summary[1].ind_6
			;MsgBox, % AppDLAll
			;MsgBox % QIndex "`n" AppID "`n" RecomID "`n" AppName "`n" RecomZone "`n" MateID "`n" MateType "`n" RecomVersion "`n" StartTime "`n" EndTime
			LV_Add( ,,QIndex,AppID,RecomID,AppName,AppDLAll,RecomZone,MateID,MateType,RecomVersion,StartTime,EndTime)
		}
	}
	LV_ModifyCol()
	LV_ModifyCol(5, 120)
	LV_ModifyCol(6, 60)
	return
}


HttpRequestWC(ByRef InOutURL, ByRef InOutData="", ByRef InOutCookie="")
{
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	if InOutData =
		WebRequest.Open("GET", InOutURL, true)
	else
		WebRequest.Open("POST", InOutURL, true)
	WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/601.4.4 (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4")
	WebRequest.SetRequestHeader("Cookie",InOutCookie)
	WebRequest.Option(6) := False
	if InOutData <>
		WebRequest.SetRequestHeader("Content-Length", StrLen(InOutData))
	if InOutData =
		WebRequest.Send()
	else
		WebRequest.Send(InOutData)
	WebRequest.WaitForResponse(-1)
	NextURL := WebRequest.GetResponseHeader("Location")
	Headers := WebRequest.Status()
	InOutData := WebRequest.ResponseText
	Resp := WebRequest.GetAllResponseHeaders
	p := 1
	while (p := RegExMatch(Resp,"(?<=Set-Cookie: ).*?;",Cookies, p+StrLen(Cookies)))
		NextCookie .= Cookies . " "
	if NextCookie <>
		InOutCookie := NextCookie
	if NextURL <>
		InOutURL := NextURL
	return Headers
}



Collection:
	Gui, Submit, NoHide

return

SubMode:
	Gui, Submit, NoHide
	
return

Query:
	Gui, Submit, NoHide

	GuiControl, Enable, 查ID
return

GuiContextMenu:
	if A_GuiControl <> AppRecomm
		return
	Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
return

ContextCheckCon:
	Gui, Submit, NoHide

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

AppRecomm:
	if A_GuiEvent = K  ; 脚本还可以检查许多其他的可能值.
		;if A_EventInfo = 32
		MsgBox % "检测到" Chr(A_EventInfo)
			;gosub, ContextCheckCon
return

Search:
	Gui, Submit, NoHide
	GuiControl, Disable, 搜索

	GuiControl, Enable, 搜索
return

Save:
return


GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, BoxIn, % "W" . (A_GuiWidth - 28)
	GuiControl, Move, BoxOut, % "W" . (A_GuiWidth - 28) . " H" . (A_GuiHeight - 185)
	GuiControl, Move, AppRecomm, % "W" . (A_GuiWidth - 58) . " H" . (A_GuiHeight - 215)
	GuiControl, Move, Mytabs, % "W" . (A_GuiWidth - 10) . " H" . (A_GuiHeight - 10)
	GuiControl, Move, WB, % "W" . (A_GuiWidth - 28) . " H" . (A_GuiHeight - 80)
return


GuiClose:
	Gui, Destroy
	ExitApp

ContextTest:
	doc := wb.doc
	MyCookie := doc.cookie
return


UriEncode(Uri)
{
    oSC := ComObjCreate("ScriptControl")
    oSC.Language := "JScript"
    Script := "var Encoded = encodeURIComponent(""" . Uri . """)"
    oSC.ExecuteStatement(Script)
    Return, oSC.Eval("Encoded")
}

UriDecode(Uri)
{
    oSC := ComObjCreate("ScriptControl")
    oSC.Language := "JScript"
    Script := "var Decoded = decodeURIComponent(""" . Uri . """)"
    oSC.ExecuteStatement(Script)
    Return, oSC.Eval("Decoded")
}