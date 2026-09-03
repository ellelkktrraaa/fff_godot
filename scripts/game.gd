extends Node2D

# UI nodes (CanvasLayer)
@onready var ui_layer = $UILayer
@onready var pause_btn = $UILayer/PauseBtn
@onready var pause_menu = $UILayer/PauseMenu
@onready var continue_btn = $UILayer/PauseMenu/PausePanel/ContinueBtn
@onready var menu_btn = $UILayer/PauseMenu/PausePanel/MenuBtn
@onready var exit_btn = $UILayer/PauseMenu/PausePanel/ExitBtn
@onready var touch_controls = $TouchControls

var is_paused := false

# Input state
var keys := {
	"left": false, "right": false, "up": false, "down": false,
	"attack": false, "skill1": false, "skill2": false, "ult": false, "sub": false,
	"talent1": false, "talent2": false, "talent3": false,
	"space": false,  # 练习模式：按住空格 + 其他按键 = 控制对手角色
}

# Fixed timestep 固定时间步
const FIXED_DT := 1000.0 / 60.0
var _last_time := 0.0
var _accumulator := 0.0

# 战斗镜头拉近（_process 每渲染帧推进，不受时缓减慢影响）
const CAM_ZOOM_SMOOTH_IN := 0.03    # 拉近时缩放平滑速率（缓慢推近，~90 帧到达 ~94%）
const CAM_ZOOM_SMOOTH_OUT := 0.12   # 恢复时缩放平滑速率（较快收回）
# [FX-ENHANCE] 特写快速拉近速率：命中特写 3~4 帧到位（怼脸），恢复仍走 CAM_ZOOM_SMOOTH_OUT
const CAM_ZOOM_SMOOTH_IN_FAST := 0.30
const CAM_ZOOM_POS_LERP := 0.08     # 拉近期间镜头位置每帧趋近目标的比例（60fps 平滑）
const CAM_ZOOM_Y_BIAS := 24.0       # 拉近居中屏幕向下偏移（px）：人形角色头/胸视觉重心在
									# 几何中心上方，需下移才能让视线焦点居中

# AI
var ai_think_delay := 0

# 游戏结束选择操作后的加载滤镜时长（帧，60fps 下 90 帧 ≈ 1.5 秒）
const LOADING_FILTER_FRAMES := 90

# 异步重开加载状态：R 重开时后台预加载资源，期间呼吸滤镜保持画面活动
var _restart_loading := false
var _pending_map_path := ""      # 预选并后台加载的地图
var _pending_enemy_char := ""    # 预选的敌方角色（与 _restart_game 保持一致）
var _pending_load_paths: Array = []

# 当前地图实例
var _current_map: Node2D = null

# ── 练习模式 HUD（顶部开关 + 技能介绍面板）──
var _practice_btns: Dictionary = {}   # key -> Button
var _practice_bar: Control = null
var _intro_overlay: Control = null
var _intro_text: Label = null

# ── 通用开场动画 ──
static var _intro_loaded := false
static var INTRO_F1: Texture2D = null
static var INTRO_F2: Texture2D = null
static var INTRO_F3: Texture2D = null
static var INTRO_F4: Texture2D = null
static var INTRO_FRAMES: Array[Texture2D] = []
const INTRO_FRAME_DUR := 60  # 默认每帧时长（60次=1秒@60fps）
var _intro_durs: Array[int] = []   # 每帧时长（帧数）；角色自定义登场动画可覆盖
var _intro_total := 0              # 开场总时长（帧）
var _intro_timer := -1

func _ready():
	print("[Game] _ready() start")
	_last_time = Time.get_ticks_msec()
	CharConfigs.ensure_init()
	TalentPool.init()
	print("[Game] configs OK, selected_char = ", GameWorld.selected_char_id)
	
	# Pause UI setup
	_style_pause_ui()
	pause_btn.pressed.connect(_toggle_pause)
	continue_btn.pressed.connect(_toggle_pause)
	menu_btn.pressed.connect(_back_to_menu)
	exit_btn.pressed.connect(_exit_game)

	# 练习模式：顶部开关按钮 + 技能介绍面板
	if GameWorld.practice_mode:
		_build_practice_hud()

	call_deferred("_start_game")

func _start_game():
	# Boss 模式：敌人固定为该 Boss 的 char_id（不再随机、不再用 selected_ai_char_id）
	var ai_char := ""
	if GameWorld.is_boss_mode():
		ai_char = BossSystem.resolve_enemy_char()
	else:
		ai_char = GameWorld.selected_ai_char_id
		if ai_char == "":
			# 随机敌人只从可选角色中选（排除隐藏形态如黑法师）
			var enemy_chars = CharacterFactory.get_visible_char_ids()
			ai_char = enemy_chars[randi() % enemy_chars.size()]
	print("Starting game: player=", GameWorld.selected_char_id, " enemy=", ai_char)
	# ── 玩家天赋：使用主菜单选择（若无选择则用默认测试集）──
	var pool = GameWorld.talent_pool
	var has_talent = false
	for tid in pool:
		if tid != "":
			has_talent = true
			break
	if not has_talent:
		GameWorld.player_talents = []
	else:
		GameWorld.player_talents = []
		for tid in pool:
			if tid != "":
				GameWorld.player_talents.append(tid)
	GameWorld.enemy_talents = []
	init_game(GameWorld.selected_char_id, ai_char)

func init_game(player_char_id: String, enemy_char_id: String):
	CharConfigs.ensure_init()
	print("Configs available: ", CharConfigs.configs.keys())
	# 每次开局先清空旧角色实例，避免上一局残留引用触发 "previously freed"
	_clear_old_fighters()
	GameWorld.reset_world()
	CharacterFactory.reinject_draws()
	
	# Boss 模式加载 Boss 固定地图；PVE 传空路径（_load_map 内部走异步预载图优先/随机原逻辑）
	_load_map(BossSystem.resolve_map_path())
	
	# 计算双方出生位置（站在最近的平台上）
	var spawns = _find_spawn_positions()
	
	var p_skills = CharacterFactory.create_skills(player_char_id)
	var e_skills = CharacterFactory.create_skills(enemy_char_id)
	print("Skills created: p=", p_skills.size(), " e=", e_skills.size())
	GameWorld.player = Fighter.new()
	GameWorld.player.setup(spawns.player_x, spawns.player_y, true, player_char_id, p_skills)
	add_child(GameWorld.player)
	GameWorld.enemy = Fighter.new()
	GameWorld.enemy.setup(spawns.enemy_x, spawns.enemy_y, false, enemy_char_id, e_skills)
	add_child(GameWorld.enemy)
	GameWorld.entities = [GameWorld.player, GameWorld.enemy]
	# Boss 战：enemy setup 之后、装配天赋之前应用 modifiers（enemy_talents 为空，顺序安全）
	BossSystem.apply_to_enemy(GameWorld.enemy)
	# ── 装配天赋 ──
	_assemble_talents(GameWorld.player, GameWorld.player_talents)
	_assemble_talents(GameWorld.enemy, GameWorld.enemy_talents)
	PickupSystem.init_pickups()
	GameWorld.game_running = true
	GameWorld.game_over = false
	GameWorld.frame = 0
	# 通用开场动画（所有角色、所有模式）
	_start_intro()
	# 战斗镜头拉近
	self.scale = Vector2(1.375, 1.375)
	# 战斗 BGM 在开场动画播完后由 _update() 触发
	print("Game initialized! player.hp=", GameWorld.player.hp, " enemy.hp=", GameWorld.enemy.hp)

## 清除上一局残留的角色实例：解除注入 → 释放节点 → 置空全局引用
func _clear_old_fighters():
	if is_instance_valid(GameWorld.player):
		GameWorld.player.detach_injections()
		GameWorld.player.queue_free()
	if is_instance_valid(GameWorld.enemy):
		GameWorld.enemy.detach_injections()
		GameWorld.enemy.queue_free()
	GameWorld.player = null
	GameWorld.enemy = null
	GameWorld.entities.clear()
	GameWorld.cleanup_draw_callbacks()
	# 清理死灵骑士战马
	NecroKnightCharacter.horses.clear()

# ── 通用开场动画 ──

## 启动开场动画：注册全屏绘制回调 + 时停，播完自动解除
## 优先使用玩家角色的自定义登场动画（CharacterFactory.get_intro），否则用通用开场
func _start_intro():
	var custom = CharacterFactory.get_intro(GameWorld.selected_char_id)
	if not custom.is_empty():
		# 角色自定义登场动画：帧列表 + 每帧时长（角色脚本自治）
		INTRO_FRAMES.assign(custom["frames"])
		_intro_durs.assign(custom["durs"])
	else:
		if not _intro_loaded:
			INTRO_F1 = load("res://assets/battle_intro/intro_f1.png")
			INTRO_F2 = load("res://assets/battle_intro/intro_f2.png")
			INTRO_F3 = load("res://assets/battle_intro/intro_f3.png")
			INTRO_F4 = load("res://assets/battle_intro/intro_f4.png")
			INTRO_FRAMES = [INTRO_F1, INTRO_F2, INTRO_F3, INTRO_F4]
			_intro_loaded = true
		_intro_durs.resize(INTRO_FRAMES.size())
		_intro_durs.fill(INTRO_FRAME_DUR)
	_intro_total = 0
	for d in _intro_durs:
		_intro_total += d
	_intro_timer = 0
	GameWorld.register_draw_effect("battle_intro", _draw_intro_cb, 999, true)
	GameWorld.hit_stop = _intro_total  # 开场期间全冻结

## 绘制回调入口（签名匹配 draw_effect_callbacks: (font, cam_x, cam_y) -> Array）
## 只负责渲染；帧推进由 _update()（固定 60Hz 逻辑帧）完成，避免受渲染帧率影响
func _draw_intro_cb(_font, _cam_x, _cam_y = 0.0) -> Array:
	if _intro_timer < 0 or _intro_durs.is_empty():
		return []
	var idx := 0
	var elapsed := 0
	for i in range(_intro_durs.size()):
		elapsed += _intro_durs[i]
		if _intro_timer < elapsed:
			idx = i
			break
	return [{"type": "tex", "tex": INTRO_FRAMES[idx], "rect": Rect2(0, 0, Constants.W, Constants.H), "color": Color.WHITE}]

## 根据已加载的平台计算出生位置,确保角色站在地面/平台上
func _assemble_talents(fighter: Fighter, talent_ids: Array):
	if talent_ids.is_empty():
		return
	fighter.talent_manager = TalentManager.new()
	fighter.talent_manager.init(fighter, talent_ids)

func _find_spawn_positions() -> Dictionary:
	var player_x = 160
	var enemy_x = 600
	var player_y = Constants.GROUND_Y - Constants.FIGHTER_H
	var enemy_y = Constants.GROUND_Y - Constants.FIGHTER_H
	
	if GameWorld.platforms.is_empty():
		return {"player_x": player_x, "player_y": player_y, "enemy_x": enemy_x, "enemy_y": enemy_y}
	
	var best_player_plat = null
	var best_player_dist = INF
	var best_enemy_plat = null
	var best_enemy_dist = INF
	
	for p in GameWorld.platforms:
		if p.get("is_void", false):
			continue
		var plat_x = p["x"] + p["w"] / 2.0
		var plat_top = p["y"]
		
		# 左半场（玩家）
		if plat_x < Constants.MAP_W / 2.0:
			var dist_to_default = absf(plat_top - Constants.GROUND_Y)
			if dist_to_default < best_player_dist:
				# 确保角色宽度能站在平台上
				if p["w"] >= Constants.FIGHTER_W:
					best_player_dist = dist_to_default
					best_player_plat = p
		# 右半场（敌方）
		else:
			var dist_to_default = absf(plat_top - Constants.GROUND_Y)
			if dist_to_default < best_enemy_dist:
				if p["w"] >= Constants.FIGHTER_W:
					best_enemy_dist = dist_to_default
					best_enemy_plat = p
	
	if best_player_plat:
		player_y = best_player_plat["y"] - Constants.FIGHTER_H
		# 角色居中放在平台上
		player_x = best_player_plat["x"] + best_player_plat["w"] / 2.0 - Constants.FIGHTER_W / 2.0
	if best_enemy_plat:
		enemy_y = best_enemy_plat["y"] - Constants.FIGHTER_H
		enemy_x = best_enemy_plat["x"] + best_enemy_plat["w"] / 2.0 - Constants.FIGHTER_W / 2.0
	
	print("[Spawn] 玩家: (", player_x, ", ", player_y, ") 敌人: (", enemy_x, ", ", enemy_y, ")")
	return {"player_x": player_x, "player_y": player_y, "enemy_x": enemy_x, "enemy_y": enemy_y}

## 加载指定地图并实例化平台。map_path 为空时保留原随机逻辑：
## 优先使用异步重开时预加载的 _pending_map_path，再随机选图（MapManager.pick_random()）
func _load_map(map_path: String = ""):
	# 清理旧地图
	if _current_map:
		_current_map.queue_free()
		_current_map = null
	GameWorld.platforms.clear()
	
	MapManager.ensure_init()
	# 优先使用异步重开时预加载的地图，否则随机选
	if map_path == "":
		map_path = _pending_map_path
	_pending_map_path = ""
	if map_path == "":
		map_path = MapManager.pick_random()
	print("[Map] 选中地图: ", map_path)
	
	var map_scene = load(map_path)
	if not map_scene:
		push_error("[Map] 加载地图场景失败: ", map_path)
		GameWorld.init_platforms()
		return
	
	_current_map = map_scene.instantiate()
	add_child(_current_map)
	# 地形块改由 RenderSystem 管线统一绘制（避免场景 sprite 作为子节点盖住角色/HUD），隐藏场景自渲染
	_current_map.visible = false
	
	# 根据地图类型随机选择背景
	GameWorld.battle_bg = MapManager.get_background(map_path)
	print("[Map] 背景: ", "有" if GameWorld.battle_bg else "无(渐变)")
	
	# 从 PlatformContainer 读取地形块
	var container = _current_map.get_node_or_null("PlatformContainer")
	if not container:
		push_error("[Map] 地图缺少 PlatformContainer 节点: ", map_path)
		GameWorld.init_platforms()
		return
	
	for child in container.get_children():
		var tile_script = child.get_script()
		if tile_script and tile_script.resource_path == "res://scripts/terrain_tile.gd":
			var tt = child
			var ttype = tt.tile_type
			var is_ground = ttype == 0
			var is_wall = ttype == 1
			var is_void = ttype == 3
			GameWorld.platforms.append({
				"x": tt.position.x,
				"y": tt.position.y,
				# 碰撞盒尺寸必须乘以 scale，否则与渲染宽度不一致（见 map3 隐形屏障 bug）
				"w": tt.block_w * tt.scale.x,
				"h": tt.block_h * tt.scale.y,
				"is_ground": is_ground,
				"is_wall": is_wall,
				"is_void": is_void,
				"terrain_type": ttype,
				# 贴图与缩放：供 RenderSystem 在正确层级（角色/HUD 之下）统一绘制
				"tex": tt.texture,
				"scale_x": 1.0,
				"scale_y": 1.0,
			})
	
	# 地形块已隐藏场景自渲染，由 RenderSystem 管线统一绘制
	print("[Map] 加载 ", GameWorld.platforms.size(), " 个地形块, 地图=", MapManager.get_display_name(map_path))

func _process(_delta: float):
	# 战斗镜头缩放：基准 1.375x × 拉近倍率。camera_zoom 每渲染帧平滑趋近目标
	# （拉近慢速、恢复快速），不受时缓减慢影响，避免慢动作下逐帧跳变卡顿
	# [FX-ENHANCE] 特写快速模式：zoom_is_closeup 时用快速速率 3~4 帧怼脸，否则原慢速蓄力渐变
	var zoom_smooth: float = CAM_ZOOM_SMOOTH_OUT
	if GameWorld.camera_zoom_target > 1.0:
		zoom_smooth = CAM_ZOOM_SMOOTH_IN_FAST if GameWorld.zoom_is_closeup else CAM_ZOOM_SMOOTH_IN
	GameWorld.camera_zoom = lerpf(GameWorld.camera_zoom, GameWorld.camera_zoom_target, zoom_smooth)
	if absf(GameWorld.camera_zoom - GameWorld.camera_zoom_target) < 0.001:
		GameWorld.camera_zoom = GameWorld.camera_zoom_target
	self.scale = Vector2(GameWorld.CAMERA_BASE_SCALE, GameWorld.CAMERA_BASE_SCALE) * GameWorld.camera_zoom
	# 异步重开加载中：持续点亮呼吸滤镜，直到后台资源加载完成
	if _restart_loading:
		GameWorld.loading_filter_frames = LOADING_FILTER_FRAMES
	# 加载滤镜帧计数：每渲染帧递减
	if GameWorld.loading_filter_frames > 0:
		GameWorld.loading_filter_frames -= 1
	if not GameWorld.game_running or GameWorld.game_over:
		# 非运行期间刷新基准时间，避免恢复后一次性补跑造成时间跳跃
		_last_time = Time.get_ticks_msec()
		queue_redraw()
		# Always show UI for game over
		return
	if is_paused:
		_last_time = Time.get_ticks_msec()
		queue_redraw()
		return
	var now = Time.get_ticks_msec()
	if _last_time == 0:
		_last_time = now
	var dt = now - _last_time
	_last_time = now
	if dt > 250:
		dt = 250
	_accumulator += dt
	while _accumulator >= FIXED_DT:
		if GameWorld.slow_mo_timer > 0:
			GameWorld.slow_mo_timer -= 1
			GameWorld.slow_mo_tick += 1
			if GameWorld.slow_mo_tick >= GameWorld.slow_mo_factor:
				GameWorld.slow_mo_tick = 0
				_update()
		else:
			GameWorld.slow_mo_tick = 0
			GameWorld.slow_mo_factor = GameWorld.SLOW_FACTOR  # 时缓结束复位默认力度
			_update()
		if GameWorld.grayscale_timer > 0:
			GameWorld.grayscale_timer -= 1
		_accumulator -= FIXED_DT
	# 拉近期间：镜头位置每渲染帧直接趋近居中目标（60fps 平滑，不受时缓减慢影响）。
	# 以角色碰撞盒中心（冲刺时随冲刺方向前移）为拉近中心，角色移动时中心随之移动，
	# 允许拍到地图外（不做地图边界钳制）
	if GameWorld.camera_zoom_target > 1.0:
		var cam_scale: float = GameWorld.CAMERA_BASE_SCALE * GameWorld.camera_zoom
		# [FX-ENHANCE] 特写焦点可指定：zoom_focus 非空时聚焦该对象中心（null 默认玩家）
		var focus_obj: Node = GameWorld.zoom_focus if GameWorld.zoom_focus != null else GameWorld.player
		var hb: Rect2 = focus_obj.get_hit_box()
		var ccx: float = hb.position.x + hb.size.x / 2.0
		var ccy: float = hb.position.y + hb.size.y / 2.0
		var tcam: float = ccx - (Constants.W * 0.5) / cam_scale
		var tcamy: float = ccy - (Constants.H * 0.5 + CAM_ZOOM_Y_BIAS) / cam_scale
		GameWorld.camera_vel.x = 0.0
		GameWorld.camera_vel.y = 0.0
		GameWorld.camera.x += (tcam - GameWorld.camera.x) * CAM_ZOOM_POS_LERP
		GameWorld.camera.y += (tcamy - GameWorld.camera.y) * CAM_ZOOM_POS_LERP
	queue_redraw()

func _update():
	# 开场动画按固定 60Hz 逻辑帧推进（与渲染帧率无关，保证各设备时长一致）
	if _intro_timer >= 0:
		_intro_timer += 1
		if _intro_timer >= _intro_total:
			_intro_timer = -1
			GameWorld.unregister_draw_effect("battle_intro")
			# 开场动画播放完毕 → 战斗 BGM 开始（play_music 幂等，重开时不重复触发）
			# Boss 战固定播 bgm_boss；PVE 保持原两首随机
			if GameWorld.is_boss_mode():
				AudioManager.play_music("bgm_boss")
			else:
				AudioManager.play_music("bgm_battle" if randi() % 2 == 0 else "bgm_battle_alt")
	if GameWorld.hit_stop > 0:
		GameWorld.hit_stop -= 1
		return

	# ── 时停：全冻结（技能冷却/飞行物/buff 持续时间/AI/输入/物理 全部停摆）──
	# 只推进 大招 overlay 动画（播放时长即时停时长）与 出招者自身的逻辑（保证大招出伤）
	if GameWorld.is_time_stopped():
		if GameWorld.time_stop_timer > 0:
			GameWorld.time_stop_timer -= 1
		CharacterSystems.update_active_overlays()
		GameWorld.check_time_stop_end()
		_advance_time_stop_casters()
		return

	# 角色系统更新先行：让角色向中断器注册计时项
	# 双影武者对局时，双方的中断计时器同时递减
	FrameInterrupter.reset()
	CharacterSystems.update_characters()

	# 中断器判定：有活跃中断则 on_break 接管本帧执行权
	if FrameInterrupter.has_active():
		FrameInterrupter.run_breaks()
		GameWorld.frame += 1
		return

	GameWorld.frame += 1
	if GameWorld.player and GameWorld.player.dashing and GameWorld.player.image_state == "skill1":
		print("[ROSE-GRAB] === 帧开始 === frame=", GameWorld.frame, " rose.pos_x=", GameWorld.player.pos_x, " enemy.pos_x=", GameWorld.enemy.pos_x if GameWorld.enemy else "N/A", " enemy.vx=", GameWorld.enemy.vx if GameWorld.enemy else "N/A", " trails.size=", GameWorld.rose_slash_trails.size())
	# Cap particles to prevent performance leak
	if GameWorld.particles.size() > 300:
		GameWorld.particles = GameWorld.particles.slice(GameWorld.particles.size() - 300)
	# Update all skills (cooldowns)
	for f in GameWorld.entities:
		if not is_instance_valid(f):
			continue
		for sk in f.skills:
			sk.update()
	# Update status effects (burn, frozen, etc.) every frame
	for f in GameWorld.entities:
		if not is_instance_valid(f):
			continue
		f.update_statuses()
	# Update talent managers
	for f in GameWorld.entities:
		if not is_instance_valid(f):
			continue
		if f.talent_manager:
			f.talent_manager.update()
	# Input & AI (must happen BEFORE physics, so vx/vy from input take effect same frame)
	InputHandler.update_player_input(GameWorld, keys)
	InputRouter.handle_talent_keys(keys)
	# 练习模式：空格按住手动控制对手期间，不跑敌方 AI
	if GameWorld.practice_mode and keys["space"]:
		ai_think_delay = 0
	else:
		ai_think_delay = AISystem.update_ai(ai_think_delay)
	# Apply physics (after input, matching JS order)
	_apply_physics_all()
	if GameWorld.player and GameWorld.player.dashing and GameWorld.player.image_state == "skill1":
		print("[ROSE-GRAB] physics后: frame=", GameWorld.frame, " rose.pos_x=", GameWorld.player.pos_x, " enemy.pos_x=", GameWorld.enemy.pos_x if GameWorld.enemy else "N/A", " enemy.vx=", GameWorld.enemy.vx if GameWorld.enemy else "N/A")
	# 作弊：无限蓝
	if GameWorld.infinite_energy and GameWorld.player:
		GameWorld.player.energy = GameWorld.player.max_energy
	# 练习模式：无限火力（无限能量 + 技能/大招无cd）
	if GameWorld.practice_mode and GameWorld.practice_infinite_fire and GameWorld.player:
		GameWorld.player.energy = GameWorld.player.max_energy
		for sk in GameWorld.player.skills:
			sk.cd = 0
	# 练习模式：主动天赋无冷却（放在输入之后，避免激活当帧 HUD 闪一下冷却）
	GameWorld.practice_clear_talent_cd()
	# 闪避慢动作：刺客 dodge_slow_mo 期间，跳过敌方实体和投射物更新
	var dodge_slow_active = false
	for f in GameWorld.entities:
		if not is_instance_valid(f):
			continue
		if f.state_flags.get("dodge_slow", 0) > 0:
			dodge_slow_active = true
			break
	# Systems
	DashSystem.update_dash()
	if not dodge_slow_active:
		CharacterFactory.call_global_update("witch")
		ProjectileSystem.update_projectiles(self)
		FlameZoneSystem.update_flame_zones()
	SlowSystem.update_slow()
	PickupSystem.update_pickups_and_end()
	# CharacterSystems.update_characters() 已移至帧首，不再重复调用
	if GameWorld.enemy and GameWorld.player and GameWorld.player.dashing and GameWorld.player.image_state == "skill1":
		print("[ROSE-GRAB] 敌人位置(update_characters后): frame=", GameWorld.frame, " enemy.pos_x=", GameWorld.enemy.pos_x, " enemy.vx=", GameWorld.enemy.vx)
	CharacterSystems.update_active_overlays()
	# CharacterFactory.call_rose_trails() 已由 CharacterSystems.update_characters() 在帧首调用，不再重复
	CharacterFactory.call_global_update("evoker")
	CharacterFactory.call_global_update("bard")
	# Camera — 面向方向占3/5屏幕，钳制防止拍到地图以外。
	# 拉近期间镜头位置由 _process 每渲染帧驱动（不受时缓减慢影响），这里只跑常规取景弹簧
	const CAM_STIFFNESS := 0.015
	const CAM_FRICTION := 0.88
	if GameWorld.camera_zoom_target <= 1.0:
		var cam_offset = Constants.W * 0.275 if GameWorld.player.facing > 0 else Constants.W * 0.475
		var target_cam = GameWorld.player.pos_x - cam_offset
		# 视野受战斗缩放影响：实际可见宽 = W / scale（scale=CAMERA_BASE_SCALE×zoom），
		# clamp 上限需相应放大，否则按未缩放视口算会拍不到地图右端
		var view_w: float = Constants.W / maxf(GameWorld.CAMERA_BASE_SCALE * GameWorld.camera_zoom, 0.1)
		target_cam = clampf(target_cam, 0.0, Constants.MAP_W - view_w)
		# Camera Y — 以角色为中心，地面以下可以照一点
		var target_cam_y = GameWorld.player.pos_y - Constants.H / 2.0
		target_cam_y = clampf(target_cam_y, -30.0, 80.0)
		GameWorld.camera_vel.x += (target_cam - GameWorld.camera.x) * CAM_STIFFNESS
		GameWorld.camera_vel.x *= CAM_FRICTION
		GameWorld.camera.x += GameWorld.camera_vel.x
		GameWorld.camera_vel.y += (target_cam_y - GameWorld.camera.y) * CAM_STIFFNESS
		GameWorld.camera_vel.y *= CAM_FRICTION
		GameWorld.camera.y += GameWorld.camera_vel.y
	# 屏幕抖动：直接叠加高频随机偏移（X/Y 双轴同震，绕过弹簧保持高频）
	# [FX-ENHANCE] 强度每帧指数衰减（×0.88）：从强到弱自然消退，结束无"戛然而止"感
	if GameWorld.screen_shake_duration > 0:
		GameWorld.screen_shake_duration -= 1
		var shk = GameWorld.screen_shake_intensity
		GameWorld.camera.x += randf_range(-shk, shk)
		GameWorld.camera.y += randf_range(-shk, shk) * 0.7
		GameWorld.screen_shake_intensity *= 0.88  # 指数衰减（0.88 可调，0.82~0.9 区间）
		if GameWorld.screen_shake_intensity < 0.5:
			GameWorld.screen_shake_duration = 0  # 强度近零直接收尾，避免低频残留
	# 地图贴图同步镜头偏移
	if _current_map:
		_current_map.position = Vector2(-GameWorld.camera.x, -GameWorld.camera.y)

## 时停期间：只推进出招者（state=ult / time_stop 标记 / 拥有 "_ult" 大招 overlay）的 update_systems，
## 保证大招出伤与演出状态在时停中照常推进；其余实体全部冻结
func _advance_time_stop_casters():
	for f in GameWorld.entities:
		if not is_instance_valid(f) or f.hp <= 0:
			continue
		var is_caster: bool = f.state == "ult" or f.state_flags.get("time_stop", false)
		if not is_caster:
			for ov in GameWorld.active_overlays:
				if str(ov.get("overlay_id", "")).ends_with("_ult") and ov.get("owner") == f:
					is_caster = true
					break
		if is_caster:
			CharacterFactory.update_char_systems(f)

func _apply_physics_all():
	# Time stop check — 全局 trigger_time_stop 或 任一实体 time_stop（角色大招）激活时跳过物理
	var time_stopped = GameWorld.time_stop_timer > 0
	if not time_stopped:
		for f in GameWorld.entities:
			if not is_instance_valid(f):
				continue
			if f.state_flags.get("time_stop", false):
				time_stopped = true
				break
	if not time_stopped:
		for f in GameWorld.entities:
			if is_instance_valid(f):
				f.apply_physics()

# ===== Drawing =====
func _draw():
	RenderSystem.draw_frame(self)

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if GameWorld.game_over:
				_start_loading_filter()
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			else:
				_toggle_pause()
			return
		# 调试：F2 切换碰撞体边框显示
		if event.pressed and event.keycode == KEY_F2:
			RenderSystem.debug_draw_hitboxes = not RenderSystem.debug_draw_hitboxes
			print("[DEBUG] hitbox 显示: ", "ON" if RenderSystem.debug_draw_hitboxes else "OFF")
			return
		InputRouter.map_game_keys(event, keys)
		if event.pressed and event.keycode == KEY_R and GameWorld.game_over and not _restart_loading:
			_begin_async_restart()
		if event.pressed and event.keycode == KEY_C and GameWorld.game_over:
			_start_loading_filter()
			_back_to_menu()

## 游戏结束选择 ESC/R/C 后，开启加载中的灰色呼吸滤镜（帧计数，阻塞加载不消耗）
func _start_loading_filter():
	GameWorld.loading_filter_frames = LOADING_FILTER_FRAMES

## R 重开：先显示呼吸滤镜，后台线程预加载地图+角色贴图，加载完成才正式开局
func _begin_async_restart():
	if _restart_loading:
		return
	_restart_loading = true
	_start_loading_filter()
	await _do_async_restart()

func _do_async_restart():
	# 先让滤镜渲染一帧
	await get_tree().process_frame
	# 预选地图与敌方角色（与 _restart_game 保持一致）
	# Boss 模式固定用 BossSystem 解析值，重开不漂移；PVE 保持原随机策略
	if GameWorld.is_boss_mode():
		_pending_map_path = BossSystem.resolve_map_path()
		_pending_enemy_char = BossSystem.resolve_enemy_char()
	else:
		_pending_map_path = MapManager.pick_random()
		_pending_enemy_char = GameWorld.selected_ai_char_id if GameWorld.selected_ai_char_id != "" else _pick_enemy_char()
	# 分帧收集所有角色动画贴图路径（避免一次性扫描上千文件卡住主循环）
	_pending_load_paths = [_pending_map_path]
	for cid in CharacterFactory.get_all_char_ids():
		_pending_load_paths.append_array(_collect_char_images(cid))
		await get_tree().process_frame
	# 分批后台加载：发出请求 → 等本批完成 → 下一批
	# （每批数量受限，主循环每帧都渲染呼吸滤镜，加载全程画面保持活动）
	const BATCH_SIZE := 64
	var batch := 0
	while batch < _pending_load_paths.size():
		var end = mini(batch + BATCH_SIZE, _pending_load_paths.size())
		for i in range(batch, end):
			ResourceLoader.load_threaded_request(_pending_load_paths[i])
		var waited := 0
		while waited < 300:  # 每批最多等 5 秒
			var all_done := true
			for i in range(batch, end):
				var st = ResourceLoader.load_threaded_get_status(_pending_load_paths[i])
				if st != ResourceLoader.THREAD_LOAD_LOADED \
						and st != ResourceLoader.THREAD_LOAD_FAILED \
						and st != ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
					all_done = false
					break
			if all_done:
				break
			waited += 1
			await get_tree().process_frame
		# 取出资源写入缓存，后续 load() 命中缓存不再阻塞
		for i in range(batch, end):
			ResourceLoader.load_threaded_get(_pending_load_paths[i])
		batch = end
		await get_tree().process_frame  # 批次间隙让滤镜多渲染几帧
	_pending_load_paths = []
	_restart_loading = false
	GameWorld.loading_filter_frames = 0
	_restart_game()

## 随机敌方角色（供异步重开预加载与 _restart_game 共用，保证加载与使用一致）
func _pick_enemy_char() -> String:
	var enemy_chars = CharacterFactory.get_all_char_ids()
	return enemy_chars[randi() % enemy_chars.size()]

## 收集角色动画目录下所有图片路径（用于后台预加载）
func _collect_char_images(char_id: String) -> Array:
	var paths: Array = []
	var base := "res://assets/char_ani/" + char_id + "/"
	var dir = DirAccess.open(base)
	if dir:
		_collect_images_recursive(dir, base, paths)
	return paths

func _collect_images_recursive(dir: DirAccess, base: String, paths: Array):
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if fname.begins_with("."):
			fname = dir.get_next()
			continue
		var full: String = base + fname
		if dir.current_is_dir():
			var sub = DirAccess.open(full)
			if sub:
				_collect_images_recursive(sub, full + "/", paths)
		elif fname.ends_with(".png") or fname.ends_with(".jpg"):
			paths.append(full)
		fname = dir.get_next()
	dir.list_dir_end()

func _restart_game():
	# 旧角色实例的清理由 init_game → _clear_old_fighters() 统一处理
	# 重置角色配置缓存（大招等修改的 config 字段需要还原）
	CharConfigs.reset()
	# 重新填充天赋
	var pool = GameWorld.talent_pool
	var has_talent = false
	for tid in pool:
		if tid != "":
			has_talent = true
			break
	if not has_talent:
		GameWorld.player_talents = []
	else:
		GameWorld.player_talents = []
		for tid in pool:
			if tid != "":
				GameWorld.player_talents.append(tid)
	GameWorld.enemy_talents = []
	# Boss 模式：敌人固定为当前 Boss 的 char_id（不随重开漂移，优先于异步预选值）
	var ai_char := ""
	if GameWorld.is_boss_mode():
		ai_char = BossSystem.resolve_enemy_char()
	if ai_char == "":
		# 优先使用异步重开时预选的敌方角色（已后台预加载其贴图）
		ai_char = _pending_enemy_char
	_pending_enemy_char = ""  # 无论哪条路径，预选角色本局已消费
	if ai_char == "":
		ai_char = GameWorld.selected_ai_char_id
	if ai_char == "":
		ai_char = _pick_enemy_char()
	init_game(GameWorld.selected_char_id, ai_char)

# ===== Pause menu =====

func _toggle_pause():
	is_paused = not is_paused
	pause_menu.visible = is_paused
	# 练习模式 HUD（顶部开关栏 + 技能介绍面板）暂停期间隐藏，避免盖住暂停菜单
	if _practice_bar:
		_practice_bar.visible = not is_paused
	if _intro_overlay:
		_intro_overlay.visible = not is_paused and GameWorld.practice_skill_intro
	# Hide/show touch controls with pause state
	if touch_controls:
		touch_controls.visible = not is_paused
	# Clear lingering keys so they don't trigger actions right after unpause
	if not is_paused:
		keys["attack"] = false
		keys["skill1"] = false
		keys["skill2"] = false
		keys["ult"] = false
		keys["up"] = false
		keys["talent1"] = false
		keys["talent2"] = false
		keys["talent3"] = false

func _back_to_menu():
	is_paused = false
	# 先解除所有角色注入（避免 lambda 持有已释放对象导致退出挂起）
	if GameWorld.player: GameWorld.player.detach_injections()
	if GameWorld.enemy: GameWorld.enemy.detach_injections()
	GameWorld.cleanup_draw_callbacks()
	# Stop game loop and clean up before changing scene
	GameWorld.game_running = false
	GameWorld.game_over = true
	if GameWorld.player:
		GameWorld.player.queue_free()
		GameWorld.player = null
	if GameWorld.enemy:
		GameWorld.enemy.queue_free()
		GameWorld.enemy = null
	CharConfigs.reset()
	if _current_map:
		_current_map.queue_free()
		_current_map = null
	GameWorld.reset_world()
	GameWorld.skip_to_char_select = true
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _exit_game():
	if GameWorld.player: GameWorld.player.detach_injections()
	if GameWorld.enemy: GameWorld.enemy.detach_injections()
	GameWorld.cleanup_draw_callbacks()
	get_tree().quit()

func _style_pause_ui():
	# Pause button — small, subtle, top-right
	pause_btn.add_theme_font_size_override("font_size", 14)
	pause_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	pause_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	
	# Pause title
	var pause_title = $UILayer/PauseMenu/PausePanel/PauseTitle
	pause_title.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	
	# Style the three menu buttons
	_style_pause_button(continue_btn, Color(0.298, 0.686, 0.314))
	_style_pause_button(menu_btn, Color(1.0, 0.843, 0.0))
	_style_pause_button(exit_btn, Color(0.914, 0.271, 0.157))

	# 添加"角色选择"按钮
	var char_btn = Button.new()
	char_btn.name = "CharSelectBtn"
	char_btn.text = "🎭 角色选择"
	char_btn.pressed.connect(func():
		_back_to_menu()
	)
	_style_pause_button(char_btn, Color(0.667, 0.533, 1.0))
	var panel = $UILayer/PauseMenu/PausePanel
	panel.add_child(char_btn)

func _style_pause_button(btn: Button, accent: Color):
	btn.add_theme_font_size_override("font_size", 16)
	
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(accent.r, accent.g, accent.b, 0.15)
	normal.set_corner_radius_all(10)
	normal.border_width_left = 2; normal.border_width_right = 2
	normal.border_width_top = 2; normal.border_width_bottom = 2
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.5)
	btn.add_theme_stylebox_override("normal", normal)
	
	var hover = normal.duplicate()
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.35)
	hover.border_color = accent
	btn.add_theme_stylebox_override("hover", hover)
	
	btn.add_theme_color_override("font_color", accent)

# ===== 练习模式 =====

## 构建练习模式 HUD：顶部居中的 4 个开关按钮 + 技能介绍面板
## （技能介绍面板先加入 UILayer，按钮栏后加入，保证按钮绘制在面板之上仍可点击）
func _build_practice_hud():
	_build_skill_intro_panel()
	var bar = HBoxContainer.new()
	bar.name = "PracticeBar"
	bar.add_theme_constant_override("separation", 8)
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_top = 6
	bar.offset_bottom = 40
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(bar)
	_practice_bar = bar
	var defs := [
		{"key": "infinite_fire", "label": "无限火力"},
		{"key": "damage", "label": "伤害显示"},
		{"key": "enemy_ai", "label": "敌人攻击"},
		{"key": "intro", "label": "技能介绍"},
	]
	for d in defs:
		var btn = Button.new()
		btn.name = "PracticeBtn_" + d.key
		btn.text = d.label
		btn.custom_minimum_size = Vector2(96, 30)
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(_on_practice_toggle.bind(d.key, btn))
		bar.add_child(btn)
		_practice_btns[d.key] = btn
		_style_practice_btn(btn, _practice_toggle_on(d.key))

func _practice_toggle_on(key: String) -> bool:
	match key:
		"infinite_fire": return GameWorld.practice_infinite_fire
		"damage": return GameWorld.practice_damage_display
		"enemy_ai": return GameWorld.practice_enemy_ai
		"intro": return GameWorld.practice_skill_intro
	return false

## 开关点击：点一下开启，再点一下关闭
func _on_practice_toggle(key: String, btn: Button):
	match key:
		"infinite_fire": GameWorld.practice_infinite_fire = not GameWorld.practice_infinite_fire
		"damage": GameWorld.practice_damage_display = not GameWorld.practice_damage_display
		"enemy_ai": GameWorld.practice_enemy_ai = not GameWorld.practice_enemy_ai
		"intro": GameWorld.practice_skill_intro = not GameWorld.practice_skill_intro
	_style_practice_btn(btn, _practice_toggle_on(key))
	if key == "intro":
		if GameWorld.practice_skill_intro:
			_populate_skill_intro()
		if _intro_overlay:
			_intro_overlay.visible = GameWorld.practice_skill_intro

func _style_practice_btn(btn: Button, active: bool):
	var normal = StyleBoxFlat.new()
	normal.set_corner_radius_all(8)
	normal.border_width_left = 2; normal.border_width_right = 2
	normal.border_width_top = 2; normal.border_width_bottom = 2
	if active:
		normal.bg_color = Color(1.0, 0.843, 0.0, 0.35)
		normal.border_color = Color(1.0, 0.843, 0.0, 0.9)
		btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	else:
		normal.bg_color = Color(0.1, 0.1, 0.15, 0.6)
		normal.border_color = Color(0.4, 0.4, 0.5, 0.5)
		btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	btn.add_theme_stylebox_override("normal", normal)
	var hover = normal.duplicate()
	hover.bg_color = Color(1.0, 0.843, 0.0, 0.25)
	hover.border_color = Color(1.0, 0.843, 0.0, 0.7)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", normal)
	btn.add_theme_stylebox_override("focus", normal)

## 技能介绍面板：全屏半透明遮罩 + 居中可滚动文本
func _build_skill_intro_panel():
	_intro_overlay = ColorRect.new()
	_intro_overlay.name = "SkillIntroOverlay"
	_intro_overlay.color = Color(0.02, 0.02, 0.06, 0.82)
	_intro_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_intro_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_intro_overlay.visible = false
	ui_layer.add_child(_intro_overlay)

	var panel = PanelContainer.new()
	panel.name = "SkillIntroPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300
	panel.offset_top = -190
	panel.offset_right = 300
	panel.offset_bottom = 190
	_intro_overlay.add_child(panel)

	var pstyle = StyleBoxFlat.new()
	pstyle.bg_color = Color(0.08, 0.08, 0.12, 0.98)
	pstyle.set_corner_radius_all(12)
	pstyle.border_width_left = 2; pstyle.border_width_right = 2
	pstyle.border_width_top = 2; pstyle.border_width_bottom = 2
	pstyle.border_color = Color(1.0, 0.843, 0.0, 0.5)
	panel.add_theme_stylebox_override("panel", pstyle)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = "📖 技能介绍"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_btn = Button.new()
	close_btn.text = "✕ 关闭"
	close_btn.add_theme_font_size_override("font_size", 14)
	close_btn.add_theme_color_override("font_color", Color(0.914, 0.271, 0.157))
	close_btn.pressed.connect(_close_skill_intro)
	header.add_child(close_btn)
	vbox.add_child(header)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# 图鉴规范：只保留竖向滚动，禁用横向滚动
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	_intro_text = Label.new()
	_intro_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_intro_text.add_theme_font_size_override("font_size", 13)
	_intro_text.add_theme_color_override("font_color", Color(0.85, 0.85, 0.92))
	_intro_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_intro_text)

func _close_skill_intro():
	GameWorld.practice_skill_intro = false
	if _intro_overlay:
		_intro_overlay.visible = false
	var btn = _practice_btns.get("intro")
	if btn:
		_style_practice_btn(btn, false)

## 填充技能介绍内容：普攻 / 技能一·二·三 / 大招 / 特殊机制 / 天赋
func _populate_skill_intro():
	var p = GameWorld.player
	if not is_instance_valid(p):
		return
	var cfg = CharConfigs.configs.get(p.char_id, {})
	var dex = cfg.get("dex", {})
	var lines: Array[String] = []
	lines.append("【" + CharConfigs.get_char_name(p.char_id) + "】")
	var sections := _classify_dex_skills(dex.get("skills", []))
	if sections.has("attack"):
		lines.append("")
		lines.append("【普攻】" + sections["attack"].get("name", ""))
		lines.append(sections["attack"].get("desc", ""))
		lines.append(sections["attack"].get("meta", ""))
	var skill_labels := {"skill1": "技能一", "skill2": "技能二", "skill3": "技能三"}
	for key in ["skill1", "skill2", "skill3"]:
		if sections.has(key):
			lines.append("")
			lines.append("【" + skill_labels[key] + "】" + sections[key].get("name", ""))
			lines.append(sections[key].get("desc", ""))
			lines.append(sections[key].get("meta", ""))
	if sections.has("ult"):
		lines.append("")
		lines.append("【大招】" + sections["ult"].get("name", ""))
		lines.append(sections["ult"].get("desc", ""))
		lines.append(sections["ult"].get("meta", ""))
	# 特殊机制：未分类的技能条目 + 图鉴 stats
	var special: Array = sections.get("special", [])
	var stats: Array = dex.get("stats", [])
	if not special.is_empty() or not stats.is_empty():
		lines.append("")
		lines.append("【特殊机制】")
		for s in special:
			lines.append("✦ " + s.get("name", "") + "：" + s.get("desc", ""))
		for s in stats:
			lines.append("✦ " + s.get("label", "") + "：" + s.get("value", ""))
	# 天赋
	if not GameWorld.player_talents.is_empty():
		lines.append("")
		lines.append("【天赋】")
		for tid in GameWorld.player_talents:
			var meta = TalentPool.get_metadata(tid)
			if meta.is_empty():
				continue
			lines.append("✦ " + meta.get("name", tid))
			lines.append(meta.get("desc", ""))
	if _intro_text:
		_intro_text.text = "\n".join(lines)

## 将 dex.skills 分类为 普攻/技能一·二·三/大招/特殊机制。
## 带关键词（普攻/技能一/大招等）的直接归类；无关键词的按顺序补位，剩余归特殊机制。
func _classify_dex_skills(dex_skills: Array) -> Dictionary:
	var result := {}
	var unmatched: Array = []
	for s in dex_skills:
		var name: String = s.get("name", "")
		var section := ""
		if "普通攻击" in name or "普攻" in name:
			section = "attack"
		elif "技能一" in name or "一技能" in name:
			section = "skill1"
		elif "技能二" in name or "二技能" in name:
			section = "skill2"
		elif "技能三" in name or "三技能" in name:
			section = "skill3"
		elif "大招" in name:
			section = "ult"
		else:
			unmatched.append(s)
			continue
		result[section] = s
	var slots: Array = ["attack", "skill1", "skill2", "ult"]
	for s in unmatched:
		var filled := false
		for slot in slots:
			if not result.has(slot):
				result[slot] = s
				filled = true
				break
		if not filled:
			if not result.has("special"):
				result["special"] = []
			result["special"].append(s)
	return result
