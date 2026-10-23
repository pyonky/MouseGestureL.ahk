;===============================================================================
;
;		MouseGestureL.ahk
;		  - Activation function of the previously active windows -
;
;															Created by Pyonkichi
;===============================================================================
Goto("MG_WinActivateEnd")

;-------------------------------------------------------------------------------
; Initialization
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_InitPrevWinActivate() {
	global
	MG_PrevWinActivate := PrevWinActivateClass(MG_ExcActivate)
}

;-------------------------------------------------------------------------------
; Activate previously active window
;
;	timeout		: Timeout for subsequent calls (ms)
;	bRestoreMin : true  - Restore the minimized window
;				  false - Ignore the minimized window
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ActivatePrevWin(timeout:=0, bRestoreMin:=true) {
	Try MG_PrevWinActivate.Activate(timeout, bRestoreMin)
}

;-------------------------------------------------------------------------------
; Core class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class PrevWinActivateClass
{
	__New(excluded)
	{
		this._excludedWindows := excluded
		this._index := 0
		this._timeout := 0
		this._bRestoreMinWnd := false
		this._bInEventProc := false
		this._bInActivation := false
		this._eventQueue := []
		this._activeHistory := []
		this._historySnapshot := ""

		this._fnActivation := this._Activation.Bind(this)
		this._fnCheckNextQueue := this._CheckNextQueue.Bind(this)
		this._fnDeleteSnapshot := this._DeleteSnapshot.Bind(this)

		this._FillActiveHistoryBuffer()
		fn := CallbackCreate(this._WinEventProc.Bind(this), "Fast", 7)
		this._hHook := DllCall("SetWinEventHook", "UInt",0x0003, "UInt",0x0003
												, "Ptr",0, "Ptr",fn, "UInt",0
												, "UInt",0, "UInt",3, "Ptr")
		this._StoreActiveWindowHandle(WinGetID("A"))
	}

	Dispose()
	{
		if (this._hHook) {
			DllCall("UnhookWinEvent", "Ptr",this._hHook)
			this._hHook := 0
		}

		SetTimer(this._fnActivation, 0)
		this._fnActivation := ""

		SetTimer(this._fnCheckNextQueue, 0)
		this._fnCheckNextQueue := ""

		SetTimer(this._fnDeleteSnapshot, 0)
		this._fnDeleteSnapshot := ""
	}

	Activate(timeout:=0, bRestoreMin:=true)
	{
		if (this._activeHistory.Length == 0) {
			return
		}
		this._timeout := (timeout<=0) ? 1 : timeout
		this._bRestoreMinWnd := bRestoreMin
		if (timeout <= 0) {
			this._DeleteSnapshot()
		}
		SetTimer(this._fnActivation, -1)
	}

	Activating {
		get {
			return (this._index > 0)
		}
	}

	_WinEventProc(hWinEventHook, iEvent, hWnd, idObject, idChild, dwEventThread, dwmsEventTime)
	{
		if (iEvent==0x0003 && idObject==0 && idChild==0) {
			;Critical(-1)
			if (this._bInEventProc) {
				this._eventQueue.Push(hWnd)
				return
			}
			this._bInEventProc := true
			;Critical("Off")

			this._StoreActiveWindowHandle(hWnd)
		}
	}

	_StoreActiveWindowHandle(hWnd)
	{
		if (this._IsActivationTarget(hWnd, true)) {
			idx := max := this._activeHistory.Length
			Loop max {
				if ((this._activeHistory[idx] == hWnd)
				||	!WinExist(this._activeHistory[idx]))
				{
					this._activeHistory.RemoveAt(idx)
				}
				idx--
			}
			this._activeHistory.Push(hWnd)
		}
		SetTimer(this._fnCheckNextQueue, -1)
	}

	_CheckNextQueue()
	{
		hWnd := 0
		Critical(-1)
		if (this._eventQueue.Length > 0) {
			hWnd := this._eventQueue.RemoveAt(1)
		} else {
			this._bInEventProc := false
		}
		Critical("Off")

		if (hWnd != 0) {
			this._StoreActiveWindowHandle(hWnd)
		}
	}

	_Activation()
	{
		tmStart := A_TickCount
		while (1) {
			Critical(-1)
			if (!this._bInEventProc) {
				this._bInActivation := true
				if (this._index <= 0) {
					this._historySnapshot := this._activeHistory.Clone()
					this._index := this._historySnapshot.Length
				}
				break
			}
			Critical("Off")
			Sleep(20)
			if ((A_TickCount-tmStart) > 300) {
				return
			}
		}
		Critical("Off")
		if (!IsObject(this._historySnapshot)) {
			this._bInActivation := false
			return
		}

		prevMode := DetectHiddenWindows(true)
		hwActive := WinGetID("A")
		Loop this._historySnapshot.Length {
			hwPrev := this._historySnapshot[this._index]
			if (WinExist(hwPrev)) {
				dwStyle := WinGetStyle(hwPrev)
				bMin := (dwStyle & 0x20000000) ? true : false
				hwTApp := this._IsDelphiMinWnd(hwPrev)
				if (this._bRestoreMinWnd) {
					bActivate := (hwActive!=hwPrev || bMin) ? true : false
				} else {
					bActivate := (hwActive!=hwPrev && !bMin && !hwTApp) ? true : false
				}
				if (bActivate) {
					if (hwTApp || this._IsActivationTarget(hwPrev)) {
						WinActivate(hwPrev)
						if (hwTApp) {
							; Restore minimized Delphi application window
							WinRestore(hwTApp)
						}
						break
					}
				}
			}
			if (--this._index < 1) {
				this._index := this._historySnapshot.Length
			}
		}
		DetectHiddenWindows(prevMode)
		this._bInActivation := false
		SetTimer(this._fnDeleteSnapshot, -this._timeout)
	}

	_DeleteSnapshot()
	{
		if (!this._bInActivation) {
			this._index := 0
			this._historySnapshot := ""
		}
	}

	_IsActivationTarget(hWnd, bIncHidden:=false)
	{
		if (!WinExist(hWnd)) {
			return false
		}
		dwStyle := WinGetStyle(hWnd)
		dwExStyle := WinGetExStyle(hWnd)
		if ((!bIncHidden && !(dwStyle & 0x10000000))					; not WS_VISIBLE
		||	(dwStyle & 0x08000000) || (dwExStyle & 0x00000080)			; or WS_DISABLED or WS_EX_TOOLWINDOW
		||	((dwStyle & 0x80000000) && !(dwStyle & 0x20C80000))) {		; or (WS_POPUP and not WS_MINIMIZE and not WS_CAPTION and not WS_SYSMENU)
			return false
		}
		wndClass := WinGetClass(hWnd)
		if (wndClass = "TApplication") {
			return false
		}
		if (IsObject(this._excludedWindows)) {
			for idx, wnd in this._excludedWindows {
				wndTitle := wnd.title
				wndTitle .= wnd.class!="" ? " ahk_class " wnd.class : ""
				wndTitle .= wnd.exe!="" ? " ahk_exe " wnd.exe : ""
				if (hWnd = WinExist(wndTitle)) {
					return false
				}
			}
		}
		return true
	}

	_IsDelphiMinWnd(hWnd)
	{
		dwStyle := WinGetStyle(hWnd)
		if (!(dwStyle & 0x10000000)) {			; not WS_VISIBLE
			pid := WinGetPid(hWnd)
			hwTApp := WinExist("ahk_class TApplication ahk_pid " pid)
			if (hwTApp && (hwTApp!=hWnd)) {
				dwStyle := WinGetStyle(hwTApp)
				if (dwStyle & 0x20000000) {		; WS_MINIMIZE
					return hwTApp
				}
			}
		}
		return 0
	}

	_FillActiveHistoryBuffer()
	{
		prevMode := A_DetectHiddenWindows

		Loop 2 {
			phase := A_Index
			DetectHiddenWindows(phase==1 ? false : true)
			hWnds := WinGetList()
			for hWnd in hWnds {
				if (phase == 1) {
					WinGetPos(, , &w, &h, hWnd)
					bTarget := (this._IsActivationTarget(hWnd) && w!=0 && h!=0)
				} else {
					bTarget := this._IsDelphiMinWnd(hWnd)
				}
				if (bTarget) {
					bExist := false
					for hwPrev in this._activeHistory {
						if (hwPrev == hWnd) {
							bExist := true
							break
						}
					}
					if (!bExist) {
						this._activeHistory.Push(hWnd)
					}
				}
			}
		}
		DetectHiddenWindows(prevMode)
	}
}

MG_WinActivateEnd:
