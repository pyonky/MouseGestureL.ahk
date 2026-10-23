;===============================================================================
;
;		MouseGestureL.ahk - Gesture Hint Class
;
;															Created by Pyonkichi
;===============================================================================
Goto("MG_HintClassEnd")

class GestureDisplayBase
{
	_MakeTransColorStr(colorStr)
	{
		RegExMatch(colorStr, "([a-zA-Z0-9][a-zA-Z0-9])"
						   . "([a-zA-Z0-9][a-zA-Z0-9])"
						   . "([a-zA-Z0-9][a-zA-Z0-9])", &part)
		RR := Number("0x" part[1]),	 RR += (RR ? -1 : 1)
		GG := Number("0x" part[2]),	 GG += (GG ? -1 : 1)
		BB := Number("0x" part[3]),	 BB += (BB ? -1 : 1)
		color := (RR<<16) + (GG<<8) + BB
		return Format("{:06X}", color)
	}

	_MakeColorRef(colorStr)
	{
		return Number(RegExReplace(colorStr, "([a-zA-Z0-9][a-zA-Z0-9])"
										   . "([a-zA-Z0-9][a-zA-Z0-9])"
										   . "([a-zA-Z0-9][a-zA-Z0-9])", "0x$3$2$1"))
	}
}

class HintSettings
{
	__New()
	{
		this._threadPriority	  := -1
		this._gestureMap		  := MG_GestureMap
		this._triggersRegEx		  := MG_TriggersRegEx

		this._bEnableFromStartup  := MG_UseNavi
		this._hintType			  := MG_UseExNavi
		this._updateInterval	  := (MG_NaviInterval < 10) ? MG_NaviInterval : 10
		this._afterimageDuration  := MG_NaviPersist

		this._bFromButtonDown	  := MG_AdNaviOnClick
		this._bgColor			  := MG_AdNaviBG
		this._textColor			  := MG_AdNaviFG
		this._pendingColor		  := MG_AdNaviNI
		this._transparency		  := MG_AdNaviTranspcy
		this._fontFace			  := MG_AdNaviFont
		this._textSize			  := MG_AdNaviSize
		this._cornerRadius		  := MG_AdNaviRound
		this._cursorOffset		  := MG_AdNaviMargin
		this._offsetX			  := MG_AdNaviSpaceX
		this._offsetY			  := MG_AdNaviSpaceY
		this._position			  := MG_AdNaviPosition
		this._padding :=	MG_Rect( MG_AdNaviPaddingL
								   , MG_AdNaviPaddingT
								   , MG_AdNaviPaddingR
								   , MG_AdNaviPaddingB )
		this._arrowClipping		  := MG_ExNaviTransBG
		this._arrowColor		  := MG_ExNaviFG
		this._arrowBgColor		  := MG_ExNaviBG
		this._arrowTransparency	  := MG_ExNaviTranspcy
		this._arrowSize			  := MG_ExNaviSize
		this._arrowSpacing	 	  := MG_ExNaviSpacing
		this._arrowPadding	 	  := MG_ExNaviPadding
		this._arrowCursorOffset	  := MG_ExNaviMargin
		this._arrowColorMap		  := MG_ArrowColors			; MG_ExNaviFG_...
	}
}

class GestureHintClass extends GestureDisplayBase
{
	__New()
	{
		this.opt := HintSettings()

		this._gestureRenderer := GestureRendererClass(this.opt._triggersRegEx
														, this.opt._fontFace
														, this.opt._textSize, 700
														, this._MakeColorRef(this.opt._textColor)
														, this._MakeColorRef(this.opt._pendingColor))

		this._bEnabled					:= false			; MG_NaviEnabled
		this._bGestureListShowing		:= false			; MG_bListShowing
		this._bAllListShowing			:= false
		this._bAfterimageShowing		:= false			; MG_NaviPrst
		this._afterimageSequence		:= ""				; MG_NaviPrstStr
		this._prevSequence				:= ""				; MG_PrevGesture
		this._userTooltip				:= ""				; MG_Tooltip
		this._firstTrigger				:= ""				; MG_FirstTrigger

		this._hintWnd					:= ""				; MGW_Hints
		this._bgColorRef				:= 0				; MG_AdvHintsBgColorVal
		this._transColor				:= ""				; MG_AdvHintsTransColor
		this._transColorRef				:= 0				; MG_AdvHintsTransColorVal
		this._startX					:= 0
		this._startY					:= 0
		this._prevX						:= 0				; prevX (static local)
		this._prevY						:= 0				; prevY (static local)
		this._hFontAction				:= 0				; MG_hFntAct
		this._rcMonitor					:= MG_Rect()		; MG_MonitorL, MG_MonitorT, MG_MonitorR, MG_MonitorB
		this._dispPos					:= 0

		this._arrowWnd					:= ""				; MGW_Arrows
		this._prevArrows				:= ""				; MG_PrevGesture
		this._arrowColorRef				:= 0				; MG_ExNaviFG2
		this._arrowBgColorRef			:= 0				; MG_ExNaviBG2
		this._arrowUseDynamicColor		:= false
		this._arrowDynamicColorRef		:= 0				; MG_ExNaviIdvFG
		this._arrowUseDynamicBgColor	:= false
		this._arrowDynamicBgColorRef	:= ""				; MG_ExNaviIdvBG
		this._arrowPrevX				:= 0				; prevX (static local)
		this._arrowPrevY				:= 0				; prevY (static local)
		this._arrowType2Pos				:= []				; MG_ArrowPos...
		this._arrowBgColorVar := this.opt._arrowBgColor		; MG_ExNaviBG

		this._arrowCharMap := Map( "D", 0xEA, "L", 0xE7, "R", 0xE8, "U", 0xE9
								 , "1", 0xED, "2", 0xEA, "3", 0xEE, "4", 0xE7
								 , "6", 0xE8, "7", 0xEB, "8", 0xE9, "9", 0xEC )

		this._arrowNextPos := [ [  1, 10,  2, 12,  0,  2,  4,  4,  9 ]
							  , [ 10,  2, 11,  1,  0,  3,  4,  8,  6 ]
							  , [  2, 11,  3,  2,  0, 13,  7,  6,  6 ]
							  , [ 12,  1,  2,  4,  0,  6, 14,  7,  8 ]
							  , [  0,  0,  0,  0,  0,  0,  0,  0,  0 ]
							  , [  2,  3, 13,  4,  0,  6,  8,  9, 15 ]
							  , [  4,  4,  3, 14,  0,  8,  7, 16,  8 ]
							  , [  4,  2,  6,  7,  0,  9, 16,  8, 17 ]
							  , [  1,  6,  6,  8,  0, 15,  8, 17,  9 ] ]

		this._fnUpdate := this._Update.Bind(this)
		this._fnAfterimageTimer := this._AfterimageTimer.Bind(this)

		if (this.opt._bEnableFromStartup) {
			this.Enable()
		}
	}

	__Delete() {
		if (this._hFontAction) {
			DllCall("DeleteObject", "Ptr",this._hFontAction)
			this._hFontAction := 0
		}
	}

	Dispose()
	{
		SetTimer(this._fnUpdate, 0)
		this._fnUpdate := ""

		SetTimer(this._fnAfterimageTimer, 0)
		this._fnAfterimageTimer := ""
	}

	;--- Properties ---

	Enabled {
		get {
			return this._bEnabled
		}
	}

	UserTooltip {
		set {
			this._userTooltip := value
		}
		get {
			return this._userTooltip
		}
	}

	;--- Functions ---

	Enable()
	{
		if (!this._bEnabled) {
			this._bEnabled := true
			this._CreateHintWindow()
			if (this.opt._hintType==2 || this.opt._hintType==3) {
				this._CreateArrowWindow()
			}
		}
	}

	Disable()
	{
		if (this._bEnabled) {
			this._bEnabled := false
			this._DestroyHintWindows()
		}
	}

	IsHintWindow(hWnd) {
		return ((this._hintWnd	&& hWnd==this._hintWnd.Hwnd)
			 || (this._arrowWnd	&& hWnd==this._arrowWnd.Hwnd))
	}

	Start(x, y)
	{
		if (!this._bEnabled) {
			return
		}
		this._startX := x
		this._startY := y
		this._dispPos := this.opt._position
		this._bAfterimageShowing := false
		SetTimer(this._fnAfterimageTimer, 0)
		this._bGestureListShowing := false
		this._bAllListShowing := false
		this._GetTargetMonitorRect(x, y)
		this._SetArrowColor()
		SetTimer(this._fnUpdate, this.opt._updateInterval, this.opt._threadPriority)
	}

	Stop(bForce:=true)
	{
		if (!this._bEnabled || this._bAllListShowing) {
			return
		}
		if (bForce) {
			this._bAfterimageShowing := false
			SetTimer(this._fnAfterimageTimer, 0)
		}
		else if (this._bAfterimageShowing) {
			return
		}
		SetTimer(this._fnUpdate, 0)
		if (this._hintWnd) {
			this._hintWnd.Hide()
		}
		if (this._arrowWnd) {
			this._arrowWnd.Hide()
		}
		else if (this.opt._hintType == 1) {
			ToolTip()
			this._userTooltip := ""
		}
		this._bGestureListShowing := false
	}

	Reset() {
		this._prevArrows := ""
		this._prevSequence := ""
		this._afterimageSequence := ""
	}

	SaveFirstTrigger(trigger) {
		this._firstTrigger := trigger
	}

	PrepareAfterimage(gestureSequence)
	{
		if (!this._bEnabled) {
			return
		}
		if (this.opt._afterimageDuration > 0) {
			this._afterimageSequence := gestureSequence
		}
	}

	StartAfterimage()
	{
		if (!this._bEnabled) {
			return false
		}
		if (this._afterimageSequence != "") {
			this._bAfterimageShowing := true
			SetTimer(this._fnAfterimageTimer, this.opt._afterimageDuration)
			return true
		}
		return false
	}

	_AfterimageTimer()
	{
		SetTimer(this._fnAfterimageTimer, 0)
		this.Stop(true)
	}

	ToggleGestureList()
	{
		if (!this._bGestureListShowing) {
			this._bGestureListShowing := true
			MG.DisableTimeout()
			if (this.opt._hintType != 5) {
				this._ShowHints("Open")
			}
		} else {
			this.HideGestureList()
		}
	}

	ToggleAllGestureList(pos:=2)
	{
		if (!this._bGestureListShowing) {
			if (!MG.Active) {
				MG.GetMousePosInfo()
			}
			this._GetTargetMonitorRect(MG_X, MG_Y)
			this._dispPos := pos
			this._bAllListShowing := true
			this._ShowHints("ShowAll")
		} else {
			this.HideGestureList()
			this._bAllListShowing := false
		}
	}

	HideGestureList()
	{
		if (this._bGestureListShowing) {
			this._bGestureListShowing := false
			if (this.opt._hintType < 4) {
				this._hintWnd.Hide()
			}
			else if (this.opt._hintType == 4) {
				this._ShowHints("Close")
			}
			MG.ResetTimeout()
		}
	}

	_CreateHintWindow()
	{
		this._hintWnd := Gui("-Caption +ToolWindow +AlwaysOnTop -DPIScale", "MouseGestureL.ahk Gesture Hints")
		this._hintWnd.BackColor := this.opt._bgColor
		this._bgColorRef := this._MakeColorRef(this.opt._bgColor)
		this._transColor := this._MakeTransColorStr(this.opt._bgColor)
		this._transColorRef := this._MakeColorRef(this._transColor)
		bgColor := this._transColor
		if (this.opt._transparency>0 && this.opt._transparency<255) {
			bgColor .= " " this.opt._transparency
		}
		WinSetTransColor(bgColor, this._hintWnd)
		this._hFontAction := MG_CreateFont(this.opt._fontFace, this.opt._textSize)
	}

	_CreateArrowWindow()
	{
		this._arrowWnd := Gui("-Caption +ToolWindow +AlwaysOnTop -DPIScale", "MouseGestureL.ahk Arrow Hints")
		if (this.opt._arrowClipping) {
			this._arrowBgColorVar := this._MakeTransColorStr(this.opt._arrowColor)
		}
		else if (this.opt._arrowTransparency>0 && this.opt._arrowTransparency<255) {
			WinSetTransparent(this.opt._arrowTransparency, this._arrowWnd)
		}
		this._arrowColorRef := this._MakeColorRef(this.opt._arrowColor)
		this._arrowBgColorRef := this._MakeColorRef(this._arrowBgColorVar)
	}

	_DestroyHintWindows()
	{
		if (this._hintWnd) {
			Try this._hintWnd.Destroy()
			this._hintWnd := ""
		}
		if (this._arrowWnd) {
			Try this._arrowWnd.Destroy()
			this._arrowWnd := ""
		}
		if (this._hFontAction) {
			DllCall("DeleteObject", "Ptr",this._hFontAction)
			this._hFontAction := 0
		}
	}

	_GetTargetMonitorRect(x, y) {
		MG_GetMonitorRect(x, y, this._rcMonitor, true)
	}

	_Update()
	{
		if (this._bGestureListShowing) {
			return
		}
		if (this.opt._hintType==2 || this.opt._hintType==3) {
			this._ShowArrows()
		}
		else if (this.opt._hintType==4 || this.opt._hintType==5) {
			this._ShowHints()
		}
		else {
			this._ShowTooltipHint()
		}
	}

	_ShowTooltipHint()
	{
		if (this._userTooltip != "") {
			ToolTip(RegExReplace(this._userTooltip, "(?<=^|\n)\t+"))
		}
		else if (this._bAfterimageShowing) {
			ToolTip(this._afterimageSequence)
		}
		else {
			ToolTip(MG.CurrentGesture)
		}
	}


	;--- Hints displaying arrows and actions ---

	_ShowHints(listOperation:="")
	{
		global MG_ScreenDPI

		if (listOperation = "ShowAll") {
			gestureSequence := ""
			this._hintWnd.Move(0, 0, 0, 0)
		}
		else {
			gestureSequence := this._bAfterimageShowing ? this._afterimageSequence : MG.CurrentGesture
			if (gestureSequence == "") {
				return
			}
			if (!this.opt._bFromButtonDown && (gestureSequence = this._firstTrigger)) {
				this._hintWnd.Hide()
				return
			}
		}

		; Determine the drawing position
		x := y := 0
		bDpiChanged := false
		if (this._dispPos <= 1) {
			if (this.opt._cursorOffset < 0) {
				x:=this._startX, y:=this._startY
			}
			else {
				CoordMode("Mouse", "Screen")
				MouseGetPos(&x, &y)
				x += MG_ScaleToDPI(this.opt._cursorOffset)
				y += MG_ScaleToDPI(this.opt._cursorOffset)
				if (x!=this._prevX || y!=this._prevY) {
					newDPI := MG_GetDpiFromPoint(x, y)
					if (newDPI != MG_ScreenDPI) {
						MG_ScreenDPI := newDPI
						bDpiChanged := true
					}
				}
			}
		}

		if ((gestureSequence != this._prevSequence) || listOperation || bDpiChanged) {
			; Show hint window
			if (!MG_IsVisible(this._hintWnd)) {
				this._hintWnd.Show("NA")
			}
			; Draw gesture sequence
			hDC := DllCall("GetWindowDC", "Ptr",this._hintWnd.Hwnd, "Ptr")
			DllCall("SetBkColor", "Ptr",hDC, "UInt",this._bgColorRef)
			if (this.opt._hintType==4 && (!listOperation || listOperation="Close")) {
				this._DrawSimpleHints(hDC, x, y, gestureSequence)
			} else {
				this._DrawListStyleHints(hDC, x, y, gestureSequence)
			}
			DllCall("ReleaseDC", "Ptr",this._hintWnd.Hwnd, "Ptr",hDC)
		}
		else if ((this._dispPos<=1) && (x!=this._prevX || y!=this._prevY)) {
			; Move the window only
			this._hintWnd.Move(x, y)
		}
		this._prevX := x
		this._prevY := y
		this._prevSequence := gestureSequence
	}

	_DrawSimpleHints(hDC, x, y, gestureSequence)
	{
		this._gestureRenderer.GetExtent(hDC, gestureSequence, &gesW, &gesH)
		actionTitle := ""
		actionFunc := this.opt._gestureMap.Has(gestureSequence "_")
					? this.opt._gestureMap[gestureSequence "_"] : ""
		if (actionFunc) {
			actionTitle := actionFunc(false)
		}
		if (InStr(actionTitle, MG_HIDEHINTS)) {
			actionTitle := ""
		}
		actW := actH := 0
		if (actionTitle != "") {
			actionTitle := " : " . actionTitle
			this._GetActionExtent(hDC, actionTitle, &actW, &actH)
		}
		if (!this._ResizeWindow(hDC, gesW+actW, (gesH>actH ? gesH : actH), &x, &y)) {
			return
		}
		this._gestureRenderer.Draw(hDC, x, y, gestureSequence)
		if (actW > 0) {
			this._DrawAction(hDC, x+gesW, y, actionTitle)
		}
	}

	_DrawListStyleHints(hDC, x, y, currentGesture)
	{
		aryGestures := []
		maxGesW := maxActW := totalHeight := 0

		; Compare current gesture and registered gestures
		for definedGesture, actionFunc in this.opt._gestureMap {
			if (!currentGesture									; All gesture list.
			||	(InStr(definedGesture, currentGesture) == 1))	; Matching against defined gesture prefixes.
			{
				if (currentGesture) {
					; Eliminate the cases matched to part of the button names
					def := RegExReplace(definedGesture, this.opt._triggersRegEx "_")
					cur := RegExReplace(currentGesture, this.opt._triggersRegEx "_")
					if (InStr(def, cur) != 1) {
						continue
					}
				}

				; Get the title of the assigned action
				actionTitle := ""
				actionTitle := actionFunc(false)
				if (InStr(actionTitle, MG_HIDEHINTS)) {
					actionTitle := ""
				}
				if (actionTitle == "") {
					continue
				}

				; Update the size of the drawing area
				this._gestureRenderer.GetExtent(hDC, definedGesture, &gesW, &gesH)
				if (maxGesW < gesW) {
					maxGesW := gesW
				}
				actionTitle := " : " actionTitle
				this._GetActionExtent(hDC, actionTitle, &actW, &actH)
				if (maxActW < actW) {
					maxActW := actW
				}
				h := (gesH > actH) ? gesH : actH
				totalHeight += h
				aryGestures.Push({ sequence: definedGesture, action: actionTitle, height: h })
			}
		}

		; Draw gesture patterns and the assigned actions
		if (aryGestures.Length <= 0) {
			this._hintWnd.Hide()
			return
		}
		if (!this._ResizeWindow(hDC, maxGesW+maxActW, totalHeight, &x, &y)) {
			return
		}
		len := StrLen(currentGesture)
		for idx, gesture in aryGestures {
			this._gestureRenderer.Draw(hDC, x, y, gesture.sequence, len)
			this._DrawAction(hDC, x+maxGesW, y, gesture.action)
			y += gesture.height
		}
	}

	_GetActionExtent(hDC, actionTitle, &w:=0, &h:=0)
	{
		hFontOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",this._hFontAction, "Ptr")
		size := Buffer(8, 0)			; struct SIZE
		DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",actionTitle, "Int",StrLen(actionTitle), "Ptr",size.Ptr)
		w := NumGet(size, 0, "UInt")	; SIZE.cx
		h := NumGet(size, 4, "UInt")	; SIZE.cy
		DllCall("SelectObject", "Ptr",hDC, "Ptr",hFontOld)
	}

	_DrawAction(hDC, x, y, actionTitle)
	{
		hFontOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",this._hFontAction, "Ptr")
		DllCall("TextOut", "Ptr",hDC, "Int",x, "Int",y, "Str",actionTitle, "Int",StrLen(actionTitle))
		DllCall("SelectObject", "Ptr",hDC, "Ptr",hFontOld)
	}

	_ResizeWindow(hDC, contentsW, contentsH, &x, &y)
	{
		padL := MG_ScaleToDPI(this.opt._padding.left)
		padT := MG_ScaleToDPI(this.opt._padding.top)
		padR := MG_ScaleToDPI(this.opt._padding.right)
		padB := MG_ScaleToDPI(this.opt._padding.bottom)
		w := padL + contentsW + padR
		h := padT + contentsH + padB
		if (w==0 || h==0) {
			return false
		}
		this._AdjustDisplayPosition(w, h, &x, &y)
		this._hintWnd.Move(x, y, w, h)
		radius := MG_ScaleToDPI(this.opt._cornerRadius)
		this._RoundWindow(hDC, w, h, radius, this._bgColorRef, this._transColorRef)
		x := padL
		y := padT
		return true
	}

	_AdjustDisplayPosition(w, h, &x, &y)
	{
		switch (this._dispPos) {
		  case 2:
			x := this._rcMonitor.left + MG_ScaleToDPI(this.opt._offsetX)
			y := this._rcMonitor.top + MG_ScaleToDPI(this.opt._offsetY)
		  case 3:
			x := this._rcMonitor.right - MG_ScaleToDPI(this.opt._offsetX) - w
			y := this._rcMonitor.top + MG_ScaleToDPI(this.opt._offsetY)
		  case 4:
			x := this._rcMonitor.left + MG_ScaleToDPI(this.opt._offsetX)
			y := this._rcMonitor.bottom - MG_ScaleToDPI(this.opt._offsetY) - h
		  case 5:
			x := this._rcMonitor.right - MG_ScaleToDPI(this.opt._offsetX) - w
			y := this._rcMonitor.bottom - MG_ScaleToDPI(this.opt._offsetY) - h
		}
	}

	_RoundWindow(hDC, w, h, nRadius, colorRefBg, colorRefTrans)
	{
		if (nRadius <= 0) {
			return
		}
		w++, h++
		hBrsB := DllCall("CreateSolidBrush", "UInt",colorRefBg, "Ptr")
		hBrsT := DllCall("CreateSolidBrush", "UInt",colorRefTrans, "Ptr")
		hRgn1 := DllCall("CreateRectRgn", "Int",0, "Int",0, "Int",w, "Int",h, "Ptr")
		hRgn2 := DllCall("CreateRoundRectRgn", "Int",0, "Int",0, "Int",w, "Int",h, "Int",nRadius*2, "Int",nRadius*2, "Ptr")
		DllCall("CombineRgn", "Ptr",hRgn1, "Ptr",hRgn1, "Ptr",hRgn2, "Int",4)
		DllCall("FillRgn", "Ptr",hDC, "Ptr",hRgn1, "Ptr",hBrsT)
		DllCall("FillRgn", "Ptr",hDC, "Ptr",hRgn2, "Ptr",hBrsB)
		DllCall("DeleteObject", "Ptr",hBrsB)
		DllCall("DeleteObject", "Ptr",hBrsT)
		DllCall("DeleteObject", "Ptr",hRgn1)
		DllCall("DeleteObject", "Ptr",hRgn2)
	}


	;--- Arrow Hints ---

	_SetArrowColor()
	{
		if (this.opt._hintType!=2 && this.opt._hintType!=3) {
			return
		}
		this._arrowUseDynamicColor := false
		this._arrowDynamicColorRef := 0
		this._arrowUseDynamicBgColor := false
		this._arrowDynamicBgColorRef := 0

		RegExMatch(MG.CurrentGesture, "^([^_]+?)_", &part)
		btn := part[1]
		arrowColor := this.opt._arrowColorMap.Has(btn)
					? this.opt._arrowColorMap[btn] : ""
		if (arrowColor) {
			this._arrowUseDynamicColor := true
			this._arrowDynamicColorRef := this._MakeColorRef(arrowColor)
		}
		bgColor := this._arrowBgColorVar
		if (this.opt._arrowClipping) {
			if (arrowColor) {
				this._arrowUseDynamicBgColor := true
				bgColor := this._MakeTransColorStr(arrowColor)
				this._arrowDynamicBgColorRef := this._MakeColorRef(bgColor)
			}
			transparency := ""
			if (this.opt._arrowTransparency>0 && this.opt._arrowTransparency<255) {
				transparency := " " this.opt._arrowTransparency
			}
			WinSetTransColor(bgColor . transparency, this._arrowWnd)
		}
		this._arrowWnd.BackColor := bgColor
	}

	_ShowArrows()
	{
		global MG_ScreenDPI

		gestureSequence := this._bAfterimageShowing ? this._afterimageSequence : MG.CurrentGesture
		arrowString := this._MakeArrowsString(gestureSequence)
		if (arrowString == "") {
			return
		}

		; Determine the drawing position
		bDpiChanged:=false
		if (this.opt._arrowCursorOffset < 0) {
			x:=this._startX, y:=this._startY
		}
		else {
			CoordMode("Mouse", "Screen")
			MouseGetPos(&x, &y)
			x += MG_ScaleToDPI(this.opt._arrowCursorOffset)
			y += MG_ScaleToDPI(this.opt._arrowCursorOffset)
			if (x!=this._arrowPrevX || y!=this._arrowPrevY) {
				newDPI := MG_GetDpiFromPoint(x, y)
				if (newDPI != MG_ScreenDPI) {
					MG_ScreenDPI := newDPI
					bDpiChanged := true
				}
			}
		}

		if ((arrowString != this._prevArrows) || bDpiChanged) {
			; Draw arrows
			if (!MG_IsVisible(this._arrowWnd)) {
				this._arrowWnd.Show("NA")
			}
		 	colorRefArrows := this._arrowUseDynamicColor ? this._arrowDynamicColorRef : this._arrowColorRef
			colorRefBg := this._arrowUseDynamicBgColor ? this._arrowDynamicBgColorRef : this._arrowBgColorRef
			hDC := DllCall("GetWindowDC", "Ptr",this._arrowWnd.Hwnd, "Ptr")
			hFont := MG_CreateFont("Wingdings", this.opt._arrowSize)
			hFontOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",hFont, "Ptr")
			DllCall("SetTextColor", "Ptr",hDC, "UInt",colorRefArrows)
			DllCall("SetBkColor", "Ptr",hDC, "UInt",colorRefBg)
			if (this.opt._hintType == 2) {
				this._DrawArrowsType1(hDC, arrowString, x, y, colorRefBg)
			} else if (this.opt._hintType == 3) {
				this._DrawArrowsType2(hDC, arrowString, x, y, colorRefBg)
			}
			DllCall("SelectObject", "Ptr",hDC, "Ptr",hFontOld)
			DllCall("DeleteObject", "Ptr",hFont)
			DllCall("ReleaseDC", "Ptr",this._arrowWnd.Hwnd, "Ptr",hDC)
		}
		else if (x!=this._arrowPrevX || y!=this._arrowPrevY) {
			; Move window only
			this._arrowWnd.Move(x, y)
		}
		this._arrowPrevX := x
		this._arrowPrevY := y
		this._prevArrows := arrowString
	}

	_MakeArrowsString(gestureSequence)
	{
		gestureStrokes := RegExReplace(gestureSequence, this.opt._triggersRegEx "_")
		gestureStrokes := StrReplace(gestureStrokes, "_")
		if (StrLen(gestureStrokes) == 0) {
			return
		}
		prevDir := 0
		arrowString := ""
		this._arrowType2Pos := []
		Loop Parse, gestureStrokes {
			arrowString .= Chr(this._arrowCharMap[A_LoopField])
			if (this.opt._hintType == 3) {
				dir := A_LoopField
				switch (dir) {
					case "L":	dir := 4
					case "R":	dir := 6
					case "U":	dir := 8
					case "D":	dir := 2
				}
				dir += 0
				posCode := (prevDir > 0) ? this._arrowNextPos[prevDir][dir] : 0
				this._arrowType2Pos.Push(posCode)
				prevDir := dir
			}
		}
		return arrowString
	}

	_DrawArrowsType1(hDC, arrowString, x, y, colorRefBg)
	{
		pad := MG_ScaleToDPI(this.opt._arrowPadding)
		DllCall("SetTextCharacterExtra", "Ptr",hDC, "Int",MG_ScaleToDPI(this.opt._arrowSpacing))
		size := Buffer(8, 0)					; struct SIZE
		DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",arrowString, "Int",StrLen(arrowString), "Ptr",size.Ptr)
		w := NumGet(size, 0, "UInt") + pad*2	; SIZE.cx + padding
		h := NumGet(size, 4, "UInt") + pad*2	; SIZE.cy + padding
		if (w && h) {
			this._arrowWnd.Move(x, y, w, h)
			this._EraseArrows(hDC, colorRefBg)
			DllCall("TextOut", "Ptr",hDC, "Int",pad, "Int",pad, "Str",arrowString, "Int",StrLen(arrowString))
		}
	}

	_DrawArrowsType2(hDC, arrowString, winX, winY, colorRefBg)
	{
		size := Buffer(8, 0)			; struct SIZE
		oneArrow := SubStr(arrowString, 1, 1)
		DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",oneArrow, "Int",1, "Ptr",size.Ptr)
		w := NumGet(size, 0, "UInt")	; SIZE.cx
		h := NumGet(size, 4, "UInt")	; SIZE.cy
		fullOfs := (w > h) ? w : h
		fullOfs += MG_ScaleToDPI(this.opt._arrowSpacing)
		halfOfs := Round(fullOfs / 2)

		drawPos := []
		maxX := maxY := minX := minY := 0
		Loop Parse, arrowString {
			x := y := 0
			if (A_Index > 1) {
				prev := drawPos[A_Index-1]
				switch (this._arrowType2Pos[A_Index]) {
				  case  1:	x := prev.x - fullOfs	,	y := prev.y + fullOfs
				  case  2:	x := prev.x				,	y := prev.y + fullOfs
				  case  3:	x := prev.x + fullOfs	,	y := prev.y + fullOfs
				  case  4:	x := prev.x - fullOfs	,	y := prev.y
				  case  6:	x := prev.x + fullOfs	,	y := prev.y
				  case  7:	x := prev.x - fullOfs	,	y := prev.y - fullOfs
				  case  8:	x := prev.x				,	y := prev.y - fullOfs
				  case  9:	x := prev.x + fullOfs	,	y := prev.y - fullOfs
				  case 10:	x := prev.x - halfOfs	,	y := prev.y + fullOfs
				  case 11:	x := prev.x + halfOfs	,	y := prev.y + fullOfs
				  case 12:	x := prev.x - fullOfs	,	y := prev.y + halfOfs
				  case 13:	x := prev.x + fullOfs	,	y := prev.y + halfOfs
				  case 14:	x := prev.x - fullOfs	,	y := prev.y - halfOfs
				  case 15:	x := prev.x + fullOfs	,	y := prev.y - halfOfs
				  case 16:	x := prev.x - halfOfs	,	y := prev.y - fullOfs
				  case 17:	x := prev.x + halfOfs	,	y := prev.y - fullOfs
				}
			}
			drawPos.Push({ x:x, y:y })

			maxX := (x > maxX) ? x : maxX
			maxY := (y > maxY) ? y : maxY
			minX := (x < minX) ? x : minX
			minY := (y < minY) ? y : minY
		}
		winW := maxX - minX + fullOfs - MG_ScaleToDPI(this.opt._arrowSpacing)
		winH := maxY - minY + fullOfs - MG_ScaleToDPI(this.opt._arrowSpacing)
		if (winW>0 && winH>0) {
			this._arrowWnd.Move(winX, winY, winW, winH)
			this._EraseArrows(hDC, colorRefBg)
			Loop Parse, arrowString {
				x := drawPos[A_Index].x - minX
				y := drawPos[A_Index].y - minY
				DllCall("TextOut", "Ptr",hDC, "Int",x, "Int",y, "Str",A_LoopField, "Int",1)
			}
		}
	}

	_EraseArrows(hDC, colorRefBg)
	{
		WinGetPos(, , &w, &h, this._arrowWnd)
		rc := Buffer(16, 0)			; struct RECT
		NumPut("UInt", w, rc, 8)	; RECT.right
		NumPut("UInt", h, rc, 12)	; RECT.bottom
		hBrush := DllCall("CreateSolidBrush", "UInt",colorRefBg, "Ptr")
		DllCall("FillRect", "Ptr",hDC, "Ptr",rc.Ptr, "Ptr",hBrush)
		DllCall("DeleteObject", "Ptr",hBrush)
	}
}

MG_HintClassEnd:
