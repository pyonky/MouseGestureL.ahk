;===============================================================================
;
;		MouseGestureL.ahk - Language Definition Module
;			<< 简体中文 v1.61 >>
;			Created by 盆地平平
/*
问题：
右键+滚轮型手势无法显示提示，但却总会显示所有被识别的手势，哪怕这个手势没有动作，哪怕是一个释放型手势。
激活前一个窗口功能，应该跳过有置顶属性的窗口，否则激活时就像功能失效一样。同时TIM无法被激活。
鼠标手势在屏幕中间固定显示。

翻译原则：
中文引号“”括起的对象原则上两边不加空格。
英文括号()括起的对象原则上两边不加空格。
数字与英文两边不加空格。
～两边加空格。
秒用s、毫秒用ms、像素用px、角度用deg。
统一名词“触发键”。
统一用数字123代替中文数字一二三(除单词“一个”)。
*/
;===============================================================================
;-------------------------------------------------------------------------------
; Common
;-------------------------------------------------------------------------------
; Language Name
MC_LanguageName := "简体中文"

; Help File
MC_HelpFile := "MouseGestureL_ENG.chm"

; Buttons
MC_LngButton001 := "关闭"
MC_LngButton002 := "复制到剪贴板"

; Messages
MC_LngMessage001 := "没找到帮助文件。"
MC_LngMessage002 :=
(LTrim
			   "可能是设置中出现了问题。
				从以下信息中寻找问题的原因，并通过设置对话框修改。
				如果您不能做到这一点，请从备份中恢复配置文件。
				`n----------------------------------------------------------------------`n`n"
)

; User Extension Script
MG_UserExtension := [
(LTrim
			   ";===============================================================================
				;
				;		MouseGestureL.ahk 用户扩展
				;
				;	- 此文件描述了额外的初始化过程和用户定义的子程序与函数。
				;	- 当你修改了这个文件的内容后，必须重新加载脚本。
				;
				;===============================================================================`n"
)
			 , "; 在此处添加代码，以便在 MouseGestureL.ahk 的主初始化之前运行。"
			 , "; 把想在 MouseGestureL.ahk 初始化完成后运行的程序放在下面。"
			 , "; 子程序与函数定义" ]

if (MG_IsEdit) {
	Goto("MG_SetEditLang")
}
;-------------------------------------------------------------------------------
; for MouseGestureL.ahk
;-------------------------------------------------------------------------------
; Menus
MG_LngMenu001 := "AutoHot&key"
MG_LngMenu002 := "开启手势(&E)"
MG_LngMenu003 := "显示提示(&G)"
MG_LngMenu004 := "设置(&C)..."
MG_LngMenu005 := "编辑用户扩展(&U)"
MG_LngMenu006 := "复制日志到剪贴板(&P)"
MG_LngMenu007 := "打开插件目录(&O)"
MG_LngMenu008 := "插件(&P)"
MG_LngMenu009 := "语言(&L)..."
MG_LngMenu010 := "帮助(&H)"
MG_LngMenu011 := "关于(&A)"
MG_LngMenu012 := "重启(&R)"
MG_LngMenu013 := "退出(&X)"
MG_LngMenu014 := "&MouseGestureL"

; Tooltips
MG_LngTooltip001 := "手势已启用"
MG_LngTooltip002 := "手势已关闭"
MG_LngTooltip003 := "提示 ON"
MG_LngTooltip004 := "提示 OFF"

Goto("MG_LanguageEnd")

;-------------------------------------------------------------------------------
; for MG_Edit.ahk
;-------------------------------------------------------------------------------
MG_SetEditLang:

; User Extension Script
ME_UserExtension := [
(LTrim
			   ";===============================================================================
				;
				;		MG_Edit.ahk 用户扩展
				;
				;	- 此文件描述了额外的初始化过程和用户定义的子程序与函数。
				;	- 你可以通过设置适当的变量来改变配置对话框的大小。
				;	- 当你修改了这个文件的内容后，必须重新加载脚本。
				;
				;===============================================================================`n"
)
			 , "; 在此处添加代码，以便在 MG_Edit.ahk 的主初始化之前运行。"
			 , "; 把想在 MG_Edit.ahk 初始化完成后运行的程序放在下面。"
			 , "; 子程序与函数定义" ]

; Gesture Triggers
ME_BtnDesc_LB	:= "左键"
ME_BtnDesc_RB	:= "右键"
ME_BtnDesc_MB	:= "中键"
ME_BtnDesc_X1B	:= "第4键"
ME_BtnDesc_X2B	:= "第5键"
ME_BtnDesc_WU	:= "滚轮上"
ME_BtnDesc_WD	:= "滚轮下"
ME_BtnDesc_LT	:= "左滚轮"
ME_BtnDesc_RT	:= "右滚轮"
ME_BtnDesc_ET	:= "触碰屏幕上方 	(整体)"
ME_BtnDesc_ETA	:= "触碰屏幕上方 	(左1/2)"
ME_BtnDesc_ETB	:= "触碰屏幕上方 	(右1/2)"
ME_BtnDesc_ET1	:= "触碰屏幕上方 	(左1/3)"
ME_BtnDesc_ET2	:= "触碰屏幕上方 	(中央1/3)"
ME_BtnDesc_ET3	:= "触碰屏幕上方 	(右1/3)"
ME_BtnDesc_EB	:= "触碰屏幕下方 	(整体)"
ME_BtnDesc_EBA	:= "触碰屏幕下方 	(左1/2)"
ME_BtnDesc_EBB	:= "触碰屏幕下方 	(右1/2)"
ME_BtnDesc_EB1	:= "触碰屏幕下方 	(左1/3)"
ME_BtnDesc_EB2	:= "触碰屏幕下方 	(中央1/3)"
ME_BtnDesc_EB3	:= "触碰屏幕下方 	(右1/3)"
ME_BtnDesc_EL	:= "触碰屏幕左侧 	(整体)"
ME_BtnDesc_ELA	:= "触碰屏幕左侧 	(上1/2)"
ME_BtnDesc_ELB	:= "触碰屏幕左侧 	(下1/2)"
ME_BtnDesc_EL1	:= "触碰屏幕左侧 	(上1/3)"
ME_BtnDesc_EL2	:= "触碰屏幕左侧 	(中央1/3)"
ME_BtnDesc_EL3	:= "触碰屏幕左侧 	(下1/3)"
ME_BtnDesc_ER	:= "触碰屏幕右侧 	(整体)"
ME_BtnDesc_ERA	:= "触碰屏幕右侧 	(上1/2)"
ME_BtnDesc_ERB	:= "触碰屏幕右侧 	(下1/2)"
ME_BtnDesc_ER1	:= "触碰屏幕右侧 	(上1/3)"
ME_BtnDesc_ER2	:= "触碰屏幕右侧 	(中央1/3)"
ME_BtnDesc_ER3	:= "触碰屏幕右侧 	(下1/3)"
ME_BtnDesc_CRT	:= "触碰屏幕右上角"
ME_BtnDesc_CLT	:= "触碰屏幕左上角"
ME_BtnDesc_CRB	:= "触碰屏幕右下角"
ME_BtnDesc_CLB	:= "触碰屏幕左下角"

; Action Categories
ActionType001 := "全部"
ActionType002 := "按键模拟"
ActionType003 := "滚动模拟"
ActionType004 := "窗口控制"
ActionType005 := "程序控制"
ActionType006 := "程序功能调用"
ActionType007 := "声音控制"
ActionType008 := "手势控制"
ActionType009 := "提示与轨迹"
ActionType010 := "批量窗口控制"
ActionType100 := "其它"

; Action Templates
ActionName001 := "按键"
ActionName002 := "点击鼠标"
ActionName003 := "滚动滚轮"
ActionName004 := "移动鼠标"
ActionName011 := "键盘滚动"
ActionName012 := "拖拽滚动"
ActionName021 := "激活窗口"
ActionName022 := "最小化窗口"
ActionName023 := "最大化窗口"
ActionName024 := "还原窗口"
ActionName025 := "关闭窗口"
ActionName026 := "窗口置底"
ActionName027 := "窗口置顶"
ActionName028 := "取消窗口置顶"
ActionName029 := "切换窗口置顶"
ActionName030 := "移动与缩放窗口"
ActionName031 := "设置窗口透明度"
ActionName032 := "取消窗口透明"
ActionName033 := "激活前一个窗口"
ActionName034 := "移动窗口"
ActionName041 := "最小化同类窗口"
ActionName042 := "关闭同类窗口"
ActionName043 := "还原同类窗口"
ActionName044 := "排列同类窗口"
ActionName051 := "运行程序"
ActionName052 := "杀死进程"
ActionName061 := "调用目标工具栏"
ActionName062 := "调用目标菜单栏"
ActionName071 := "设置音量大小"
ActionName072 := "设置静音状态"
ActionName073 := "播放声音"
ActionName081 := "取消手势"
ActionName082 := "等待下个手势"
ActionName083 := "等待指定时间"
ActionName084 := "等待结束后运行"
ActionName085 := "触发键释放后运行"
ActionName086 := "触发键释放时停止循环"
ActionName087 := "处理阻塞型操作"
ActionName088 := "是首个被激活的手势则运行"
ActionName089 := "执行触发键的默认行为"
ActionName090 := "取消触发键的默认行为"
ActionName091 := "禁用手势超时"
ActionName092 := "将当前手势设为基态1"
ActionName093 := "将当前手势设为基态2"
ActionName094 := "将活动窗口设为目标"
ActionName101 := "暂停手势提示"
ActionName102 := "恢复手势提示"
ActionName103 := "暂停手势轨迹"
ActionName104 := "恢复手势轨迹"
ActionName105 := "将文本显示为文字提示"
ActionName901 := "复制文本到剪贴板"
ActionName902 := "Post Message"
ActionName903 := "Send Message"

; Action Comments
ActionComment001 := "识别手势后立即执行的动作"
ActionComment002 := "等待时间过后执行的动作"
ActionComment003 := "按住触发键时重复执行的动作"
ActionComment004 := "释放触发键时执行的动作"
ActionComment005 := "释放触发键时执行的动作"
ActionComment006 := "即使下面的动作包含阻塞型操作，例如“MsgBox”，也不影响下个手势的识别"
ActionComment007 := "如果本手势是按下触发键后，首个被激活的手势，则继续执行下面的动作"
ActionComment011 := "按 ###REPLACE###"
ActionComment012 := "按下 ###REPLACE###"
ActionComment013 := "释放 ###REPLACE###"
ActionComment014 := " (###REPLACE### 次)"
ActionComment021 := "单击 ###REPLACE###"
ActionComment022 := "按住 ###REPLACE###"
ActionComment023 := "释放 ###REPLACE###"
ActionComment031 := "滚轮上滚"
ActionComment032 := "滚轮下滚"
ActionComment033 := " (###REPLACE### 圈)"
ActionComment041 := "移动鼠标到手势开始位置"
ActionComment042 := "从手势开始位置移动鼠标到 ###REPLACE###"
ActionComment043 := "从手势结束位置移动鼠标到 ###REPLACE###"
ActionComment044 := "从当前位置移动鼠标到 ###REPLACE###"
ActionComment045 := "移动鼠标到 ###REPLACE###"
ActionComment051 := "上滚页面"
ActionComment052 := "下滚页面"
ActionComment053 := "左滚页面"
ActionComment054 := "右滚页面"
ActionComment055 := " (###REPLACE### 行)"
ActionComment056 := " (###REPLACE### 页)"
ActionComment061 := "移动并重设窗口为 (###REPLACE###)"
ActionComment062 := "移动窗口到 ###REPLACE###"
ActionComment071 := "水平排列同类窗口"
ActionComment072 := "垂直排列同类窗口"
ActionComment073 := "纵横排列同类窗口"

; Caption of Dialog Box
ME_LngCapt001 := "MouseGestureL"
ME_LngCapt002 := "MouseGestureL 设置"
ME_LngCapt003 := "确认删除"
ME_LngCapt004 := "确认覆盖"
ME_LngCapt005 := "编辑触发键"
ME_LngCapt006 := "指定脚本编辑器"
ME_LngCapt007 := "箭头颜色"
ME_LngCapt008 := "矩形区域"
ME_LngCapt009 := "例外列表 (列表中的对象不会被动作“激活前一个窗口”所激活)"
ME_LngCapt010 := "任务列表"
ME_LngCapt011 := "添加动作"
ME_LngCapt012 := "生成按键"
ME_LngCapt013 := "直接编辑按键"
ME_LngCapt014 := "生成鼠标点击"
ME_LngCapt015 := "生成滚轮滚动"
ME_LngCapt016 := "生成鼠标移动"
ME_LngCapt017 := "生成键盘滚动"
ME_LngCapt018 := "生成拖拽滚动"
ME_LngCapt019 := "移动与缩放窗口"
ME_LngCapt020 := "移动窗口"
ME_LngCapt022 := "运行程序"
ME_LngCapt023 := "播放声音"
ME_LngCapt024 := "Post/SendMessage"
ME_LngCapt025 := "选择图标文件"
ME_LngCapt026 := "最小化同类窗口"
ME_LngCapt027 := "关闭同类窗口"
ME_LngCapt028 := "还原同类窗口"
ME_LngCapt029 := "排列同类窗口"

; Tabs
ME_LngTab001 := [ "主要", "目标", "手势", "识别", "提示", "轨迹与日志", "其它" ]

; Menus
ME_LngMenu000 := "(无)"
ME_LngMenu001 := "匹配窗口位置"
ME_LngMenu002 := "标题栏"
ME_LngMenu003 := "标题栏图标"
ME_LngMenu004 := "最小化按钮"
ME_LngMenu005 := "最大化按钮"
ME_LngMenu006 := "关闭按钮"
ME_LngMenu007 := "帮助按钮"
ME_LngMenu008 := "菜单栏"
ME_LngMenu009 := "垂直滚动条"
ME_LngMenu010 := "水平滚动条"
ME_LngMenu011 := "细边框 	(Border)"
ME_LngMenu012 := "可调整窗口大小的边框处"
ME_LngMenu013 := "客户区 	(Client)"
ME_LngMenu014 := "表格/树视图 	(ListView/TreeView)"
ME_LngMenu015 := "匹配鼠标形状"
ME_LngMenu016 := "箭头 	(正常)"
ME_LngMenu017 := "文本 	(文本选择)"
ME_LngMenu018 := "手指 	(链接选择)"
ME_LngMenu019 := "沙漏 	(忙)"
ME_LngMenu020 := "十字 	(精确选择)"
ME_LngMenu021 := "禁止 	(不可用)"
ME_LngMenu022 := "箭头+沙漏 	(后台运行)"
ME_LngMenu023 := "箭头+问号 	(帮助选择)"
ME_LngMenu024 := "上下左右箭头 	(移动)"
ME_LngMenu025 := "上下箭头 	(垂直调整大小)"
ME_LngMenu026 := "左右箭头 	(水平调整大小)"
ME_LngMenu027 := "＼箭头 	(沿对角线调整大小1)"
ME_LngMenu028 := "／箭头 	(沿对角线调整大小2)"
ME_LngMenu029 := "垂直箭头 	(候选)"
ME_LngMenu030 := "以上任意形状"
ME_LngMenu031 := "非系统自带形状"
ME_LngMenu032 := "匹配窗口状态"
ME_LngMenu033 := "最大化"
ME_LngMenu034 := "正常"
ME_LngMenu035 := "半透明"
ME_LngMenu036 := "不透明"
ME_LngMenu037 := "置顶"
ME_LngMenu038 := "非置顶"
ME_LngMenu039 := "匹配键盘状态"
ME_LngMenu040 := "Shift 	按下"
ME_LngMenu041 := "Shift 	释放"
ME_LngMenu042 := "Ctrl 	按下"
ME_LngMenu043 := "Ctrl 	释放"
ME_LngMenu044 := "Alt 	按下"
ME_LngMenu045 := "Alt 	释放"
ME_LngMenu046 := "匹配矩形区域"
ME_LngMenu047 := "使用窗口坐标"
ME_LngMenu048 := "使用屏幕坐标"
ME_LngMenu049 := "触碰屏幕边缘"
ME_LngMenu050 := "键盘触发"
ME_LngMenu101 := "设置目标(&T)	Enter"
ME_LngMenu102 := "新建目标(&N)	Ctrl+N"
ME_LngMenu103 := "添加子项(&S)"
ME_LngMenu104 := "添加手势(&A)"
ME_LngMenu105 := "删除(&D)	Delete"
ME_LngMenu106 := "复制(&P)	Ctrl+D"
ME_LngMenu107 := "复制到剪贴板(&C)	Ctrl+C"
ME_LngMenu108 := "从剪贴板导入(&I)	Ctrl+V"
ME_LngMenu109 := "上移(&U)	Shift+↑"
ME_LngMenu110 := "下移(&O)	Shift+↓"
ME_LngMenu111 := "按 A-Z 排序(&R)"
ME_LngMenu112 := "展开全部子项(&E)	Ctrl+E"
ME_LngMenu113 := "分配手势(&G)	Enter"
ME_LngMenu121 := "新建手势(&N)"
ME_LngMenu122 := "设置手势(&G)	Enter"
ME_LngMenu123 := "更换手势(&C)"
ME_LngMenu124 := "复制到其它目标(&T)"
ME_LngMenu125 := "使用外部编辑器进行编辑(&E)	Ctrl+Enter"
ME_LngMenu141 := "新建手势(&N)	Ctrl+N"
ME_LngMenu142 := "编辑(&E)..."
ME_LngMenu151 := "更换目标(&T)"

; Static Text
ME_LngText001 := "目标:"
ME_LngText002 := "手势:"
ME_LngText003 := "目标优先级:"
ME_LngText004 := "动作脚本:"
ME_LngText005 := "类别:"
ME_LngText006 := "动作:"
;下面这个值被目标和手势两个选项卡共用，要是分开的话，就可以单独翻译为“目标”和“手势”了。
ME_LngText011 := "名称:"
ME_LngText012 := "类型:"
ME_LngText013 := "值:"
ME_LngText014 := "判定方法:"
ME_LngText021 := "手势触发键:"
ME_LngText022 := "鼠标移动:"
ME_LngText023 := "名称:"
ME_LngText024 := "函数名:"
ME_LngText025 := "触发键:"
ME_LngText026 := "全局动作:"
ME_LngText027 := "高"
ME_LngText028 := "低"
ME_LngText029 := "请用下划线“_”(点击 “释放”按钮添加)关闭手势，除非你打算进行特殊设置。`n手势末尾的下划线意味着手势将在触发键被释放时激活。`n`n`t【×】   ###REPLACE###`n`t【〇】   ###REPLACE###_`n`n如果你了解规范并有意定义按下即触发型手势，可忽略此警告。"
ME_LngText100 := "识别间隔 (ms):"
ME_LngText101 := "普通移动:"
ME_LngText102 := "横向超长移动:"
ME_LngText103 := "竖向超长移动:"
ME_LngText104 := "斜向超长移动:"
ME_LngText105 := "首次移动时:"
ME_LngText106 := "横竖移动后:"
ME_LngText107 := "斜向移动后:"
ME_LngText108 := "鼠标移动多长距离后开始判断超时 (px):"
ME_LngText109 := "手势超时时间 (ms):`n(0表示永不超时)"
ME_LngText110 := "双重手势超时时间 (ms):"
ME_LngText111 := "识别间隔 (ms):"
ME_LngText112 := "四边角大小 (px):"
ME_LngText113 := "宽度:"
ME_LngText114 := "高度:"
ME_LngText115 := "超时后多长时间强制释放触发键 (s):`n(0表示不强制释放)"
ME_LngText200 := "提示类型:"
ME_LngText201 := "绘制间隔 (ms):"
ME_LngText202 := "手势结束后继续显示 (ms):"
ME_LngText203 := "箭头颜色 (RRGGBB):"
ME_LngText204 := "背景色 (RRGGBB):"
ME_LngText205 := "箭头透明度 (0 ～ 255):"
ME_LngText206 := "箭头大小 (px):"
ME_LngText207 := "箭头间距 (px):"
ME_LngText208 := "距离边缘 (px):"
ME_LngText209 := "距离鼠标 (px):`n(-1表示固定在起点)"
ME_LngText210 := "颜色:"
ME_LngText300 := "文本颜色 (RRGGBB):"
ME_LngText301 := "未确定文本颜色 (RRGGBB):"
ME_LngText302 := "窗口背景色 (RRGGBB):"
ME_LngText303 := "窗口透明度 (0 ～ 255):"
ME_LngText304 := "文本字号:"
ME_LngText305 := "文本字体:"
ME_LngText306 := "显示位置:"
ME_LngText307 := "左边距 (px):"
ME_LngText308 := "右边距 (px):"
ME_LngText309 := "上边距 (px):"
ME_LngText310 := "下边距 (px):"
ME_LngText311 := "圆角 (px):"
ME_LngText312 := "距离鼠标 (px):`n(-1表示固定在起点)"
ME_LngText313 := "距离边角X (px):"
ME_LngText314 := "距离边角Y (px):"
ME_LngText400 := "轨迹颜色 (RRGGBB):"
ME_LngText401 := "轨迹透明度 (0 ～ 255):"
ME_LngText402 := "轨迹宽度 (px):"
ME_LngText403 := "鼠标移动多长距离后开始绘制轨迹 (px):"
ME_LngText421 := "X:"
ME_LngText422 := "Y:"
ME_LngText423 := "日志最大行数:"
ME_LngText424 := "窗口宽度 (px):"
ME_LngText451 := "重启自己:"
ME_LngText452 := "手势开关:"
ME_LngText453 := "中止當前手势:"
ME_LngText454 := "显示手势清單:"
ME_LngText455 := "提示开关:"
ME_LngText456 := "高度限制 (0表示不限制):"
ME_LngText501 := "宽度:"
ME_LngText502 := "高度:"
ME_LngText503 := "* 宽度/高度设为0表示使用整个窗口/整个屏幕的宽度或高度。"
ME_LngText504 := "坐标模式:"
ME_LngText505 := "定位方法:"
ME_LngText506 := "判定方法:"
ME_LngText521 := "生成按键:"
ME_LngText522 := "点击:"
ME_LngText523 := "按键方式:"
ME_LngText524 := "按键计数:"
ME_LngText525 := "点击方式:"
ME_LngText526 := "点击计数:"
ME_LngText527 := "滚轮计数:"
ME_LngText528 := "移动起点:"
ME_LngText529 := "滚动方向:"
ME_LngText530 := "滚动计数:"
ME_LngText531 := "按住触发键时，通过移动鼠标滚动目标。"
ME_LngText532 := "* 本动作只适用于按下即触发型手势。"
ME_LngText533 := "垂直敏感度:"
ME_LngText534 := "水平敏感度:"
ME_LngText535 := "(值越小越敏感)"
ME_LngText536 := "滚动方向:"
ME_LngText537 := "滚动方法:"
ME_LngText541 := "指定窗口位置(左上角坐标)及窗口大小。"
ME_LngText542 := "- 用空白指定的项目将不会被更改。"
ME_LngText543 := "- 如果勾选了“使用相对值”，将根据当前位置/大小增加或减少。"
ME_LngText544 := "- 如果勾选了“使用相对值”，并指定了分数，将根据与当前位置/大小的比例来确定。"
ME_LngText545 := "- 如果不勾选“使用相对值”，并指定了分数，将根据与桌面大小的比例来确定(若需要与桌面一样大，请将宽度/高度指定为“0”替代“1/1”)。"
ME_LngText546 := "X:"
ME_LngText547 := "Y:"
ME_LngText548 := "宽度:"
ME_LngText549 := "高度:"
ME_LngText551 := "命令行:"
ME_LngText552 := "工作目录:"
ME_LngText553 := "窗口大小:"
ME_LngText554 := "运行权限:"
ME_LngText556 := "程序文件 (*.exe)"
ME_LngText557 := "声音文件 (*.wav;*.mid)"
ME_LngText558 := "图标文件 (*.ico;*.exe;*.dll;*.cpl;*.icl)"
ME_LngText561 := "消息:"
ME_LngText562 := "wParam:"
ME_LngText563 := "lParam:"
ME_LngText571 := "按窗口标题的文字进行过滤 (可省略)"
ME_LngText572 := "包含文字:"
ME_LngText573 := "排除文字:"
ME_LngText581 := "排列方向:"
ME_LngText582 := "左侧:"
ME_LngText583 := "右侧:"
ME_LngText584 := "上方:"
ME_LngText585 := "下方:"
ME_LngText591 := "指定窗口位置"
ME_LngText592 := "- 指定“目标位置”为“原始位置”时，通过此动作移动的窗口将返回到移动前的位置。"
ME_LngText593 := "- 指定“显示器编号”可将窗口移至对应显示器中(多显示器环境下）。"
ME_LngText594 := "- 指定“偏移量”可对“目标位置”进行微调。"
ME_LngText595 := "目标位置:"
ME_LngText596 := "显示器编号 #:"
ME_LngText597 := "X:"
ME_LngText598 := "Y:"

; Buttons
ME_LngButton001 := "确认"
ME_LngButton002 := "取消"
ME_LngButton003 := "帮助"
ME_LngButton004 := "从剪贴板导入"
ME_LngButton005 := "将手势添加到选定目标"
ME_LngButton006 := "将动作应用于选定手势"
ME_LngButton007 := "添加"
ME_LngButton008 := "更新"
ME_LngButton009 := "修改"
ME_LngButton010 := "辅助输入"
ME_LngButton011 := "删除"
ME_LngButton012 := "按下"
ME_LngButton013 := "释放"
ME_LngButton014 := "从当前手势中删除最后一步"
ME_LngButton015 := "设为自启动"
ME_LngButton016 := "取消自启动"
ME_LngButton017 := "为不同触发键单独设置箭头颜色"
ME_LngButton018 := "编辑"
ME_LngButton019 := "特殊按键"
ME_LngButton020 := "浏览..."
ME_LngButton021 := "应用图标"
ME_LngButton022 := "为动作“激活前一个窗口”指定例外对象"
ME_LngButton023 := "从任务列表中选择例外对象"
ME_LngButton024 := "选择"
ME_LngButton025 := "MouseGestureL.ahk 用"
ME_LngButton026 := "MG_Edit.ahk 用"

; Items of Drop Down List
ME_LngDropDown001 := [ "窗口类名", "控件类名", "文件名", "标题", "自定义条件", "匹配其它目标" ]
ME_LngDropDown002 := [ "完全匹配", "部分匹配", "前面匹配", "后面匹配", "正则匹配" ]
ME_LngDropDown003 := [ "文字提示", "箭头提示1", "箭头提示2", "高级提示", "导航提示" ]
ME_LngDropDown004 := [ "跟随鼠标", "左上角", "右上角", "左下角", "右下角" ]
ME_LngDropDown005 := [ "左上角", "右上角", "左下角", "右下角", "指定坐标" ]
ME_LngDropDown101 := [ "相对于窗口", "相对于控件", "相对于屏幕" ]
ME_LngDropDown102 := [ "跟随目标左上角", "跟随目标右上角", "跟随目标左下角", "跟随目标右下角" ]
ME_LngDropDown103 := [ "手势开始时的坐标", "手势结束时的坐标" ]
ME_LngDropDown201 := [ "左键", "右键", "中键", "第4键", "第5键" ]
ME_LngDropDown202 := [ "普通", "按下", "释放" ]
ME_LngDropDown203 := [ "单击", "按住", "释放" ]
ME_LngDropDown204 := [ "手势开始位置", "手势结束位置", "当前鼠标位置" ]
ME_LngDropDown205 := [ "向上", "向下", "向左", "向右" ]
ME_LngDropDown206 := [ "与鼠标移动方向相同", "与鼠标移动方向相反" ]
ME_LngDropDown207 := [ "根据鼠标移动距离滚动", "根据鼠标移动方向自动滚动" ]
ME_LngDropDown208 := [ "正常", "最小化", "最大化", "隐藏" ]
ME_LngDropDown209 := [ "普通运行", "管理员运行" ]
ME_LngDropDown210 := [ "水平排列", "垂直排列", "纵横排列" ]
ME_LngDropDown211 := [ "屏幕中心", "屏幕左侧", "屏幕上方", "屏幕右侧", "屏幕下方", "屏幕左上角", "屏幕右上角", "屏幕左下角", "屏幕右下角", "原始位置" ]

; Column Titles of ListView
ME_LngListView001 := [ "匹配类型", "值" ]
ME_LngListView002 := [ "手势", "动作", "" ]
ME_LngListView003 := [ "目标", "动作", "" ]
ME_LngListView004 := [ "触发键", "箭头颜色", "" ]
ME_LngListView005 := [ "标题", "窗口类名", "文件名" ]

; Group Box
ME_LngGroupBox001 := "手势识别"
ME_LngGroupBox002 := "多长距离算作1次移动 (px)"
ME_LngGroupBox003 := "多大角度范围算作斜向移动 (0 ～ 90 deg)"
ME_LngGroupBox004 := "超时"
ME_LngGroupBox005 := "触碰屏幕边缘识别"
ME_LngGroupBox006 := "额外鼠标按键"
ME_LngGroupBox007 := "手势提示"
ME_LngGroupBox008 := "箭头提示"
ME_LngGroupBox009 := "高级提示 / 手势清單"
ME_LngGroupBox010 := "手势轨迹"
ME_LngGroupBox011 := "手势日志"
ME_LngGroupBox012 := "热键"
ME_LngGroupBox013 := "外部编辑器"
ME_LngGroupBox014 := "自启动"
ME_LngGroupBox015 := "激活前一个窗口"
ME_LngGroupBox016 := "其它"
ME_LngGroupBox017 := "图标"
ME_LngGroupBox018 := "匹配条件"
ME_LngGroupBox019 := "匹配规则"
ME_LngGroupBox020 := "编辑用户扩展"
ME_LngGroupBox101 := "滚轮方向"
ME_LngGroupBox102 := "排列时保留的屏幕区域 (px)"
ME_LngGroupBox103 := "偏移量"

; Check Box
ME_LngCheckBox001 := "不匹配"
ME_LngCheckBox002 := "不继承父目标的规则"
ME_LngCheckBox003 := "8方向模式 (默认识别上下左右4方向无斜向)"
ME_LngCheckBox004 := "活动窗口作为目标 (默认鼠标下窗口作为目标)"
ME_LngCheckBox005 := "多显示器屏幕边缘独立 (默认将多显示器视为整体再划分边缘区域)"
ME_LngCheckBox006 := "单独禁止中键的默认行为"
ME_LngCheckBox007 := "单独禁止第4键的默认行为"
ME_LngCheckBox008 := "单独禁止第5键的默认行为"
ME_LngCheckBox009 := "显示手势提示"
ME_LngCheckBox010 := "箭头背景透明"
ME_LngCheckBox011 := "触发键按下时立刻显示提示"
ME_LngCheckBox012 := "显示手势轨迹"
ME_LngCheckBox013 := "显示日志窗口"
ME_LngCheckBox014 := "轨迹覆盖窗口"
ME_LngCheckBox015 := "层叠托盘菜单"
ME_LngCheckBox016 := "根据“目标”与“手势”中项目数量调整本窗口高度"
ME_LngCheckBox017 := "执行未定义手势时禁止触发键的默认行为 (例如以未定义的右键手势结束也不会激活右键菜单)"
ME_LngCheckBox018 := "忽略修饰键状态"
ME_LngCheckBox019 := "不要再显示此消息"
ME_LngCheckBox020 := "总是勾住触发键 (默认只在目标程序中勾住触发键)"
ME_LngCheckBox021 := "从默认手势目标中排除"
ME_LngCheckBox022 := "同方向的连续超长移动视作单个超长移动"
ME_LngCheckBox023 := "将动作脚本中的变量视为全局变量"
ME_LngCheckBox101 := "Shift"
ME_LngCheckBox102 := "Ctrl"
ME_LngCheckBox103 := "Alt"
ME_LngCheckBox110 := "屏幕坐标 (默认窗口坐标)"
ME_LngCheckBox111 := "按页滚动 (默认按行)"
ME_LngCheckBox112 := "使用相对值"
ME_LngCheckBox113 := "自动调整Aero窗口的边框宽度"
ME_LngCheckBox114 := "使用“最小化同类窗口”恢復最小化的窗口"

; Radio Button
ME_LngRadioBtn001 := "匹配条件仅需单条符合"
ME_LngRadioBtn002 := "匹配条件需全部符合"
ME_LngRadioBtn051 := "在“启动”文件夹中创建快捷方式 (以标准用户身份运行)"
ME_LngRadioBtn052 := "注册到任务计划程序 (以管理员身份运行)"
ME_LngRadioBtn101 := "上滚"
ME_LngRadioBtn102 := "下滚"

; Messages
ME_LngMessage001 := "“###REPLACE###”"
ME_LngMessage002 := "，"
ME_LngMessage003 := "以下手势已分配给 ###REPLACE### 或其子目标:"
ME_LngMessage004 := "###REPLACE### 或其子目标包含在以下目标中:"
ME_LngMessage005 := "确定要删除吗？"
ME_LngMessage006 := "动作已分配给该手势。`n确定要删除此手势吗？"
ME_LngMessage007 := "目标中存在手势 “###REPLACE###”。`n确定用此动作覆盖吗?"
ME_LngMessage011 := "函数名只能使用字母或数字。"
ME_LngMessage012 := "此函数名是保留的。"
ME_LngMessage013 := "使用该函数名的触发键已经存在。"
ME_LngMessage014 := "使用该触发键的函数名已经存在。"
ME_LngMessage015 := "确定要删除所选触发键吗？"
ME_LngMessage021 := "想将现有手势转换为 ###REPLACE###方向模式吗？"
ME_LngMessage022 := "`n`n* 注意这将删除手势中已存在的斜向运动。"
ME_LngMessage031 := "选择 MouseGestureL.ahk 开机启动的运行方式。"
ME_LngMessage032 := "已添加开机自启。"
ME_LngMessage033 := "已删除开机自启。"
ME_LngMessage101 := "调用目标程序菜单栏的菜单项。`n`n  - 不是所有程序都支持此功能。`n  - 使用“,”(英文逗号)分隔子项 (最大支持6个子项)。`n  - 例如“`"编辑`", `"转换`", `"简繁转换`"”表示调用菜单栏 “编辑”→“转换”→“简繁转换”功能。"
ME_LngMessage102 := "输入待运行程序命令行或URL。"
ME_LngMessage104 := "指定透明度。`n`n  0(全透明) ～ 255(不透明)"
ME_LngMessage105 := "激活前一个窗口。`n`n  - 假设依次打开ABCD四个窗口，此时窗口D处于激活状态，超时时间设为1000ms(即1秒)。`n  - 若在1秒内运行本动作3次，则将依次激活C、B、A。`n  - 若运行1次本动作，2秒后运行第2次，再过2秒运行第3次，则将依次激活C、D、C。`n`n超时时间 (ms):"
ME_LngMessage106 := "指定以下值之一。`n`n      0 ～ 100	: 音量绝对值`n     +1 ～ +100	: 音量增量`n     -1 ～ -100	: 音量减量"
ME_LngMessage107 := "指定以下值之一。`n`n     1 : 静音开`n     0 : 静音关`n     -1 : 静音切换"
ME_LngMessage108 := "指定要播放的声音文件。`n`n  * 无法播放操作系统不支持的文件格式。"
ME_LngMessage109 := "- 当触发键被释放时，激活本动作。`n`n使用本动作可实现组合手势，例如“右键双击”。`n  1. 将本动作分配给“右键单击 (RB__)”手势。`n  2. 在“右键双击 (RB__RB__)”手势中分配你真正想完成的动作(例如打开窗口A)。`n  3. 在超时前完成“右键双击”，就会打开窗口A。`n`n超时时间 (ms):"
ME_LngMessage110 := "等待指定时间。`n`n  - 等待期间不能识别下个手势。`n`n    例如将本动作“Sleep, 10000 (等待10秒)”分配给手势“按住右键→ (RB_R_)”。`n    当手势被触发后，此时按鼠标左右键都没有反应，就像被冻住了一样，直到等待结束。    `n    因此最好仅用本动作进行短时间的等待，例如“Sleep, 200 (等待200毫秒)”。`n`n    如果需要长时间的等待，最好使用动作 “处理阻塞型操作”。`n`n等待时间 (ms):"
ME_LngMessage111 := "识别手势后，动作将延迟到等待时间结束后再运行。`n  - 在等待时间内手势发生改变，则取消动作。`n`n    【例】“中键单击”与“中键双击”同时生效。 `n    1. “中键单击(MB__)”手势分配本动作，并在 “else {” 后写入真正想完成的动作例如“打开窗口A”。`n    2. “中键双击(MB__MB__)”手势分配动作“打开窗口B” 。`n    3. 当你在等待时间内完成“中键双击”，将只执行“打开窗口B”(因为“中键单击”被取消)。`n    4. 当你在等待时间结束后，只完成了“中键单击”，将执行“打开窗口A”。`n`n等待时间 (ms):"
ME_LngMessage112 := "触发键被按下，且在等待时间结束后才被释放时，该动作被执行。`n`n  - 本动作只适用于按下即触发型手势。`n  - 等待时间没过完，中途释放不会执行动作。`n`n等待时间 (ms):"
ME_LngMessage113 := "在按下触发键的同时，以指定的间隔时间重复执行某动作。`n`n  - 本动作只适用于按下即触发型手势。`n`n间隔时间 (ms):"
ME_LngMessage114 := "当识别过程结束后，该动作被执行。`n`n  - 通常动作脚本中应当尽量避免出现长时间阻塞型操作。`n    例如“Sleep, 10000 (等待10秒)”或“MsgBox (显示一个消息框)”。`n`n    因为阻塞过程中不能识别下个手势并且触发键会被冻住。`n    例如“MsgBox (显示一个消息框)”会让鼠标左右键按下无反应且无法识别新手势，直到消息框被关闭。`n`n    此功能可解决这样的问题。`n"
ME_LngMessage115 := "在手势完成后，释放触发键时，执行触发键原行为。`n`n  - 例如完成一个右键手势后，当释放右键时，正常来说右键菜单不会显示，但如果调用本动作，则会显示。`n  - 又如完成一个“a”键手势后，当释放“a”键时，将会输出一个字符“a”。"
ME_LngMessage116 := "在手势完成后，释放触发键时，取消触发键原行为。`n`n  - 例如完成一个未定义的右键手势后，当释放右键时，此时会弹出右键菜单，但如果调用本动作，则可避免菜单弹出。`n  - 又如完成一个未定义的“a”键手势后，当释放“a”键时，则可阻止输出字符“a”。`n  - 双重手势过程中，等待后续手势时也常用到本动作。"
ME_LngMessage117 := "将文本显示为文字提示。`n`n  - 本动作只适用于按下即触发型手势。`n  - 如果“提示”→“提示类型”不是文字提示或被禁用，则此功能无效。`n  - 如果要显示多行文字，按 “确定”关闭此对话框，然后编辑( )的内文。`n`n要显示的文字:"
ME_LngMessage118 := "复制文本到剪贴板。`n`n  - “``t”表示制表符  “``n”表示换行  `n  - 如果要复制多行文字，按“确定”关闭此对话框，然后编辑( )的内文。`n`n要复制的文字:"
ME_LngMessage119 := "输入按键字符串。`n`n    格式: +^!#{Key Name}`n    +表示Shift  ^表示Ctrl  !表示Alt  #表示Win`n`n  - 单字符按键周围的{ }可以省略。`n  - 例如 x与{x} 等效，tab与{tab} 不等效。`n  - {Key Down} 表示按下， {Key Up} 表示释放。`n  - {LButton}，{RButton}，{MButton}，{XButton1}，{XButton2} 表示鼠标按键。`n  - 例如“xyz{tab}”，程序就会依次输入xyz与一个制表符。"
ME_LngMessage120 := "有關如何使用此操作的信息，請參閱###LinkStart###網站上的說明###LinkEnd###。`n"

; Tooltips
ME_LngTooltip001 := "删除"
ME_LngTooltip002 := "清空"
ME_LngTooltip003 := "使用外部编辑器进行编辑"
ME_LngTooltip011 := "新建目标"
ME_LngTooltip012 := "上移"
ME_LngTooltip013 := "下移"
ME_LngTooltip014 := "按 A-Z 排序"
ME_LngTooltip015 := "复制"
ME_LngTooltip016 := "显示全部子项"
ME_LngTooltip017 := "折叠全部子项"
ME_LngTooltip021 := "新建手势"
ME_LngTooltip101 := "“###REPLACE###” 已复制到剪贴板。"
ME_LngTooltip103 := "目标窗口上右键单击"
ME_LngTooltip104 := "请在 “目标程序” 的 “目标工具栏按钮上” 右键单击"
ME_LngTooltip105 := "左键拖动画出矩形区域"

; Fonts
;高级提示字体
ME_AdNaviFont	 := "微软雅黑"
ME_LogFont	 	 := "微软雅黑"
;动作脚本编辑框字体
ME_ScriptFont	 := "微软雅黑"
ME_ScriptSize	 := 9

; Other Text
ME_LngOthers001	 := "全局"
ME_LngOthers002  := "忽略目标"
ME_LngOthers003	 := "目标"
ME_LngOthers004	 := "无"
ME_LngOthers005	 := ""
ME_LngOthers006	 := "部分匹配"
ME_LngOthers007	 := "前面匹配"
ME_LngOthers008	 := "后面匹配"
ME_LngOthers009	 := "正则匹配"
ME_LngOthers010	 := "不匹配"
ME_LngOthers011	 := "部分不匹配"
ME_LngOthers012	 := "前面不匹配"
ME_LngOthers013	 := "后面不匹配"
ME_LngOthers014	 := "正则不匹配"
ME_LngOthers015	 := "<< 其它触发方式 >>"

;-------------------------------------------------------------------------------
; Preset Items
;-------------------------------------------------------------------------------
ME_PresetTarget01 := "浏览器"
ME_PresetTarget02 := "资源管理器"
ME_PresetTarget03 := "图标"

ME_PresetGesture01 := "右键按下"
ME_PresetGesture02 := "按住右键再按左键"
ME_PresetGesture03 := "按住右键←"
ME_PresetGesture04 := "按住右键→"
ME_PresetGesture05 := "按住右键↑"
ME_PresetGesture06 := "按住右键↓"
ME_PresetGesture07 := "按住右键←↑"
ME_PresetGesture08 := "按住右键←↓"
ME_PresetGesture09 := "按住右键→↑"
ME_PresetGesture10 := "按住右键→↓"
ME_PresetGesture11 := "按住右键↑←"
ME_PresetGesture12 := "按住右键↑→"
ME_PresetGesture13 := "按住右键↓←"
ME_PresetGesture14 := "按住右键↓→"

ME_PresetAction01 := "激活窗口"
ME_PresetAction02 := "取消手势"
ME_PresetAction03 := "关闭窗口"
ME_PresetAction04 := "后退"
ME_PresetAction05 := "前进"
ME_PresetAction06 := "跳至文首"
ME_PresetAction07 := "跳至文末"
ME_PresetAction08 := "激活前一个窗口"
ME_PresetAction09 := "最小化"

;-------------------------------------------------------------------------------
MG_LanguageEnd:

SplitPath(A_LineFile,,,, &MG_Language)

