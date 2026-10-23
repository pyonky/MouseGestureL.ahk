;===============================================================================
;
;		Terminate MouseGestureL.ahk externally
;															Created by Pyonkichi
;===============================================================================
#Requires Autohotkey v2.0
KM_Timeout	:= 3000
KM_WinTitle	:= "MouseGestureL.ahk Main Window ahk_class AutoHotkeyGUI"
KillMGL()
Goto("KM_End")

KillMGL()
{
	DetectHiddenWindows(true)
	if (hWnd := WinExist(KM_WinTitle)) {
		tmStart := A_TickCount
		WinClose(hWnd)
		while (hWnd := WinExist(KM_WinTitle)) {
			Sleep(100)
			if ((A_TickCount-tmStart) > KM_Timeout) {
				if (pid := WinGetPID(hWnd)) {
					ProcessClose(pid)
				}
				break
			}
		}
	}
}

KM_End:
