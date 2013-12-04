#cs
Способ сопоставления образца с заголовком окна при операции поиска. 
Стандартное значение 1:
1 = сопоставление с началом
2 = сопоставление с произвольным фрагментом
3 = точное сопоставление

AUTOITSETOPTION("WinTitleMatchMode", 2)
#ce
Opt("MustDeclareVars", 1)
Opt("WinTitleMatchMode", 3)
Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 1)
Opt("MouseCoordMode", 0) ;0 = относительные координаты активного окна
Opt("PixelCoordMode", 0) ;0 = относительные координаты активного окна
;Задаем глобальные переменные
Global $state = 0
#csСостояние программы
0-выкл.
1-неопред.
2-ничего не происходит
3-ждем рыбу
4-ловим рыбу
6-теряем здоровье
#ce
Global $bColor = -1 ;Цвет левой части полоски(Голубой)
Global $hpColor = -1 ;
Global $fwColor = -1 ;
;Global $rColor = -1 ;Цвет правой части полоски(Красный)
Global $linePos[2] = [-1, -1] ;массив с х и у точки на полоске рыбалки
Global $fwPos[2] = [-1, -1] ;массив с х и у 
Global $hpFullPos[2] = [-1, -1] ;массив с х и у точки на конце полоски hp
Global $hpHalfPos[2] = [-1, -1] ;массив с х и у точки на (середине) полоски hp
Global $hpNonePos[2] = [-1, -1] ;массив с х и у точки на начале полоски hp
Global $toolTipPos[2] = [0, 0]
;Global $ready[2] = [0,0]
;Global $delayAfterSkill = 600
HotKeySet("^g", "start")
HotKeySet("^s", "stop")
HotKeySet("^d", "setLinePos")
HotKeySet("^a", "setHPPos")
HotKeySet("^t", "setToolTipPos")
HotKeySet("^x", "temp")
HotKeySet("^h", "help")
HotKeySet("^q", "quit")

ConsoleWrite("start")
global $startTime = TimerInit()
;;;;  Бесконечный цикл, чтобы программа не завершалась пока ее не завершить ;;;;
;$g_szVersion = "My Script 1.1"
;If WinExists($g_szVersion) Then WinKill ($g_szVersion) ; Он уже запущен
;AutoItWinSetTitle($g_szVersion)
While 1
	Sleep(1000) ;Не знаю, имеет ли какое-то значение аргумент в данном случае
WEnd

Func chkState() 
	Switch $state
	Case 0
		showMsg("Скрипт остановлен")
	Case 1
		showMsg("Состояние неизвестно")
		if chkLossHp() then setState(5)
		elseif chkFishing() then setState(4)
		elseif chkFishWaiting() then setState(3)
		else setState(2)
	
	Case 2
		showMsg("Курим бамбук")
	Case 3
		showMsg("Ждем рыбу")
	Case 4
		showMsg("Ловим рыбу рыбу")
	Case 5
		showMsg("Спасаем свою шкуру")
	EndSwitch
endFunc

func chkLossHp()
	return PixelGetColor($hpPos[0], $hpPos[1]) == $hpColor
EndFunc
func chkFishing()
	return PixelGetColor($linePos[0], $linePos[1]) == $bColor
EndFunc
func chkFishWaiting()
	return PixelGetColor($fwPos[0], $fwPos[1]) == $fwColor
EndFunc
Func start()
	
	;TrayTip("La2 FishBot", "Start", 0)
	showMsg("Скрипт запущен", "Состояние:")
	$state = 1
	;$linePos[0] = 1087
	;$linePos[1] = 360
	;проверка на значения переменных
	If ($linePos[0] == -1) Then showMsg("Координаты не заданы","Ошибка:")
	While getState()
		Switch $state
 		Case 1
 			;If (PixelGetColor($linePos[0], $linePos[1]) == $bColor) Then $state = 4
			;ElseIf (0) Then Sleep(1);hp check, switch with 1 place
			;Else $state = 2
			;EndIf
			setState(2)
			showMsg("Стоим без дела","Состояние:")
		Case 2
			Sleep(1000)
			Send("{F1}")
			setState(3)
			showMsg("Закидываем удочку","Состояние:")
		Case 3
			If (PixelGetColor($linePos[0], $linePos[1]) == $bColor) Then setState(4)
			showMsg("Ждем рыбу","Состояние:")
		Case 4
			showMsg("Ловим рыбу","Состояние:")
			ConsoleWrite("c4")
			If (PixelGetColor($linePos[0], $linePos[1]) <> $bColor) Then setState(2)
			local $curPos = $linePos ;+стандартное значение.
			;задаем текущую позицию конца полоски
			while $bColor == PixelGetColor($curPos[0], $curPos[1])
				$curPos[0] += 1
			WEnd
			ConsoleWrite(" позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
			;dim $
			;цикл
			dim $lineGrownTime = TimerInit(), $reelingUsedTime = 0, $pumpingUsedTime = 0
			dim $sleepTime = 100
			ConsoleWrite("$lineGrownTime = " & timerDiff($startTime) & " | $reelingUsedTime = " & $reelingUsedTime & " | $pumpingUsedTime = " & $pumpingUsedTime & @LF)
			sleep(1000)
			ConsoleWrite(@LF & "----------------=Новый 'раунд'=------------------" & @LF)
			Do
				;если полоска сдвинулась вправо - запоминаем время.
				ConsoleWrite("текущ. позиция: " & $curPos[0] & @LF)
				if(PixelGetColor($curPos[0], $curPos[1]) == $bColor) then 
					$lineGrownTime = TimerInit()
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
					while PixelGetColor($curPos[0]-1, $curPos[1]) <> $bColor and $curPos[0]>$linePos[0]
						$curPos[0] -= 1
					WEnd
					ConsoleWrite(" позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
					$sleepTime = 100
				endIf	
				;если за последнюю секунду линия увеличивалась, то юзаем скилл reeling
				if TimerDiff($lineGrownTime) < 1000 and TimerDiff($reelingUsedTime)>2000 then 
					send("{F3}")
					ConsoleWrite(TimerDiff($lineGrownTime) & " : TimerDiff($lineGrownTime)" & @LF)
					$reelingUsedTime = TimerInit()
					ConsoleWrite(timerDiff($startTime) & " : юзаем скилл reeling" & @LF)
					$sleepTime = 20
				endIf
				;если за последнюю секунду(чуть больше на всякий случай) линия не увеличивалась, то юзаем скилл pumping
				if TimerDiff($lineGrownTime) > 1200 and TimerDiff($pumpingUsedTime)>2000 then 
					ConsoleWrite("линия не двигалась - " & timerDiff($lineGrownTime) &  @LF)
					send("{F2}")
					$pumpingUsedTime = TimerInit()
					ConsoleWrite(timerDiff($startTime) & " : юзаем скилл pumping" & @LF)
					$sleepTime = 20
					;ConsoleWrite("delay=" & $i*50 & " позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
					;ConsoleWrite(" позиция: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
				endIf	
				sleep($sleepTime)
			Until PixelGetColor($linePos[0], $linePos[1]) <> $bColor
			ConsoleWrite("lol")
		EndSwitch
		Sleep(500)
	WEnd
EndFunc

func temp()
	ConsoleWrite(" позиция: " & $linePos[0] & "  color: " & hex(PixelGetColor($linePos[0], $linePos[1])) & @LF)
EndFunc

func logVars($vars)
	for $var in $vars
		ConsoleWrite($var & " = " & eval($var) & " | ")
	Next
EndFunc

Func getState()
	#cs
	Select
	Case (PixelGetColor($linePos[0], $linePos[1]) == $bColor)
		$state = 4
	Case ($state == 1)
		$state = 2
	Case 
	EndSelect
	#ce
	Return $state
EndFunc

Func setState($val)
	If ($state <> 0) then $state = $val
EndFunc

Func setLinePos() 
	$linePos = MouseGetPos()
	$bColor = PixelGetColor($linePos[0], $linePos[1]) ;Hex($bColor, 6)
	ConsoleWrite(" b color: " & hex($bColor) & @LF)
	Local $curPos = $linePos, $curColor = $bColor
	While $curColor == $bColor
		$curPos[0] -= 1
		$curColor = PixelGetColor($curPos[0], $curPos[1])
	WEnd
	$linePos[0] = $curPos[0]+1 ;Записываем сюда Х начала полоски
	;Local $curPos = $linePos, $curColor = $bColor
	;While $curColor == $bColor
	;	$curPos[0] += 1
	;	$curColor = PixelGetColor($curPos[0], $curPos[1])
	;WEnd
	;$rColor = $curColor
	showMsg("Координаты полоски рыбалки заданы: " & @LF _
			& $linePos[0] & ":" & $linePos[1] & @LF _
			& "Цвета: " & $bColor & @LF _ 
			& "Координаты конца: " & $curPos[0] & ":" & $curPos[1])
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
Func setHPPos()
	
EndFunc

Func showMsg($text, $title='Info:') 
	ToolTip($text, $toolTipPos[0], $toolTipPos[1], $title)
EndFunc

Func setToolTipPos()
	$toolTipPos = MouseGetPos()
	showMsg("Координаты Всплывающего окна изменены: " & @LF _
			& $toolTipPos[0] & ":" & $toolTipPos[1])
EndFunc