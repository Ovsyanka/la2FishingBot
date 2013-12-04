#cs
������ ������������� ������� � ���������� ���� ��� �������� ������. 
����������� �������� 1:
1 = ������������� � �������
2 = ������������� � ������������ ����������
3 = ������ �������������

AUTOITSETOPTION("WinTitleMatchMode", 2)
#ce
Opt("MustDeclareVars", 1)
Opt("WinTitleMatchMode", 3)
Opt("TrayAutoPause", 0)
Opt("TrayIconDebug", 1)
Opt("MouseCoordMode", 0) ;0 = ������������� ���������� ��������� ����
Opt("PixelCoordMode", 0) ;0 = ������������� ���������� ��������� ����
;������ ���������� ����������
Global $state = 0
#cs��������� ���������
0-����.
1-�������.
2-������ �� ����������
3-���� ����
4-����� ����
6-������ ��������
#ce
Global $bColor = -1 ;���� ����� ����� �������(�������)
Global $hpColor = -1 ;
Global $fwColor = -1 ;
;Global $rColor = -1 ;���� ������ ����� �������(�������)
Global $linePos[2] = [-1, -1] ;������ � � � � ����� �� ������� �������
Global $fwPos[2] = [-1, -1] ;������ � � � � 
Global $hpFullPos[2] = [-1, -1] ;������ � � � � ����� �� ����� ������� hp
Global $hpHalfPos[2] = [-1, -1] ;������ � � � � ����� �� (��������) ������� hp
Global $hpNonePos[2] = [-1, -1] ;������ � � � � ����� �� ������ ������� hp
Global $toolTipPos[2] = [0, 0]
;Global $ready[2] = [0,0]
;Global $delayAfterSkill = 600
HotKeySet("^g", "start")
HotKeySet("^s", "stop")
HotKeySet("^d", "setLinePos")
HotKeySet("^a", "setHpFullPos")
HotKeySet("^z", "setHpHalfPos")
HotKeySet("^f", "setfwPos")
HotKeySet("^t", "setToolTipPos")
HotKeySet("^x", "chkLossHp")
HotKeySet("^h", "help")
HotKeySet("^q", "quit")
;HotKeySet("^i", "savePosToIni")

ConsoleWrite("start")
global $startTime = TimerInit()
;;;;  ����������� ����, ����� ��������� �� ����������� ���� �� �� ��������� ;;;;
;$g_szVersion = "My Script 1.1"
;If WinExists($g_szVersion) Then WinKill ($g_szVersion) ; �� ��� �������
;AutoItWinSetTitle($g_szVersion)
While 1
	Sleep(1000) ;�� ����, ����� �� �����-�� �������� �������� � ������ ������
WEnd
;func savePosToIni($hpPos = $hpFullPos)
;	$sData = "Key1=Value1" & @LF & "Key2=Value2" & @LF & "Key3=Value3"
;	IniWriteSection("conf.ini", "Config", $sData)
;EndFunc
func chkLossHp($hpPos = $hpFullPos)
	;local $t
	;ConsoleWrite("x: " & $hpFullPos[0] & " y: " & $hpFullPos[1] & " hpcolor: " & $hpColor & " cur color: " & PixelGetColor($hpFullPos[0], $hpFullPos[1]) & @LF)
	;$t = not (PixelGetColor($hpFullPos[0], $hpFullPos[1]) == $hpColor)
	;ConsoleWrite("$t = " & $t & @LF)
	return not (PixelGetColor($hpFullPos[0], $hpFullPos[1]) == $hpColor)
EndFunc
func chkFishing()
	return PixelGetColor($linePos[0], $linePos[1]) == $bColor
EndFunc
func chkFishWaiting()
	local $t
	$t = PixelGetColor($fwPos[0], $fwPos[1]) == $fwColor
	ConsoleWrite("chkFishWaiting: " & $t)
	return $t
EndFunc

func selfProtection()
	send("{F9}") ;����� ������
	do
		if chkLossHp($hpHalfPos) then
			send("{F6}") ;�������� ����
			sleep(200)
			send("{F11}") ;�������
		endif
		if chkLossHp() then
			send("{F5}") ;�������� ����
			sleep(200)
			send("{F10}") ;��������
		EndIf
		sleep(1000)
		;send("{F6}") ;�������� ����
		;sleep(200)
		;send("{F11}") ;�������
	until not chkLossHp()
	send("{F7}") ;����� ������
	sleep(200)
	send("{F8}") ;����� ��������
EndFunc

Func start()
	;TrayTip("La2 FishBot", "Start", 0)
	showMsg("������ �������", "���������:")
	$state = 1
	;$linePos[0] = 1087
	;$linePos[1] = 360
	;�������� �� �������� ����������
	;If ($linePos[0] == -1) Then showMsg("���������� �� ������","������:")
	While getState()
		Switch $state
 		Case 1
 			showMsg("��������� ����������")
			ConsoleWrite("chkLossHp: " & chkLossHp())
			if chkLossHp() then
				setState(5) 
			elseif chkFishing() then
				setState(4) 
			elseif chkFishWaiting() then
				setState(3)
			else
				setState(2)
			EndIf
		Case 2
			showMsg("����� ������")
			if chkFishWaiting() then 
				setState(3)
			else
				Send("{F1}")
			endif
		Case 3
			showMsg("���� ����")
			if not chkFishWaiting() then 
				setState(1)
			elseif chkFishing() then 
				setState(4)
			endif
		Case 4
			showMsg("����� ����")
			local $curPos = $linePos ;+����������� ��������.
			;������ ������� ������� ����� �������
			while $bColor == PixelGetColor($curPos[0], $curPos[1])
				$curPos[0] += 1
			WEnd
			ConsoleWrite(" �������: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
			;����
			dim $lineGrownTime = TimerInit(), $reelingUsedTime = 0, $pumpingUsedTime = 0
			dim $sleepTime = 100
			;ConsoleWrite("$lineGrownTime = " & timerDiff($startTime) & " | $reelingUsedTime = " & $reelingUsedTime & " | $pumpingUsedTime = " & $pumpingUsedTime & @LF)
			sleep(1000)
			ConsoleWrite(@LF & "----------------=����� '�����'=------------------" & @LF)
			while chkFishing()
				;���� ������� ���������� ������ - ���������� �����.
				ConsoleWrite("�����. �������: " & $curPos[0] & @LF)
				if(PixelGetColor($curPos[0], $curPos[1]) == $bColor) then 
					$lineGrownTime = TimerInit()
					ConsoleWrite(round(timerDiff($startTime)) & " : ������� ���������� ������ - ���������� �����" & @LF)
					while $bColor == PixelGetColor($curPos[0], $curPos[1])
						$curPos[0] += 1
					WEnd
					ConsoleWrite(" �������: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
					$sleepTime = 100
				EndIf
				;���� ������� ���������� ����� - �������� ����������.
				if PixelGetColor($curPos[0]-1, $curPos[1]) <> $bColor then
					ConsoleWrite(round(timerDiff($startTime)) & " : ������� ���������� ����� - �������� ����������" & @LF)
					while PixelGetColor($curPos[0]-1, $curPos[1]) <> $bColor and $curPos[0]>$linePos[0]
						$curPos[0] -= 1
					WEnd
					ConsoleWrite(" �������: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
					$sleepTime = 100
				endIf	
				;���� �� ��������� ������� ����� �������������, �� ����� ����� reeling
				if TimerDiff($lineGrownTime) < 1000 and TimerDiff($reelingUsedTime)>2000 then 
					send("{F3}")
					ConsoleWrite(TimerDiff($lineGrownTime) & " : TimerDiff($lineGrownTime)" & @LF)
					$reelingUsedTime = TimerInit()
					ConsoleWrite(timerDiff($startTime) & " : ����� ����� reeling" & @LF)
					$sleepTime = 20
				endIf
				;���� �� ��������� �������(���� ������ �� ������ ������) ����� �� �������������, �� ����� ����� pumping
				if TimerDiff($lineGrownTime) > 1200 and TimerDiff($pumpingUsedTime)>2000 then 
					ConsoleWrite("����� �� ��������� - " & timerDiff($lineGrownTime) &  @LF)
					send("{F2}")
					$pumpingUsedTime = TimerInit()
					ConsoleWrite(timerDiff($startTime) & " : ����� ����� pumping" & @LF)
					$sleepTime = 20
					;ConsoleWrite("delay=" & $i*50 & " �������: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
					;ConsoleWrite(" �������: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
				endIf	
				sleep($sleepTime)
			wend
			sleep(2000)
			setState(1)
		case 5
			showMsg("������� ���� �����")
			selfProtection()
			setState(1)
		EndSwitch
		Sleep(500)
	WEnd
EndFunc

func temp()
	ConsoleWrite(" �������: " & $linePos[0] & "  color: " & hex(PixelGetColor($linePos[0], $linePos[1])) & @LF)
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
	$linePos[0] = $curPos[0]+1 ;���������� ���� � ������ �������
	showMsg("���������� ������� ������� ������: " & @LF _
			& $linePos[0] & ":" & $linePos[1] & @LF _
			& "�����: " & $bColor & @LF _ 
			& "���������� �����: " & $curPos[0] & ":" & $curPos[1])
EndFunc

Func quit()
	Exit 0
EndFunc

Func stop()
	$state = 0
	showMsg("������ ����������")
EndFunc
Func help()

EndFunc
Func setHpFullPos()
	$hpFullPos = MouseGetPos()
	$hpHalfPos[1] = $hpFullPos[1]
	$hpColor = PixelGetColor($hpFullPos[0], $hpFullPos[1]) ;Hex($bColor, 6)
	;ConsoleWrite(" hp color: " & hex($bColor) & @LF)
	Local $curPos = $hpFullPos, $curColor = $hpColor
	While $curColor == $hpColor
		$curPos[0] += 1
		$curColor = PixelGetColor($curPos[0], $curPos[1])
		ConsoleWrite("x: " & $curPos[0] & " y: " & $curPos[1] & " color: " & $curColor & @LF)
	WEnd
	$hpFullPos[0] = $curPos[0]-1 ;���������� ���� �
	showMsg("���������� ������")
EndFunc
Func setHpHalfPos()
	$hpHalfPos = MouseGetPos()
EndFunc

Func setfwPos()
	$fwPos = MouseGetPos()
	$fwColor = PixelGetColor($fwPos[0], $fwPos[1])
EndFunc

Func showMsg($text, $title='Info:') 
	ToolTip($text, $toolTipPos[0], $toolTipPos[1], $title)
EndFunc

Func setToolTipPos()
	$toolTipPos = MouseGetPos()
	showMsg("���������� ������������ ���� ��������: " & @LF _
			& $toolTipPos[0] & ":" & $toolTipPos[1])
EndFunc