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
@onready var diff_back_btn = $DiffSelect/DiffPanel/DiffBackBtn
@onready var diff_title = $DiffSelect/DiffPanel/DiffTitle

var selected_char := "knight"
var chars_initialized := false
var char_cards := {}
var _title_click_count := 0  # 作弊计数器

const IMG_TITLE = preload("res://assets/34-20260705005653.png")
const IMG_PVE = preload("res://assets/29-20260705005340.png")
const IMG_COMING = preload("res://assets/33-20260705005611.png")
const IMG_PVP = preload("res://assets/31-20260705005426.png")
const IMG_BG = preload("res://assets/无标题102_20260722154610.png")
const IMG_DIFF_EASY = preload("res://assets/36-20260705005735.png")
const IMG_DIFF_MEDIUM = preload("res://assets/38-20260705005805.png")
const IMG_DIFF_HARD = preload("res://assets/39-20260705005825.png")


func _ready():
	print("[MainMenu] _ready() start")
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
	easy_btn.pressed.connect(_on_easy_pressed)
	medium_btn.pressed.connect(_on_medium_pressed)
	hard_btn.pressed.connect(_on_hard_pressed)
	diff_back_btn.pressed.connect(_on_diff_back_pressed)
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)
	dex_close_btn.pressed.connect(_on_dex_close)
	dex_back_btn.pressed.connect(_on_dex_back)
	
	_style_pokedex_button()
	_style_exit_button()
	_style_dex_overlay()
	_style_diff_buttons()
	_style_char_select_buttons()
	
	_populate_characters()
	_populate_dex_grid()

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
	var cfg = CharConfigs.configs.get(char_id, {})
	var dex = cfg.get("dex", {})
	
	dex_detail_icon.text = dex.get("icon", "?")
	dex_detail_name.text = CharConfigs.get_char_name(char_id)
	dex_intro_label.text = dex.get("intro", "")
	
	# Stats
	for child in dex_stats_row.get_children():
		child.queue_free()
	for s in dex.get("stats", []):
		var lbl = Label.new()
		lbl.text = s.get("label", "") + " " + str(s.get("value", ""))
		lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		lbl.add_theme_font_size_override("font_size", 10)
		dex_stats_row.add_child(lbl)
	
	# Skills
	for child in dex_skills_container.get_children():
		child.queue_free()
	for sk in dex.get("skills", []):
		var skill_box = VBoxContainer.new()
		skill_box.add_theme_constant_override("separation", 2)
		
		var name_lbl = Label.new()
		name_lbl.text = sk.get("name", "")
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
		name_lbl.add_theme_font_size_override("font_size", 12)
		skill_box.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = sk.get("desc", "")
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		desc_lbl.add_theme_font_size_override("font_size", 9)
		skill_box.add_child(desc_lbl)
		
		var meta_lbl = Label.new()
		meta_lbl.text = sk.get("meta", "")
		meta_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
		meta_lbl.add_theme_font_size_override("font_size", 8)
		skill_box.add_child(meta_lbl)
		
		dex_skills_container.add_child(skill_box)
	
	dex_list_scroll.visible = false
	dex_detail.visible = true

func _on_pokedex_pressed():
	pokedex_overlay.visible = true
	menu_main.visible = false
	pokedex_btn.visible = false
	exit_btn.visible = false
	# Reset to list view
	dex_detail.visible = false
	dex_list_scroll.visible = true

func _on_dex_close():
	pokedex_overlay.visible = false
	menu_main.visible = true
	pokedex_btn.visible = true
	exit_btn.visible = true

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
	var animations = config.get("animations", {})
	var idle_anim = animations.get("idle", null)
	var img = null
	if idle_anim is FrameAnimation and not idle_anim.frames.is_empty():
		img = idle_anim.frames[0].texture
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
	for cid in char_cards:
		var card = char_cards[cid]
		var inner = card.get_child(0) as PanelContainer
		var border = inner.get_theme_stylebox("panel", "PanelContainer") as StyleBoxFlat
		if not border: continue
		if cid == char_id:
			border.bg_color = Color(1, 0.843, 0, 0.12)
			border.border_color = Color(1, 0.843, 0, 0.9)
			border.shadow_size = 8
			border.shadow_color = Color(1, 0.843, 0, 0.3)
		else:
			border.bg_color = Color(1, 1, 1, 0.06)
			border.border_color = Color(0.4, 0.4, 0.4, 0.6)
			border.shadow_size = 0
	selected_char = char_id
	GameWorld.selected_char_id = char_id

func _on_card_clicked(event: InputEvent, char_id: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_card(char_id)

# ===== Signal handlers =====

func _init_char_configs():
	if chars_initialized: return
	CharConfigs.ensure_init()
	chars_initialized = true

func _on_pve_pressed():
	GameWorld.game_mode = "pve"; _show_diff_select()

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
	menu_main.visible = false
	pokedex_btn.visible = false; exit_btn.visible = false
	char_select.visible = true
	if char_cards.is_empty(): _populate_characters()

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
	get_tree().quit()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
