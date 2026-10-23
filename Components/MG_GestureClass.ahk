;===============================================================================
;
;		MouseGestureL.ahk - Gesture Processing Core Class
;
;															Created by Pyonkichi
;===============================================================================
Goto("MG_GestureClassEnd")

class RecognitionSettings
{
	__New()
	{
		this._triggerPriority		:= 0
		this._wheelPriority			:= 0
		this._mainTriggers	 		:= MG_MainTriggers
		this._subTriggers		 	:= MG_SubTriggers
		this._triggerMap		 	:= MG_TriggerMap
		this._gestureMap		 	:= MG_GestureMap
		this._maxLength			 	:= MG_MaxLength
		this._b8DirMode			 	:= MG_8Dir
		this._alwaysHook		 	:= MG_AlwaysHook
		this._bActiveWndAsTarget	:= MG_ActiveAsTarget
		this._recognitionInterval 	:= MG_Interval
		this._bCancelDefBehavior 	:= MG_PrvntCtxtMenu
		this._distanceThreshold	 	:= MG_Threshold
		this._longDiagThreshold		:= MG_LongThreshold
		this._longThresholdX 		:= MG_LongThresholdX
		this._longThresholdY 		:= MG_LongThresholdY
		this._bFirstLongOnly	 	:= MG_FirstLongOnly
		this._timeoutDistance	 	:= MG_TimeoutThreshold
		this._timeout			 	:= MG_Timeout
		this._doubleClickTimeout 	:= MG_DGInterval
		this._autoReleaseCount	 	:= MG_TmReleaseTrigger
		this._defAngleThreshold	 	:= MG_ORangeDefault
		this._afterOrthogonal	 	:= MG_ORangeA
		this._afterDiagonal		 	:= MG_ORangeB
		this._bDisableMBDefault	 	:= MG_DisableDefMB
		this._bDisableX1Default	 	:= MG_DisableDefX1B
		this._bDisableX2Default	 	:= MG_DisableDefX2B
	}
}

class GestureClass
{
	__New(objHints, objTrail, objLog, objEdges)
	{
		this.hints	:= objHints
		this.trail	:= objTrail
		this.log	:= objLog
		this.edges	:= objEdges
		this.opt	:= RecognitionSettings()

		this._bEnabled				:= false			; MG_Enabled
		this._bActive				:= false			; MG_Active
		this._bAborted				:= false			; MG_Aborted
		this._bTimedOut				:= false			; MG_TimedOut
		this._bTimeoutEnabled		:= false			; MG_TimeoutEnabled
		this._timeLimit				:= 0				; MG_TimeLimit
		this._currentGesture		:= ""				; MG_Gesture
		this._currentTriggers		:= ""				; MG_CurTriggers
		this._triggerCount			:= 0				; MG_TriggerCount
		this._lastProcessTime		:= 0				; MG_LastTime
		this._waitNext				:= 0				; MG_WaitNext
		this._snapshot				:= ""				; MG_Snapshot
		this._nowX					:= 0				; MG_NowX
		this._nowY					:= 0				; MG_NowY
		this._prevX					:= 0				; MG_PreX
		this._prevY					:= 0				; MG_PreY
		this._prevLongX				:= 0				; plx (static local)
		this._prevLongY				:= 0				; ply (static local)
		this._nowDir				:= ""				; dir (static local)
		this._prevDir				:= ""				; prev_dir (static local)
		this._prevLongDir			:= ""				; prev_long (static local)
		this._angleThreshold		:= 0				; orange (static local)
		this._executedCount			:= 0				; MG_Executed
		this._autoReleaseCounts		:= Map()			; MG_UnpressCount
		this._triggerEnabled		:= Map()			; MG_TriggerEnabled
		this._tempDisabled			:= Map()			; btnDisabled (static local)
		this._hotIfFuncs			:= Map()
		this._btnDownFuncs			:= Map()
		this._btnUpFuncs			:= Map()
		this._90degrees				:= MG_GetAngleThreshold(90)

		; for Action Functions
		this._delayedState			:= 0				; MG_TimerMode
		this._delayedGesture		:= ""				; MG_TimerGesture

		this._repeatedState			:= 0				; MG_WhileState
		this._repeatedInterval		:= 0				; MG_WhileInterval
		this._repeatedGesture		:= ""				; MG_WhileGesture
		this._repeatedTrrigers		:= ""				; MG_WhileTrrigers

		this._holdDownStartTime		:= 0				; MG_HoldStart
		this._holdDownGesture		:= ""				; MG_HoldGesture
		this._holdDownTrrigers		:= ""				; MG_HoldTrrigers
		this._holdDownFinish		:= false			; MG_HoldState

		this._bypassGesture			:= ""				; MG_BypassGesture
		this._bypassTrigger			:= ""				; MG_BypassTrigger

		this._performDefBehavior	:= 0				; MG_PerformDef
		this._bDefBehaviorCanceled	:= false			; MG_CancelDef

		this._gestureCounter		:= Map()			; MG_Counter_...

		this._fnDisable := this.Disable.Bind(this)
		this._fnRecognition := this._Recognition.Bind(this)
		this._fnDelayedExecutionThread := this._DelayedExecutionThread.Bind(this)
		this._fnRepeatedExecutionThread := this._RepeatedExecutionThread.Bind(this)
		this._fnHoldDownExecutionThread := this._HoldDownExecutionThread.Bind(this)
	}

	Dispose()
	{
		SetTimer(this._fnDisable, 0)
		this._fnDisable := ""

		SetTimer(this._fnRecognition, 0)
		this._fnRecognition := ""

		SetTimer(this._fnDelayedExecutionThread, 0)
		this._fnDelayedExecutionThread := ""

		SetTimer(this._fnRepeatedExecutionThread, 0)
		this._fnRepeatedExecutionThread := ""

		SetTimer(this._fnHoldDownExecutionThread, 0)
		this._fnHoldDownExecutionThread := ""

		this.hints.Dispose()

		if (IsObject(this.edges)) {
			this.edges.Dispose()
		}
	}

	;--- Properties ---

	Enabled {
		get {
			return this._bEnabled
		}
	}

	Active {
		get {
			return this._bActive
		}
	}

	TriggerCount {
		get {
			return this._triggerCount
		}
	}

	CurrentGesture {
		get {
			return this._currentGesture
		}
	}

	NowX {
		get {
			return this._nowX
		}
	}

	NowY {
		get {
			return this._nowY
		}
	}

	PrevX {
		get {
			return this._prevX
		}
	}

	PrevY {
		get {
			return this._prevY
		}
	}

	;--- Functions ---

	Enable()
	{
		if (!this._bEnabled) {
			this._bEnabled := true
			for idx, trigger in this.opt._mainTriggers {
				this._EnableTrigger(trigger)
			}
		}
		if (IsObject(this.edges)) {
			this.edges.Start()
		}
		this.trail.ShowWindow()
	}

	_EnableTrigger(btnName) {
		if (!this.opt._triggerMap.Has(btnName)) {
			return
		}
		btnInfo := this.opt._triggerMap[btnName]
		if (btnInfo.hotkey == "") {
			this._triggerEnabled[btnName] := true
			return
		}
		if (!this.opt._alwaysHook) {
			fn := this._hotIfFuncs[btnName] := btnInfo.hotif
			HotIf(fn)
		}
		if (btnInfo.IsWheel) {
			opt := "On" (this.opt._wheelPriority ? " P" this.opt._wheelPriority : "")
			fn := this._btnDownFuncs[btnName] := this._WheelRotate.Bind(this, btnName)
			Hotkey(btnInfo.hotkey, fn, opt)
		}
		else {
			opt := "On" (this.opt._triggerPriority ? " P" this.opt._triggerPriority : "")
			fn := this._btnDownFuncs[btnName] := this.TriggerDown.Bind(this, btnName)
			Hotkey(btnInfo.hotkey, fn, opt)
			fn := this._btnUpFuncs[btnName] := this.TriggerUp.Bind(this, btnName)
			Hotkey(btnInfo.hotkey " Up", fn, opt)
		}
		HotIf()
		this._triggerEnabled[btnName] := true
	}

	Disable()
	{
		if (this._bActive) {
			SetTimer(this._fnDisable, -500)
			return
		}
		if (this._bEnabled) {
			this._bEnabled := false
			for idx, trigger in this.opt._mainTriggers {
				this._DisableTrigger(trigger)
			}
		}
		if (IsObject(this.edges)) {
			this.edges.Stop()
		}
		this.trail.HideWindow()
	}

	_DisableTrigger(btnName) {
		if (!this.opt._triggerMap.Has(btnName)) {
			return
		}
		btnInfo := this.opt._triggerMap[btnName]
		if (btnInfo.hotkey == "") {
			this._triggerEnabled[btnName] := false
			return
		}
		if (this._hotIfFuncs.Has(btnName)) {
			HotIf(this._hotIfFuncs[btnName])
		}
		fn := this._btnDownFuncs[btnName]
		Hotkey(btnInfo.hotkey, fn, "Off")
		if (this._btnUpFuncs.Has(btnName)) {
			fn := this._btnUpFuncs[btnName]
			Hotkey(btnInfo.hotkey " Up", fn, "Off")
		}
		HotIf()
		this._triggerEnabled[btnName] := false
	}

	TriggerEnabled(btnName) {
		return this._triggerEnabled.Has(btnName) ? this._triggerEnabled[btnName] : false
	}

	SetActiveAsTarget()
	{
		global
		MG_HWND := WinGetID("A")
		if (WinExist(MG_HWND)) {
			MG_WClass := WinGetClass()
			MG_PID := WinGetPID()
			MG_Title := WinGetTitle()
			MG_Exe := MG_GetExeName(MG_HWND)
		}
		if (MG_HCTL := MG_GetFocus()) {
			MG_CClass := WinGetClass(MG_HCTL)
		}
	}

	GetMousePosInfo()
	{
		global
		MG_TickCount := A_TickCount
		CoordMode("Mouse", "Screen")
		MG_X := MG_Y := MG_HWND := MG_HCTL := 0
		MouseGetPos(&MG_X, &MG_Y, &MG_HWND, &MG_HCTL, 3)
		if (MG_HCTL) {
			local lParam := (MG_Y & 0xFFFF)<<16|(MG_X & 0xFFFF)
			if (SendMessage(0x0084, 0, lParam, , MG_HCTL) == 0xFFFFFFFF) {		; WM_NCHITTEST
				MouseGetPos(, , , &MG_HCTL, 2)
			}
		}
		MG_Cursor := MG_GetCursor()
		if (this.opt._bActiveWndAsTarget) {
			MG_HWND := WinGetID("A")
			MG_HCTL := MG_GetFocus()
		}
		MG_WClass := MG_CClass := MG_Title := MG_Exe := ""
		MG_PID := MG_WStyle := MG_ExWStyle := 0
		if (WinExist(MG_HWND)) {
			MG_WClass := WinGetClass()
			MG_Title := WinGetTitle()
			MG_Exe := MG_GetExeName()
			MG_PID := WinGetPID()
			MG_WStyle := WinGetStyle()
			MG_ExWStyle := WinGetExStyle()
		}
		if (WinExist(MG_HCTL)) {
			MG_CClass := WinGetClass(MG_HCTL)
			if (MG_CClass = "Button") {
				this._CorrectDialogControllHandle()
			}
		}
	}

	_CorrectDialogControllHandle()
	{
		global MG_HCTL, MG_CClass

		if (this.opt._bActiveWndAsTarget || MG_WClass!="#32770") {
			return
		}
		prc := DllCall("GlobalAlloc", "UInt",0x40, "UInt",16, "Ptr")
		hParent := DllCall("GetParent", "Ptr",MG_HCTL, "Ptr")
		hCtrl := MG_HCTL
		while (hCtrl) {
			hCtrl := DllCall("FindWindowEx", "Ptr",hParent, "Ptr",hCtrl, "Ptr",0, "Ptr",0, "Ptr")
			if (!hCtrl) {
				break
			}
			DllCall("GetWindowRect", "Ptr",hCtrl, "Ptr",prc)
			if (DllCall("PtInRect", "Ptr",prc, "Int64",MG_Y<<32|MG_X, "Ptr")) {
				dwStyle := WinGetStyle(hCtrl)
				if (dwStyle & 0x10000000) {
					MG_HCTL := hCtrl
				}
			}
		}
		MG_CClass := WinGetClass(MG_HCTL)
		DllCall("GlobalFree", "Ptr",prc)
	}

	TriggerDown(btnName, *)
	{
		Critical()
		if (!InStr(this._currentTriggers, btnName "_")) {
			this.hints.HideGestureList()
			this._triggerCount++
			this._autoReleaseCounts[btnName] := 0
			this._currentTriggers := this._currentTriggers . btnName "_"

			sendKey := !this._DefBehaviorDisabled(btnName)
					? this.opt._triggerMap[btnName].sendkey : ""

			if (this._bActive && this._bTimedOut) {
				this.SendButton(btnName, sendKey, "Down")
			}
			else if (this._triggerCount == 1) {
				; Begin to process gesture at first trigger-down
				if (A_TickCount > (this._lastProcessTime
								 + this.opt._doubleClickTimeout
								 + this._waitNext))
				{
					this._currentGesture := btnName "_"
					this.hints.SaveFirstTrigger(this._currentGesture)
					this._snapshot := ""
				} else {
					this._currentGesture .= btnName "_"
				}
				this.GetMousePosInfo()
				this._nowX := this._prevX := MG_X
				this._nowY := this._prevY := MG_Y
				this.hints.Reset()
				this.trail.Reset(MG_X, MG_Y)
				this.log.Reset()

				if (MG_IsIgnoredTarget()) {
					this.SendButton(btnName, sendKey, "Down")
				}
				else {
					this.hints.Start(MG_X, MG_Y)
					this._bAborted := false
					this._Check()
					if (this._bAborted) {
						this.hints.Stop(false)
						this.SendButton(btnName, sendKey, "Down")
					}
					else {
						this._StartRecognition()
					}
				}
			} else {
				; Processing the gesture sequence recognition
				this._Recognition()
				if (this._bypassGesture
				&&	InStr("_" this._bypassTrigger "_", "_" btnName "_"))
				{
					this._currentGesture := this._bypassGesture . btnName "_"
				} else {
					this._currentGesture .= btnName "_"
				}
				this._Check()
				this._prevX := this._nowX
				this._prevY := this._nowY
				this.log.ResetPrevTime()
			}
		}
	}

	TriggerUp(btnName, *)
	{
		Critical()
		btnRegEx := "(?<=_|^)" . btnName . "_"
		if (!RegExMatch(this._currentTriggers, btnRegEx)) {
			return
		}
		this.hints.HideGestureList()
		bReproduce := false
		if (this._bActive && !this._bAborted) {
			this._Recognition()
		}
		this._triggerCount := (this._triggerCount > 0)
							? (this._triggerCount - 1) : 0
		this._currentTriggers := RegExReplace(this._currentTriggers, btnRegEx)

		sendKey := !this._DefBehaviorDisabled(btnName)
				? this.opt._triggerMap[btnName].sendkey : ""

		if (!this._bActive || this._bTimedOut) {
			this.SendButton(btnName, sendKey, "Up")
		}
		else {
			this._currentGesture .= "_"
			if (!this._bAborted) {
				this._Check()
			}
			if (this._triggerCount < 1) {
				if (!this.hints.StartAfterimage()) {
					this.hints.Stop(false)
				}
				this.trail.Erase()

				if (this._bDefBehaviorCanceled) {
					this._bDefBehaviorCanceled := false
				}
				else if (this._performDefBehavior) {
					if (this._executedCount <= this._performDefBehavior) {
						bReproduce := true
					}
					this._performDefBehavior := 0
				}
				else if (this._executedCount==0
				&&		(!this.opt._bCancelDefBehavior
					  || (this._currentGesture = btnName "__")))
				{
					bReproduce := true
				}
			}
		}
		if (bReproduce) {
			this._ReproduceUserOperations(btnName, sendKey)
		}
	}

	_DefBehaviorDisabled(btnName) {
		return (btnName="MB"  && this.opt._bDisableMBDefault
		||		btnName="X1B" && this.opt._bDisableX1Default
		||		btnName="X2B" && this.opt._bDisableX2Default)
	}

	_ReproduceUserOperations(btnName, sendKey)
	{
		CoordMode("Mouse", "Screen")
		SetMouseDelay(-1)
		BlockInput("On")
		MouseGetPos(&x, &y)
		MouseMove(MG_X, MG_Y, 0)
		this.SendButton(btnName, sendKey, "Down")
		MouseMove(x, y, 0)
		Sleep(-1)
		this.SendButton(btnName, sendKey, "Up")
		BlockInput("Off")
	}

	_WheelRotate(btnName, *)
	{
		this.hints.HideGestureList()
		sendKey := this.opt._triggerMap[btnName].sendkey
		if (this._bActive && this._bTimedOut) {
			this.SendButton(btnName, sendKey)
		} else {
			if (!this._bActive && (A_TickCount > (this._lastProcessTime
												+ this.opt._doubleClickTimeout
												+ this._waitNext)))
			{
				this.GetMousePosInfo()
				if (MG_IsIgnoredTarget()) {
					this.SendButton(btnName, sendKey)
				}
				else {
					this._currentGesture := btnName "_"
					this._snapshot := ""
					this._bAborted := false
					this._waitNext := 0
					this._executedCount := 0
					this._bTimedOut := false
					this._nowX := this._prevX := MG_X
					this._nowY := this._prevY := MG_Y
					this.log.Reset()

					if (!this._Check()) {
						this.SendButton(btnName, sendKey)
					}
				}
			} else {
				this._Recognition()
				if (this._bypassGesture!="" && InStr("_" this._bypassTrigger "_", "_" btnName "_")) {
					this._currentGesture := this._bypassGesture . btnName "_"
				} else {
					this._currentGesture .= btnName "_"
				}
				if (!this._Check()) {
					this.SendButton(btnName, sendKey)
				}
				this._prevX := this._nowX
				this._prevY := this._nowY
				this.log.ResetPrevTime()
			}
		}
	}

	_Check(gestureString:="")
	{
		this._lastProcessTime := A_TickCount
		if (StrLen(this._currentGesture) > this.opt._maxLength) {
			; Gesture is too long
			this._currentGesture := this._snapshot!="" ? this._snapshot : this._currentTriggers
		}
		else {
			if (gestureString == "") {
				gestureString := this._currentGesture
				bCheckCurrent := true
			} else {
				bCheckCurrent := false
			}
			actionFunc := this.opt._gestureMap.Has(gestureString)
						? this.opt._gestureMap[gestureString] : ""
			if (actionFunc) {
				this.hints.PrepareAfterimage(this._currentGesture)
				dummy := WinExist(MG_HWND)
				executedCount := this._executedCount++
				if (bCheckCurrent) {
					this.log.Update(gestureString)
				}
				if (!this.hints.IsHintWindow(MG_HWND) && !this.trail.IsTrailWindow(MG_HWND)) {
					actionFunc()
				} else {
					this.WaitNext(0)
				}
				if (executedCount != this._executedCount) {
					if (bCheckCurrent) {
						this._currentGesture := this._snapshot!="" ? this._snapshot : this._currentTriggers
						this.log.Update()
					}
					return true
				} else {
					return (this._waitNext != 0)
				}
			}
		}
		this.log.Update()
		return false
	}

	_StartRecognition()
	{
		this._bActive				:= true
		this._bAborted				:= false
		this._bTimedOut				:= false
		this._bDefBehaviorCanceled	:= false
		this._performDefBehavior	:= 0
		this._waitNext				:= 0
		this._executedCount			:= 0
		this._prevX := this._prevLongX := MG_X
		this._prevY := this._prevLongY := MG_Y
		this._nowDir := this._prevDir := this._prevLongDir := ""
		this._angleThreshold := this.opt._defAngleThreshold
		this.hints.Reset()
		this.log.ClearPrevGesture()

		MG_GetDpiFromPoint(MG_X, MG_Y, true)
		for idx, trigger in this.opt._subTriggers {
			this._EnableTrigger(trigger)
		}
		this.ResetTimeout()
		SetTimer(this._fnRecognition, this.opt._recognitionInterval)
	}

	_Recognition()
	{
		CoordMode("Mouse", "Screen")
		MouseGetPos(&x, &y)
		this._nowX := x
		this._nowY := y
		bDrawTrail := true
		if (this._triggerCount < 1) {
			; All triggers have been released.
			SetTimer(this._fnRecognition, 0)
			this._bActive := false
			this._triggerCount := 0
			this._currentTriggers := ""
			this._bypassGesture := ""
			this._bypassTrigger := ""
			for idx, trigger in this.opt._subTriggers {
				this._DisableTrigger(trigger)
			}
			this.hints.Stop(false)
			bDrawTrail := false
		}
		else if ((MG_X-this._nowX)**2+(MG_Y-this._nowY)**2 < this.opt._timeoutDistance**2) {
			; Less than the minimum distance. -> Reset the timeout.
			this.ResetTimeout()
		}
		else if (!this._bTimedOut
		&&		(this._bAborted
				|| (this._bTimeoutEnabled && this.opt._timeout>0
					&& (A_TickCount > this._timeLimit) && this._executedCount==0)))
		{
			; Recognition was aborted within the action script, or a timeout. -> _Reproduce user operations.
			Critical()
			this._bTimedOut := true
			SetMouseDelay(-1)
			BlockInput("On")
			MouseMove(MG_X, MG_Y, 0)
			Loop Parse, this._currentTriggers, "_" {
				if (A_LoopField != "") {
					sendKey := !this._DefBehaviorDisabled(A_LoopField)
							? this.opt._triggerMap[A_LoopField].sendkey : ""
					this.SendButton(A_LoopField, sendKey, "Down")
				}
			}
			MouseMove(this._nowX, this._nowY, 0)
			BlockInput("Off")
			Critical("Off")

			this.hints.Stop(false)
			bDrawTrail := false
		}
		else if (!this._bTimedOut
		&&		((powx:=(this._nowX-this._prevX)**2) + (powy:=(this._nowY-this._prevY)**2)
														>= this.opt._distanceThreshold**2))
		{
			; Movement exceeding the threshold distance has been detected
			if (this.opt._b8DirMode) {
				angle := Abs(this._90degrees - Abs(ATan((this._nowX-this._prevX) / (this._nowY-this._prevY))))
				if (this._angleThreshold > angle) {
					this._nowDir := (this._nowX > this._prevX) ? ((this._nowY > this._prevY) ? 3 : 9)
															   : ((this._nowY > this._prevY) ? 1 : 7)
				} else {
					this._nowDir := (powx > powy) ? ((this._nowX > this._prevX) ? 6 : 4)
												  : ((this._nowY > this._prevY) ? 2 : 8)
				}
			} else {
				this._nowDir := (powx > powy) ? ((this._nowX > this._prevX) ? "R" : "L")
											  : ((this._nowY > this._prevY) ? "D" : "U")
			}
			bConfirmed := false
			if (this._nowDir != this._prevDir) {
				; Direction change has been detected
				bConfirmed := true
				this._prevLongDir := ""
			}
			else {
				; Determination of long distance movement
				if (this.opt._b8DirMode) {
					bConfirmed := ((this._nowX-this._prevLongX)**2 + (this._nowY-this._prevLongY)**2
																 >= this.opt._longDiagThreshold**2)
				} else if (powx > powy) {
					bConfirmed := (Abs(this._nowX-this._prevLongX) >= this.opt._longThresholdX)
				} else {
					bConfirmed := (Abs(this._nowY-this._prevLongY) >= this.opt._longThresholdY)
				}
				if (bConfirmed) {
					if (this.opt._bFirstLongOnly && (this._prevLongDir == this._nowDir)) {
						bConfirmed := false
					}
					this._prevLongDir := this._nowDir
				}
			}
			if (bConfirmed) {
				; Movement has been confirmed
				this.hints.HideGestureList()
				this._currentGesture .= this._nowDir
				if (this.opt._b8DirMode) {
					if (this._nowDir & 1) {
						this._angleThreshold := this.opt._afterDiagonal
					} else {
						this._angleThreshold := this.opt._afterOrthogonal
					}
				}
				this._prevLongX := this._prevX
				this._prevLongY := this._prevY
				this._prevDir := this._Check() ? "" : this._nowDir
			}
			MouseGetPos(&x, &y)
			this._prevX := x
			this._prevY := y
			this.ResetTimeout()
			this.log.ResetPrevTime()
		}

		if (bDrawTrail) {
			this.trail.Draw()
		} else {
			this.trail.Erase()
		}
	}

	ResetTimeout() {
		this._timeLimit := A_TickCount + this.opt._timeout
		this._bTimeoutEnabled := true
	}

	SendButton(btnName, ahkKey, option:="")
	{
		if (ahkKey == "") {
			return
		}
		SetMouseDelay(-1)
		if (this.TriggerEnabled(btnName)) {
			this._DisableTrigger(btnName)
			this._tempDisabled[btnName] := true
		} else {
			this._tempDisabled[btnName] := false
		}
		Send("{Blind}{" . ahkKey . (option!="" ? " " option : "") . "}")
		if (this._tempDisabled[btnName]) {
			this._EnableTrigger(btnName)
		}
	}

	CheckAbnormalConditions()
	{
		; Check the mouse buttons that is not physically being pressed.
		; This is a safeguard against cases where the button-release event fails to be captured.
		if (this.opt._autoReleaseCount > 0) {
			Loop Parse, this._currentTriggers, "_" {
				this._CheckButton(A_LoopField)
			}
		}
		; Hide hints and trail
		if ((!this._bActive && (A_TickCount>(this._lastProcessTime + this.opt._doubleClickTimeout + this._waitNext)))
		||	(this._bActive && this._bTimedOut))
		{
			this.hints.Stop(false)
			this.trail.Erase()
		}
	}

	_CheckButton(btnName)
	{
		; Release the pressed state for physically unpressed mouse button.
		if (!this._autoReleaseCounts.Has(btnName)) {
			return
		}
		if (this._bActive && this._bTimedOut) {
			this._autoReleaseCounts[btnName]++
			if (this._autoReleaseCounts[btnName] > this.opt._autoReleaseCount) {
				this._autoReleaseCounts[btnName] := 0
				this.TriggerUp(btnName)
			}
		} else {
			this._autoReleaseCounts[btnName] := 0
		}
	}

	;--- Action Functions ---

	IsFirstAction() {
		return (this._executedCount <= 1)
	}

	Abort() {
		this._bAborted := true
	}

	DisableTimeout() {
		this._bTimeoutEnabled := false
	}

	WaitNext(wait) {
		if (this._executedCount > 0) {
			this._executedCount--
		}
		this._waitNext := wait
	}

	DelayedExecution(delay:=0)
	{
		if (this._delayedState == -1) {
			this._delayedState := 0
			return false
		}
		this._delayedGesture := this._currentGesture
		if (delay) {
			if (delay > 0) {
				this._delayedState := 1
				SetTimer(this._fnDelayedExecutionThread, -delay)
			}else{
				this._delayedState := 2
				this._executedCount--
				this._waitNext := -delay
				SetTimer(this._fnDelayedExecutionThread, delay)
			}
		}else{
			this._delayedState := 3
			SetTimer(this._fnDelayedExecutionThread, -this.opt._recognitionInterval)
		}
		return true
	}
	_DelayedExecutionThread()
	{
		if ((this._delayedState==3) && this._bActive) {
			SetTimer(this._fnDelayedExecutionThread, -this.opt._recognitionInterval)
			return
		}
		if ((this._delayedState!=2) || (this._currentGesture = this._delayedGesture)) {
			this._delayedState := -1
			this._Check(this._delayedGesture)
		} else {
			this._delayedState := 0
		}
	}

	RepeatedExecution(interval:=20)
	{
		if (this._repeatedState == 0) {
			this._repeatedGesture := this._currentGesture
			this._repeatedTrrigers := this._currentTriggers
			if (interval < 1) {
				this._repeatedInterval := this.opt._recognitionInterval
				this._repeatedState := 2
			}else{
				this._repeatedInterval := interval
				this._repeatedState := 1
			}
		}
		else if (this._repeatedState = -1) {
			this._repeatedState := 0
			return false
		}
		SetTimer(this._fnRepeatedExecutionThread, -this._repeatedInterval)
		return true
	}
	_RepeatedExecutionThread()
	{
		if (this._bActive && InStr(this._currentTriggers, this._repeatedTrrigers)==1) {
			SetTimer(this._fnRepeatedExecutionThread, -this._repeatedInterval)
			if (this._repeatedState == 1) {
				this._Check(this._repeatedGesture)
			}
		}
		else {
			this._repeatedState := -1
			this._Check(this._repeatedGesture)
		}
	}

	HoldDownExecution()
	{
		if (this._holdDownFinish) {
			this._holdDownTrrigers := ""
			return A_TickCount - this._holdDownStartTime
		}
		else if (this._holdDownTrrigers == "") {
			this._holdDownGesture := this._currentGesture
			this._holdDownTrrigers := this._currentTriggers
			this._holdDownStartTime := A_TickCount
			SetTimer(this._fnHoldDownExecutionThread, -this.opt._recognitionInterval)
		}
		return 0
	}
	_HoldDownExecutionThread()
	{
		if (this._bActive && InStr(this._currentTriggers, this._holdDownTrrigers)==1) {
			SetTimer(this._fnHoldDownExecutionThread, -this.opt._recognitionInterval)
		}
		else {
			this._holdDownFinish := true
			this._Check(this._holdDownGesture)
			this._holdDownFinish := false
		}
	}

	SaveGesture(bNotCountedAction:=true) {
		this._snapshot := this._currentGesture
		if (bNotCountedAction && this._executedCount>0) {
			this._executedCount--
		}
	}

	SetBypass(trigger:="") {
		this._bypassGesture := this._currentGesture
		this._bypassTrigger := (trigger!="") ? trigger : this.opt._subTriggers
	}

	PerformDefaultBehavior(limit:=1) {
		if (limit >= 1) {
			this._performDefBehavior := limit
			this._bDefBehaviorCanceled := false
		}
	}

	CancelDefaultBehavior() {
		this._performDefBehavior := 0
		this._bDefBehaviorCanceled := true
	}

	Counter(gesture:="", operation:=2)
	{
		if (gesture == "") {
			gesture := this._currentGesture
		}
		count := this._gestureCounter.Has(gesture)
				? this._gestureCounter[gesture] : 0

		if (operation < -1) {
			ret := Mod(count, -operation)
		}
		else if (operation == -1) {
			ret := count
		}
		else if (operation == 1) {
			ret := count := 0
		}
		else if (operation == 0) {
			ret := ++count
		}
		else {
			ret := Mod(++count, operation)
		}
		
		this._gestureCounter[gesture] := count
		return ret
	}
}

MG_GestureClassEnd:
