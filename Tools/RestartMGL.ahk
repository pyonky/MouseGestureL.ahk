;===============================================================================
;
;		Restart MouseGestureL.ahk externally
;															Created by Pyonkichi
;===============================================================================
#Requires Autohotkey v2.0
#include "%A_ScriptDir%\KillMGL.ahk"
Sleep(500)
RestartMGL((A_Args.Length >= 1) ? A_Args[1] : "")
return

RestartMGL(folderPath:="")
{
	DetectHiddenWindows(true)
	if (!WinExist(KM_WinTitle)) {
		if (InStr(FileExist(folderPath), "D")==0) {
			folderPath := ".."
		}
		path := folderPath "\MouseGestureL.ahk"
		if (FileExist(path)) {
			Run(path)
		}
	}
}

