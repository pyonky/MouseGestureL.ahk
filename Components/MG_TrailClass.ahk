;===============================================================================
;
;		MouseGestureL.ahk - Gesture Trail Class / Gesture Log Class
;
;															Created by Pyonkichi
;===============================================================================
Goto("MG_TrailClassEnd")

;-------------------------------------------------------------------------------
;
;	Gesture Trail Class
;
class TrailSettings
{
	__New()
	{
		this._bEnable			:= MG_ShowTrail
		this._bOverlayWindow	:= MG_DrawTrailWnd
		this._lineColor			:= MG_TrailColor
		this._lineWidth			:= MG_TrailWidth
		this._lineTransparency	:= MG_TrailTranspcy
		this._startDistance		:= MG_TrailStartMove
	}
}

class GestureTrailClass extends GestureDisplayBase
{
	__New()
	{
		this.opt := TrailSettings()

		this._bDrawing		:= false			; MG_TrailDrawing
		this._bDrawn		:= false			; MG_TrailDrawn
		this._bPaused		:= false
		this._trailWnd		:= ""				; MGW_Trail
		this._lineColorRef	:= 0				; MG_TrailColor2
		this._transColor	:= ""				; MG_TrailTransClr
		this._transColorRef	:= 0				; MG_TrailTransClr2
		this._startX		:= 0				; MG_X
		this._startY		:= 0				; MG_Y
		this._prevX			:= 0				; MG_TX
		this._prevY			:= 0				; MG_TY
		this._rcTrail		:= MG_Rect()		; MG_TL, MG_TR, MG_TT, MG_TB

		if (this.opt._bEnable) {
			this._Initialize()
		}
	}

	_Initialize()
	{
		this._bDrawn := false
		this._lineColorRef := this._MakeColorRef(this.opt._lineColor)
		this._transColor := this._MakeTransColorStr(this.opt._lineColor)
		this._transColorRef := this._MakeColorRef(this._transColor)
		if (!this.opt._bOverlayWindow) {
			return
		}
		x := SysGet(76)+1, y := SysGet(77)+1, w := SysGet(78)-1, h := SysGet(79)-1
		this._trailWnd := Gui("-Caption +ToolWindow +E0x08000020", "MouseGestureL.ahk Gesture Trai")
		this._trailWnd.BackColor := this._transColor
		transparency := ""
		if (this.opt._lineTransparency>0 && this.opt._lineTransparency<255) {
			transparency := " " this.opt._lineTransparency
		}
		opt := this._transColor . transparency
		WinSetTransColor(opt, this._trailWnd)
		this._trailWnd.Show("x" x " y" y " w" w " h" h " NA")
		WinMoveBottom(this._trailWnd)
	}

	ShowWindow() {
		if (this._trailWnd) {
			this._trailWnd.Show("NA")
			WinMoveBottom(this._trailWnd)
		}
	}

	HideWindow() {
		if (this._trailWnd) {
			this._trailWnd.Hide()
		}
	}

	IsTrailWindow(hWnd) {
		return (this._trailWnd && hWnd==this._trailWnd.Hwnd)
	}

	Reset(x, y)
	{
		if (this.opt._bEnable) {
			this._startX := this._prevX := x
			this._startY := this._prevY := y
			this._rcTrail.left := this._rcTrail.right := x
			this._rcTrail.top := this._rcTrail.bottom := y
			this._bPaused := false
		}
	}

	Draw()
	{
		if (!this.opt._bEnable || this._bDrawing || this._bPaused) {
			return
		}
		this._bDrawing := true

		; Check the cursor movement
		CoordMode("Mouse", "Screen")
		MouseGetPos(&nowX, &nowY)
		if (!this._bDrawn) {
			if ((this._startX-nowX)**2+(this._startY-nowY)**2 < this.opt._startDistance**2) {
				this._bDrawing := false
				return
			} else {
				this._bDrawn := true
				if (this._trailWnd) {
					this._trailWnd.Opt("+AlwaysOnTop")
				}
			}
		}
		x1 := this._prevX
		y1 := this._prevY
		x2 := nowX
		y2 := nowY
		if (this._trailWnd) {
			this._trailWnd.GetPos(&winX, &winY)
			x1-=winX, x2-=winX, y1-=winY, y2-=winY
		}
		hWnd := this._trailWnd ? this._trailWnd.Hwnd : 0
		hDC := DllCall("GetWindowDC", "Ptr",hWnd, "Ptr")
		hPen := DllCall("CreatePen", "Int",0, "Int",MG_ScaleToDPI(this.opt._lineWidth), "UInt",this._lineColorRef, "Ptr")
		hPenOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",hPen, "Ptr")
		DllCall("MoveToEx", "Ptr",hDC, "Int",x1, "Int",y1, "Ptr",0)
		DllCall("LineTo", "Ptr",hDC, "Int",x2, "Int",y2)
		DllCall("SelectObject", "Ptr",hDC, "Ptr",hPenOld)
		DllCall("DeleteObject", "Ptr",hPen)
		DllCall("ReleaseDC", "Ptr",hWnd, "Ptr",hDC)
		this._prevX := nowX
		this._prevY := nowY

		; Update bounding rectangle of Gesture Trail
		if (this._rcTrail.left > nowX) {
			this._rcTrail.left := nowX
		}
		if (this._rcTrail.right < nowX) {
			this._rcTrail.right := nowX
		}
		if (this._rcTrail.top > nowY) {
			this._rcTrail.top := nowY
		}
		if (this._rcTrail.bottom < nowY) {
			this._rcTrail.bottom := nowY
		}
		this._bDrawing := false
	}

	Erase()
	{
		if (!this.opt._bEnable || !this._bDrawn) {
			return
		}
		this._bDrawn := false

		; Set bounding rectangle of the gesture trail
		l := this._rcTrail.left - MG_ScaleToDPI(this.opt._lineWidth)-1
		t := this._rcTrail.top - MG_ScaleToDPI(this.opt._lineWidth)-1
		r := this._rcTrail.right + MG_ScaleToDPI(this.opt._lineWidth)+1
		b := this._rcTrail.bottom + MG_ScaleToDPI(this.opt._lineWidth)+1
		if (this._trailWnd) {
			this._trailWnd.GetPos(&winX, &winY)
			l-=winX, t-=winY, r-=winX, b-=winY
		}
		rc := Buffer(16, 0)									; struct RECT
		NumPut("UInt",l, "UInt",t, "UInt",r, "UInt",b, rc)	; rc.left, rc.top, rc.right, rc.bottom

		if (this._trailWnd) {
			; Clear the overlay window
			hDC := DllCall("GetWindowDC", "Ptr",this._trailWnd.Hwnd, "Ptr")
			hBrush := DllCall("CreateSolidBrush", "UInt",this._transColorRef, "Ptr")
			DllCall("FillRect", "Ptr",hDC, "Ptr",rc.Ptr, "Ptr",hBrush)
			DllCall("DeleteObject", "Ptr",hBrush)
			DllCall("ReleaseDC", "Ptr",this._trailWnd.Hwnd, "Ptr",hDC)
			this._trailWnd.Opt("-AlwaysOnTop")
			WinMoveBottom(this._trailWnd)
		}
		else {
			; Redraw the screen
			DllCall("RedrawWindow", "Ptr",0, "Ptr",rc.Ptr, "Ptr",0, "Ptr",0x0587)
			; RDW_INVALIDATE | RDW_INTERNALPAINT | RDW_ERASE | RDW_ALLCHILDREN | RDW_UPDATENOW | RDW_FRAME
		}
	}

	Pause() {
		this._bPaused := true
		this.Erase()
	}

	Resume() {
		this._bPaused := false
	}
}


;-------------------------------------------------------------------------------
;
;	Gesture Log Class
;
class LogSettings
{
	__New()
	{
		this._gestureMap		:= MG_GestureMap
		this._bEnable			:= MG_ShowLog
		this._position			:= MG_LogPosition
		this._xCoordinate		:= MG_LogPosX
		this._yCoordinate		:= MG_LogPosY
		this._maxHistory		:= MG_LogMax
		this._displayWidth		:= MG_LogSizeW
		this._textColor			:= MG_LogFG
		this._bgColor			:= MG_LogBG
		this._transparency		:= MG_LogTranspcy
		this._fontFace			:= MG_LogFont
		this._textSize			:= MG_LogFontSize
	}
}

