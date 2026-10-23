;===============================================================================
;
;		MG_Edit.ahk - Configuration Management Module
;
;															Created by Pyonkichi
;===============================================================================
ME_InitConfigGlobals()
Goto("ME_ConfigEnd")

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Classes
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Target information class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class TargetInfoClass
{
	__New(nameTarget:="")
	{
		this._name			:= nameTarget
		this._bMatchAll		:= false
		this._bExcDefAction	:= false
		this._bNotInherit	:= false
		this._iconFile		:= ""
		this._iconIndex		:= 1
		this._idxIL			:= 0
		this._conditions	:= []
		this._children		:= []
		this._parent		:= ""
	}

	Name {
		set {
			this._name := value
		}
		get {
			return this._name
		}
	}

	MatchAll {
		set {
			this._bMatchAll := value
		}
		get {
			return this._bMatchAll
		}
	}

	DefActionDisabled {
		set {
			this._bExcDefAction := value
		}
		get {
			return this._bExcDefAction
		}
	}

	NoInheritance {
		set {
			this._bNotInherit := value
		}
		get {
			return this._bNotInherit
		}
	}

	IconFileAndIndex {
		set {
			if (RegExMatch(value, "^(.+?)\s*,\s*(.*?)$", &part)) {
				this._iconFile	:= part[1]
				this._iconIndex	:= part[2]!="" ? part[2] : 1
			} else {
				this._iconFile	:= value
				this._iconIndex	:= 1
			}
		}
		get {
			if (this._iconFile != "") {
				return this._iconFile "," this._iconIndex
			}
			return ""
		}
	}

	IconFile {
		get {
			return this._iconFile
		}
	}

	IconIndex {
		get {
			return this._iconIndex
		}
	}

	ImageListIndex {
		set {
			this._idxIL := value
		}
		get {
			return this._idxIL
		}
	}

	AddCondition(targetType, targetValue) {
		if (IsObject(this._conditions)) {
			this._conditions.Push({type: targetType, value: targetValue})
		}
	}

	DeleteCondition(idx) {
		if (IsObject(this._conditions) && (idx <= this._conditions.Length)) {
			this._conditions.RemoveAt(idx)
		}
	}

	UpdateCondition(idx, targetType, targetValue) {
		if (IsObject(this._conditions) && (idx <= this._conditions.Length)) {
			this._conditions[idx].type	:= targetType
			this._conditions[idx].value := targetValue
		}
	}

	GetConditions() {
		return this._conditions
	}

	ConditionsNum {
		get {
			return IsObject(this._conditions) ? this._conditions.Length : 0
		}
	}

	AddChild(tinfToAdd) {
		if (IsObject(this._children)) {
			tinfToAdd.Parent := this
			this._children.Push(tinfToAdd)
		}
	}

	DeleteChild(tinfToDelete) {
		if (!IsObject(this._children)) {
			return
		}
		for idx, tinf in this._children {
			if (tinf == tinfToDelete) {
				this._children.RemoveAt(idx)
			}
		}
	}

	GetChildren() {
		return this._children
	}

	MoveChild(tinfMove, moveDir) {
		if (IsObject(tinfMove) && IsObject(this._children)) {
			nChildren := this._children.Length
			if (nChildren < 2) {
				return
			}
			idxFrom := 0
			for idx, tinf in this._children {
				if (tinf == tinfMove) {
					idxFrom := idx
					break
				}
			}
			if (moveDir = "Up") {
				if (idxFrom < 2) {
					return
				}
				idxTo := idxFrom - 1
			}
			else {
				if (idxFrom >= nChildren) {
					return
				}
				idxTo := idxFrom + 1
			}
			tinfTo := this._children[idxTo]
			this._children[idxTo] := tinfMove
			this._children[idxFrom] := tinfTo
		}
	}

	TotalChildrenNum {
		get {
			cnt := 0
			this._CountChildren(&cnt)
			return cnt
		}
	}

	_CountChildren(&cnt) {
		if (IsObject(this._children)) {
			for tinf in this._children {
				cnt += tinf.TotalChildrenNum + 1
			}
		}
	}

	Parent {
		set {
			this._parent := value
		}
		get {
			return this._parent
		}
	}

	NestLevel {
		get {
			level := 1
			parent := this._parent
			while (IsObject(parent)) {
				parent := parent.Parent
				level++
			}
			return level
		}
	}

	FullName {
		get {
			fullname := this._name
			parent := this._parent
			while (IsObject(parent)) {
				fullname := parent.Name . ME_TargetDelim . fullname
				parent := parent.Parent
			}
			return fullname
		}
	}

	InfoFromName(nameTargetFull) {
		aryNames := StrSplit(nameTargetFull, ME_TargetDelim)
		if (aryNames.Length==0 || this._name != aryNames[1]) {
			return ""
		}
		return this._CheckNextLevel(this, aryNames, 2)
	}

	_CheckNextLevel(tinfCurrent, aryNames, nestLevel) {
		if (nestLevel > aryNames.Length) {
			return tinfCurrent
		}
		name := aryNames[nestLevel]
		children := tinfCurrent.GetChildren()
		if (!IsObject(children)) {
			return ""
		}
		for tinfChild in children {
			if (tinfChild.Name = name) {
				res := this._CheckNextLevel(tinfChild, aryNames, nestLevel+1)
				if (IsObject(res)) {
					return res
				}
			}
		}
		return ""
	}

	SortChildren() {
		children := this._children
		if (!IsObject(children) || children.Length==0) {
			return
		}
		arySorted := []
		for tinf1 in children {
			tinf1.SortChildren()
			bInserted := false
			for idx, tinf2 in arySorted {
				if (tinf1.Name < tinf2.Name) {
					arySorted.InsertAt(idx, tinf1)
					bInserted := true
					break
				}
			}
			if (!bInserted) {
				arySorted.Push(tinf1)
			}
		}
		this._children := arySorted
	}
}

;-------------------------------------------------------------------------------
; Gesture information class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class GestureInfoClass
{
	__New(nameGesture:="") {
		this._name		:= nameGesture
		this._patterns	:= []
		this._targets	:= []
	}

	Name {
		set {
			this._name := value
		}
		get {
			return this._name
		}
	}

	AddPattern(gestureSequence) {
		if (IsObject(this._patterns)) {
			this._patterns.Push(gestureSequence)
		}
	}

	DeletePattern(idx) {
		if (IsObject(this._patterns) && (idx <= this._patterns.Length)) {
			this._patterns.RemoveAt(idx)
		}
	}

	UpdatePattern(idx, gestureSequence) {
		if (IsObject(this._patterns) && (idx <= this._patterns.Length)) {
			this._patterns[idx] := gestureSequence
		}
	}

	GetPatterns() {
		return this._patterns
	}

	AddTarget(targetName, targetAction) {
		if (IsObject(this._targets)) {
			this._targets.Push({name: targetName, action: targetAction})
		}
	}

	DeleteTarget(idx) {
		if (IsObject(this._targets) && (idx <= this._targets.Length)) {
			this._targets.RemoveAt(idx)
		}
	}

	UpdateTarget(idx, targetName, targetAction) {
		if (IsObject(this._targets) && (idx <= this._targets.Length)) {
			this._targets[idx].name	  := targetName
			this._targets[idx].action := targetAction
		}
	}

	GetTargets() {
		return this._targets
	}

	TargetsNum {
		get {
			return IsObject(this._targets) ? this._targets.Length : 0
		}
	}

	TargetIndexFromName(targetName) {
		if (IsObject(this._targets)) {
			for idx, target in this._targets {
				if (target.name = targetName) {
					return idx
				}
			}
		}
		return 0
	}
}

;-------------------------------------------------------------------------------
; Trigger button information class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class TriggerClass
{
	__New(btnName:="", ahkKey:="", desc:="", type:="", bUserDef:=false) {
		this._name				:= btnName
		this._ahkKey			:= ahkKey
		this._description		:= desc
		this._type				:= type
		this._bUserDefined		:= bUserDef
	}

	Name {
		set {
			this._name := value
		}
		get {
			return this._name
		}
	}

	AhkKey {
		set {
			this._ahkKey := value
		}
		get {
			return this._ahkKey
		}
	}

	Description {
		set {
			this._description := value
		}
		get {
			return this._description
		}
	}

	Type {
		set {
			this._type := value
		}
		get {
			return this._type
		}
	}

	UserDefined {
		set {
			this._bUserDefined := value
		}
		get {
			return this._bUserDefined
		}
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Initialization Functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize configuration variables
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_InitConfigGlobals()
{
	global

	ME_Targets			:= []
	ME_Gestures			:= []
	ME_ExcActivate		:= []
	ME_mapArrowColors	:= Map()
	ME_mapTargetOrder	:= Map()

	ME_DefTargetName	:= "Default"
	ME_TargetDelim		:= "/"

	; Triggers
	ME_mapUserButtons := Map()

	ME_DefaultButtons := [ TriggerClass("LB",  "*LButton",		ME_BtnDesc_LB)
						 , TriggerClass("RB",  "*RButton",		ME_BtnDesc_RB)
						 , TriggerClass("MB",  "*MButton",		ME_BtnDesc_MB)
						 , TriggerClass("X1B", "*XButton1",		ME_BtnDesc_X1B)
						 , TriggerClass("X2B", "*XButton2",		ME_BtnDesc_X2B)
						 , TriggerClass("WU",  "*WheelUp",		ME_BtnDesc_WU,	"Wheel")
						 , TriggerClass("WD",  "*WheelDown",	ME_BtnDesc_WD,	"Wheel")
						 , TriggerClass("LT",  "*WheelLeft",	ME_BtnDesc_LT)
						 , TriggerClass("RT",  "*WheelRight",	ME_BtnDesc_RT) ]

	ME_AllEdges :=  [ TriggerClass("ET" , ,	ME_BtnDesc_ET,	"Edge")
					, TriggerClass("ETA", ,	ME_BtnDesc_ETA,	"Edge")
					, TriggerClass("ETB", ,	ME_BtnDesc_ETB,	"Edge")
					, TriggerClass("ET1", ,	ME_BtnDesc_ET1,	"Edge")
					, TriggerClass("ET2", ,	ME_BtnDesc_ET2,	"Edge")
					, TriggerClass("ET3", ,	ME_BtnDesc_ET3,	"Edge")
					, TriggerClass("EB" , ,	ME_BtnDesc_EB,	"Edge")
					, TriggerClass("EBA", ,	ME_BtnDesc_EBA,	"Edge")
					, TriggerClass("EBB", ,	ME_BtnDesc_EBB,	"Edge")
					, TriggerClass("EB1", ,	ME_BtnDesc_EB1,	"Edge")
					, TriggerClass("EB2", ,	ME_BtnDesc_EB2,	"Edge")
					, TriggerClass("EB3", ,	ME_BtnDesc_EB3,	"Edge")
					, TriggerClass("EL" , ,	ME_BtnDesc_EL,	"Edge")
					, TriggerClass("ELA", ,	ME_BtnDesc_ELA,	"Edge")
					, TriggerClass("ELB", ,	ME_BtnDesc_ELB,	"Edge")
					, TriggerClass("EL1", ,	ME_BtnDesc_EL1,	"Edge")
					, TriggerClass("EL2", ,	ME_BtnDesc_EL2,	"Edge")
					, TriggerClass("EL3", ,	ME_BtnDesc_EL3,	"Edge")
					, TriggerClass("ER" , ,	ME_BtnDesc_ER,	"Edge")
					, TriggerClass("ERA", ,	ME_BtnDesc_ERA,	"Edge")
					, TriggerClass("ERB", ,	ME_BtnDesc_ERB,	"Edge")
					, TriggerClass("ER1", ,	ME_BtnDesc_ER1,	"Edge")
					, TriggerClass("ER2", ,	ME_BtnDesc_ER2,	"Edge")
					, TriggerClass("ER3", ,	ME_BtnDesc_ER3,	"Edge")
					, TriggerClass("CRT", ,	ME_BtnDesc_CRT,	"Edge")
					, TriggerClass("CLT", ,	ME_BtnDesc_CLT,	"Edge")
					, TriggerClass("CRB", ,	ME_BtnDesc_CRB,	"Edge")
					, TriggerClass("CLB", ,	ME_BtnDesc_CLB,	"Edge") ]

	local edgeList := ""
	for binf in ME_AllEdges {
		Join(&edgeList, binf.Name, "|")
	}
	ME_AllEdgesRegEx := "(" edgeList ")"

	; Target condition types
	ME_TargetTypes := [ "WClass"
					  , "CClass"
					  , "Exe"
					  , "Title"
					  , "Custom"
					  , "Include" ]

	ME_TargetRegEx	:= "WClass"
					. "|WClass_[NPTBR][PTBR]?"
					. "|CClass"
					. "|CClass_[NPTBR][PTBR]?"
					. "|Title"
					. "|Title_[NPTBR][PTBR]?"
					. "|Exe"
					. "|Exe_[NPTBR][PTBR]?"
					. "|Custom"
					. "|Custom_N"
					. "|Include"
					. "|Include_N"
}

;-------------------------------------------------------------------------------
; Initialize configuration variables
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_InitConfigurations()
{
	_InitConfRecognition()
	_InitConfHints()
	_InitConfTrail()
	_InitConfLog()
	_InitConfOthers()
}

;-------------------------------------------------------------------------------
; Initialize variables for recognition processing
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
_InitConfRecognition()
{
	global
	tblConfRecog :=	[ { name: "IniFileVersion"		, def: 0		, type: "Number"	}
					, { name: "8Dir"				, def: 0		, type: "Number"	}
					, { name: "ActiveAsTarget"		, def: 0		, type: "Number"	}
					, { name: "Interval"			, def: 20		, type: "Number"	}
					, { name: "AlwaysHook"			, def: 0		, type: "Number"	}
					, { name: "PrvntCtxtMenu"		, def: 0		, type: "Number"	}
					, { name: "Threshold"			, def: 60		, type: "Number"	}
					, { name: "LongThresholdX"		, def: 800		, type: "Number"	}
					, { name: "LongThresholdY"		, def: 600		, type: "Number"	}
					, { name: "LongThreshold"		, def: 700		, type: "Number"	}
					, { name: "FirstLongOnly"		, def: 0		, type: "Number"	}
					, { name: "TimeoutThreshold"	, def: 12		, type: "Number"	}
					, { name: "Timeout"				, def: 400		, type: "Number"	}
					, { name: "DGInterval"			, def: 0		, type: "Number"	}
					, { name: "TmReleaseTrigger"	, def: 3		, type: "Number"	}
					, { name: "ORangeDefault"		, def: 45		, type: "Number"	}
					, { name: "ORangeA"				, def: 45		, type: "Number"	}
					, { name: "ORangeB"				, def: 45		, type: "Number"	}
					, { name: "EdgeInterval"		, def: 20		, type: "Number"	}
					, { name: "EdgeIndiv"			, def: 0		, type: "Number"	}
					, { name: "CornerX"				, def: 1		, type: "Number"	}
					, { name: "CornerY"				, def: 1		, type: "Number"	}
					, { name: "DisableDefMB"		, def: 0		, type: "Number"	}
					, { name: "DisableDefX1B"		, def: 0		, type: "Number"	}
					, { name: "DisableDefX2B"		, def: 0		, type: "Number"	} ]

	local conf, varName
	for conf in tblConfRecog {
		varName := "Config_" conf.name
		%varName% := conf.def
	}
}

;-------------------------------------------------------------------------------
; Initialize variables for gesture hints
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
_InitConfHints()
{
	global
	tblConfHints :=	[ { name: "UseNavi"			, def: 1			, type: "Number"	}
					, { name: "UseExNavi"		, def: 4			, type: "Number"	}
					, { name: "NaviInterval"	, def: 20			, type: "Number"	}
					, { name: "NaviPersist"		, def: 0			, type: "Number"	}
					, { name: "AdNaviFG"		, def: "FFFFFF"		, type: "String"	}
					, { name: "AdNaviNI"		, def: "7F7F7F"		, type: "String"	}
					, { name: "AdNaviBG"		, def: "000000"		, type: "String"	}
					, { name: "AdNaviTranspcy"	, def: 220			, type: "Number"	}
					, { name: "AdNaviSize"		, def: 11			, type: "Number"	}
					, { name: "AdNaviFont"		, def: ME_AdNaviFont, type: "String"	}
					, { name: "AdNaviPosition"	, def: 1			, type: "Number"	}
					, { name: "AdNaviPaddingL"	, def: 6			, type: "Number"	}
					, { name: "AdNaviPaddingR"	, def: 6			, type: "Number"	}
					, { name: "AdNaviPaddingT"	, def: 3			, type: "Number"	}
					, { name: "AdNaviPaddingB"	, def: 3			, type: "Number"	}
					, { name: "AdNaviRound"		, def: 2			, type: "Number"	}
					, { name: "AdNaviMargin"	, def: 14			, type: "Number"	}
					, { name: "AdNaviSpaceX"	, def: 2			, type: "Number"	}
					, { name: "AdNaviSpaceY"	, def: 2			, type: "Number"	}
					, { name: "AdNaviOnClick"	, def: 0			, type: "Number"	}
					, { name: "ExNaviTransBG"	, def: 1			, type: "Number"	}
					, { name: "ExNaviFG"		, def: "5050F0"		, type: "String"	}
					, { name: "ExNaviBG"		, def: "FFFFFF"		, type: "String"	}
					, { name: "ExNaviTranspcy"	, def: 255			, type: "Number"	}
					, { name: "ExNaviSize"		, def: 24			, type: "Number"	}
					, { name: "ExNaviSpacing"	, def: 2			, type: "Number"	}
					, { name: "ExNaviPadding"	, def: 4			, type: "Number"	}
					, { name: "ExNaviMargin"	, def: 8			, type: "Number"	} ]

	local conf, varName
	for conf in tblConfHints {
		varName := "Config_" conf.name
		%varName% := conf.def
	}
}

;-------------------------------------------------------------------------------
; Initialize variables for gesture trail
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
_InitConfTrail()
{
	global
	tblConfTrail := [ { name: "ShowTrail"		, def: 1			, type: "Number"	}
					, { name: "DrawTrailWnd"	, def: 1			, type: "Number"	}
					, { name: "TrailColor"		, def: "0000FF"		, type: "String"	}
					, { name: "TrailTranspcy"	, def: 255			, type: "Number"	}
					, { name: "TrailWidth"		, def: 3			, type: "Number"	}
					, { name: "TrailStartMove"	, def: 3			, type: "Number"	} ]

	local conf, varName
	for conf in tblConfTrail {
		varName := "Config_" conf.name
		%varName% := conf.def
	}
}

;-------------------------------------------------------------------------------
; Initialize variables for log display
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
_InitConfLog()
{
	global
	tblConfLog :=	[ { name: "ShowLog"			, def: 0			, type: "Number"	}
					, { name: "LogPosition"		, def: 4			, type: "Number"	}
					, { name: "LogPosX"			, def: 0			, type: "Number"	}
					, { name: "LogPosY"			, def: 0			, type: "Number"	}
					, { name: "LogMax"			, def: 20			, type: "Number"	}
					, { name: "LogSizeW"		, def: 500			, type: "Number"	}
					, { name: "LogFG"			, def: "FFFFFF"		, type: "String"	}
					, { name: "LogBG"			, def: "000000"		, type: "String"	}
					, { name: "LogTranspcy"		, def: 100			, type: "Number"	}
					, { name: "LogFontSize"		, def: 10			, type: "Number"	}
					, { name: "LogFont"			, def: ME_LogFont	, type: "String"	} ]

	local conf, varName
	for conf in tblConfLog {
		varName := "Config_" conf.name
		%varName% := conf.def
	}
}

;-------------------------------------------------------------------------------
; Initialize other settings
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
_InitConfOthers()
{
	global
	tblConfOthers :=[ { name: "HotkeyReload"	, def: ""			, type: "String"	}
					, { name: "HotkeyEnable"	, def: ""			, type: "String"	}
					, { name: "HotkeyAbort"		, def: "Esc"		, type: "String"	}
					, { name: "HotkeyShowList"	, def: "F1"			, type: "String"	}
					, { name: "HotkeyNavi"		, def: ""			, type: "String"	}
					, { name: "ScriptEditor"	, def: ""			, type: "String"	}
					, { name: "VarAssumeGlobal"	, def: 1			, type: "Number"	}
					, { name: "AdjustDlg"		, def: 0			, type: "Number"	}
					, { name: "TraySubmenu"		, def: 0			, type: "Number"	}
					, { name: "DlgHeightLimit"	, def: 800			, type: "Number"	}
					, { name: "FoldTarget"		, def: 0			, type: "Number"	}
					, { name: "DisableWarning"	, def: 0			, type: "Number"	} ]

	local conf, varName
	for conf in tblConfOthers {
		varName := "Config_" conf.name
		%varName% := conf.def
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	INI File
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Load ini file
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LoadIniFile(iniStr:="")
{
	global ME_Gestures

	ME_Gestures	:= []
	if (iniStr == "") {
		iniStr := FileRead(MG_IniFilePath, "UTF-8")
	}
	ME_LoadIni(iniStr)
	ME_UpdateOldConfigValue()
}

;-------------------------------------------------------------------------------
; Load settings from an INI format string.
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LoadIni(iniStr, &tinfSel:="", idxGesSel:=0)
{
	global ME_Targets, ME_Gestures, ME_mapUserButtons, ME_mapArrowColors, ME_ExcActivate

	iniStr .= "`n[EndOfIni]`n"
	sectionName := ginf := tinf := tinfRet := ""
	lvInsert := lvNest := 1
	idxInsG := idxGesSel
	bTargetImport := IsObject(tinfSel)
	bTargetAdded:= bGestureAdded := bInRangeComment := false
	aryParents := []

	Loop Parse, iniStr, "`n", "`r" A_Tab A_Space
	{
		iniOneLine := A_LoopField		; Read one line

		;-----------------------------------------------------------------------
		; Skip comments
		;-----------------------------------------------------------------------
		; Line comments ( #... )
		if (!bInRangeComment && RegExMatch(iniOneLine, "^\s*#")) {
			continue
		}
		; Range comments ( /* ... */ )
		if (!bInRangeComment && RegExMatch(iniOneLine, "^\s*\/\*")) {
			bInRangeComment := true
		}
		if (bInRangeComment) {
			if (RegExMatch(iniOneLine, "\*\/\s*$")) {
				bInRangeComment := false
			}
			continue
		}
		;-----------------------------------------------------------------------
		; Sections
		;-----------------------------------------------------------------------
		if (RegExMatch(iniOneLine, "^\[(.+)\]$", &sect)) {

 			; Previous section is General Settings
			if (sectionName = ""
			||	sectionName = "Settings"
			||	sectionName = "UserButtons"
			||	sectionName = "ArrowHintColors"
			||	sectionName = "ActivationExcluded")
			{
				; No processing is required.
			}
 			; Previous section is Gesture
			else if (bGes) {
				nameGesture := sectionName

				; If the gesture name already exists, create a new gesture name.
				if (ME_GestureIndexFromName(nameGesture) > 0) {
					cnt := 1
					if (RegExMatch(nameGesture, "(.+?)\s*?\(([0-9])\)", &name)) {
						nameGesture := name[1]
						cnt := name[2]
					}
					Loop{
						cnt++
						nameNew := nameGesture . " (" . cnt . ")"
						if (ME_GestureIndexFromName(nameNew) == 0) {
							nameGesture := nameNew
							break
						}
					}
				}

				if (IsObject(ginf)) {
					ginf.Name := nameGesture
					;=-= Import operation starts here =-=-=-==-=-=-==-=-=-=-=-=-
					if (idxInsG > 0) {
						ME_Gestures.InsertAt(idxInsG++, ginf)
					}
					;=-= Import operation ends here =-=-=-==-=-=-==-=-=-=-=-=-=-
					else {
						ME_Gestures.Push(ginf)
					}
					ginf := ""
					bGestureAdded := true
				}
			}
			; Previous section is Target ( neither Gesture nor General Settings )
			else {
				nameTarget := sectionName
				tinfParent := (lvNest>1 && (aryParents.Length >= lvNest-1))
							? aryParents[lvNest-1] : ""

				; If the target name already exists, create a new target name.
				nameTargetFull := ME_MakeTargetFullName(tinfParent, nameTarget)
				if (ME_TargetExists(nameTargetFull)) {
					cnt := 1
					if (RegExMatch(nameTarget, "(.+?)\s*?\(([0-9])\)", &name)) {
						nameTarget := name[1]
						cnt := name[2]
					}
					Loop {
						cnt++
						nameNew := nameTarget . " (" . cnt . ")"
						nameTargetFull := ME_MakeTargetFullName(tinfParent, nameNew)
						if (!ME_TargetExists(nameTargetFull)) {
							nameTarget := nameNew
							break
						}
					}
				}

				if (IsObject(tinf)) {
					tinf.Name := nameTarget
					if (lvNest == 1 || !IsObject(tinfParent)) {
						aryParents := []
						;=-= Import operation starts here =-=-=-==-=-=-==-=-=-=-
						idxInsT := 0
						nTargets := ME_Targets.Length
						if (bTargetImport && !bTargetAdded) {
							idxInsT := ME_TargetIndexFromInfo(tinfSel)
							idxInsT := idxInsT>1 ? idxInsT : (idxInsT==1 ? 2 : nTargets+1)
						}
						if (idxInsT>0 && idxInsT<=nTargets) {
							ME_Targets.InsertAt(idxInsT++, tinf)
							Loop lvInsert {
								aryParents.Push(tinf)
							}
						}
						;=-= Import operation ends here =-=-=-==-=-=-==-=-=-=-=-
						else {
							ME_Targets.Push(tinf)
							aryParents.Push(tinf)
						}
					}
					else {
						tinfParent.AddChild(tinf)
						if (aryParents.Length >= lvNest) {
							aryParents[lvNest] := tinf
						} else {
							aryParents.Push(tinf)
						}
					}
					if (!bTargetAdded) {
						tinfRet := tinf
					}
					bTargetAdded := true
					tinf := ""
				}
			}

			; Initialize section data
			sectionName := sect[1]
			bGes := false
			lvNest := 1
			tinf := TargetInfoClass()
			ginf := GestureInfoClass()
			if (!IsObject(tinf) || !IsObject(ginf)) {
				return ""
			}
			continue
		}
		;-----------------------------------------------------------------------
		; Key=Value entries
		;-----------------------------------------------------------------------
		if (RegExMatch(iniOneLine, "^(.+?)\s*=\s*(.*?)$", &part)) {
			key := part[1]
			val := part[2]

			; [Settings] section (General settings)
			if (sectionName = "Settings") {
				ME_SetGlobalConfigVariable(key, val)
			}
			; [UserButtons] section (<number>=<Name{TAB}AhkKey{TAB}Description{TAB}Type>
			; (Individual colors of arrow hints)
			else if (sectionName = "UserButtons") {
				if (RegExMatch(val, "^{\s*(.+?)\t(.*?)\t(.*?)\t(.*?)\s*}$", &part)) {
					btnName := part[1]
					binf := TriggerClass(btnName, part[2], part[3], part[4], true)
					ME_mapUserButtons[btnName] := binf
				}
			}
			; [ArrowHintColors] section (<number>=<button{TAB}color>
			; (Individual colors of arrow hints)
			else if (sectionName = "ArrowHintColors") {
				if (RegExMatch(val, "^{\s*(.+?)\t(.+?)\s*}$", &part)) {
					btnName := part[1]
					ME_mapArrowColors[btnName] := part[2]
				}
			}
			; [ActivationExcluded] section (<number>=<title{TAB}class{TAB}exe>
			; (Excluded targets for MG_ActivatePrevWin() function)
			else if (sectionName = "ActivationExcluded") {
				if (RegExMatch(val, "^{\s*(.*?)\t(.*?)\t(.*?)\s*}$", &part)
				&&	(part[1]!="" || part[2]!="" || part[3]!=""))
				{
					ex := { title: part[1], class: part[2], exe: part[3] }
					ME_ExcActivate.Push(ex)
				}
			}
			;-------------------------------------------------------------------
			; Target entries ( <target type>=<value> )
			else if (ME_IsTargetTypeName(key)
			&&		!ME_RuleExists(tinf, key, val))
			{
				if (IsObject(tinf)) {
					tinf.AddCondition(key, val)
				}
			}
			; Target Icon ( Icon=<icon filename, icon index> )
			else if (key = "Icon") {
				if (IsObject(tinf)) {
					tinf.IconFileAndIndex := val
					tinf.ImageListIndex := ME_FindImageListIcon(tinf.IconFile, tinf.IconIndex)
					if (ME_hImageList && !tinf.ImageListIndex) {
						tinf.ImageListIndex := IL_Add(ME_hImageList
													, MG_CnvVariablesInStr(tinf.IconFile)
													, tinf.IconIndex)
					}
				}
			}
			; And Condition ( And=<value> )
			else if (key = "And") {
				if (IsObject(tinf)) {
					tinf.MatchAll := (val==1) ? true : false
				}
			}
			; "Exclude from default gesture targets" ( ExcludeDefault=<value> )
			else if (key = "ExcludeDefault") {
				if (IsObject(tinf)) {
					tinf.DefActionDisabled := (val==1) ? true : false
				}
			}
			; Target Nesting Level ( Level=<value> )
			else if (key = "Level") {
				lvNest := val

				;=-= Import operation starts here =-=-=-==-=-=-==-=-=-=-=-=-=-=-
				if (bTargetImport && !bTargetAdded && (lvNest > 1)) {
					; When the tinfSel (selected target information) is specified,
					; the operation is an import, and the parent will be tinfSel.
					aryParents := []
					if (tinfSel == ME_Targets[1]) {
						; The first item cannot have children.
						lvInsert := lvNest
						lvNest := 1
					}
					else {
						; Fill the parents array with the selected target information.
						Loop (lvNest - 1) {
							aryParents.Push(tinfSel)
						}
					}
				}
				;=-= Import operation ends here =-=-=-==-=-=-==-=-=-=-=-=-=-=-=-
			}
			; "Don't inherit the parent conditions" ( NotInherit=<value> )
			else if (key = "NotInherit") {
				if (IsObject(tinf)) {
					tinf.NoInheritance := (val==1) ? true : false
				}
			}
			;-------------------------------------------------------------------
			; Gesture entries ( G=<gesture string> )
			else if (key = "G") {
				bGes := true
				if (val!="" && IsObject(ginf)) {
					ginf.AddPattern(val)
				}
			}
			; Target name and Actions ( <target name>=<action string> )
			else if (bGes) {
				if (IsObject(ginf)) {
					if (ginf.TargetIndexFromName(key)==0) {
						if (Config_IniFileVersion < 1.20) {
							val := RegExReplace(val, "(?<!\t)\t", "<MG_CR>")
						}
						ginf.AddTarget(key, val)
					}
				}
			}
		}
	}

	; If there are no targets, register the empty target to ignore.
	if (ME_Targets.Length == 0) {
		ME_Targets.Push(TargetInfoClass(ME_LngOthers002))
	}

	; Set return value for the import operation.
	tinfSel := tinfRet
	ret := bTargetAdded  ? "T" : ""
	ret .= bGestureAdded ? "G" : ""
	return ret
}

ME_SetGlobalConfigVariable(varName, value) {
	global
	Config_%varName% := value
}

;-------------------------------------------------------------------------------
; Update the old configuration data
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_UpdateOldConfigValue()
{
	global
	if (Config_IniFileVersion < 2) {
		Config_UseExNavi++
		Config_AdNaviPosition++
	}
}

;-------------------------------------------------------------------------------
; Register preset targets and gestures
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_RegisterPresetItems()
{
	global ME_Targets, ME_Gestures

	;--- Targets ---
	; Ignored Targets
	tinf := TargetInfoClass(ME_LngOthers002)
	ME_Targets.Push(tinf)

	; Browsers
	tinf := TargetInfoClass(ME_PresetTarget01)
	tinf.AddCondition("Exe", "msedge.exe")
	tinf.AddCondition("Exe", "chrome.exe")
	tinf.AddCondition("Exe", "firefox.exe")
	tinf.IconFileAndIndex := "%A_WinDir%\system32\inetcpl.cpl,6"
	if (ME_hImageList) {
		tinf.ImageListIndex := IL_Add(ME_hImageList
				, MG_CnvVariablesInStr(tinf.IconFile), tinf.IconIndex)
	}
	ME_Targets.Push(tinf)

	; Explorer
	tinf := TargetInfoClass(ME_PresetTarget02)
	tinf.AddCondition("WClass", "CabinetWClass")
	tinf.AddCondition("WClass", "ExploreWClass")
	tinf.AddCondition("WClass", "Progman")
	tinf.AddCondition("WClass", "WorkerW")
	tinf.IconFileAndIndex := "%A_WinDir%\explorer.exe,1"
	if (ME_hImageList) {
		tinf.ImageListIndex := IL_Add(ME_hImageList
				, MG_CnvVariablesInStr(tinf.IconFile), tinf.IconIndex)
	}
	; Explorer/Icons
	tinfChild := TargetInfoClass(ME_PresetTarget03)
	tinfChild.AddCondition("Custom", "MG_TreeListHitTest()")
	tinfChild.IconFileAndIndex := "%A_WinDir%\explorer.exe,1"
	if (ME_hImageList) {
		tinfChild.ImageListIndex := IL_Add(ME_hImageList
				, MG_CnvVariablesInStr(tinfChild.IconFile), tinfChild.IconIndex)
	}
	tinf.AddChild(tinfChild)
	ME_Targets.Push(tinf)

	;--- Gestures ---
	; RB_
	ginf := GestureInfoClass(ME_PresetGesture01)
	ginf.AddPattern("RB_")

	taraget := ME_DefTargetName
	action := ";" ME_PresetAction01 "<MG_CR>"
				. "if (InStr(MG_WClass, `"Chrome_WidgetWin`")!=1 || (MG_WStyle & 0x000B0000)) {<MG_CR>"
				. "<MG_TAB>MG_WinActivate()<MG_CR>}"
	ginf.AddTarget(taraget, action)

	taraget := ME_PresetTarget02 "/" ME_PresetTarget03
	action := ";" ME_PresetAction02 "<MG_CR>MG_Abort()"
	ginf.AddTarget(taraget, action)

	ME_Gestures.Push(ginf)

	; RB_LB__
	ginf := GestureInfoClass(ME_PresetGesture02)
	ginf.AddPattern("RB_LB__")
	taraget := ME_DefTargetName
	action := ";" ME_PresetAction03 "<MG_CR>PostMessage(0x0010)"
	ginf.AddTarget(taraget, action)
	ME_Gestures.Push(ginf)

	; RB_L_
	ginf := GestureInfoClass(ME_PresetGesture03)
	ginf.AddPattern("RB_L_")
	taraget := ME_DefTargetName
	action := ";" ME_PresetAction04 "<MG_CR>Send(`"!{Left}`")"
	ginf.AddTarget(taraget, action)
	ME_Gestures.Push(ginf)

	; RB_R_
	ginf := GestureInfoClass(ME_PresetGesture04)
	ginf.AddPattern("RB_R_")
	taraget := ME_DefTargetName
	action := ";" ME_PresetAction05 "<MG_CR>Send(`"!{Right}`")"
	ginf.AddTarget(taraget, action)
	ME_Gestures.Push(ginf)

	; RB_U_
	ginf := GestureInfoClass(ME_PresetGesture05)
	ginf.AddPattern("RB_U_")
	taraget := ME_DefTargetName
	action := ";" ME_PresetAction06 "<MG_CR>Send(`"^{Home}`")"
	ginf.AddTarget(taraget, action)
	ME_Gestures.Push(ginf)

	; RB_D_
	ginf := GestureInfoClass(ME_PresetGesture06)
	ginf.AddPattern("RB_D_")
	taraget := ME_DefTargetName
	action := ";" ME_PresetAction07 "<MG_CR>Send(`"^{End}`")"
	ginf.AddTarget(taraget, action)
	ME_Gestures.Push(ginf)

	; RB_LU_
	ginf := GestureInfoClass(ME_PresetGesture07)
	ginf.AddPattern("RB_LU_")
	ME_Gestures.Push(ginf)

	; RB_LD_
	ginf := GestureInfoClass(ME_PresetGesture08)
	ginf.AddPattern("RB_LD_")
	ME_Gestures.Push(ginf)

	; RB_RU_
	ginf := GestureInfoClass(ME_PresetGesture09)
	ginf.AddPattern("RB_RU_")
	taraget := ME_DefTargetName
	action := ";" ME_PresetAction08 "<MG_CR>MG_ActivatePrevWin(1000)"
	ginf.AddTarget(taraget, action)
	ME_Gestures.Push(ginf)

	; RB_RD_
	ginf := GestureInfoClass(ME_PresetGesture10)
	ginf.AddPattern("RB_RD_")
	taraget := ME_DefTargetName
	action := ";" ME_PresetAction09 "<MG_CR>PostMessage(0x0112, 0xF020)"
	ginf.AddTarget(taraget, action)
	ME_Gestures.Push(ginf)

	; RB_UL_
	ginf := GestureInfoClass(ME_PresetGesture11)
	ginf.AddPattern("RB_UL_")
	ME_Gestures.Push(ginf)

	; RB_UR_
	ginf := GestureInfoClass(ME_PresetGesture12)
	ginf.AddPattern("RB_UR_")
	ME_Gestures.Push(ginf)

	; RB_DL_
	ginf := GestureInfoClass(ME_PresetGesture13)
	ginf.AddPattern("RB_DL_")
	ME_Gestures.Push(ginf)

	; RB_DR_
	ginf := GestureInfoClass(ME_PresetGesture14)
	ginf.AddPattern("RB_DR_")
	ME_Gestures.Push(ginf)
}

;-------------------------------------------------------------------------------
; Retrieves the button information for the older version
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_LoadOldUserButtons()
{
	global ME_mapUserButtons

	if (!FileExist(MG_DirUserBtn)) {
		return
	}
	Loop Files, MG_DirUserBtn "*.ahk" {
		SplitPath(A_LoopFilePath, , , , &btnName)
		if (!IsObject(ME_mapUserButtons[btnName])) {
			type := ""
			desc := _GetButtonData(A_LoopFilePath, &ahkKey, &type)
			binf := TriggerClass(btnName, ahkKey, desc, type, true)
			ME_mapUserButtons[btnName] := binf
		}
	}
}

_GetButtonData(btnFilePath, &ahkKeyStr:="", &type:="")
{
	btnScript := ""
	btnDescription := ""
	btnScript := FileRead(btnFilePath, "UTF-8")
	if (InStr(btnScript, "MG_ScreenEdge.ahk")) {
		type := "Edge"
		SplitPath(btnFilePath, , , , &btnName)
		btnDescription := "ME_BtnDesc_" btnName
		desc := %btnDescription%
		return desc
	}
	btnScript := RegExReplace(btnScript, "Hotkey[\t\s]*?,[\t\s]*?If")
	if (RegExMatch(btnScript, "Hotkey[\t\s]*,[\t\s]*(.+?)[\t\s]*,", &part)) {
		ahkKeyStr := part[1]
	}
	if (RegExMatch(btnScript, "m)^.*Description[\s\t]*=[\s\t]*(.+).*$", &part)) {
		btnDescription := part[1]
	}
	if (btnDescription=="") {
		RegExMatch(btnFilePath, ".+\\(.+)\.ahk", &part)
		btnDescription := "ME_BtnDesc_" part[1]
		btnDescription := %btnDescription% ? %btnDescription% : part[1]
	}
	return btnDescription
}


;			--- Utilitie functions for the target information ---

;-------------------------------------------------------------------------------
; Check whether specified string is a target type name
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_IsTargetTypeName(str)
{
	return RegExMatch(str, "^(" . ME_TargetRegEx . ")$")
}

;-------------------------------------------------------------------------------
; Check whether specified rule exists
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_RuleExists(tinf, ruleType, ruleValue)
{
	conds := IsObject(tinf) ? tinf.GetConditions() : ""
	if (IsObject(conds)) {
		for cond in conds {
			if ((cond.type = ruleType) && (cond.value = ruleValue)) {
				return true
			}
		}
	}
	return false
}

;-------------------------------------------------------------------------------
; Concatenate the target name and the parent's full name.
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_MakeTargetFullName(tinfParent, nameTarget)
{
	if (!IsObject(tinfParent)) {
		return nameTarget
	}
	return tinfParent.FullName . ME_TargetDelim . nameTarget
}

;-------------------------------------------------------------------------------
; Check whether specified target exists
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetExists(nameTargetFull) {
	return IsObject(ME_TargetInfoFromName(nameTargetFull))
}

;-------------------------------------------------------------------------------
; Retrieves the target information object from the full name
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetInfoFromName(nameTargetFull)
{
	if (nameTargetFull == ME_DefTargetName) {
		return ME_Targets[1]
	}
	for tinf in ME_Targets {
		tinfFull := tinf.InfoFromName(nameTargetFull)
		if (IsObject(tinfFull)) {
			return tinfFull
		}
	}
	return ""
}

;-------------------------------------------------------------------------------
; Retrieves the target information object from the index
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetInfoFromIndex(idx)
{
	if (idx>0 && idx<=ME_Targets.Length) {
		return ME_Targets[idx]
	}
	return ""
}

;-------------------------------------------------------------------------------
; Retrieves the target index from the target information object
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetIndexFromInfo(tinfToSearch)
{
	if (IsObject(tinfToSearch)) {
		for idx, tinf in ME_Targets {
			if (tinf == tinfToSearch) {
				return idx
			}
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Searches for an icon that is already registered to the Image List.
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_FindImageListIcon(iconFile, iconIndex)
{
	for tinf in ME_Targets {
		if (idxIL := _FindImageListIcon(tinf, iconFile, iconIndex)) {
			return idxIL
		}
	}
	return 0
}

_FindImageListIcon(tinf, iconFile, iconIndex)
{
	if ((tinf.IconFile = iconFile) && (tinf.IconIndex == iconIndex)) {
		return tinf.ImageListIndex
	}
	return _FindImageListIconFromChildren(tinf, iconFile, iconIndex)
}

_FindImageListIconFromChildren(tinfParent, iconFile, iconIndex)
{
	children := tinfParent.GetChildren()
	if (IsObject(children)) {
		for tinf in children {
			if (idxIL := _FindImageListIcon(tinf, iconFile, iconIndex)) {
				return idxIL
			}
		}
	}
	return 0
}


;			--- Utilitie functions for the gesture information ---

;-------------------------------------------------------------------------------
; Retrieves the gesture information object from the index
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureInfoFromIndex(idx)
{
	if (idx>0 && idx<=ME_Gestures.Length) {
		return ME_Gestures[idx]
	}
	return ""
}

;-------------------------------------------------------------------------------
; Retrieves the gesture targets object from the gesture index
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetsFromGestureIndex(idx)
{
	ginf := ME_GestureInfoFromIndex(idx)
	return IsObject(ginf) ? ginf.GetTargets() : ""
}

;-------------------------------------------------------------------------------
; Retrieves the gesture index from the name
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureIndexFromName(nameGesture)
{
	if (nameGesture != "") {
		for idx, ginf in ME_Gestures {
			if (ginf.Name = nameGesture) {
				return idx
			}
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Retrieves the gesture index from gesture pattern string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureIndexFromPattern(gestureSequence)
{
	if (gestureSequence != "") {
		for idxG, ginf in ME_Gestures {
			for pat in ginf.GetPatterns() {
				if (pat = gestureSequence) {
					return idxG
				}
			}
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Retrieves the gesture index from the gesture information object
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureIndexFromInfo(ginfToSearch)
{
	if (IsObject(ginfToSearch)) {
		for idx, ginf in ME_Gestures {
			if (ginf == ginfToSearch) {
				return idx
			}
		}
	}
	return 0
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Save configurations
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Generates the configuration string for .ini file
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ConfigToIni()
{
	ME_CorrectConfigValue()

	iniAll := ME_GeneralSettingsToIni()

	iniAll .= ME_AllTargetsToIni()

	for ginf in ME_Gestures {
		Join(&iniAll, ME_GestureToIni(ginf))
	}
	return iniAll
}

;-------------------------------------------------------------------------------
; Correct the configuration data
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_CorrectConfigValue()
{
	global

	Config_IniFileVersion := Format("{:0.2f}", MG_Version)

	local var, value
	tbl := [ &Config_ORangeDefault, &Config_ORangeA, &Config_ORangeB ]
	for var in tbl {
		value := %var%
		if (value < 0) {
			%var% := 0
		} else if (value > 90) {
			%var% := 90
		}
	}
}

;-------------------------------------------------------------------------------
; Generates the general setting string for .ini file
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_GeneralSettingsToIni()
{
	buf := "[Settings]`n"
	for conf in tblConfRecog {
		varName := "Config_" conf.name
		buf .= conf.name "=" %varName% "`n"
	}
	for conf in tblConfHints {
		varName := "Config_" conf.name
		buf .= conf.name "=" %varName% "`n"
	}
	for conf in tblConfTrail {
		varName := "Config_" conf.name
		buf .= conf.name "=" %varName% "`n"
	}
	for conf in tblConfLog {
		varName := "Config_" conf.name
		buf .= conf.name "=" %varName% "`n"
	}
	for conf in tblConfOthers {
		varName := "Config_" conf.name
		buf .= conf.name "=" %varName% "`n"
	}
	buf .= "`n[UserButtons]`n"
	cnt := 1
	for key, binf in ME_mapUserButtons {
		buf .= cnt++ "={" binf.Name "`t" binf.AhkKey "`t" binf.Description "`t" binf.Type "}`n"
	}
	buf .= "`n[ArrowHintColors]`n"
	cnt := 1
	for binf in ME_AllButtons {
		if (!ME_mapArrowColors.Has(binf.Name)) {
			continue
		}
		hexColor := ME_mapArrowColors[binf.Name]
		if (hexColor != "") {
			buf .= cnt++ "={" binf.Name "`t" hexColor "}`n"
		}
	}
	buf .= "`n[ActivationExcluded]`n"
	for idx, ex in ME_ExcActivate {
		buf .= idx "={" ex.title "`t" ex.class "`t" ex.exe "}`n"
	}
	return buf "`n"
}

;-------------------------------------------------------------------------------
; Generates the INI string for all targets
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_AllTargetsToIni()
{
	global ME_TargetCounter, ME_mapTargetOrder

	ME_TargetCounter := 0
	ME_mapTargetOrder := Map()
	iniTargets := ""
	for tinf in ME_Targets {
		ME_TargetToIniIncludeChildren(tinf, &iniTargets)
	}
	return iniTargets
}

;-------------------------------------------------------------------------------
; Generates the target INI string that includes child targets
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetToIniIncludeChildren(tinf, &iniTargets)
{
	global ME_TargetCounter, ME_mapTargetOrder

	ME_mapTargetOrder[tinf] := ++ME_TargetCounter
	Join(&iniTargets, ME_TargetToIni(tinf))
	ME_ChildTargetToIni(tinf, &iniTargets)
}

;-------------------------------------------------------------------------------
; Generates the child target INI string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ChildTargetToIni(tinfParent, &iniTargets)
{
	children := tinfParent.GetChildren()
	if (IsObject(children)) {
		for tinf in children {
			ME_TargetToIniIncludeChildren(tinf, &iniTargets)
		}
	}
}

;-------------------------------------------------------------------------------
; Generates the single-target INI string
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetToIni(tinf)
{
	buf := "[" tinf.Name "]`n"
	if (tinf.IconFileAndIndex != "") {
		buf .= "Icon=" tinf.IconFileAndIndex "`n"
	}
	if (tinf.NestLevel > 1) {
		buf .= "Level=" tinf.NestLevel "`n"
	}
	if (tinf.MatchAll) {
		buf .= "And=1`n"
	}
	if (tinf.DefActionDisabled) {
		buf .= "ExcludeDefault=1`n"
	}
	if (tinf.NoInheritance) {
		buf .= "NotInherit=1`n"
	}
	conds := tinf.GetConditions()
	if (IsObject(conds)) {
		for cond in conds {
			buf .= cond.type "=" cond.value "`n"
		}
	}
	return buf
}

;-------------------------------------------------------------------------------
; Generates the gesture section string
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureToIni(ginf)
{
	if (!IsObject(ginf)) {
		return
	}
	iniGestures := "[" ginf.Name "]`n"
	pats := ginf.GetPatterns()
	if (IsObject(pats)) {
		for pat in pats {
			iniGestures .= "G=" pat "`n"
		}
	}
	targets := ginf.GetTargets()
	if (IsObject(targets)) {
		for target in targets {
			iniGestures .= target.name "=" target.action "`n"
		}
	}
	return iniGestures
}

;-------------------------------------------------------------------------------
; Generates the configuration script string
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ConfigToAhk()
{
	global ME_ExDefMap, ME_ExDefStr, ME_GestureFuncs

	ME_ExDefMap := Map()
	ME_ExDefStr := ""
	ME_GestureFuncs := []
	ME_EnumTriggers()

	allScript := ";-------------------------------------------------------------------------------`n"
	allScript .= "; General settings`n`n"
	allScript .= ME_GeneralSettingsToAhk() "`n"
	allScript .= "Goto(`"MG_GestureFuncs_End`")`n`n"

	allScript .= ";-------------------------------------------------------------------------------`n"
	allScript .= "; Target determination functions`n"
	for tinf in ME_Targets {
		ME_TargetToAhkIncludeChildren(tinf, &allScript)
	}
	allScript .= "`nMG_IsExDefault() {`n`treturn (" (ME_ExDefStr ? ME_ExDefStr : 0) ")`n}`n`n" 

	allScript .= ";-------------------------------------------------------------------------------`n"
	allScript .= "; Gesture action functions`n"
	for idx, ginf in ME_Gestures {
		Join(&allScript, ME_GestureToAhk(idx, ginf))
	}

	allScript .= ";-------------------------------------------------------------------------------`n"
	allScript .= "; Trigger Button HotIf Functions`n`n" 
	allScript .= ME_GetTriggerActivationFuncStr()

	allScript .= "MG_GestureFuncs_End:`n`n"

	allScript .= ";-------------------------------------------------------------------------------`n"
	allScript .= "; Gesture Triggers`n`n"
	bUseScreenEdge := false
	allScript .= ME_GetTriggerStr(&bUseScreenEdge)
	allScript .= "MG_bUseScrenEdge := " bUseScreenEdge "`n`n"

	allScript .= ";-------------------------------------------------------------------------------`n"
	allScript .= "; Gesture Map`n`n"
	allScript .= ME_GetGestureMapStr()

	allScript .= ";-------------------------------------------------------------------------------`n"
	allScript .= "; Hotkeys`n`n"
	allScript .= ME_GetHotkeyStr()

	return allScript
}

;-------------------------------------------------------------------------------
; Enumerates the gesture triggers
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnumTriggers()
{
	global ME_MaxLength, ME_AllTriggers, ME_SubTriggers, ME_TargetFuncMap

	ME_MaxLength   := 0
	ME_AllTriggers := []
	ME_SubTriggers := []
	ME_TargetFuncMap := Map()

	gesPatterns := ""
	for ginf in ME_Gestures {
		pats := ginf.GetPatterns()
		if (!IsObject(pats)) {
			continue
		}
		for pat in pats {
			len := StrLen(pat)
			ME_MaxLength := (ME_MaxLength < len) ? len : ME_MaxLength
			Join(&gesPatterns, pat)
		}
	}

	nonTriggers := []
	for binf in ME_AllButtons {
		if(RegExMatch(gesPatterns, "m`n)^" binf.Name "_")) {
			ME_AllTriggers.Push(binf)
			ME_TargetFuncMap[binf.Name] := ""
		} else {
			nonTriggers.Push(binf)
		}
	}

	for binf in nonTriggers {
		if (RegExMatch(gesPatterns, "_" binf.Name "_")) {
			ME_AllTriggers.Push(binf)
			ME_SubTriggers.Push(binf)
			ME_TargetFuncMap[binf.Name] := ""
		}
	}
}

;-------------------------------------------------------------------------------
; Generates the general setting string of configuration script
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_GeneralSettingsToAhk()
{
	ME_ConvertDiagonalAngles()

	buf := ""
	for conf in tblConfRecog {
		quote := (conf.type = "String") ? "`"" : ""
		varName := "Config_" conf.name
		buf .= "MG_" conf.name " := " quote %varName% quote "`n"
	}
	for conf in tblConfHints {
		quote := (conf.type = "String") ? "`"" : ""
		varName := "Config_" conf.name
		buf .= "MG_" conf.name " := " quote %varName% quote "`n"
	}
	for conf in tblConfTrail {
		quote := (conf.type = "String") ? "`"" : ""
		varName := "Config_" conf.name
		buf .= "MG_" conf.name " := " quote %varName% quote "`n"
	}
	for conf in tblConfLog {
		quote := (conf.type = "String") ? "`"" : ""
		varName := "Config_" conf.name
		buf .= "MG_" conf.name " := " quote %varName% quote "`n"
	}
	for conf in tblConfOthers {
		quote := (conf.type = "String") ? "`"" : ""
		varName := "Config_" conf.name
		buf .= "MG_" conf.name " := " quote %varName% quote "`n"
	}
	buf .= "MG_MaxLength := " ME_MaxLength "`n"

	tbl := ""
	indentStr := "`t`t`t`t`t , "
	for binf in ME_AllButtons {
		if (!ME_mapArrowColors.Has(binf.Name)) {
			continue
		}
		hexColor := ME_mapArrowColors[binf.Name]
		if (hexColor != "") {
			Join(&tbl, indentStr "`"" binf.Name "`", `"" hexColor "`"")
		}
	}
	tbl := RegExReplace(tbl, "^" indentStr)
	buf .= "MG_ArrowColors := Map( " tbl " )`n"

	buf .= "MG_ExcActivate := ["
	for idx, ex in ME_ExcActivate {
		buf .= (idx > 1) ? "`n`t`t`t`t,  " : ""
		buf .= "{ title: `"" ex.title "`", class: `"" ex.class "`", exe: `"" ex.exe "`" }"
	}
	buf .= "]`n"
	return buf
}

;-------------------------------------------------------------------------------
; Convert the angle value of the diagonal stroke
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ConvertDiagonalAngles()
{
	global
	Config_ORangeDefault := MG_GetAngleThreshold(Config_ORangeDefault)
	Config_ORangeA		 := MG_GetAngleThreshold(Config_ORangeA)
	Config_ORangeB		 := MG_GetAngleThreshold(Config_ORangeB)
}

;-------------------------------------------------------------------------------
; Generates the target AHK script string that includes child targets
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetToAhkIncludeChildren(tinf, &ahkTargets)
{
	Join(&ahkTargets, ME_TargetToAhk(tinf))
	ME_ChildTargetToAhk(tinf, &ahkTargets)
}

;-------------------------------------------------------------------------------
; Generates the child target AHK script string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ChildTargetToAhk(tinfParent, &ahkTargets)
{
	children := tinfParent.GetChildren()
	if (IsObject(children)) {
		for tinf in children {
			ME_TargetToAhkIncludeChildren(tinf, &ahkTargets)
		}
	}
}

;-------------------------------------------------------------------------------
; Generates the single-target AHK script string
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetToAhk(tinf)
{
	global ME_ExDefMap, ME_ExDefStr

	buf := ""
	delim := tinf.MatchAll ? " && " : " || "
	conds := tinf.GetConditions()
	if (IsObject(conds)) {
		for cond in conds {
			ruleType := cond.type
			bInvert := false
			methodCode := ME_GetMatchingMethod(ruleType, &bInvert)
			invertPrefix := bInvert ? "!" : ""
			ruleType := RegExReplace(ruleType, "_.+$")
			if (ruleType = "Custom") {
				Join(&buf, invertPrefix "(" cond.value ")", delim)
			}
			else if (ruleType = "Include") {
				tinfInc := ME_TargetInfoFromName(cond.value)
				if (tinfInc.Parent!=tinf || tinfInc.NoInheritance) {
					Join(&buf, invertPrefix "(" ME_GetTargetFuncName(tinfInc) ")", delim)
				}
			}
			else if (methodCode == 1) {
				Join(&buf, invertPrefix "(MG_" ruleType "=`"" cond.value "`")", delim)
			}
			else {
				Join(&buf, invertPrefix "(MG_StrComp(MG_" ruleType ", `"" cond.value "`", " methodCode "))", delim)
			}
		}
	}
	if (buf == "") {
		buf := (tinf.TotalChildrenNum > 0) ? "1" : "0"
	}
	if (IsObject(tinf.Parent) && !tinf.NoInheritance) {
		buf := ME_GetTargetFuncName(tinf.Parent) " && (" buf ")"
	}
	targetFunc := ME_GetTargetFuncName(tinf)
	ret := "; " tinf.FullName "`n"
	ret .= targetFunc " {`n	global`n	return (" buf ")`n}`n"
	if (tinf!=ME_Targets[1] && tinf.DefActionDisabled) {
		for binf in ME_AllTriggers {
			exDef := ME_ExDefMap.Has(binf.Name) ? ME_ExDefMap[binf.Name] : ""
			ME_ExDefMap[binf.Name] := exDef " && !" targetFunc
		}
		Join(&ME_ExDefStr, targetFunc, " || ")
	}
	return ret
}

;-------------------------------------------------------------------------------
; Generates the gesture subroutine string
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureToAhk(idxG, ginf)
{
	global ME_TargetFuncMap, ME_ExDefMap, ME_GestureFuncs

	pats := IsObject(ginf) ? ginf.GetPatterns() : ""
	if (!IsObject(pats) || pats.Length==0) {
		return ""
	}

	triggers := Map()
	headerAct := ""
	for idx, pat in ginf.GetPatterns() {
		if (idx == 1) {
			funcName := "MG_Action" idxG
			headerAct .= "; " ginf.Name "`n"
			headerAct .= funcName "(bExecute:=true) {`n"
		}
		if (RegExMatch(pat, "^(.+?)_.*", &part)) {
			triggers[part[1]] := true
		}
		ME_GestureFuncs.Push({pattern: pat, func: funcName})
	}
	if (headerAct == "") {
		return ""
	}

	targetAct := defaultAct := targetFuncs := defaultFunc := ""
	bDefSet := false
	for idx, target in ginf.GetTargets() {
		titleStr := ME_ActionTitleStr(target.action, "ReplaceQuotes")
		nameTarget := target.name
		if (nameTarget = ME_DefTargetName) {
			funcName := "MG_Action" idxG "_Default()"
			defaultAct := "return bExecute ? " funcName " : `"" titleStr "`"" 
			for key in triggers {
				ME_TargetFuncMap[key] := ME_DefTargetName
			}
			actScript := ME_ReplaceCR(target.action, "Decode", 1)
			defaultFunc := funcName " {`n"
			if (Config_VarAssumeGlobal) {
				defaultFunc .= "`tglobal`n"
			}
			defaultFunc .= "`t" actScript "`n}`n`n"
		}
		else {
			targetAct .= "`t; " nameTarget "`n`t"
			if (bDefSet) {
				targetAct .= "else "
			}
			bDefSet := true
			targetFunc := ME_GetTargetFuncName(ME_TargetInfoFromName(nameTarget))
			funcName := "MG_Action" idxG "_" idx "()"
			targetAct .= "if (" targetFunc ") {`n"
			targetAct .= "`t`treturn bExecute ? " funcName " : `"" titleStr "`"`n`t}`n"
			for key in triggers {
				funcOR := ME_TargetFuncMap[key]
				if (!InStr(funcOR, targetFunc)) {
					ME_TargetFuncMap[key] := Join(&funcOR, targetFunc, " || ")
				}
				if (ME_ExDefMap.Has(key)) {
					ME_ExDefMap[key] := StrReplace(ME_ExDefMap[key], " && !" targetFunc)
				}
			}
			actScript := ME_ReplaceCR(target.action, "Decode", 1)
			targetFuncs .= funcName " {`n"
			if (Config_VarAssumeGlobal) {
				targetFuncs .= "`tglobal`n"
			}
			targetFuncs .= "`t" actScript "`n}`n`n"
		}
	}

	elseAct := "`t; " ME_LngOthers001 "`n`telse "
	if (targetAct != "") {
		if (defaultAct) {
			elseAct .= "if (!MG_IsExDefault())"
		} else {
			defaultAct := "MG_Cancel()"
		}
		targetAct := headerAct . targetAct . elseAct "{`n`t`t" defaultAct "`n`t}`n"
	} else {
		targetAct := headerAct "`t; " ME_LngOthers001 "`n"
		targetAct .= "`tif (!MG_IsExDefault()) {`n`t`t" defaultAct "`n`t}`n"
	}
	return targetAct "`treturn `"`"`n}`n`n" targetFuncs . defaultFunc
}

;-------------------------------------------------------------------------------
; Get name of the target discriminant function
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetTargetFuncName(tinf)
{
	idx := ME_mapTargetOrder[tinf]
	return "MG_Is" ((idx==1) ? "Disabled" : "Target" idx-1) "()"
}

;-------------------------------------------------------------------------------
; Generates the trigger activation function string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetTriggerActivationFuncStr()
{
	global ME_IsHookEnabledFuncs

	ME_IsHookEnabledFuncs := Map()
	for binf in ME_AllTriggers {
		funcName := "MG_IsHookEnabled_" binf.Name
		ME_IsHookEnabledFuncs[binf.Name] := funcName
		funcScript := ME_TargetFuncMap[binf.Name]
		buf .= funcName "(*) {`n`tglobal`n"
		if (funcScript == "") {
			buf .= "`treturn (MG_TriggerEnabled(`"" binf.Name "`") && MG_TriggerCount())"
		}
		else {
			buf .= "`tMG_TriggerCount() ? `"`" : MG_GetMousePosInfo()`n"
			buf .= "`treturn (MG_TriggerEnabled(`"" binf.Name "`") && (MG_TriggerCount() || (!MG_IsDisabled()"
			if (InStr(funcScript, ME_DefTargetName)) {
				buf .= (ME_ExDefMap.Has(binf.Name) ? ME_ExDefMap[binf.Name] : "") . ")))"
			} else {
				buf .= " && (" funcScript "))))"
			}
		}
		buf .= "`n}`n`n"
	}
	return buf
}

;-------------------------------------------------------------------------------
; Generates the trigger array string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetTriggerStr(&bUseScreenEdge)
{
	mainTriggers := subTriggers := triggersRegEx := ""

	for binf in ME_AllTriggers {
		Join(&mainTriggers, binf.Name, "`", `"")
		Join(&triggersRegEx, binf.Name, "|")
		if (binf.Type = "Edge") {
			bUseScreenEdge := true
		}
	}

	for binf in ME_SubTriggers {
		Join(&subTriggers, binf.Name, "`", `"")
	}
	if (subTriggers != "") {
		mainTriggers := RegExReplace(mainTriggers, "`", `"" subTriggers "$")
	}

	buf := ""
	buf .= "MG_MainTriggers := [ `"" mainTriggers "`" ]`n`n"
	buf .= "MG_SubTriggers := [ `"" subTriggers "`" ]`n`n"
	buf .= "MG_TriggersRegEx := `"(" triggersRegEx ")`"`n`n"
	buf .= ME_GetTriggerMapStr()
	return buf
}

;-------------------------------------------------------------------------------
; Generates the trigger map string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetTriggerMapStr()
{
	map := ""
	indentStr := "`t`t`t`t`t, "
	for binf in ME_AllTriggers {
		sendKey := binf.AhkKey
		if (StrLen(sendKey) > 1) {
			sendKey := RegExReplace(sendKey, "^[~*]")
		}
		Join(&map, indentStr "`"" binf.Name "`", { "
						  . "hotkey: `"" binf.AhkKey "`", "
						  . "sendkey: `"" sendKey "`", "
						  . "hotif: " ME_IsHookEnabledFuncs[binf.Name] ", "
						  . "IsWheel: " (binf.Type = "Wheel") " }")
	}
	return "MG_TriggerMap := Map( " RegExReplace(map, "^" indentStr) " )`n`n"
}

;-------------------------------------------------------------------------------
; Generates the gesture map string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetGestureMapStr()
{
	map := ""
	indentStr := "`t`t`t`t`t, "
	for finf in ME_GestureFuncs {
		Join(&map, indentStr "`"" finf.pattern "`", " finf.func "")
	}
	return "MG_GestureMap := Map( " RegExReplace(map, "^" indentStr) " )`n`n"
}

;-------------------------------------------------------------------------------
; Generates the hotkey setting string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetHotkeyStr()
{
	hotkeyStr := ""
	if (Config_HotkeyReload) {
		hotkeyStr .= "Hotkey(`"" Config_HotkeyReload "`", MG_Reload, `"On P" ME_ReloadHotkeyPriority "`")`n"
	}
	if (Config_HotkeyEnable) {
		hotkeyStr .= "Hotkey(`"" Config_HotkeyEnable "`", MG_ToggleEnable, `"On`")`n"
	}
	if (Config_HotkeyNavi) {
		hotkeyStr .= "Hotkey(`"" Config_HotkeyNavi "`", MG_ToggleHints, `"On`")`n"
	}
	if (Config_HotkeyAbort || Config_HotkeyShowList) {
		hotkeyStr .= "HotIf(MG_IsActive)`n"
		if (Config_HotkeyAbort) {
			hotkeyStr .= "Hotkey(`"" Config_HotkeyAbort "`", MG_Abort, `"On`")`n"
		}
		if (Config_HotkeyShowList) {
			hotkeyStr .= "Hotkey(`"" Config_HotkeyShowList "`", MG_ShowGestureList, `"On`")`n"
		}
		hotkeyStr .= "HotIf()`n`n"
	}
	return hotkeyStr
}

;-------------------------------------------------------------------------------
; Replace carriage returns with placeholders, and vice versa.
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ReplaceCR(actScript, mode, indent:=0)
{
	if (mode = "Encode") {
		return StrReplace(actScript, "`n", "<MG_CR>")
	}
	else if (mode = "Decode") {
		tabs := ""
		Loop indent {
			tabs .= "`t"
		}
		actScript := StrReplace(actScript, "<MG_TAB>", "`t")
		return StrReplace(actScript, "<MG_CR>", "`n" tabs)
	}
	return ""
}

ME_ConfigEnd:
