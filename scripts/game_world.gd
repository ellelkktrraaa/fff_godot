extends Node

# Explicit preloads for cold cache autoload compilation
const Fighter = preload("res://scripts/fighter.gd")
const Constants = preload("res://data/constants.gd")

# Game state
var game_running := false
var game_over := false
var game_result := ""  # "win" or "lose"
var game_mode := "pve" # "pve" or "pvp"
var difficulty := "medium"
var frame := 0
var hit_stop := 0
var time_stop_timer := 0  # 全局时停剩余帧数（60帧=1秒），与角色大招的实体 time_stop 并存
var _time_stop_end_queue: Array = []  # 时停完全结束时触发的动作队列（如"时停结束后紧跟震动"）
# 加载滤镜：游戏结束选择 ESC/R/C 后的呼吸灰色遮罩（帧计数，跨场景生效；阻塞加载不消耗）
var loading_filter_frames := 0

# Talent system
const MAX_TALENT_SLOTS := 3
var player_talents: Array = []
var enemy_talents: Array = []
var talent_pool: Array = ["", "", ""]  # 3个固定槽位: [0]=主动天赋专用, [1][2]=被动天赋专用

# Slow motion
var slow_mo_timer := 0
var slow_mo_tick := 0
var slow_mo_factor: int = 3  # 当前时缓力度：每 N 个逻辑 tick 才跑一帧 _update（默认 3 = 3 倍慢速）
const SLOW_FACTOR := 3
const SLOW_DURATION := 90
const SLOW_MAX := 300
const DEATH_SLOWMO_DURATION := 180  # 击杀时缓 3 秒（60帧=1秒）

# 击杀时缓结算状态：空=未触发；"win"/"lose"=已有人被击杀，正在播放 3 秒时缓，结束后才结算
var death_slowmo_result: String = ""

# Entities
var player = null
var enemy = null
var entities: Array = []

# World arrays
var projectiles: Array = []
var particles: Array = []
var pickups: Array = []
var flame_zones: Array = []
var explosion_effects: Array = []
var tornadoes: Array = []
var vortexes: Array = []
var phantoms: Array = []
var evoker_summons: Array = []
var void_rifts: Array = []
var evoker_fire_seas: Array = []
var gravity_balls: Array = []
var craters: Array = []           # 占星术士陨石坑
var astrologer_cards: Array = []  # 占星术士一技能圣三角牌面显示
var rose_slash_trails: Array = []
var rose_joystick_dir: Vector2 = Vector2.ZERO
var active_overlays: Array = []  # [{anim, position, owner, overlay_id, on_finish}]

# 占星术士大招：愚者之旅
var astrologer_ult_end_frame := 0      # 大招结束帧号（实秒计时）
var astrologer_ult_bg: Texture2D = null
var astrologer_ult_owner = null   # 大招释放者引用
var battle_bg: Texture2D = null   # 当前地图战斗背景

# 从游戏内"角色选择"返回时，主菜单直接跳转到选人界面
var skip_to_char_select := false

# 角色注入的绘制回调 { "key": unique_key, "cb": Callable, "z": int }
# 角色在 skill 激活时注册，用完自行注销；game.gd 只遍历调用，不关心来源
static var draw_effect_callbacks: Array = []

## 注册绘制回调（角色调用）
## top_layer=true 时绘制在全屏 Overlay 之上（HUD 常驻元素，如千峰破云图标）
static func register_draw_effect(key: String, cb: Callable, z: int = 0, screen_space: bool = false, top_layer: bool = false):
	unregister_draw_effect(key)
	draw_effect_callbacks.append({"key": key, "cb": cb, "z": z, "screen_space": screen_space, "top_layer": top_layer})
	draw_effect_callbacks.sort_custom(_sort_by_z)

static func unregister_draw_effect(key: String):
	for i in range(draw_effect_callbacks.size() - 1, -1, -1):
		var e: Dictionary = draw_effect_callbacks[i]
		if e.get("key") == key:
			draw_effect_callbacks.remove_at(i)

static func _sort_by_z(a: Dictionary, b: Dictionary) -> bool:
	return a.get("z", 0) < b.get("z", 0)

# 清理绘制回调（切场景/退出时调用，避免 lambda 持有已释放对象导致挂起）
static func cleanup_draw_callbacks():
	draw_effect_callbacks.clear()

# Platforms
var platforms: Array = []

# Camera
var camera := {"x": 0.0, "y": 0.0}
var camera_vel := {"x": 0.0, "y": 0.0}  # 阻尼速度
var screen_shake_intensity: float = 0.0
var screen_shake_duration: int = 0
# 战斗镜头拉近：倍率（1.0 = 常规）+ 目标倍率（由 zoom_character_centered 设置，
# game.gd _process 每渲染帧平滑趋近目标，不受时缓减慢影响）
const CAMERA_BASE_SCALE := 1.375  # game.gd 初始化时的战斗镜头基准缩放
var camera_zoom := 1.0            # 当前镜头拉近倍率（≥1.0，1.0 = 常规）
var camera_zoom_target := 1.0     # 目标拉近倍率
# [FX-ENHANCE] 特写快速拉近标记：true 时 game.gd _process 用 CAM_ZOOM_SMOOTH_IN_FAST 3~4 帧怼脸
static var zoom_is_closeup: bool = false
# [FX-ENHANCE] 特写焦点（null = 默认玩家）：指定后拉近期间镜头聚焦该对象中心（如命中敌人）
static var zoom_focus: Node = null
var grayscale_timer := 0  # 屏幕黑白滤镜剩余帧数
# [FX-ENHANCE] 本次灰度总时长（帧）：渲染端用 grayscale_total 归一化剩余帧做三角波渐入渐出
static var grayscale_total: int = 0

# Pickup timer
var pickup_timer := 0.0

# Selected character
var selected_char_id := "knight"
var selected_ai_char_id := ""  # 空字符串 = 随机选择

# Cheats
var infinite_energy := false

# ── 练习模式 ──
# 主菜单"练习模式"入口设置 practice_mode=true；练习中任意一方死亡不触发游戏结束
var practice_mode := false
# 战斗内四个开关（顶部按钮切换）：无限火力 / 伤害显示 / 敌人攻击(地狱AI) / 技能介绍
var practice_infinite_fire := false
var practice_damage_display := false
var practice_enemy_ai := false
var practice_skill_intro := false
# 伤害显示：玩家累积对敌人造成的伤害 + 最近一次造成伤害的帧号（15 秒未造成伤害则清零）
var practice_damage_dealt := 0.0
var practice_damage_last_frame := -9999
# 练习模式死亡复活计时（帧，>0 表示正在等待复活）
var practice_respawn_player := 0
var practice_respawn_enemy := 0

## 练习模式敌人攻击开关开启时，AI 一律按地狱难度运行
func effective_ai_difficulty() -> String:
	if practice_mode and practice_enemy_ai:
		return "hell"
	return difficulty

## 练习模式：清零玩家主动天赋冷却（game.gd 每帧调用，实现"主动天赋无冷却"）
func practice_clear_talent_cd():
	if not practice_mode or not is_instance_valid(player):
		return
	if not player.talent_manager:
		return
	for inst in player.talent_slots:
		if not inst or not inst.is_skill or not player.ad.has(inst.talent_id):
			continue
		var state = player.ad[inst.talent_id]
		if state is Dictionary and state.has("cd"):
			state["cd"] = 0

func _ready():
	init_platforms()

func init_platforms():
	platforms = [
		{"x": 0, "y": Constants.GROUND_Y, "w": Constants.MAP_W, "h": 10, "is_ground": true},
		{"x": 400, "y": Constants.GROUND_Y - 120, "w": 120, "h": 12},
		{"x": 1000, "y": Constants.GROUND_Y - 160, "w": 140, "h": 12},
		{"x": 1600, "y": Constants.GROUND_Y - 110, "w": 130, "h": 12},
	]

func reset_world():
	FrameInterrupter.reset()
	projectiles.clear()
	particles.clear()
	pickups.clear()
	flame_zones.clear()
	explosion_effects.clear()
	tornadoes.clear()
	vortexes.clear()
	phantoms.clear()
	evoker_summons.clear()
	void_rifts.clear()
	evoker_fire_seas.clear()
	gravity_balls.clear()
	craters.clear()              # 占星术士陨石坑
	astrologer_cards.clear()     # 占星术士圣三角
	astrologer_ult_bg = null     # 占星术士大招背景（重开需还原）
	astrologer_ult_owner = null
	astrologer_ult_end_frame = 0
	battle_bg = null             # 战斗背景
	rose_slash_trails.clear()
	active_overlays.clear()
	draw_effect_callbacks.clear()
	entities.clear()
	camera.x = 0
	camera.y = 0
	camera_vel.x = 0
	camera_vel.y = 0
	pickup_timer = 0
	slow_mo_timer = 0
	slow_mo_tick = 0
	death_slowmo_result = ""
	grayscale_timer = 0
	grayscale_total = 0  # [FX-ENHANCE] 灰度总时长随定时器一并复位
	time_stop_timer = 0
	_time_stop_end_queue.clear()
	# 练习模式运行状态（practice_mode 本身保留，由主菜单设置/清除）
	practice_infinite_fire = false
	practice_damage_display = false
	practice_enemy_ai = false
	practice_skill_intro = false
	practice_damage_dealt = 0.0
	practice_damage_last_frame = -9999
	practice_respawn_player = 0
	practice_respawn_enemy = 0

func get_opponent(fighter):
	if fighter == player:
		return enemy
	return player

## 时缓：duration 帧内逻辑 3 倍慢速（每 factor 个 tick 才跑一帧），可叠加取最大。
## factor 为 0 时用默认 SLOW_FACTOR(3)；传更大值（如 6/8）可制造更极限的慢镜头。
func trigger_slow_motion(duration: int = SLOW_DURATION, factor: int = 0):
	if game_mode == "pvp":
		return
	slow_mo_factor = factor if factor > 0 else SLOW_FACTOR
	slow_mo_timer = min(SLOW_MAX, slow_mo_timer + duration)

## 屏幕黑白滤镜：全屏灰色覆盖，duration 帧内渐入渐出
func trigger_grayscale(duration: int = 30):
	grayscale_timer = maxi(grayscale_timer, duration)
	# [FX-ENHANCE] 记录本次灰度总时长，渲染端按三角波 0→1→0 渐变
	grayscale_total = duration

## 屏幕抖动：intensity 为抖动强度（像素），duration 为持续帧数
func trigger_shake(intensity: float = 20.0, duration: int = 20):
	screen_shake_intensity = intensity
	screen_shake_duration = maxi(screen_shake_duration, duration)

## 以角色为中心的镜头拉近（通用函数）：设置**目标**拉近倍率，由 game.gd _process 每渲染帧
## 平滑趋近（不受时缓减慢影响），相机目标偏移按 1/zoom 缩放，使角色保持在屏幕中心。
## 倍率计算与触发/恢复时机由调用方负责（如弓箭手按蓄力程度渐进、刺客完美闪避演出），
## 效果结束时调用 restore_camera_zoom() 平滑恢复常规取景。
## closeup = true 表示命中特写：_process 改用快速速率（3~4 帧到位），用于怼脸镜头语言。
func zoom_character_centered(mult: float, closeup: bool = false) -> void:
	camera_zoom_target = maxf(mult, 1.0)
	# [FX-ENHANCE] 记录特写模式，恢复时由 restore_camera_zoom() 复位
	zoom_is_closeup = closeup

## 恢复镜头缩放（目标倍率回 1.0，_process 平滑收敛）
func restore_camera_zoom():
	camera_zoom_target = 1.0
	# [FX-ENHANCE] 恢复时一并复位特写标记与焦点，避免残留影响后续常规取景
	zoom_is_closeup = false
	zoom_focus = null

## 全局时停：duration 帧内所有实体物理冻结（60 帧 = 1 秒），可叠加取最大。
## 返回是否真正生效（PvP 下禁用，返回 false；角色大招的实体时停仍走网络同步）
func trigger_time_stop(duration: int = 60) -> bool:
	if game_mode == "pvp":
		return false
	time_stop_timer = maxi(time_stop_timer, duration)
	return true

## 排队一个动作：在当前时停完全结束时触发（用于"时停结束后紧跟震动"等连招反馈）
func queue_after_time_stop(cb: Callable):
	_time_stop_end_queue.append(cb)

## 时停帧内调用（计时递减 / overlay 结束后）：若时停已完全结束，触发排队动作
func check_time_stop_end():
	if _time_stop_end_queue.is_empty():
		return
	if time_stop_timer <= 0 and not is_time_stopped():
		var q := _time_stop_end_queue
		_time_stop_end_queue = []
		for cb in q:
			if cb.is_valid():
				cb.call()

## 时停是否激活：全局计时器 / 实体 time_stop 标记 / 大招 fullscreen overlay（动画播放期间全程时停）
func is_time_stopped() -> bool:
	if time_stop_timer > 0:
		return true
	for f in entities:
		if is_instance_valid(f) and f.state_flags.get("time_stop", false):
			return true
	for ov in active_overlays:
		var ov_pos: Dictionary = ov.get("position", {})
		if ov_pos.get("type", "") == "fullscreen" and str(ov.get("overlay_id", "")).ends_with("_ult"):
			return true
	return false
