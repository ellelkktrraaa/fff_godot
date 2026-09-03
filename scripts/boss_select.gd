extends Control

## Boss 战"开战前选择界面"。
##
## 数据驱动：进入时通过 BossConfigs 扫描注册表动态加载 Boss 列表（禁硬编码到 UI）。
## 选择 Boss → 弹难度选择层 → 校验解锁 → 写入 GameWorld.boss_id/difficulty → 进 game.tscn。
##
## ProgressSystem（scripts/systems/progress_system.gd）由并行任务创建，为避免并行期间
## 编译期引用失败，本文件绝不写 ProgressSystem 标识符，仅运行时 load 延迟取类再调 static。

# ── 素材 ──
const IMG_BG := preload("res://assets/bg_main_menu.png")
const IMG_DIFF := {
	"easy": preload("res://assets/ui_diff_easy.png"),
	"medium": preload("res://assets/ui_diff_medium.png"),
	"hard": preload("res://assets/ui_diff_hard.png"),
	"hell": preload("res://assets/ui_diff_hell.png"),
}
const DIFF_CN := {"easy": "简单", "medium": "普通", "hard": "困难", "hell": "地狱"}

# ── 主菜单同款配色 ──
const ACCENT_GOLD := Color(1.0, 0.843, 0.0)
const ACCENT_GRAY := Color(0.6, 0.6, 0.6)
const ACCENT_GREEN := Color(0.298, 0.686, 0.314)
const ACCENT_LOCKED := Color(0.95, 0.45, 0.35)

@onready var background: TextureRect = $Background
@onready var back_btn: Button = $BackBtn
@onready var boss_title: Label = $BossTitle
@onready var name_label: Label = $NameLabel
@onready var anim_view = $AnimView
@onready var prev_btn: Button = $PrevBtn
@onready var next_btn: Button = $NextBtn
@onready var index_label: Label = $IndexLabel
@onready var start_btn: Button = $StartBtn
@onready var empty_tip: Label = $EmptyTip
@onready var diff_layer: ColorRect = $DiffLayer
@onready var diff_title: Label = $DiffLayer/DiffPanel/DiffTitle
@onready var diff_tip: Label = $DiffLayer/DiffPanel/DiffTip
@onready var diff_row: HBoxContainer = $DiffLayer/DiffPanel/DiffRow
@onready var diff_back_btn: Button = $DiffLayer/DiffPanel/DiffBackBtn

# Boss 列表状态（数据驱动，从 BossConfigs 读取）
var _boss_ids: Array[String] = []
var _boss_index := 0
var _boss_id := ""

# 难度按钮缓存：difficulty -> {"btn": TextureButton, "tag": Label}
var _diff_buttons := {}

# ProgressSystem 延迟引用（见文件头注释：并行开发期避免编译期引用）
var _ProgressScript = null
var _progress_probed := false


func _ready():
	background.texture = IMG_BG
	_apply_theme()
	_connect_signals()
	# 载入 Boss 列表（BossConfigs 数据驱动，禁硬编码）
	BossConfigs.ensure_init()
	_boss_ids = BossConfigs.get_boss_ids()
	_build_diff_buttons()
	AudioManager.play_music("bgm_boss")
	_show_current_boss()

func _connect_signals():
	back_btn.pressed.connect(_on_back_pressed)
	prev_btn.pressed.connect(_on_prev_pressed)
	next_btn.pressed.connect(_on_next_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	diff_back_btn.pressed.connect(_on_diff_back_pressed)

func _apply_theme():
	boss_title.text = "👑 首领挑战"
	boss_title.add_theme_color_override("font_color", ACCENT_GOLD)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78))
	index_label.add_theme_color_override("font_color", Color(0.8, 0.78, 0.72))
	diff_title.add_theme_color_override("font_color", ACCENT_GOLD)
	diff_tip.add_theme_color_override("font_color", Color(0.7, 0.7, 0.78))
	_style_action_button(back_btn, ACCENT_GRAY, "← 返回")
	_style_arrow_button(prev_btn, "◀")
	_style_arrow_button(next_btn, "▶")
	_style_action_button(start_btn, ACCENT_GREEN, "⚔️ 开始战斗")
	_style_action_button(diff_back_btn, ACCENT_GRAY, "← 返回")

# ===== Boss 展示 =====

func _show_current_boss():
	empty_tip.visible = false
	if _boss_ids.is_empty():
		_set_empty_state()
		return
	_boss_index = clampi(_boss_index, 0, _boss_ids.size() - 1)
	_boss_id = _boss_ids[_boss_index]
	var boss := BossConfigs.get_boss(_boss_id)
	var display_name: String = str(boss.get("name", _boss_id))
	name_label.text = display_name
	index_label.text = "%d / %d" % [_boss_index + 1, _boss_ids.size()]
	start_btn.disabled = false
	prev_btn.disabled = false
	next_btn.disabled = false
	anim_view.present(_load_idle_animation(boss), "该首领暂无可展示动画")

## 通过 CharacterFactory 取角色配置的 idle 动画（FrameAnimation）；无则返回 null
func _load_idle_animation(boss: Dictionary):
	var char_id := str(boss.get("char_id", ""))
	if char_id == "":
		return null
	var cfg := CharacterFactory.get_config(char_id)
	if cfg.is_empty():
		return null
	var anims = cfg.get("animations", {})
	if not (anims is Dictionary):
		return null
	var idle = anims.get("idle")
	return idle if idle is FrameAnimation else null

func _set_empty_state():
	name_label.text = ""
	index_label.text = ""
	start_btn.disabled = true
	prev_btn.disabled = true
	next_btn.disabled = true
	anim_view.present(null, "")
	empty_tip.visible = true

func _on_prev_pressed():
	if _boss_ids.is_empty():
		return
	_boss_index = (_boss_index - 1 + _boss_ids.size()) % _boss_ids.size()
	_show_current_boss()

func _on_next_pressed():
	if _boss_ids.is_empty():
		return
	_boss_index = (_boss_index + 1) % _boss_ids.size()
	_show_current_boss()

func _on_start_pressed():
	# 防止没有 Boss 配置时进入战斗崩溃：空注册表直接退回主菜单
	if _boss_id == "":
		print("[BossSelect] 无 Boss 数据，退回主菜单")
		_exit_to_menu()
		return
	# 每次打开刷新解锁态（进度可能随战斗更新）
	_refresh_diff_buttons()
	diff_tip.text = "为「%s」选择挑战难度" % name_label.text
	diff_layer.visible = true

# ===== 难度选择层 =====

func _build_diff_buttons():
	for child in diff_row.get_children():
		child.queue_free()
	_diff_buttons.clear()
	for d in Constants.DIFFICULTY_LEVELS:
		var icon: Texture2D = IMG_DIFF.get(d)
		var cn_name: String = DIFF_CN.get(d, d)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 4)
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		var btn := TextureButton.new()
		btn.custom_minimum_size = Vector2(104, 104)
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		if icon:
			btn.texture_normal = icon
			btn.texture_pressed = icon
			btn.texture_hover = icon
		btn.tooltip_text = cn_name
		btn.pressed.connect(_on_difficulty_pressed.bind(d))
		var tag := Label.new()
		tag.text = ""
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.add_theme_font_size_override("font_size", 10)
		box.add_child(btn)
		box.add_child(tag)
		diff_row.add_child(box)
		_diff_buttons[d] = {"btn": btn, "tag": tag}

func _refresh_diff_buttons():
	for d in Constants.DIFFICULTY_LEVELS:
		var entry: Dictionary = _diff_buttons.get(d, {})
		var btn: TextureButton = entry.get("btn")
		var tag: Label = entry.get("tag")
		if btn == null:
			continue
		var unlocked := _difficulty_unlocked(d)
		btn.disabled = not unlocked
		btn.modulate = Color(1, 1, 1, 1) if unlocked else Color(0.5, 0.5, 0.55, 0.85)
		if unlocked:
			tag.text = ""
		else:
			tag.text = "🔒 未解锁"
			tag.add_theme_color_override("font_color", ACCENT_LOCKED)

func _on_difficulty_pressed(diff: String):
	if _boss_id == "":
		return
	if not _difficulty_unlocked(diff):
		return
	# 写入 Boss 战上下文，随后切到战斗场景
	GameWorld.boss_id = _boss_id
	GameWorld.difficulty = diff
	GameWorld.game_mode = "pve"
	GameWorld.practice_mode = false
	GameWorld.skip_to_char_select = false
	# 本流程不走选人/选天赋，清空以免残留上一局 PVE 的天赋
	GameWorld.player_talents = []
	GameWorld.enemy_talents = []
	GameWorld.talent_pool = ["", "", ""]
	print("[BossSelect] 开始 Boss 战: boss_id=", _boss_id, " difficulty=", diff)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_diff_back_pressed():
	diff_layer.visible = false

## ProgressSystem.is_boss_difficulty_unlocked 的运行时调用（见文件头注释）
func _difficulty_unlocked(diff: String) -> bool:
	if not _progress_probed:
		_progress_probed = true
		if ClassDB.class_exists("ProgressSystem"):
			_ProgressScript = load("res://scripts/systems/progress_system.gd")
		if _ProgressScript == null and ResourceLoader.exists("res://scripts/systems/progress_system.gd"):
			_ProgressScript = load("res://scripts/systems/progress_system.gd")
		if _ProgressScript == null:
			# TODO(并行开发降级)：progress_system.gd 尚未落盘时，全部难度按"已解锁"处理；
			# 待 ProgressSystem 创建后本分支自动失效（走上方正常 load 路径）。
			print("[BossSelect] 未找到 progress_system.gd → 全部难度按已解锁处理")
	if _ProgressScript == null:
		return true
	return bool(_ProgressScript.is_boss_difficulty_unlocked(_boss_id, diff))

# ===== 返回主菜单 =====

func _exit_to_menu():
	# 返回主菜单时清空 Boss 上下文，避免下次普通 PVE 误进 Boss 流程
	GameWorld.boss_id = ""
	GameWorld.skip_to_char_select = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_back_pressed():
	_exit_to_menu()

# ===== 样式（沿用 main_menu 的 _style_action_button / StyleBoxFlat 深色圆角+描边）=====

func _style_action_button(btn: Button, accent: Color, text: String):
	btn.text = text
	btn.add_theme_font_size_override("font_size", 16)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(accent.r, accent.g, accent.b, 0.2)
	normal.set_corner_radius_all(10)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.6)
	btn.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.4)
	hover.border_color = accent
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", accent)
	btn.add_theme_color_override("font_hover_color", accent.lightened(0.3))
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.2, 0.2, 0.22, 0.25)
	disabled.border_color = Color(0.35, 0.35, 0.4, 0.4)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.45, 0.5))

func _style_arrow_button(btn: Button, glyph: String):
	btn.text = glyph
	btn.add_theme_font_size_override("font_size", 22)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.1, 0.1, 0.14, 0.55)
	normal.set_corner_radius_all(12)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(1.0, 0.843, 0.0, 0.35)
	btn.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color(1.0, 0.843, 0.0, 0.2)
	hover.border_color = Color(1.0, 0.843, 0.0, 0.7)
	btn.add_theme_stylebox_override("hover", hover)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.12, 0.12, 0.14, 0.3)
	disabled.border_color = Color(0.3, 0.3, 0.35, 0.25)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.8))
	btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.45))