class GestureLogClass extends GestureDisplayBase
{
	__New()
	{
		this.opt := LogSettings()

		this._logs				:= []		; MG_Log
		this._prevGesture		:= ""		; MG_PrevGesture
		this._prevTime			:= 0		; MG_PrevTime
		this._logText			:= ""		; MG_EGestureLog
		this._bStart			:= false
		if (this.opt._bEnable) {
			this._Initialize()
		}
	}

	_Initialize()
	{
		wndTitle := "MouseGestureL.ahk Gesture Log "
		bgWnd := Gui("-Caption +ToolWindow +E0x08000020", wndTitle "BG")
		bgWnd.BackColor := this.opt._bgColor
		WinSetTransparent(this.opt._transparency, bgWnd)

		fgWnd := Gui("-Caption +ToolWindow +E0x08000020 +Owner" bgWnd.Hwnd, wndTitle "FG")
		fgWnd.MarginX := 10, fgWnd.MarginY := 0
		fgWnd.SetFont("s" this.opt._textSize, this.opt._fontFace)
		fgWnd.BackColor := this._MakeTransColorStr(this.opt._textColor)
		WinSetTransColor(fgWnd.BackColor, fgWnd)
		this._logText := fgWnd.Add("Text", "Wrap +0x00000080 -E0x00000200 y10"
													. " w" this.opt._displayWidth
													. " r" this.opt._maxHistory
													. " c" this.opt._textColor)
		fgWnd.Show("AutoSize Hide")
		fgWnd.GetPos( , , &w, &h)
		MonitorGetWorkArea( , , , &waRight, &waBottom)
		switch (this.opt._position) {
		  case 1:	x := 0			, y := 0
		  case 2:	x := waRight-w	, y := 0
		  case 3:	x := 0			, y := waBottom-h
		  case 4:	x := waRight-w	, y := waBottom-h
		  default:	x := this.opt._xCoordinate ,	y := this.opt._yCoordinate
		}
		bgWnd.Show("x" x " y" y " w" w " h" h " NA")
		fgWnd.Show("x" x " y" y " NA")
		WinMoveBottom(bgWnd)
	}

	Reset() {
		if (this.opt._bEnable) {
			this._prevGesture := ""
			this._prevTime := A_TickCount
			this._bStart := true
		}
	}

	ClearPrevGesture() {
		if (this.opt._bEnable) {
			this._prevGesture := ""
		}
	}

	ResetPrevTime() {
		if (this.opt._bEnable) {
			this._prevTime := A_TickCount
		}
	}

	Update(definedGesture:="")
	{
		if (!this.opt._bEnable) {
			return
		}
		currentGesture := MG.CurrentGesture
		if (currentGesture != this._prevGesture) {
			if (this._logs.Length >= this.opt._maxHistory) {
				this._logs.RemoveAt(1)
			}

			actionTitle := ""
			if (definedGesture) {
				actionFunc := this.opt._gestureMap.Has(definedGesture)
							? this.opt._gestureMap[definedGesture] : ""
				if (actionFunc) {
					actionTitle := actionFunc(false)
				}
			}
			deltaInfo := ""
			if (currentGesture && !this._bStart) {
				deltaInfo := Format("{:5d}ms  dx: {:-4d} dy: {:-4d}"
									, A_TickCount - this._prevTime
									, MG.NowX-MG.PrevX, MG.NowY-MG.PrevY)
			} else {
				deltaInfo := Format("{:-26}", this._bStart ? "<Start>" : "< End >")
			}
			this._bStart := false
			log := Format("{:}  {:-10} {:}"
							, deltaInfo, currentGesture, actionTitle)

			this._logs.Push(log)
			this._prevGesture := currentGesture
			logs := ""
			for idx, log in this._logs {
				Join(&logs, log)
			}
			this._logText.Value := logs
		}
	}

	CopyToClipboard() {
		if (this._logText) {
			A_Clipboard := this._logText.Value
		}
	}
}

MG_TrailClassEnd:
