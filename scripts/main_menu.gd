extends Control

@onready var menu_main = $MenuMain
@onready var bg_texture = $Background
@onready var title_texture = $MenuMain/Title
@onready var pve_button = $MenuMain/ButtonRow/PVEButton
@onready var coming_button = $MenuMain/ButtonRow/ComingButton
@onready var pvp_button = $MenuMain/ButtonRow/PVPButton
@onready var pokedex_btn = $PokedexBtn
@onready var exit_btn = $ExitBtn
@onready var pokedex_overlay = $PokedexOverlay
@onready var dex_grid = $PokedexOverlay/PokedexPanel/DexListScroll/DexGrid
@onready var dex_detail = $PokedexOverlay/PokedexPanel/DexDetail
@onready var dex_detail_icon = $PokedexOverlay/PokedexPanel/DexDetail/DexDetailHeader/DexDetailIcon
@onready var dex_detail_name = $PokedexOverlay/PokedexPanel/DexDetail/DexDetailHeader/DexDetailName
@onready var dex_intro_label = $PokedexOverlay/PokedexPanel/DexDetail/DexIntroLabel
@onready var dex_stats_row = $PokedexOverlay/PokedexPanel/DexDetail/DexStatsRow
@onready var dex_skills_container = $PokedexOverlay/PokedexPanel/DexDetail/DexDetailScroll/DexSkillsContainer
@onready var dex_close_btn = $PokedexOverlay/PokedexPanel/DexHeader/DexCloseBtn
@onready var dex_back_btn = $PokedexOverlay/PokedexPanel/DexDetail/DexBackBtn
@onready var dex_list_scroll = $PokedexOverlay/PokedexPanel/DexListScroll
@onready var char_select = $CharSelect
@onready var card_grid = $CharSelect/CharPanel/ScrollContainer/CardGrid
@onready var start_button = $CharSelect/CharPanel/ButtonRow2/StartButton
@onready var back_button = $CharSelect/CharPanel/ButtonRow2/BackButton
@onready var char_title_label = $CharSelect/CharPanel/CharTitle
@onready var diff_select = $DiffSelect
@onready var easy_btn = $DiffSelect/DiffPanel/DiffButtonRow/EasyBtn
@onready var medium_btn = $DiffSelect/DiffPanel/DiffButtonRow/MediumBtn
@onready var hard_btn = $DiffSelect/DiffPanel/DiffButtonRow/HardBtn
@onready var hell_btn = $DiffSelect/DiffPanel/DiffButtonRow/HellBtn
@onready var diff_back_btn = $DiffSelect/DiffPanel/DiffBackBtn
@onready var diff_title = $DiffSelect/DiffPanel/DiffTitle
@onready var map_pool_btn = $MapPoolBtn
@onready var map_pool_overlay = $MapPoolOverlay
@onready var map_pool_container = $MapPoolOverlay/MapPoolPanel/MapPoolScroll/MapPoolGrid
@onready var map_pool_close = $MapPoolOverlay/MapPoolPanel/MapPoolHeader/MapPoolCloseBtn

@onready var talent_btn = $TalentBtn
@onready var talent_overlay = $TalentOverlay
@onready var talent_container = $TalentOverlay/TalentPanel/TalentScroll/TalentGrid
@onready var talent_close = $TalentOverlay/TalentPanel/TalentHeader/TalentCloseBtn
@onready var talent_slot_bar = $TalentOverlay/TalentPanel/TalentSlotBar

@onready var talent_tab_btn = $PokedexOverlay/PokedexPanel/DexTabBar/TalentTabBtn
@onready var char_tab_btn = $PokedexOverlay/PokedexPanel/DexTabBar/CharTabBtn
@onready var talent_dex_scroll = $PokedexOverlay/PokedexPanel/TalentDexScroll
@onready var talent_dex_list = $PokedexOverlay/PokedexPanel/TalentDexScroll/TalentDexList

# Pokedex state
var _dex_body: Control = null
var _dex_desc: Label = null
var _dex_easter: Label = null
var _dex_char_id: String = ""

var selected_char := "knight"
var selected_ai_char := ""  # 空字符串 = 随机AI
var chars_initialized := false
var char_cards := {}
var _title_click_count := 0  # 作弊计数器
var _talent_from_char_select := false  # 天赋界面是否来自选人界面

# 加载滤镜（游戏结束 ESC/C 返回时的灰色呼吸遮罩 + 上升浮动圆点）
var _loading_filter: ColorRect = null
var _loading_dots: Array = []

const IMG_TITLE = preload("res://assets/ui_title.png")
const IMG_PVE = preload("res://assets/ui_btn_pve.png")
const IMG_COMING = preload("res://assets/ui_btn_coming.png")
const IMG_PVP = preload("res://assets/ui_btn_pvp.png")
const IMG_BG = preload("res://assets/bg_main_menu.png")
const IMG_DIFF_EASY = preload("res://assets/ui_diff_easy.png")
const IMG_DIFF_MEDIUM = preload("res://assets/ui_diff_medium.png")
const IMG_DIFF_HARD = preload("res://assets/ui_diff_hard.png")
const IMG_DIFF_HELL = preload("res://assets/ui_diff_hell.png")




func _ready():
	print("[MainMenu] _ready() start")
	TalentPool.init()
	_init_char_configs()
	print("[MainMenu] configs initialized, setting up UI...")
	
	title_texture.custom_minimum_size = Vector2(300, 80)
	title_texture.size_flags_horizontal = 0
	title_texture.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title_texture.mouse_filter = Control.MOUSE_FILTER_STOP
	title_texture.gui_input.connect(_on_title_clicked)
	bg_texture.texture = IMG_BG
	pve_button.texture_normal = IMG_PVE; pve_button.texture_pressed = IMG_PVE
	coming_button.texture_normal = IMG_COMING; coming_button.texture_pressed = IMG_COMING
	pvp_button.texture_normal = IMG_PVP; pvp_button.texture_pressed = IMG_PVP
	
	pve_button.pressed.connect(_on_pve_pressed)
	coming_button.pressed.connect(_on_coming_pressed)
	pvp_button.pressed.connect(_on_pvp_pressed)
	pokedex_btn.pressed.connect(_on_pokedex_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	talent_btn.pressed.connect(_on_talent_dex_pressed)
	easy_btn.pressed.connect(_on_easy_pressed)
	medium_btn.pressed.connect(_on_medium_pressed)
	hard_btn.pressed.connect(_on_hard_pressed)
	hell_btn.pressed.connect(_on_hell_pressed)
	diff_back_btn.pressed.connect(_on_diff_back_pressed)
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)
	dex_close_btn.pressed.connect(_on_dex_close)
	dex_back_btn.pressed.connect(_on_dex_back)
	
	# 显示天赋图鉴入口（独立于角色图鉴）
	talent_btn.visible = true
	talent_btn.text = "📖 天赋图鉴"
	_style_talent_dex_button()
	
	_style_pokedex_button()
	_style_exit_button()
	_style_dex_overlay()
	_style_diff_buttons()
	_style_char_select_buttons()
	_style_map_pool_ui()
	_style_talent_ui()
	
	MapManager.ensure_init()
	_populate_characters()
	_populate_dex_grid()
	_populate_talents()
	_populate_talent_dex()
	_populate_map_pool()
	
	# Pokedex tab switching
	char_tab_btn.pressed.connect(_on_char_tab_pressed)
	talent_tab_btn.pressed.connect(_on_talent_tab_pressed)
	
	# 从游戏内"角色选择"按钮返回时，直接跳到选人界面
	if GameWorld.skip_to_char_select:
		GameWorld.skip_to_char_select = false
		_show_char_select()

	# 加载滤镜：作为最后子节点绘制在全部 UI 之上（ESC/C 返回菜单时显示）
	_loading_filter = ColorRect.new()
	_loading_filter.color = Color(0.45, 0.45, 0.45, 0.5)
	_loading_filter.set_anchors_preset(Control.PRESET_FULL_RECT)
	_loading_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_loading_filter.visible = false
	add_child(_loading_filter)
	# 上升浮动小圆点（作为滤镜的子节点，随滤镜一起显隐）
	_loading_dots.clear()
	for i in 16:
		var dot = ColorRect.new()
		dot.color = Color(0.88, 0.88, 0.92, 0.6)
		dot.size = Vector2(6, 6)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_loading_filter.add_child(dot)
		_loading_dots.append({
			"rect": dot,
			"seed_x": float((i * 97 + 13) % 97) / 97.0,
			"seed_y": float((i * 53 + 7) % 101) / 101.0,
		})

func _process(_delta):
	if _loading_filter == null:
		return
	if GameWorld.loading_filter_frames > 0:
		GameWorld.loading_filter_frames -= 1
		var t = Time.get_ticks_msec() / 1000.0
		var breath = 0.5 + 0.5 * sin(t * TAU / 3.0)
		_loading_filter.color = Color(0.45, 0.45, 0.45, 0.35 + 0.3 * breath)
		# 圆点从底部上浮，左右微摆，透明度闪烁
		var w = _loading_filter.size.x
		var h = _loading_filter.size.y
		for d in _loading_dots:
			var dot: ColorRect = d.rect
			var x = d.seed_x * (w - 12.0) + sin(t * 1.5 + d.seed_x * TAU) * 10.0
			var rise = fmod(t * 45.0 + d.seed_y * (h + 80.0), h + 80.0)
			var y = h - rise
			dot.position = Vector2(x, y)
			dot.color.a = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * 2.0 + d.seed_x * TAU))
		_loading_filter.visible = true
	else:
		_loading_filter.visible = false

# ===== Pokedex =====

func _populate_dex_grid():
	for child in dex_grid.get_children():
		child.queue_free()
	for cid in CharConfigs.get_all_ids():
		var cfg = CharConfigs.configs.get(cid, {})
		var dex = cfg.get("dex", {})
		var icon = dex.get("icon", "?")
		var name_str = CharConfigs.get_char_name(cid)
		
		var btn = Button.new()
		btn.text = icon + " " + name_str
		btn.custom_minimum_size = Vector2(150, 42)
		btn.pressed.connect(_on_dex_card_clicked.bind(cid))
		_style_dex_card(btn)
		dex_grid.add_child(btn)

func _style_dex_card(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(1, 1, 1, 0.06)
	normal.set_corner_radius_all(10)
	normal.border_width_left = 2; normal.border_width_right = 2
	normal.border_width_top = 2; normal.border_width_bottom = 2
	normal.border_color = Color(0.4, 0.4, 0.4, 0.5)
	btn.add_theme_stylebox_override("normal", normal)
	var hover = normal.duplicate()
	hover.bg_color = Color(1.0, 0.843, 0.0, 0.12)
	hover.border_color = Color(1.0, 0.843, 0.0, 0.6)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _on_dex_card_clicked(char_id: String):
	_dex_char_id = char_id
	var cfg = CharConfigs.configs.get(char_id, {})
	var dex = cfg.get("dex", {})
	var intro = dex.get("intro", "")
	
	# Header
	dex_detail_icon.text = dex.get("icon", "?")
	dex_detail_name.text = CharConfigs.get_char_name(char_id)
	
	# Hide old layout, build new
	dex_stats_row.visible = false
	dex_intro_label.visible = false
	var old_scroll = dex_skills_container.get_parent()
	if old_scroll: old_scroll.visible = false
	
	# Remove previous body if exists
	if _dex_body and _dex_body.get_parent():
		_dex_body.get_parent().queue_free()

	# Clean up any old scroll containers from previous character
	for child in dex_detail.get_children():
		if child.get("name") == "DexBodyScroll":
			child.queue_free()
	
	# New layout: ScrollContainer → VBoxContainer (top image+text | bottom skill buttons)
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.name = "DexBodyScroll"

	_dex_body = VBoxContainer.new()
	_dex_body.add_theme_constant_override("separation", 12)
	_dex_body.name = "DexBody"
	_dex_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dex_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# === Top row: idle image (left) + description text (right) ===
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 20)
	top_row.size_flags_vertical = Control.SIZE_EXPAND
	
	# Character portrait image (clickable → restore intro)
	var idle_tex = _get_portrait_texture(char_id)
	if idle_tex:
		var tex_btn = Button.new()
		tex_btn.icon = idle_tex
		tex_btn.expand_icon = true
		tex_btn.flat = true
		tex_btn.custom_minimum_size = Vector2(160, 214)
		tex_btn.pressed.connect(_on_dex_char_portrait_clicked.bind(intro))
		top_row.add_child(tex_btn)
	
	# Text area (dynamic description + stats)
	var text_area = VBoxContainer.new()
	text_area.add_theme_constant_override("separation", 8)
	text_area.size_flags_horizontal = Control.SIZE_EXPAND
	
	var desc = Label.new()
	desc.name = "DescLabel"
	desc.text = intro
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	desc.add_theme_font_size_override("font_size", 13)
	desc.size_flags_vertical = Control.SIZE_EXPAND
	desc.custom_minimum_size = Vector2(330, 0)  # 约 25 字/行
	_dex_desc = desc  # 保存引用供技能按钮使用
	text_area.add_child(desc)
	
	# Stats row at bottom of text area
	var stats_box = HBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 16)
	for s in dex.get("stats", []):
		var lbl = Label.new()
		lbl.text = s.get("label", "") + " " + str(s.get("value", ""))
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		lbl.add_theme_font_size_override("font_size", 10)
		stats_box.add_child(lbl)
	text_area.add_child(stats_box)
	
	# Easter egg label (yellow, shown after介绍)
	var easter = Label.new()
	easter.name = "EasterLabel"
	easter.text = ""
	easter.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	easter.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # 金色/黄色
	easter.add_theme_font_size_override("font_size", 13)
	easter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dex_easter = easter
	text_area.add_child(easter)
	
	top_row.add_child(text_area)
	_dex_body.add_child(top_row)
	
	# === Bottom row: skill buttons (horizontal, wraps) ===
	var bottom_row = HFlowContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	bottom_row.alignment = HFlowContainer.ALIGNMENT_CENTER
	
	for i in range(dex.get("skills", []).size()):
		var sk = dex["skills"][i]
		var btn = Button.new()
		btn.text = sk.get("name", "")
		btn.custom_minimum_size = Vector2(140, 36)
		btn.pressed.connect(_on_dex_skill_clicked.bind(i, dex, intro))
		_style_dex_skill_btn(btn)
		bottom_row.add_child(btn)
	
	_dex_body.add_child(bottom_row)
	scroll.add_child(_dex_body)
	dex_detail.add_child(scroll)
	
	dex_list_scroll.visible = false
	dex_detail.visible = true

func _on_dex_skill_clicked(skill_index: int, dex: Dictionary, intro: String):
	var sk = dex.get("skills", [])[skill_index]
	if _dex_desc:
		_dex_desc.text = "【" + sk.get("name", "") + "】\n\n" + sk.get("desc", "") + "\n\n" + sk.get("meta", "")
	if _dex_easter:
		_dex_easter.text = "\n\n" + sk.get("easter_egg", "")

func _on_dex_char_portrait_clicked(intro: String):
	if _dex_desc:
		_dex_desc.text = intro
	if _dex_easter:
		_dex_easter.text = "\n\n" + CharConfigs.configs.get(_dex_char_id, {}).get("dex", {}).get("easter_egg", "")

func _get_portrait_texture(char_id: String) -> Texture2D:
	var path = "res://assets/char_ani/" + char_id + "/portrait/" + char_id + "_portrait.png"
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _style_dex_skill_btn(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(1, 1, 1, 0.05)
	normal.set_corner_radius_all(6)
	normal.border_width_left = 1; normal.border_width_right = 1
	normal.border_width_top = 1; normal.border_width_bottom = 1
	normal.border_color = Color(0.35, 0.35, 0.4, 0.5)
	btn.add_theme_stylebox_override("normal", normal)
	var hover = normal.duplicate()
	hover.bg_color = Color(1.0, 0.843, 0.0, 0.12)
	hover.border_color = Color(1.0, 0.843, 0.0, 0.5)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.8))

func _on_pokedex_pressed():
	pokedex_overlay.visible = true
	menu_main.visible = false
	pokedex_btn.visible = false
	exit_btn.visible = false
	talent_btn.visible = false
	map_pool_btn.visible = false
	# Default to character tab
	_on_char_tab_pressed()


# ===== 独立天赋图鉴 =====

var _talent_dex_overlay: Control = null
var _talent_dex_detail: Control = null
var _talent_dex_name: Label = null
var _talent_dex_type: Label = null
var _talent_dex_desc: Label = null
var _talent_dex_list_container: Control = null

func _on_talent_dex_pressed():
	if not _talent_dex_overlay:
		_create_talent_dex_overlay()
	_talent_dex_overlay.visible = true
	menu_main.visible = false
	pokedex_btn.visible = false
	exit_btn.visible = false
	talent_btn.visible = false
	map_pool_btn.visible = false

func _create_talent_dex_overlay():
	var overlay = ColorRect.new()
	overlay.name = "TalentDexOverlay"
	overlay.color = Color(0.05, 0.05, 0.08, 0.95)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	# 标题栏
	var header = HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_END
	header.add_theme_constant_override("separation", 12)
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_top = 10; header.offset_right = -20
	overlay.add_child(header)
	
	var title = Label.new()
	title.text = "📖 天赋图鉴"
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
	title.add_theme_font_size_override("font_size", 22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = "✕ 关闭"
	close_btn.add_theme_color_override("font_color", Color(0.914, 0.271, 0.157))
	close_btn.add_theme_font_size_override("font_size", 16)
	close_btn.pressed.connect(_on_talent_dex_close)
	header.add_child(close_btn)
	
	# 双栏主体
	var body = HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 0)
	body.offset_top = 50; body.offset_bottom = -20
	body.offset_left = 20; body.offset_right = -20
	overlay.add_child(body)
	
	# 左侧：天赋卡牌列表
	var left_panel = VBoxContainer.new()
	left_panel.custom_minimum_size = Vector2(220, 0)
	body.add_child(left_panel)
	
	var left_label = Label.new()
	left_label.text = "天赋列表"
	left_label.add_theme_color_override("font_color", Color(0.67, 0.53, 1.0))
	left_label.add_theme_font_size_override("font_size", 14)
	left_panel.add_child(left_label)
	
	var left_scroll = ScrollContainer.new()
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_panel.add_child(left_scroll)
	
	var card_list = VBoxContainer.new()
	card_list.add_theme_constant_override("separation", 6)
	left_scroll.add_child(card_list)
	_talent_dex_list_container = card_list
	
	# 右侧：天赋详情
	_talent_dex_detail = VBoxContainer.new()
	_talent_dex_detail.add_theme_constant_override("separation", 10)
	_talent_dex_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_talent_dex_detail.visible = false
	body.add_child(_talent_dex_detail)
	
	var detail_header = HBoxContainer.new()
	detail_header.add_theme_constant_override("separation", 12)
	
	_talent_dex_type = Label.new()
	_talent_dex_type.add_theme_font_size_override("font_size", 13)
	detail_header.add_child(_talent_dex_type)
	
	_talent_dex_name = Label.new()
	_talent_dex_name.add_theme_font_size_override("font_size", 20)
	_talent_dex_name.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
	detail_header.add_child(_talent_dex_name)
	
	_talent_dex_detail.add_child(detail_header)
	
	# 分隔线
	var detail_sep = HSeparator.new()
	detail_sep.modulate = Color(0.5, 0.4, 0.6, 0.5)
	_talent_dex_detail.add_child(detail_sep)
	
	# 描述文字（自动换行）
	_talent_dex_desc = Label.new()
	_talent_dex_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_talent_dex_desc.add_theme_font_size_override("font_size", 14)
	_talent_dex_desc.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	_talent_dex_desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_talent_dex_detail.add_child(_talent_dex_desc)
	
	# 右侧占位提示
	var placeholder = Label.new()
	placeholder.text = "← 点击左侧天赋查看详情"
	placeholder.add_theme_font_size_override("font_size", 14)
	placeholder.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder.name = "TalentDexPlaceholder"
	body.add_child(placeholder)
	
	# 填充左侧天赋卡片
	for tid in TalentPool.get_all_ids():
		var meta = TalentPool.get_metadata(tid)
		var name_str = meta.get("name", tid)
		var is_skill = meta.get("is_skill", false)
		var type_str = "主动" if is_skill else "被动"
		var type_color = Color(0.5, 0.7, 1.0) if is_skill else Color(0.5, 0.9, 0.6)
		
		var card = Button.new()
		card.text = name_str
		card.custom_minimum_size = Vector2(200, 40)
		card.pressed.connect(_on_talent_dex_card_clicked.bind(tid))
		
		# 卡片样式
		var normal = StyleBoxFlat.new()
		normal.bg_color = Color(1, 1, 1, 0.06)
		normal.set_corner_radius_all(8)
		normal.border_width_left = 2; normal.border_width_right = 2
		normal.border_width_top = 2; normal.border_width_bottom = 2
		normal.border_color = Color(0.4, 0.3, 0.5, 0.5)
		card.add_theme_stylebox_override("normal", normal)
		var hover = normal.duplicate()
		hover.bg_color = Color(0.67, 0.53, 1.0, 0.15)
		hover.border_color = Color(0.67, 0.53, 1.0, 0.7)
		card.add_theme_stylebox_override("hover", hover)
		card.add_theme_font_size_override("font_size", 13)
		card.add_theme_color_override("font_color", Color.WHITE)
		card.add_theme_color_override("font_hover_color", Color(0.8, 0.67, 1.0))
		
		# 类型标记
		var card_inner = HBoxContainer.new()
		card_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_inner.add_theme_constant_override("separation", 8)
		
		var type_badge = Label.new()
		type_badge.text = type_str
		type_badge.add_theme_font_size_override("font_size", 10)
		type_badge.add_theme_color_override("font_color", type_color)
		card_inner.add_child(type_badge)
		
		var name_lbl = Label.new()
		name_lbl.text = name_str
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		card_inner.add_child(name_lbl)
		
		card.text = ""  # Clear default text since we use inner labels
		card.add_child(card_inner)
		
		card_list.add_child(card)
	
	_talent_dex_overlay = overlay

func _on_talent_dex_card_clicked(tid: String):
	var meta = TalentPool.get_metadata(tid)
	var name_str = meta.get("name", tid)
	var desc_str = meta.get("desc", "")
	var is_skill = meta.get("is_skill", false)
	
	_talent_dex_name.text = name_str
	_talent_dex_type.text = "【主动】" if is_skill else "【被动】"
	_talent_dex_type.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0) if is_skill else Color(0.5, 0.9, 0.6))
	
	# 格式化描述：每行开头添加缩进和列表标记
	var formatted = ""
	for line in desc_str.split("\n"):
		if line.strip_edges().is_empty():
			formatted += "\n"
		else:
			formatted += "✦ " + line + "\n"
	_talent_dex_desc.text = formatted
	
	# 显示详情面板，隐藏占位符
	_talent_dex_detail.visible = true
	var placeholder = _talent_dex_overlay.find_child("TalentDexPlaceholder", true, false)
	if placeholder: placeholder.visible = false

func _on_talent_dex_close():
	if _talent_dex_overlay:
		_talent_dex_overlay.visible = false
	menu_main.visible = true
	pokedex_btn.visible = true
	exit_btn.visible = true
	talent_btn.visible = true
	map_pool_btn.visible = true

func _on_char_tab_pressed():
	talent_dex_scroll.visible = false
	dex_list_scroll.visible = true
	dex_detail.visible = false
	char_tab_btn.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
	talent_tab_btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))

func _on_talent_tab_pressed():
	dex_list_scroll.visible = false
	dex_detail.visible = false
	talent_dex_scroll.visible = true
	talent_tab_btn.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
	char_tab_btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))

func _populate_talent_dex():
	for child in talent_dex_list.get_children():
		child.queue_free()
	
	for tid in TalentPool.get_all_ids():
		var meta = TalentPool.get_metadata(tid)
		var name_str = meta.get("name", tid)
		var desc_str = meta.get("desc", "")
		var is_skill = meta.get("is_skill", false)
		var type_str = "主动" if is_skill else "被动"
		
		var card = VBoxContainer.new()
		card.add_theme_constant_override("separation", 2)
		
		var header = HBoxContainer.new()
		header.add_theme_constant_override("separation", 6)
		
		var name_lbl = Label.new()
		name_lbl.text = name_str + "  (" + type_str + ")"
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
		header.add_child(name_lbl)
		
		card.add_child(header)
		
		var desc_lbl = Label.new()
		desc_lbl.text = desc_str
		desc_lbl.add_theme_font_size_override("font_size", 12)
		desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(desc_lbl)
		
		# Separator
		var sep = HSeparator.new()
		sep.modulate = Color(0.4, 0.4, 0.4, 0.3)
		card.add_child(sep)
		
		talent_dex_list.add_child(card)

func _on_dex_close():
	pokedex_overlay.visible = false
	menu_main.visible = true
	pokedex_btn.visible = true
	exit_btn.visible = true
	talent_btn.visible = true
	map_pool_btn.visible = true

func _on_dex_back():
	dex_detail.visible = false
	dex_list_scroll.visible = true

func _style_dex_overlay():
	dex_close_btn.add_theme_color_override("font_color", Color(0.914, 0.271, 0.157))
	dex_close_btn.add_theme_font_size_override("font_size", 20)
	dex_back_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	var title = $PokedexOverlay/PokedexPanel/DexHeader/DexTitle
	title.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	dex_detail_name.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	dex_intro_label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	talent_tab_btn.visible = false
	char_tab_btn.text = "📋 角色列表"
	# Tab buttons
	for btn in [char_tab_btn, talent_tab_btn]:
		btn.add_theme_font_size_override("font_size", 14)
		btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.84, 0.4))
	_add_talent_slot_styles()

# ===== Styling helpers =====

func _style_pokedex_button():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.843, 0.0, 0.15)
	style.set_corner_radius_all(8)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.843, 0.0, 0.4)
	pokedex_btn.add_theme_stylebox_override("normal", style)
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(1.0, 0.843, 0.0, 0.25)
	hover_style.border_color = Color(1.0, 0.843, 0.0, 0.6)
	pokedex_btn.add_theme_stylebox_override("hover", hover_style)
	pokedex_btn.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	pokedex_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.843, 0.0, 0.8))

func _style_talent_dex_button():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.416, 0.298, 0.612, 0.15)
	style.set_corner_radius_all(8)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.416, 0.298, 0.612, 0.4)
	talent_btn.add_theme_stylebox_override("normal", style)
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.416, 0.298, 0.612, 0.25)
	hover_style.border_color = Color(0.416, 0.298, 0.612, 0.6)
	talent_btn.add_theme_stylebox_override("hover", hover_style)
	talent_btn.add_theme_color_override("font_color", Color(0.67, 0.53, 1.0))
	talent_btn.add_theme_color_override("font_hover_color", Color(0.8, 0.67, 1.0))

func _style_exit_button():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.914, 0.271, 0.157, 0.15)
	style.set_corner_radius_all(8)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.914, 0.271, 0.157, 0.4)
	exit_btn.add_theme_stylebox_override("normal", style)
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.914, 0.271, 0.157, 0.25)
	hover_style.border_color = Color(0.914, 0.271, 0.157, 0.6)
	exit_btn.add_theme_stylebox_override("hover", hover_style)
	exit_btn.add_theme_color_override("font_color", Color(0.914, 0.271, 0.157))
	exit_btn.add_theme_color_override("font_hover_color", Color(0.914, 0.271, 0.157, 0.8))

func _style_diff_buttons():
	easy_btn.texture_normal = IMG_DIFF_EASY
	easy_btn.texture_pressed = IMG_DIFF_EASY
	medium_btn.texture_normal = IMG_DIFF_MEDIUM
	medium_btn.texture_pressed = IMG_DIFF_MEDIUM
	hard_btn.texture_normal = IMG_DIFF_HARD
	hard_btn.texture_pressed = IMG_DIFF_HARD
	hell_btn.texture_normal = IMG_DIFF_HELL
	hell_btn.texture_pressed = IMG_DIFF_HELL
	diff_title.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	_style_action_button(diff_back_btn, Color(0.6, 0.6, 0.6), "← 返回")

func _style_char_select_buttons():
	char_title_label.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	_style_action_button(start_button, Color(0.298, 0.686, 0.314), "⚔️ 开始战斗")
	_style_action_button(back_button, Color(0.6, 0.6, 0.6), "← 返回")

func _style_action_button(btn: Button, accent: Color, text: String):
	btn.text = text
	btn.add_theme_font_size_override("font_size", 16)
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(accent.r, accent.g, accent.b, 0.2)
	normal.set_corner_radius_all(10)
	normal.border_width_left = 2; normal.border_width_right = 2
	normal.border_width_top = 2; normal.border_width_bottom = 2
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.6)
	btn.add_theme_stylebox_override("normal", normal)
	var hover = normal.duplicate()
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.4)
	hover.border_color = accent
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", accent)

# ===== Character Cards =====

func _populate_characters():
	for child in card_grid.get_children():
		child.queue_free()
	char_cards.clear()
	for cid in CharConfigs.get_all_ids():
		var card = _create_char_card(cid)
		card_grid.add_child(card)
		char_cards[cid] = card
	_select_card("knight")

func _create_char_card(char_id: String) -> Control:
	var config = CharConfigs.configs.get(char_id, {})
	var img = _get_portrait_texture(char_id)
	var name_str = CharConfigs.get_char_name(char_id)
	var hp = config.get("hp", 0)
	var energy = config.get("max_energy", 0)
	
	var card = MarginContainer.new()
	card.custom_minimum_size = Vector2(148, 170)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.gui_input.connect(_on_card_clicked.bind(char_id))
	
	var inner = PanelContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(inner)
	
	var border = StyleBoxFlat.new()
	border.bg_color = Color(1, 1, 1, 0.06)
	border.set_corner_radius_all(14)
	border.border_width_left = 2; border.border_width_right = 2
	border.border_width_top = 2; border.border_width_bottom = 2
	border.border_color = Color(0.4, 0.4, 0.4, 0.6)
	border.content_margin_left = 8; border.content_margin_right = 8
	border.content_margin_top = 8; border.content_margin_bottom = 8
	inner.add_theme_stylebox_override("panel", border)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 6)
	inner.add_child(vbox)
	
	var tex_rect = TextureRect.new()
	tex_rect.custom_minimum_size = Vector2(72, 72)
	tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if img: tex_rect.texture = img
	vbox.add_child(tex_rect)
	
	var name_label = Label.new()
	name_label.text = name_str
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)
	
	var stats_hbox = HBoxContainer.new()
	stats_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(stats_hbox)
	
	var hp_label = Label.new()
	hp_label.text = "❤️ " + str(hp)
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_label.add_theme_font_size_override("font_size", 10)
	hp_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	stats_hbox.add_child(hp_label)
	
	var en_label = Label.new()
	en_label.text = "⚡ " + str(energy)
	en_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	en_label.add_theme_font_size_override("font_size", 10)
	en_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	stats_hbox.add_child(en_label)
	
	return card

func _select_card(char_id: String):
	selected_char = char_id
	GameWorld.selected_char_id = char_id
	_update_all_card_styles()

func _update_all_card_styles():
	for cid in char_cards:
		var card = char_cards[cid]
		var inner = card.get_child(0) as PanelContainer
		var border = inner.get_theme_stylebox("panel", "PanelContainer") as StyleBoxFlat
		if not border: continue
		
		var is_player = (cid == selected_char)
		var is_ai = (cid == selected_ai_char)
		
		if is_player:
			border.bg_color = Color(1, 0.843, 0, 0.12)
			border.border_color = Color(1, 0.843, 0, 0.9)
			border.shadow_size = 8
			border.shadow_color = Color(1, 0.843, 0, 0.3)
		elif is_ai:
			border.bg_color = Color(0.3, 0.5, 1.0, 0.12)
			border.border_color = Color(0.3, 0.5, 1.0, 0.9)
			border.shadow_size = 8
			border.shadow_color = Color(0.3, 0.5, 1.0, 0.3)
		else:
			border.bg_color = Color(1, 1, 1, 0.06)
			border.border_color = Color(0.4, 0.4, 0.4, 0.6)
			border.shadow_size = 0

func _on_card_clicked(event: InputEvent, char_id: String):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_select_card(char_id)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# 右键选择/取消AI英雄
			if selected_ai_char == char_id:
				selected_ai_char = ""
			else:
				selected_ai_char = char_id
			_update_all_card_styles()
			_update_char_title()

# ===== Signal handlers =====

func _init_char_configs():
	if chars_initialized: return
	CharConfigs.ensure_init()
	chars_initialized = true

func _on_pve_pressed():
	GameWorld.game_mode = "pve"
	_show_diff_select()

func _show_diff_select():
	menu_main.visible = false
	pokedex_btn.visible = false
	exit_btn.visible = false
	diff_select.visible = true

func _on_easy_pressed():
	GameWorld.difficulty = "easy"; _show_char_select()

func _on_medium_pressed():
	GameWorld.difficulty = "medium"; _show_char_select()

func _on_hard_pressed():
	GameWorld.difficulty = "hard"; _show_char_select()

func _on_hell_pressed():
	GameWorld.difficulty = "hell"; _show_char_select()

func _on_diff_back_pressed():
	diff_select.visible = false
	menu_main.visible = true
	pokedex_btn.visible = true
	exit_btn.visible = true

func _on_coming_pressed():
	_show_toast("功能开发中，敬请期待")

func _on_pvp_pressed():
	_show_toast("局域网联机开发中，敬请期待")

func _show_toast(msg: String):
	var toast = ColorRect.new()
	toast.color = Color(0, 0, 0, 0.85)
	toast.set_anchors_preset(Control.PRESET_FULL_RECT)
	toast.mouse_filter = Control.MOUSE_FILTER_STOP
	toast.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: toast.queue_free())
	add_child(toast)

	var lbl = Label.new()
	lbl.text = msg
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.add_child(lbl)

	# Auto-close after 2 seconds
	get_tree().create_timer(2.0).timeout.connect(func():
		if is_instance_valid(toast): toast.queue_free()
	)

func _show_char_select():
	diff_select.visible = false
	menu_main.visible = false
	pokedex_btn.visible = false; exit_btn.visible = false
	char_select.visible = true
	if char_cards.is_empty(): _populate_characters()
	selected_ai_char = ""
	_update_all_card_styles()
	_update_char_title()

func _update_char_title():
	var ai_name = CharConfigs.get_char_name(selected_ai_char) if selected_ai_char != "" else "随机"
	char_title_label.text = "选择英雄 (左键)    |    AI: " + ai_name + " (右键选择)"

func _on_back_pressed():
	char_select.visible = false
	diff_select.visible = true

func _on_title_clicked(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_title_click_count += 1
		if _title_click_count >= 4:
			_title_click_count = 0
			GameWorld.infinite_energy = not GameWorld.infinite_energy
			var status = "开启" if GameWorld.infinite_energy else "关闭"
			_show_toast("作弊：" + status)

func _on_exit_pressed():
	GameWorld.cleanup_draw_callbacks()
	get_tree().quit()

func _on_start_pressed():
	# 重置天赋池为3个空槽位
	GameWorld.talent_pool = ["", "", ""]
	# 传递AI英雄选择
	GameWorld.selected_ai_char_id = selected_ai_char
	# 弹出天赋选择界面
	_talent_from_char_select = true
	talent_overlay.visible = true
	char_select.visible = false
	_rebuild_slot_bar()

# ===== 地图池管理 =====

func _style_map_pool_ui():
	map_pool_btn.pressed.connect(_on_map_pool_pressed)
	map_pool_close.pressed.connect(_on_map_pool_close)
	# 样式：匹配 pokedex 按钮风格
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.416, 0.298, 0.612, 0.15)
	style.set_corner_radius_all(8)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.416, 0.298, 0.612, 0.4)
	map_pool_btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color(0.416, 0.298, 0.612, 0.25)
	hover.border_color = Color(0.416, 0.298, 0.612, 0.6)
	map_pool_btn.add_theme_stylebox_override("hover", hover)
	map_pool_btn.add_theme_color_override("font_color", Color(0.67, 0.53, 1.0))
	map_pool_btn.add_theme_color_override("font_hover_color", Color(0.8, 0.67, 1.0))
	
	var title = $MapPoolOverlay/MapPoolPanel/MapPoolHeader/MapPoolTitle
	title.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	map_pool_close.add_theme_color_override("font_color", Color(0.914, 0.271, 0.157))
	map_pool_close.add_theme_font_size_override("font_size", 20)

func _populate_map_pool():
	for child in map_pool_container.get_children():
		child.queue_free()
	
	var all_maps = MapManager.get_all_maps()
	for map_path in all_maps:
		var name_str = MapManager.get_display_name(map_path)
		
		# 锁定地图：不可勾选，整行点击提示"开发中"
		if MapManager.is_locked(map_path):
			var hbox = HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 8)
			hbox.mouse_filter = Control.MOUSE_FILTER_STOP
			hbox.gui_input.connect(_on_locked_map_clicked.bind(map_path))
			var lbl = Label.new()
			lbl.text = name_str
			lbl.add_theme_color_override("font_color", Color(0.4, 0.35, 0.45))
			lbl.add_theme_font_size_override("font_size", 14)
			hbox.add_child(lbl)
			var tag = Label.new()
			tag.text = "开发中"
			tag.add_theme_color_override("font_color", Color(0.6, 0.4, 0.2))
			tag.add_theme_font_size_override("font_size", 10)
			hbox.add_child(tag)
			map_pool_container.add_child(hbox)
			continue
		
		var is_enabled = MapManager.is_in_pool(map_path)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		
		var check = CheckBox.new()
		check.button_pressed = is_enabled
		check.toggled.connect(_on_map_toggle.bind(map_path))
		check.add_theme_color_override("font_color", Color(0.8, 0.73, 0.9))
		hbox.add_child(check)
		
		var lbl = Label.new()
		lbl.text = name_str
		lbl.add_theme_color_override("font_color", Color(0.7, 0.6, 0.8))
		lbl.add_theme_font_size_override("font_size", 14)
		hbox.add_child(lbl)
		
		map_pool_container.add_child(hbox)

func _on_map_toggle(pressed: bool, map_path: String):
	MapManager.toggle_map(map_path)
	print("[MapPool] 切换: ", MapManager.get_display_name(map_path), " 池中=", MapManager.is_in_pool(map_path))

## 锁定地图点击：提示开发中
func _on_locked_map_clicked(event: InputEvent, _map_path: String):
	if event is InputEventMouseButton and event.pressed:
		_show_toast("该地图开发中，敬请期待")

func _on_map_pool_pressed():
	map_pool_overlay.visible = true
	menu_main.visible = false
	pokedex_btn.visible = false
	exit_btn.visible = false
	talent_btn.visible = false
	map_pool_btn.visible = false

func _on_map_pool_close():
	map_pool_overlay.visible = false
	menu_main.visible = true
	pokedex_btn.visible = true
	exit_btn.visible = true
	talent_btn.visible = true
	map_pool_btn.visible = true

# ===== 天赋管理 =====

func _add_talent_slot_styles():
	# 遍历槽位栏中的所有 VBox → PanelContainer
	for vbox in talent_slot_bar.get_children():
		if not (vbox is VBoxContainer):
			continue
		for child in vbox.get_children():
			if not (child is PanelContainer):
				continue
			var style = StyleBoxFlat.new()
			# 检查是否装有天赋（通过子 HBox 里 Label 的文字判断）
			var hbox = child.get_child(0) if child.get_child_count() > 0 else null
			if hbox and hbox.get_child_count() > 0 and hbox.get_child(0) is Label:
				var lbl = hbox.get_child(0)
				if lbl.text == "" or lbl.text == "空":
					style.bg_color = Color(0.35, 0.35, 0.4, 0.08)
					style.border_color = Color(0.35, 0.35, 0.4, 0.25)
				else:
					style.bg_color = Color(0.8, 0.6, 0.2, 0.15)
					style.border_color = Color(0.8, 0.6, 0.2, 0.6)
			style.set_corner_radius_all(6)
			style.border_width_left = 1; style.border_width_right = 1
			style.border_width_top = 1; style.border_width_bottom = 1
			child.add_theme_stylebox_override("panel", style)

func _style_talent_ui():
	talent_close.pressed.connect(_on_talent_close)
	# 不再连接 talent_btn（已隐藏）
	
	var title = $TalentOverlay/TalentPanel/TalentHeader/TalentTitle
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
	talent_close.add_theme_color_override("font_color", Color(0.914, 0.271, 0.157))
	talent_close.add_theme_font_size_override("font_size", 20)
	
	# 禁用横向滚动，只保留竖向
	var scroll = $TalentOverlay/TalentPanel/TalentScroll
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	# 在天赋面板底部添加"开始战斗"确认按钮
	var confirm_btn = Button.new()
	confirm_btn.name = "TalentConfirmBtn"
	confirm_btn.text = "⚔️ 开始战斗"
	confirm_btn.custom_minimum_size = Vector2(0, 40)
	confirm_btn.pressed.connect(_on_talent_confirm)
	_style_action_button(confirm_btn, Color(0.298, 0.686, 0.314), "⚔️ 开始战斗")
	$TalentOverlay/TalentPanel.add_child(confirm_btn)
	
	# 更新提示文字
	var tip = $TalentOverlay/TalentPanel/TipLabel
	tip.text = "左键添加天赋 | 右键移除天赋 | 主动天赋→槽位①  被动天赋→槽位②③"

func _rebuild_slot_bar():
	# Remove old slot panels and type labels (keep SlotLabel)
	for child in talent_slot_bar.get_children():
		if not (child is Label and child.name == "SlotLabel"):
			child.queue_free()
	
	var slot_type_labels = ["主动天赋", "被动天赋①", "被动天赋②"]
	var slot_type_colors = [Color(0.5, 0.7, 1.0), Color(0.5, 0.9, 0.6), Color(0.5, 0.9, 0.6)]
	
	for i in range(GameWorld.MAX_TALENT_SLOTS):
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# 类型标签（主动/被动）
		var type_lbl = Label.new()
		type_lbl.text = slot_type_labels[i]
		type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		type_lbl.add_theme_font_size_override("font_size", 9)
		type_lbl.add_theme_color_override("font_color", slot_type_colors[i])
		vbox.add_child(type_lbl)
		
		# 槽位面板
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(96, 28)
		panel.gui_input.connect(_on_slot_random_clicked.bind(i))  # 右键点击槽位 → 随机选择天赋
		
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var tid = GameWorld.talent_pool[i]
		if tid != "":
			var meta = TalentPool.get_metadata(tid)
			var lbl = Label.new()
			lbl.text = meta.get("name", tid)
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 10)
			lbl.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
			hbox.add_child(lbl)
			
			# 移除按钮
			var rm_btn = Button.new()
			rm_btn.text = "✕"
			rm_btn.flat = true
			rm_btn.custom_minimum_size = Vector2(16, 16)
			rm_btn.add_theme_font_size_override("font_size", 8)
			rm_btn.add_theme_color_override("font_color", Color(0.914, 0.271, 0.157))
			rm_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.3))
			rm_btn.pressed.connect(_on_slot_remove.bind(i))
			hbox.add_child(rm_btn)
		else:
			var lbl = Label.new()
			lbl.text = "空"
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 9)
			lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
			hbox.add_child(lbl)
		
		panel.add_child(hbox)
		vbox.add_child(panel)
		talent_slot_bar.add_child(vbox)
	
	_add_talent_slot_styles()

func _on_slot_remove(slot_index: int):
	if slot_index < GameWorld.talent_pool.size():
		GameWorld.talent_pool[slot_index] = ""
		_populate_talents()

## 右键点击携带天赋框：随机选择该槽位可用的天赋
func _on_slot_random_clicked(event: InputEvent, slot_index: int):
	if not (event is InputEventMouseButton and event.pressed):
		return
	if event.button_index != MOUSE_BUTTON_RIGHT:
		return
	# 槽位 0 为主动，1/2 为被动；battle_frenzy 占 2 格仅在两被动槽都空时可选
	var is_skill_slot = (slot_index == 0)
	var pool: Array = []
	for tid in TalentPool.get_all_ids():
		var meta = TalentPool.get_metadata(tid)
		if meta.get("is_skill", false) == is_skill_slot:
			if tid == "battle_frenzy":
				if GameWorld.talent_pool[1] == "" and GameWorld.talent_pool[2] == "":
					pool.append(tid)
			else:
				pool.append(tid)
	if pool.is_empty():
		_show_toast("没有可用的随机天赋喵~")
		return
	var tid = pool[randi() % pool.size()]
	if is_skill_slot:
		GameWorld.talent_pool[0] = tid
	elif tid == "battle_frenzy":
		GameWorld.talent_pool[1] = tid
		GameWorld.talent_pool[2] = tid
	else:
		GameWorld.talent_pool[slot_index] = tid
	_populate_talents()
	_show_toast("随机选择：" + TalentPool.get_metadata(tid).get("name", tid))

func _populate_talents():
	for child in talent_container.get_children():
		child.queue_free()
	
	_rebuild_slot_bar()
	
	# 统计每个天赋在 talent_pool 中出现了几次（支持重复选取=叠层）
	var count_map = {}
	for tid in GameWorld.talent_pool:
		if tid != "":
			count_map[tid] = count_map.get(tid, 0) + 1
	
	for tid in TalentPool.get_all_ids():
		var meta = TalentPool.get_metadata(tid)
		var count = count_map.get(tid, 0)
		var is_skill = meta.get("is_skill", false)
		var type_str = "主动" if is_skill else "被动"
		
		# Create talent card
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(80, 80)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Card style (highlighted if selected)
		var card_style = StyleBoxFlat.new()
		if count > 0:
			card_style.bg_color = Color(0.8, 0.6, 0.2, 0.2)
			card_style.border_color = Color(0.8, 0.6, 0.2, 0.8)
		else:
			card_style.bg_color = Color(0.15, 0.15, 0.18, 0.8)
			card_style.border_color = Color(0.3, 0.3, 0.35, 0.5)
		card_style.set_corner_radius_all(8)
		card_style.border_width_left = 2; card_style.border_width_right = 2
		card_style.border_width_top = 2; card_style.border_width_bottom = 2
		card.add_theme_stylebox_override("panel", card_style)
		
		# Click: left=添加, right=移除
		card.gui_input.connect(_on_talent_card_clicked.bind(tid))
		
		# Content
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 1)
		
		var name_lbl = Label.new()
		var name_text = meta.get("name", tid)
		if count > 0:
			name_text += "  ×" + str(count)
		name_lbl.text = name_text
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.7) if count > 0 else Color(0.8, 0.8, 0.85))
		vbox.add_child(name_lbl)
		
		var type_lbl = Label.new()
		type_lbl.text = type_str
		type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		type_lbl.add_theme_font_size_override("font_size", 9)
		var type_color = Color(0.5, 0.7, 1.0) if type_str == "主动" else Color(0.5, 0.9, 0.6)
		type_lbl.add_theme_color_override("font_color", type_color)
		vbox.add_child(type_lbl)
		
		card.add_child(vbox)
		talent_container.add_child(card)

func _on_talent_card_clicked(event: InputEvent, tid: String):
	if not (event is InputEventMouseButton and event.pressed):
		return
	var is_skill = TalentPool.get_metadata(tid).get("is_skill", false)
	if event.button_index == MOUSE_BUTTON_LEFT:
		# 左键：添加到对应类型的槽位
		if is_skill:
			# 主动天赋 → 只能放槽位0
			if GameWorld.talent_pool[0] != "":
				_show_toast("主动天赋栏位已满喵~")
				return
			if tid in GameWorld.talent_pool:
				_show_toast("该主动天赋已装备喵~")
				return
			GameWorld.talent_pool[0] = tid
		else:
			# 被动天赋 → 只能放槽位1或2
			# ── 战斗，爽！占2格 ──
			if tid == "battle_frenzy":
				if GameWorld.talent_pool[1] != "" or GameWorld.talent_pool[2] != "":
					_show_toast("被动天赋栏位已满喵~（战斗，爽！需要2格）")
					return
				GameWorld.talent_pool[1] = tid
				GameWorld.talent_pool[2] = tid
				_populate_talents()
				return
			# 检查战斗，爽！是否已占用被动位
			if GameWorld.talent_pool[1] == "battle_frenzy" and GameWorld.talent_pool[2] == "battle_frenzy":
				_show_toast("战斗，爽！已占用全部被动栏位喵~")
				return
			var target_slot = -1
			for j in [1, 2]:
				if GameWorld.talent_pool[j] == "":
					target_slot = j
					break
			if target_slot == -1:
				_show_toast("被动天赋栏位已满喵~")
				return
			GameWorld.talent_pool[target_slot] = tid
		_populate_talents()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		# 右键：移除所有槽位中的该天赋
		var removed = false
		for j in range(GameWorld.talent_pool.size()):
			if GameWorld.talent_pool[j] == tid:
				GameWorld.talent_pool[j] = ""
				removed = true
		if removed:
			_populate_talents()
	print("[Talent] ", TalentPool.get_metadata(tid).get("name", tid),
		" 当前=", GameWorld.talent_pool)

func _on_talent_pressed():
	talent_overlay.visible = true
	menu_main.visible = false
	pokedex_btn.visible = false
	exit_btn.visible = false
	map_pool_btn.visible = false
	talent_btn.visible = false
	_rebuild_slot_bar()

func _on_talent_close():
	talent_overlay.visible = false
	if _talent_from_char_select:
		# 从选人界面来的 → 回到选人界面
		_talent_from_char_select = false
		char_select.visible = true
	else:
		# 从主界面来的（虽然入口已删除，保留兼容）
		menu_main.visible = true
		pokedex_btn.visible = true
		exit_btn.visible = true
		map_pool_btn.visible = true

func _on_talent_confirm():
	# 过滤空槽位，只保留已选择的天赋
	var talents: Array = []
	for tid in GameWorld.talent_pool:
		if tid != "":
			talents.append(tid)
	GameWorld.player_talents = talents
	print("[Talent] 确认选择: ", talents)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
