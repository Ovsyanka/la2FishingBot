$g_szVersion = "Fishing Bot La2"
If WinExists($g_szVersion) Then WinKill ($g_szVersion) ; Он уже запущен
AutoItWinSetTitle($g_szVersion)

Opt("MustDeclareVars", 1)
Opt("WinTitleMatchMode", 3)
Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 1)
Opt("MouseCoordMode", 0) ;0 = относительные координаты активного окна
Opt("PixelCoordMode", 0) ;0 = относительные координаты активного окна

HotKeySet("^a", "setHpFullPos")
HotKeySet("^f", "setFwPos");точка заголовка окна рыбалки
HotKeySet("^d", "setLinePos")
HotKeySet("^g", "start")
HotKeySet("^x", "stop")
HotKeySet("^t", "setToolTipPos")
HotKeySet("^z", "temp")
HotKeySet("^h", "help")
HotKeySet("^q", "quit")
HotKeySet("^i", "saveToIni")
HotKeySet("^r", "readFromIni")

;Задаем глобальные переменные
Global $state = 0
#csСостояние программы
0-остановлена.
1-останавливается.
2-запущена.
#ce
Global $action = 0
#csТекущее действие
1-неопред.
2-ничего не происходит
3-ждем рыбу
4-ловим рыбу
5-ждем моба после ловли
6-деремся с мобом
#ce
Global $bColor = -1 ;Цвет левой части полоски(Голубой)
Global $hpColor = -1 ;
Global $fwColor = -1 ;
Global $linePos[2] = [-1, -1] ;массив с х и у точки на полоске рыбалки
Global $fwPos[2] = [-1, -1] ;массив с х и у 
Global $hpFullPos[2] = [-1, -1] ;массив с х и у точки на конце полоски hp
Global $toolTipPos[2] = [0, 0]
global $startTime = TimerInit()

While 1
	;Dim $color = PixelGetColor(100,100)
	;Logg(aproxEqual(100,100,$color))
	Sleep(1000) ;Не знаю, имеет ли какое-то значение аргумент в данном случае
WEnd

Func start()
	;showMsg("Скрипт запущен", "Состояние:")
	$state = 2
	;проверка на значения переменных
	;readFromIni()
	;chkCoords()
	;If ($linePos[0] == -1) Then showMsg("Координаты не заданы","Ошибка:")
	;Пока скрипт запущен
	While $state > 1
		DetectAction()
		StartNextAction()
		sleep(2000) ;tmp
	WEnd
EndFunc

;Определяем какое сейчас состояние, записываем результат в $action
Func DetectAction()
	ConsoleWrite(@LF & "Start DetectAction: " & $action)
	If $action == 0 Then
		;showMsg("Состояние неизвестно")
		if chkLossHp() then
			$action = 6
		elseif chkFishing() then
			$action = 4
		elseif chkFishWindow() then
			$action = 3
		else
			$action = 2
		EndIf
	endIf
	Switch $action
	Case 2
		;showMsg("Курим бамбук")
		if chkFishWindow() then $action = 3
	Case 3
		showMsg("Ждем рыбу")
		if not chkFishWindow() then 
			$action = 2
		elseif chkFishing() then 
			$action = 4
		endif
	Case 4
		if not chkFishWindow() then $action = 5 ;waiting mob
	case 5
		if chkLossHp() then 
			$action = 6
		Else
			$action = 2
		EndIf
	case 6
		if Not chkLossHp() then $action = 5
	EndSwitch
	ConsoleWrite(@LF & "End DetectAction: " & $action)
EndFunc

Func StartNextAction()
	ConsoleWrite(@LF & "StartNextAction (" & $action & ")")
	switch $action
	Case 0
	Case 2
		startFishing() ;забрасываем удочку
	Case 3
	Case 4
		fishing() ;ловим рыбу
	Case 5
		waitingMob()
	Case 6
		selfProtection()
	EndSwitch
EndFunc

func chkLossHp($hpPos = $hpFullPos)
	;ConsoleWrite("  Start chkLossHp: " & not (PixelGetColor($hpFullPos[0], $hpFullPos[1]) == $hpColor))
	;return not (PixelGetColor($hpFullPos[0], $hpFullPos[1]) == $hpColor)
	Dim $msg[8] = ["Start chkLossHp: ", $hpFullPos[0], ":", $hpFullPos[1], hex($hpColor), "-", hex(PixelGetColor($hpFullPos[0], $hpFullPos[1])), Not aproxEqual($hpFullPos[0], $hpFullPos[1], $hpColor)]
	Logg($msg,2)
	Return Not aproxEqual($hpFullPos[0], $hpFullPos[1], $hpColor)
EndFunc

func chkFishing()
	if $action == 4 and chkFishWindow() then 
		;ConsoleWrite("  chkFishing1: true")
		;If aproxEqual(PixelGetColor($linePos[0], $linePos[1]), $bColor) Then $bColor = PixelGetColor($linePos[0], $linePos[1])
		return true 
	else
		;If aproxEqual(PixelGetColor($linePos[0], $linePos[1]), $bColor) Then $bColor = PixelGetColor($linePos[0], $linePos[1])
		ConsoleWrite("  chkFishing2: " & Hex(PixelGetColor($linePos[0], $linePos[1])) & " == " & Hex($bColor))
		;return PixelGetColor($linePos[0], $linePos[1]) == $bColor
		return aproxEqual($linePos[0], $linePos[1], $bColor)
	EndIf
EndFunc
	
func chkFishWindow()
	;local $t
	;$t = PixelGetColor($fwPos[0], $fwPos[1]) == $fwColor
	;ConsoleWrite("chkFishWindow: " & $t)
	;return $t
	Dim $msg[5] = ["chkFishWindow:", Hex(PixelGetColor($fwPos[0], $fwPos[1])), "-", Hex($fwColor), aproxEqual($fwPos[0], $fwPos[1], $fwColor)]
	Logg($msg)
	Return aproxEqual($fwPos[0], $fwPos[1], $fwColor)
EndFunc

Func startFishing()
	ConsoleWrite(@LF & "startFishing")
	Send("{F1}")
	Sleep(1000)
	If Not chkFishWindow() Then 
		Send("{F5}") ;удочка
		;туду Сделать выбор оодной з трех наживок.
		;Send("{F6}") ;наживка
		Send("{F1}")
	EndIf
	Sleep(1000)
	If Not chkFishWindow() Then 
		$state = 1
		;в лог - рыбалка не возможна, смените место.
	EndIf
EndFunc

Func fishing()
	Logg("Ловим рыбу - ",1)
	local $curPos = $linePos ;+стандартное значение.
	while aproxEqual($curPos[0], $curPos[1], $bColor)
		$curPos[0] += 1
	WEnd
	Dim $msg[4] = ["позиция:", $curPos[0], "color:", hex(PixelGetColor($curPos[0], $curPos[1]))]
	Logg($msg,2)
	;last grown time, reeling use time, pumping use time
	dim $lgt = 0, $rut = 0, $put = 0, $lst = TimerInit()
	dim $sleepTime = 100, $waitTime = 300
	
	While chkFishing()
		If IsShining($linePos[0], $linePos[1], $bColor) Then
			Sleep($sleepTime)
			$lst = TimerInit()
			;Local $k = aproxEqual($linePos[0], $linePos[1], $bColor)
			;If $k Then $bColor = PixelGetColor($k[0],$k[1])
			ContinueLoop
		endif
		
		if aproxEqual($curPos[0], $curPos[1], $bColor) then 
			;если увеличилось после юзания скила - не считается
			If timerDiff($put) < $waitTime Or timerDiff($rut) < $waitTime Then 
				$lst = TimerInit()
			Else
				
			EndIf
			$lgt = TimerInit()-1
			while aproxEqual($curPos[0], $curPos[1], $bColor)
				$curPos[0] += 1
			WEnd
			
			Dim $msg[7] = ["  полоска вправо -", "lst:", $lst, "lgt:",$lgt, "новая позиция:", $curPos[0]]
			Logg($msg, 3)
		EndIf
		
		if Not aproxEqual($curPos[0]-1, $curPos[1], $bColor) then
			while Not aproxEqual($curPos[0]-1, $curPos[1], $bColor) and $curPos[0]>$linePos[0]
				$curPos[0] -= 1
			WEnd
			$lst = TimerInit()
			Dim $msg[7] = ["  полоска влево -", "lst:", $lst, "lgt:",$lgt, "новая позиция:", $curPos[0]]
			Logg($msg, 3)
		endIf
		
		if $lst <= $lgt And TimerDiff($lgt) < 1000 and TimerDiff($rut)>2000 then 
			send("{F7}")
			send("{F3}")
			Dim $msg[7] = [" reeling -", "dlst:", TimerDiff($lst), "dlgt:", TimerDiff($lgt), "drut:", TimerDiff($rut)]
			$rut = TimerInit()
			Logg($msg, 3)
			;checking right use
			;Sleep(200) ;просто ждем. :) поохже, что не работает.
			;If PixelGetColor($curPos[0], $curPos[1]) == $bColor Then
			
		endIf

		if TimerDiff($lgt) > 1000 And TimerDiff($lst) > 1000 and TimerDiff($put)>2000 then 
			send("{F7}")
			send("{F2}")
			$put = TimerInit()
			;$lst = TimerInit() ;подумать
			Dim $msg[7] = [" pumping -", "lst:", $lst, "lgt:", $lgt, "put:", $put]
			Logg($msg, 3)
			;checking right use
			;Sleep(200) ;просто ждем. :) поохже, что не работает.
		endIf	
		
		sleep($sleepTime)
	wend
	
EndFunc

Func fishing1()
	;если полоска побелела, проверки не производить. реакции не нреагировать)
	;сл-но написать процедуру проверки на побеление полоски
	;при изменении координат полоски нужно изменить $curPos
	;test-----------
	;while chkFishing()
	;	sleep(1000)
	;	ConsoleWrite("Ловим рыбу - ")
	;wend
	;return
	;----------------
	;showMsg("Ловим рыбу")
	ConsoleWrite(@LF & "Ловим рыбу - ")
	local $curPos = $linePos ;+стандартное значение.
	;задаем текущую позицию конца полоски
	while $bColor == PixelGetColor($curPos[0], $curPos[1])
		$curPos[0] += 1
	WEnd
	ConsoleWrite(" позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
	;цикл
	dim $lineGrownTime = TimerInit(), $reelingUsedTime = 0, $pumpingUsedTime = 0
	Dim $lineStartTime = TimerInit()
	dim $sleepTime = 100
	;ConsoleWrite("$lineGrownTime = " & timerDiff($startTime) & " | $reelingUsedTime = " & $reelingUsedTime & " | $pumpingUsedTime = " & $pumpingUsedTime & @LF)
	;sleep(1000)
	ConsoleWrite(@LF & "----------------=Новый 'раунд'=------------------" & @LF)
	while chkFishing()
		ConsoleWrite("1")
		If IsShining($linePos[0], $linePos[1], $bColor) Then
			ConsoleWrite("2")
			Sleep(200)
			$lineStartTime = TimerInit()
			ContinueLoop
		endif
		;если полоска сдвинулась вправо - запоминаем время.
		;пока при ошибке будет считаться. что полоска увелиилась...
		;потом можно сделать проверку, чтобы полоска увеличилась два раза или по размеру увеличения
		ConsoleWrite("текущ. позиция: " & $curPos[0] & @LF)
		if(PixelGetColor($curPos[0], $curPos[1]) == $bColor) then 
			$lineGrownTime = TimerInit()
			$lineStartTime = $lineGrownTime
			ConsoleWrite(round(timerDiff($startTime)) & " : полоска сдвинулась вправо - запоминаем время" & @LF)
			while $bColor == PixelGetColor($curPos[0], $curPos[1])
				$curPos[0] += 1
			WEnd
			ConsoleWrite(" позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
			$sleepTime = 100
		EndIf
		;если полоска сдвинулась влево - изменяем координаты.
		if PixelGetColor($curPos[0]-1, $curPos[1]) <> $bColor then
			ConsoleWrite(round(timerDiff($startTime)) & " : полоска сдвинулась влево - изменяем координаты" & @LF)
			local $tmpPos = $curPos[0]
			while PixelGetColor($tmpPos-1, $curPos[1]) <> $bColor and $tmpPos>$linePos[0]
				$tmpPos -= 1
			WEnd
			;if ($tmpPos==$linePos[0]) Then
			;	ConsoleWrite(" результат не засчитан ")
			;	;$lineGrownTime = TimerInit() - 1050
			;Else
			$curPos[0] = $tmpPos
			$lineStartTime = TimerInit()
			;EndIf
			ConsoleWrite(" позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
			$sleepTime = 100
		endIf	
		;если за последнюю секунду линия увеличивалась, то юзаем скилл reeling
		if $lineStartTime <= $lineGrownTime And TimerDiff($lineGrownTime) < 1000 and TimerDiff($reelingUsedTime)>2000 then 
			send("{F3}")
			send("{F7}")
			ConsoleWrite($lineStartTime & "<" & $lineGrownTime & TimerDiff($lineGrownTime) & " : TimerDiff($lineGrownTime)" & @LF)
			$reelingUsedTime = TimerInit()
			ConsoleWrite(timerDiff($startTime) & " : юзаем скилл reeling" & @LF)
			;$sleepTime = 20
		endIf
		;если за последнюю секунду(чуть больше на всякий случай) линия не увеличивалась, то юзаем скилл pumping
		;непосредстенно перед использованием проверить еще раз на увеличение?
		if TimerDiff($lineGrownTime) > 1000 And TimerDiff($lineStartTime) < 1000 and TimerDiff($pumpingUsedTime)>2000 then 
			ConsoleWrite("линия не двигалась - " & timerDiff($lineGrownTime) &  @LF)
			send("{F2}")
			send("{F7}")
			$pumpingUsedTime = TimerInit()
			$lineStartTime = TimerInit()
			ConsoleWrite(timerDiff($startTime) & " : юзаем скилл pumping" & @LF)
			;$sleepTime = 20
			;ConsoleWrite("delay=" & $i*50 & " позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
			;ConsoleWrite(" позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
		endIf	
		sleep($sleepTime)
	wend
	;sleep(2000)
	;setState(1)
EndFunc

;проверяет совпадает ли цвет в точе линии с тем, что должен быть. (начачло линии)
Func IsShining($x, $y, $c)
	ConsoleWrite(" IsShining: " & (Not aproxEqual($x, $y, $c)) & " " & Hex($c) & "<=>" & hex(PixelGetColor($x, $y)) & "  ")
	Return Not aproxEqual($x, $y, $c);PixelGetColor($x, $y) <> $c
EndFunc

func waitingMob()
	;Сделать проверку на таргет. Если моб затаргетился - значит он есть.
	ConsoleWrite(@LF & "waitingMob")
	sleep(2000)
EndFunc
	
func selfProtection()
	do
		ConsoleWrite(" - selfProtection")
		sleep(2000)
	until not chkLossHp()
	return
	;----
	send("{F9}") ;Берем оружие
	do
		if chkLossHp($hpHalfPos) then
			send("{F6}") ;выбираем себя
			sleep(200)
			send("{F11}") ;Лечимся
		endif
		if chkLossHp() then
			send("{F5}") ;выбираем моба
			sleep(200)
			send("{F10}") ;Хреначим
		EndIf
		sleep(1000)
		;send("{F6}") ;выбираем себя
		;sleep(200)
		;send("{F11}") ;Лечимся
	until not chkLossHp()
	send("{F7}") ;Берем удочку
	sleep(200)
	send("{F8}") ;Берем приманку
EndFunc

Func setLinePos() 
	$linePos = MouseGetPos()
	$bColor = PixelGetColor($linePos[0], $linePos[1]) ;Hex($bColor, 6)
	;ConsoleWrite(" b color: " & hex($bColor) & @LF)
	Local $curPos = $linePos ;, $curColor = $bColor
	While aproxEqual($curPos[0], $curPos[1], $bColor);$curColor == $bColor
		$curPos[0] -= 1
		;$curColor = PixelGetColor($curPos[0], $curPos[1])
	WEnd
	Dim $msg[6] = ["line Coord: ", $linePos[0],"-", $curPos[0]+1, "b color: ", hex($bColor)]
	Logg($msg, 1)
	$linePos[0] = $curPos[0]+1 ;Записываем сюда Х начала полоски
	
	showMsg("Координаты полоски рыбалки заданы") ;& @LF _
	;		& $linePos[0] & ":" & $linePos[1] & @LF _
	;		& "Цвета: " & $bColor & @LF _ 
	;		& "Координаты конца: " & $curPos[0] & ":" & $curPos[1])
EndFunc

Func setHpFullPos()
	$hpFullPos = MouseGetPos()
	$hpColor = PixelGetColor($hpFullPos[0], $hpFullPos[1]) ;Hex($bColor, 6)
	;ConsoleWrite(" hp color: " & hex($bColor) & @LF)
	Local $curPos = $hpFullPos, $curColor = $hpColor
	While $curColor == $hpColor
		$curPos[0] += 1
		$curColor = PixelGetColor($curPos[0], $curPos[1])
		;ConsoleWrite("x: " & $curPos[0] & " y: " & $curPos[1] & " color: " & $curColor & @LF)
	WEnd
	$hpFullPos[0] = $curPos[0]-1 ;Записываем сюда Х
	Logg("Helth set: " & $hpFullPos[0] & ":" & $hpFullPos[1] & " " & Hex($hpColor))
	showMsg("Координаты здоровья заданы")
EndFunc

Func setFwPos()
	$fwPos = MouseGetPos()
	$fwColor = PixelGetColor($fwPos[0], $fwPos[1]) ;Hex($bColor, 6)
	ConsoleWrite(" fw color: " & hex($fwColor) & $fwPos[0] & ":" & $fwPos[1] & @LF)
	showMsg("Координаты окна рыбалки заданы")
EndFunc

Func setToolTipPos()
	$toolTipPos = MouseGetPos()
	showMsg("Координаты Всплывающего окна изменены: " & @LF _
			& $toolTipPos[0] & ":" & $toolTipPos[1])
EndFunc

Func showMsg($text, $title='Info:') 
	;ToolTip($text, $toolTipPos[0], $toolTipPos[1], $title)
	TrayTip($title, $text, 3)
 EndFunc
 
func aproxEqual($x, $y, $c, $retCoords = False)
	Local $r = PixelSearch ($x, $y, $x, $y, $c, 7)
	If @error Then 
		Return false 
	Else 
		If ($retCoords) Then 
			Return $r 
		Else 
			Return True 
		EndIf
	endIf
EndFunc

#cs
func aproxEqual_my($first, $second)
	local $t1, $t2
	$first = hex($first,6)
	$second = hex($second,6)
	for $i = 1 to 5 step 2
		$t1 = dec(StringMid($first, $i, 2))
		$t2 = dec(StringMid($second, $i, 2))
		if abs($t1 - $t2) >= 7 then return 0
	next 
	
	;if (StringMid($first, 1, 1) == StringMid($second, 1, 1) and StringMid($first, 3, 1) == StringMid($second, 3, 1) and StringMid($first, 5, 1) == StringMid($second, 5, 1)) then return 1
	return 1
EndFunc
#ce
Func logg($txt, $lf = 0) 
	Local $strings[1]
	If VarGetType($txt) <> "Array" Then 
		$strings[0] = $txt 
	Else 
		$strings = $txt
	EndIf
	Local $str = ""
	If $lf == 1 Or $lf == 3 Then $str &= @LF
	For $s In $strings
		$str &= $s & " "
	Next
	If $lf == 2 Or $lf == 3 Then $str &= @LF
	ConsoleWrite($str)
EndFunc

Func quit()
	Exit 0
EndFunc

Func stop()
	$state = 0
	showMsg("Скрипт остановлен")
EndFunc

Func help()

EndFunc

func temp()
	aproxEqual(300, 300, $fwColor)
EndFunc

func saveToIni()
	local $sData = "linePos0="& $linePos[0] & @LF & _
				"linePos1="& $linePos[1] & @LF & _
				"bColor="& $bColor & @LF & _
				"fwPos0="& $fwPos[0] & @LF & _
				"fwPos1="& $fwPos[1] & @LF & _
				"fwColor="& $fwColor & @LF & _
				"hpFullPos0="& $hpFullPos[0] & @LF & _
				"hpFullPos1="& $hpFullPos[1] & @LF & _
				"hpColor="& $hpColor & @LF
	IniWriteSection("conf.ini", "config", $sData)
EndFunc

func readFromIni()
	ConsoleWrite("lolo")
	local $var = IniReadSection("conf.ini", "config")
	If @error Then 
		MsgBox(4096, "", "Error occured, probably no INI file.")
	Else
		For $i = 1 To $var[0][0]
			Assign($var[$i][0], $var[$i][1]) 
		Next
	EndIf	
EndFunc