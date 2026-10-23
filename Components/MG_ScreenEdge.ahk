;===============================================================================
;
;		MouseGestureL.ahk - Screen Edge Recognition Module
;
;														   Created by lukewarm
;														   Modified by Pyonkichi
;===============================================================================
Goto("MG_ScrenEdge_End")

class ScrenEdgeClass
{
	__New()
	{
		this._monitoringInterval	:= MG_EdgeInterval
		this._bEachDisplay			:= MG_EdgeIndiv
		this._cornerRangeX			:= (MG_CornerX > 0) ? MG_CornerX : 1
		this._cornerRangeY			:= (MG_CornerY > 0) ? MG_CornerY : 1
		this._activeEdge			:= ""
		this._releasedEdge			:= ""
		this._fnMonitoringThread	:= this._MonitoringThread.Bind(this)
	}

	Dispose() {
		SetTimer(this._fnMonitoringThread, 0)
		this._fnMonitoringThread := ""
	}

	Start() {
		this._activeEdge := ""
		SetTimer(this._fnMonitoringThread, this._monitoringInterval)
	}

	Stop() {
		SetTimer(this._fnMonitoringThread, 0)
		if (this._activeEdge != "") {
			MG.TriggerUp(this._activeEdge)
			this._activeEdge := ""
		}
	}

	_MonitoringThread()
	{
		CoordMode("Mouse", "Screen")
		MouseGetPos(&x, &y)

		; Get screen rectangule
		if (this._bEachDisplay) {
			rc := MG_Rect()
			MG_GetMonitorRect(x, y, rc)
			scrL := rc.left
			scrT := rc.top
			scrR := rc.right
			scrB := rc.bottom
			scrW := scrR - scrL
			scrH := scrB - scrT
			scrR--, scrB--
		}
		else {
			scrL := SysGet(76)
			scrT := SysGet(77)
			scrW := SysGet(78)
			scrH := SysGet(79)
			scrR := scrL + scrW - 1
			scrB := scrT + scrH - 1
		}
		edgeName := ""

		; Left
		if (x == scrL) {
			if (this._bEachDisplay && this._MonitorExists(x-1, y)) {
				; There is another monitor on the left side
			}
			else if (MG.TriggerEnabled("CLT") && y>=scrT && y<(scrT+this._cornerRangeY))
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrL, scrT-1)) {
					edgeName := "CLT"
				}
			}
			else if (MG.TriggerEnabled("CLB") && y>(scrB-this._cornerRangeY) && y<=scrB)
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrL, scrB+1)) {
					edgeName := "CLB"
				}
			}
			else if (MG.TriggerEnabled("EL1") && y<(scrT+scrH/3)) {
				edgeName := "EL1"
			}
			else if (MG.TriggerEnabled("EL2") && y>=(scrT+scrH/3) && y<(scrT+scrH*2/3)) {
				edgeName := "EL2"
			}
			else if (MG.TriggerEnabled("EL3") && y>=(scrT+scrH*2/3)) {
				edgeName := "EL3"
			}
			else if (MG.TriggerEnabled("ELA") && y<(scrT+scrH/2)) {
				edgeName := "ELA"
			}
			else if (MG.TriggerEnabled("ELB") && y>=(scrT+scrH/2)) {
				edgeName := "ELB"
			}
			else if (MG.TriggerEnabled("EL")) {
				edgeName := "EL"
			}
		}
		; Right
		else if (x == scrR) {
			if (this._bEachDisplay && this._MonitorExists(x+1, y)) {
				; There is another monitor on the right side
			}
			else if (MG.TriggerEnabled("CRT") && y>=scrT && y<(scrT+this._cornerRangeY))
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrR, scrT-1)) {
					edgeName := "CRT"
				}
			}
			else if (MG.TriggerEnabled("CRB") && y>(scrB-this._cornerRangeY) && y<=scrB)
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrR, scrB+1)) {
					edgeName := "CRB"
				}
			}
			else if (MG.TriggerEnabled("ER1") && y<(scrT+scrH/3)) {
				edgeName := "ER1"
			}
			else if (MG.TriggerEnabled("ER2") && y>=(scrT+scrH/3) && y<(scrT+scrH*2/3)) {
				edgeName := "ER2"
			}
			else if (MG.TriggerEnabled("ER3") && y>=(scrT+scrH*2/3)) {
				edgeName := "ER3"
			}
			else if (MG.TriggerEnabled("ERA") && y<(scrT+scrH/2)) {
				edgeName := "ERA"
			}
			else if (MG.TriggerEnabled("ERB") && y>=(scrT+scrH/2)) {
				edgeName := "ERB"
			}
			else if (MG.TriggerEnabled("ER")) {
				edgeName := "ER"
			}
		}
		; Top
		else if (y == scrT) {
			if (this._bEachDisplay && this._MonitorExists(x, y-1)) {
				; There is another monitor above
			}
			else if (MG.TriggerEnabled("CLT") && x>=scrL && x<(scrL+this._cornerRangeX))
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrL-1, scrT)) {
					edgeName := "CLT"
				}
			}
			else if (MG.TriggerEnabled("CRT") && x>(scrR-this._cornerRangeX) && x<=scrR)
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrR+1, scrT)) {
					edgeName := "CRT"
				}
			}
			else if (MG.TriggerEnabled("ET1") && x<(scrL+scrW/3)) {
				edgeName := "ET1"
			}
			else if (MG.TriggerEnabled("ET2") && x>=(scrL+scrW/3) && x<(scrL+scrW*2/3)) {
				edgeName := "ET2"
			}
			else if (MG.TriggerEnabled("ET3") && x>=(scrL+scrW*2/3)) {
				edgeName := "ET3"
			}
			else if (MG.TriggerEnabled("ETA") && x<(scrL+scrW/2)) {
				edgeName := "ETA"
			}
			else if (MG.TriggerEnabled("ETB") && x>=(scrL+scrW/2)) {
				edgeName := "ETB"
			}
			else if (MG.TriggerEnabled("ET")) {
				edgeName := "ET"
			}
		}
		; Bottom
		else if (y == scrB) {
			if (this._bEachDisplay && this._MonitorExists(x, y+1)) {
				; There is another monitor at the bottom
			}
			else if (MG.TriggerEnabled("CLB") && x>=scrL && x<(scrL+this._cornerRangeX))
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrL-1, scrB)) {
					edgeName := "CLB"
				}
			}
			else if (MG.TriggerEnabled("CRB") && x>(scrR-this._cornerRangeX) && x<=scrR)
			{
				if (!this._bEachDisplay || !this._MonitorExists(scrR+1, scrB)) {
					edgeName := "CRB"
				}
			}
			else if (MG.TriggerEnabled("EB1") && x<(scrL+scrW/3)) {
				edgeName := "EB1"
			}
			else if (MG.TriggerEnabled("EB2") && x>=(scrL+scrW/3) && x<(scrL+scrW*2/3)) {
				edgeName := "EB2"
			}
			else if (MG.TriggerEnabled("EB3") && x>=(scrL+scrW*2/3)) {
				edgeName := "EB3"
			}
			else if (MG.TriggerEnabled("EBA") && x<(scrL+scrW/2)) {
				edgeName := "EBA"
			}
			else if (MG.TriggerEnabled("EBB") && x>=(scrL+scrW/2)) {
				edgeName := "EBB"
			}
			else if (MG.TriggerEnabled("EB")) {
				edgeName := "EB"
			}
		}
		; Non-edge
		else {
			if (this._activeEdge != "") {
				this._releasedEdge := this._activeEdge
				this._activeEdge := ""
				SetTimer(this._TriggerUpThread.Bind(this), -1)
			}
			edgeName := ""
		}

		; Process trigger-down actions
		if (this._activeEdge=="" && edgeName!="") {
			this._activeEdge := edgeName
			SetTimer(this._TriggerDownThread.Bind(this), -1)
		}
	}

	_MonitorExists(x, y) {
		pt := (y<<32) | (x & 0xffffffff)
		return DllCall("user32.dll\MonitorFromPoint", "UInt64",pt, "UInt",0, "Ptr")
	}

	_TriggerDownThread() {
		MG.TriggerDown(this._activeEdge)
	}

	_TriggerUpThread() {
		MG.TriggerUp(this._releasedEdge)
	}


}

MG_ScrenEdge_End:
