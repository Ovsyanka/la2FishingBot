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
HotKeySet("^a", "setHPPos")
HotKeySet("^t", "setToolTipPos")
HotKeySet("^x", "temp")
HotKeySet("^h", "help")
HotKeySet("^q", "quit")

ConsoleWrite("start")
global $startTime = TimerInit()
;;;;  ����������� ����, ����� ��������� �� ����������� ���� �� �� ��������� ;;;;
;$g_szVersion = "My Script 1.1"
;If WinExists($g_szVersion) Then WinKill ($g_szVersion) ; �� ��� �������
;AutoItWinSetTitle($g_szVersion)
While 1
	Sleep(1000) ;�� ����, ����� �� �����-�� �������� �������� � ������ ������
WEnd

Func chkState() 
	Switch $state
	Case 0
		showMsg("������ ����������")
	Case 1
		showMsg("��������� ����������")
		if chkLossHp() then setState(5)
		elseif chkFishing() then setState(4)
		elseif chkFishWaiting() then setState(3)
		else setState(2)
	
	Case 2
		showMsg("����� ������")
	Case 3
		showMsg("���� ����")
	Case 4
		showMsg("����� ���� ����")
	Case 5
		showMsg("������� ���� �����")
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
	showMsg("������ �������", "���������:")
	$state = 1
	;$linePos[0] = 1087
	;$linePos[1] = 360
	;�������� �� �������� ����������
	If ($linePos[0] == -1) Then showMsg("���������� �� ������","������:")
	While getState()
		Switch $state
 		Case 1
 			;If (PixelGetColor($linePos[0], $linePos[1]) == $bColor) Then $state = 4
			;ElseIf (0) Then Sleep(1);hp check, switch with 1 place
			;Else $state = 2
			;EndIf
			setState(2)
			showMsg("����� ��� ����","���������:")
		Case 2
			Sleep(1000)
			Send("{F1}")
			setState(3)
			showMsg("���������� ������","���������:")
		Case 3
			If (PixelGetColor($linePos[0], $linePos[1]) == $bColor) Then setState(4)
			showMsg("���� ����","���������:")
		Case 4
			showMsg("����� ����","���������:")
			ConsoleWrite("c4")
			If (PixelGetColor($linePos[0], $linePos[1]) <> $bColor) Then setState(2)
			local $curPos = $linePos ;+����������� ��������.
			;������ ������� ������� ����� �������
			while $bColor == PixelGetColor($curPos[0], $curPos[1])
				$curPos[0] += 1
			WEnd
			ConsoleWrite(" �������: " & $curPos[0] & "  color: " & hex(PixelGetColor($curPos[0], $curPos[1])) & @LF)
			;dim $
			;����
			dim $lineGrownTime = TimerInit(), $reelingUsedTime = 0, $pumpingUsedTime = 0
			dim $sleepTime = 100
			ConsoleWrite("$lineGrownTime = " & timerDiff($startTime) & " | $reelingUsedTime = " & $reelingUsedTime & " | $pumpingUsedTime = " & $pumpingUsedTime & @LF)
			sleep(1000)
			ConsoleWrite(@LF & "----------------=����� '�����'=------------------" & @LF)
			Do
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
			Until PixelGetColor($linePos[0], $linePos[1]) <> $bColor
			ConsoleWrite("lol")
		EndSwitch
		Sleep(500)
	WEnd
EndFunc

func temp()
	ConsoleWrite(" �������: " & $linePos[0] & "  color: " & hex(PixelGetColor($linePos[0], $linePos[1])) & @LF)
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
	$linePos[0] = $curPos[0]+1 ;���������� ���� � ������ �������
	;Local $curPos = $linePos, $curColor = $bColor
	;While $curColor == $bColor
	;	$curPos[0] += 1
	;	$curColor = PixelGetColor($curPos[0], $curPos[1])
	;WEnd
	;$rColor = $curColor
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
Func setHPPos()
	
EndFunc

Func showMsg($text, $title='Info:') 
	ToolTip($text, $toolTipPos[0], $toolTipPos[1], $title)
EndFunc

Func setToolTipPos()
	$toolTipPos = MouseGetPos()
	showMsg("���������� ������������ ���� ��������: " & @LF _
			& $toolTipPos[0] & ":" & $toolTipPos[1])
EndFunc