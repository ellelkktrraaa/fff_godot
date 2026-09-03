class_name Fighter
extends Node2D

#######################################
#注意！ 本文件以后将不允许角色代码写入，必须用反向注入的方式放入角色自身文件
#######################################
# ── 信号 ──
signal hp_changed(old_val: float, new_val: float)
signal energy_changed(old_val: float, new_val: float)

# Minimal preloads — only scripts that don't reference Fighter type
const GameParticle = preload("res://scripts/particle.gd")

# Lazily-loaded class references for cold cache compatibility
static var _StatusEffectClass = null
static var _CharConfigsClass = null

# Everything else loaded lazily in setup() to avoid circular dependency

# Component system
var components = null # ComponentManager, loaded lazily

# Position & physics
var pos_x: float = 0
var pos_y: float = 0
var w: float = 32.0
var h: float = 56.0
var vx: float = 0
var vy: float = 0
var facing: int = 1
var on_platform = null
var passthrough_platform = null  # 当前穿透的平台（悬挂平台下落）
var passthrough_timer := 0

# Identity
var display_name: String = ""
var is_player: bool = false
var char_id: String = "knight"
var config: Dictionary = {}
var skills: Array = [] # Array of Skill objects
var skill_map: Dictionary = {}
var spawn_x: float = 160
var spawn_y: float = 324

# Health & energy
var hp: float = 100
var max_hp: float = 100
var energy: float = 0
var max_energy: float = 100
var energy_regen: float = 0.05
var energy_cost_multiplier: float = 1.0  # 能量消耗倍率（黑法师黑暗能量 = 0.5，1 黑暗能量 = 2 能量）

# ── Boss Modifier（Boss 战外部配置字段；默认值 = 无影响，PVE/PVP 行为不变）──
var damage_multiplier := 1.0          # 造成伤害倍率（apply_damage 唯一结算点统一放大）
var damage_taken_multiplier := 1.0    # 受到伤害倍率
var ai_overrides := {}                # AI_PRESETS 增量覆盖（modifier["ai"]，不改难度字符串）
var boss_name := ""                   # Boss 显示名（空 = HUD 读 config.name）

# Combat
var attacking: bool = false
var attack_timer: int = 0
var attack_cooldown: int = 0
var attack_delay: int = 0
var attack_hit_dealt: bool = false
var hit_cooldown: int = 0
var attack_range: float = 44
var attack_damage: float = 5
var attack_speed: float = 2.25
var attack_boost: float = 0
var boost_timer: int = 0

# 防御（护甲公式：减伤率 = defense / (defense + 50)，收益递减）
var defense: float = 0

# 禁疗：为 true 时所有治疗来源（生命球/天赋/技能）无效（狂战士浴血机制）
var heal_blocked: bool = false

# State
var grounded: bool = false
var state: String = "idle"
var image_state: String = "idle"
var current_anim = null # FrameAnimation
var desired_image_state: String = ""  # 技能代码设置的覆盖状态，优先级高于 apply_physics 推导
var jump_phase: int = 0  # 跳跃动画阶段：0=无 1=起跳 2=滞空 3=落地倒放（仅 load_jump_sheet 动画启用）
var damage_flash: int = 0

# Block & shield
var blocking: bool = false
var block_timer: int = 0
var shield_active: bool = false
var shield_timer: int = 0

# Dash
var dashing: bool = false
var dash_remaining: float = 0
var dash_dir: int = 1
var dash_speed: float = 0
var dash_damage_dealt: bool = false

# Status effects
var statuses: Array = []
var ice_hit_count: int = 0

# Charge
var charging: bool = false
var charge_start: int = 0
var charging_attack: bool = false
var charge_start_time: int = 0
var charging_skill1: bool = false

# AI
var ai_think_delay: int = 0
var ai_action_timer: int = 0

# Status effect timers (shared)
var slow_timer: int = 0
var slow_percent: float = 0.0
var burn_timer: int = 0

# Invincibility (shared across all characters)
var is_invincible: bool = false
var invincible_timer: int = 0

# Speed multiplier (domain effect, etc.)
var speed_multiplier: float = 1.0

# Status effects (shared)
var gravity_debuff: bool = false
var jump_reduction: float = 1.0

# Blackboard: 跨系统状态通信（组件写入，系统只读）
# 只用于全局效果（time_stop, dodge_slow, iaido_active），角色内部状态保留在组件
# Key 约定：使用语义化字符串
var state_flags: Dictionary = {}

# Signal for state flag changes (事件驱动，替代每帧轮询)
signal state_flag_changed(key: String, value: Variant)

# 设置状态标志并触发信号（组件调用此方法）
func set_state_flag(key: String, value: Variant):
	if state_flags.get(key) != value:
		state_flags[key] = value
		state_flag_changed.emit(key, value)


var bleed_timer: int = 0
var blind_timer: int = 0

# Dragon Knight
var dragon_scales_active: bool = false
var dragon_scales_timer: int = 0
var dragon_form_active: bool = false
var dragon_form_timer: int = 0
var dk_burn_applied: bool = false
var dk_sky_rise_active: bool = false
var dk_sky_rise_anim_timer: int = 0
var dk_dive_attack_timer: int = 0
var dk_crash_timer: int = 0
var dk_crack_ends_flight: bool = false
var dk_flight_timer: int = 0
var dk_shield_active: bool = false
var dk_shield_timer: int = 0
var dk_shield_absorbed_damage: float = 0.0
var dk_shield_held: bool = false
var dk_ult_active: bool = false
var dk_ult_timer: int = 0
var dk_ult_phase2_active: bool = false
var dk_ult_phase2_timer: int = 0
var dk_ult_fire_tick: int = 0
var dk_ult_fire_total: float = 0.0
var dk_ult_claw_dealt: bool = false
var dk_ult_target_locked: bool = false
var dk_air_atk_prev_air: bool = false    # 龙骑士空中普攻：上一帧是否在空中攻击（落地瞬间检测）
var dk_shield_block_fx: bool = false     # 鳞反本次举盾是否已触发格挡成功演出（每次举盾一次）
var dk_shield_shake_pending: bool = false  # 格挡成功：时缓结束后待触发的震动标记
var dk_skill1_hit_dealt: bool = false    # 龙骑士一技能：动画第6帧是否已出伤（每次释放一次）
var dk_ult1_shake_pending: bool = false  # 大招一段：时缓结束后待触发的震动标记

# ── 天赋系统 ──
var ad: Dictionary = {}                    # 天赋命名空间 { talent_id: {...} }
var talent_manager: TalentManager = null
var talent_slots: Array = []
var _stat_base: Dictionary = {}            # 属性原始值快照
var _stat_mods: Dictionary = {}            # { attr: [{ source, add, mul }, ...] }

# ── 绘制注入（角色向世界注册绘制逻辑）──
var draw_overrides: Array = []             # [{cb: Callable, z: int}] _draw_fighter 后执行
var hud_skill_labels: Dictionary = {}      # {"attack": "J 血刃", ...} 为空则用默认标签
var hud_resource_color: Color = Color(0.0, 0.831, 1.0)  # 能量条颜色（Paladin 改金色）

# ── 冲刺注入（角色向 DashSystem 注入逻辑）──
var dash_step_callbacks: Array = []        # [Callable(old_x, new_x)] 每帧冲刺回调
var dash_damage_override: float = 0.0      # 0=默认15，>0=覆盖冲刺伤害

## 对局结束时解除所有注入（在 queue_free 之前调用）
func detach_injections():
	# 清除以实例 ID 注册的绘制回调
	var fid = str(get_instance_id())
	GameWorld.unregister_draw_effect(fid + "_slash")
	GameWorld.unregister_draw_effect(fid + "_trail")
	GameWorld.unregister_draw_effect(fid + "_sw")
	GameWorld.unregister_draw_effect(fid + "_phantoms")
	GameWorld.unregister_draw_effect(fid + "_bm_ice_crystals")
	GameWorld.unregister_draw_effect(fid + "_bm_fireballs")
	GameWorld.unregister_draw_effect(fid + "_bm_thunder_aura")
	# 重置注入字段
	dash_step_callbacks.clear()
	dash_damage_override = 0.0
	draw_overrides.clear()
	hud_skill_labels.clear()
	hud_resource_color = Color(0.0, 0.831, 1.0)
	state_flags.clear()

# Forced skill timer
var forced_skill_timer: int = 0

func setup(p_x: float, p_y: float, p_is_player: bool, p_char_id: String, p_skills: Array):
	pos_x = p_x
	pos_y = p_y
	spawn_x = p_x
	spawn_y = p_y
	is_player = p_is_player
	display_name = "玩家" if is_player else "AI"
	char_id = p_char_id
	skills = p_skills
	skill_map.clear()
	for s in skills:
		skill_map[s.key] = s
	facing = 1 if is_player else -1
	on_platform = null
	_init_from_config()
	# Initialize component manager (lazy load for cold cache)
	var CmClass = load("res://scripts/components/component_manager.gd")
	components = CmClass.new()
	components.init(self)

func _init_from_config():
	if _CharConfigsClass == null:
		_CharConfigsClass = load("res://data/char_configs.gd")
	var cfg = _CharConfigsClass.configs.get(char_id, {})
	config = cfg
	hp = cfg.get("hp", 100)
	max_hp = cfg.get("hp", 100)
	max_energy = cfg.get("max_energy", 100)
	energy_regen = cfg.get("energy_regen", 0.05)
	attack_speed = cfg.get("speed", 2.25)
	attack_range = cfg.get("attack_range", 44)
	attack_damage = cfg.get("attack_damage", 5)
	defense = cfg.get("defense", 0)
	var fields = cfg.get("fields", {})
	for key in fields:
		var val = fields[key]
		if val is Array:
			set_meta(key, val.duplicate())
		elif val is Dictionary:
			set_meta(key, val.duplicate())
		else:
			set_meta(key, val)
	var anims = config.get("animations", {})
	if anims.has("idle"):
		current_anim = anims["idle"]
		current_anim.play()
		image_state = "idle"
	_snapshot_stats()

# ── 属性修饰系统 ──
func _snapshot_stats():
	_stat_base["max_hp"] = max_hp
	_stat_base["max_energy"] = max_energy
	_stat_base["attack_damage"] = attack_damage
	_stat_base["attack_speed"] = attack_speed
	_stat_base["attack_range"] = attack_range
	_stat_base["defense"] = defense

## Boss 外部配置 Modifier 应用（setup() 之后、装配天赋之前调用）：
## 1) 覆盖基础属性字段（hp 同时同步 max_hp/hp），并把对应项同步进 _stat_base 基快照，
##    再以 Boss 数值为新基重放既有 add_stat_mod 修饰，防止天赋/技能基于旧基冲掉 Boss 数值；
## 2) 解析全局倍率 damage_multiplier / damage_taken_multiplier、AI 增量 ai、显示名 boss_name。
## 只写本实例字段，绝不修改共享 config 缓存（configs 由 CharConfigs.reset() 统一还原）。
func apply_boss_modifiers(mods: Dictionary):
	if mods.is_empty():
		return
	# ── 基础属性覆盖 ──
	if mods.has("hp"):
		max_hp = float(mods["hp"])
		hp = max_hp
	if mods.has("max_energy"):
		max_energy = float(mods["max_energy"])
	if mods.has("energy_regen"):
		energy_regen = float(mods["energy_regen"])
	if mods.has("attack_speed"):
		attack_speed = float(mods["attack_speed"])
	if mods.has("attack_range"):
		attack_range = float(mods["attack_range"])
	if mods.has("attack_damage"):
		attack_damage = float(mods["attack_damage"])
	if mods.has("defense"):
		defense = float(mods["defense"])
	# ── 属性基快照重建：以 Boss 数值为新基重放既有修饰 ──
	_snapshot_stats()
	for attr in _stat_mods:
		_recalc_stat(attr)
	if hp > max_hp:
		hp = max_hp
	# ── 全局倍率 / AI 增量 / 显示名 ──
	if mods.has("damage_multiplier"):
		damage_multiplier = float(mods["damage_multiplier"])
	if mods.has("damage_taken_multiplier"):
		damage_taken_multiplier = float(mods["damage_taken_multiplier"])
	if mods.get("ai") is Dictionary:
		ai_overrides = (mods["ai"] as Dictionary).duplicate()
	if mods.has("boss_name"):
		boss_name = str(mods["boss_name"])

func add_stat_mod(attr: String, source: String, add: float = 0.0, mul: float = 1.0):
	if not _stat_mods.has(attr):
		_stat_mods[attr] = []
	_stat_mods[attr].append({"source": source, "add": add, "mul": mul})
	_recalc_stat(attr)
	# 修饰最大血量后同步当前血量
	if attr == "max_hp":
		hp = minf(hp, max_hp)

## 移除指定来源的属性修饰（供动态加成反复刷新使用）
func remove_stat_mod(attr: String, source: String):
	if not _stat_mods.has(attr):
		return
	_stat_mods[attr] = _stat_mods[attr].filter(func(m): return m.get("source", "") != source)
	_recalc_stat(attr)

## 通用治疗入口：统一拦截禁疗目标
static func try_heal(target: Fighter, amount: float):
	if not target or target.hp <= 0 or amount <= 0:
		return
	if target.heal_blocked:
		return
	target.hp = minf(target.max_hp, target.hp + amount)

func _recalc_stat(attr: String):
	var base = _stat_base.get(attr, _get_attr_val(attr))
	var total_add = 0.0
	var total_mul = 1.0
	for m in _stat_mods.get(attr, []):
		total_add += m.add
		total_mul *= m.mul
	_set_attr_val(attr, (base + total_add) * total_mul)

func _get_attr_val(attr: String) -> float:
	match attr:
		"max_hp": return max_hp
		"max_energy": return max_energy
		"attack_damage": return attack_damage
		"attack_speed": return attack_speed
		"attack_range": return attack_range
		"defense": return defense
	return 0.0

func _set_attr_val(attr: String, val: float):
	match attr:
		"max_hp": max_hp = val
		"max_energy": max_energy = val
		"attack_damage": attack_damage = val
		"attack_speed": attack_speed = val
		"attack_range": attack_range = val
		"defense": defense = val

func set_animation_state(state_key: String):
	var prev_state = image_state
	image_state = state_key
	var anims = config.get("animations", {})
	var new_anim = anims.get(state_key)
	if new_anim:
		current_anim = new_anim
		# 状态真正切换时从头播放；同状态每帧重复调用不重置（保持循环动画连续）
		if state_key != prev_state or not current_anim.is_playing():
			current_anim.play()

## 跳跃动画状态机：起跳（前 N-1 帧共 0.2s）→ 滞空（最后一帧保持）→ 落地倒放起跳帧。
## 仅当该角色 jump 动画由 FrameAnimation.load_jump_sheet 创建时启用；返回 true 表示已接管动画状态。
func _update_jump_animation() -> bool:
	var anims: Dictionary = config.get("animations", {})
	var jump_anim = anims.get("jump")
	if not (jump_anim is FrameAnimation and jump_anim.jump_sheet):
		return false
	# 飞行动画锁：角色脚本在特殊浮空状态（如龙骑士凌空）设置该黑板位，
	# 期间跳跃动画状态机不接管，空中动画完全由角色 update_systems 管理
	if state_flags.get("no_jump_anim", false):
		return false
	if jump_phase == 0 and grounded:
		return false
	if jump_phase == 0:
		# 起跳：从第 0 帧播放起跳帧
		jump_phase = 1
		set_animation_state("jump")
		return true
	# 跳跃动画可能被攻击/技能/大招打断（current_anim 被换走）：接管回跳跃动画本身，
	# 否则跳跃状态机每帧返回 true 却不再切回跳跃动画，会永远停在被打断动画的最后一帧
	if current_anim != jump_anim:
		current_anim = jump_anim
		if not jump_anim.is_playing():
			jump_anim.play()
	if not grounded:
		if jump_phase == 3:
			# 落地倒放中再次起跳 → 重新起跳（直接 play 强制复位）
			jump_phase = 1
			jump_anim.play()
		elif jump_phase == 1 and jump_anim.is_hold_phase():
			# 起跳帧放完 → 滞空保持
			jump_phase = 2
		return true
	# 已落地：开始倒放起跳帧
	if jump_phase in [1, 2]:
		jump_phase = 3
		jump_anim.start_landing()
		return true
	# 落地倒放中：结束后回到常规状态
	if jump_phase == 3 and jump_anim.is_landing_done():
		jump_phase = 0
		set_animation_state("idle")
	return true

func get_skill(key: String):
	return skill_map.get(key)

func add_status(effect_id: String):
	# 免疫所有负面效果（如狂暴模式）
	if state_flags.get("immune_negative_status", false):
		return
	if _StatusEffectClass == null:
		_StatusEffectClass = load("res://scripts/status_effect.gd")
	# 龙骑士免疫灼烧
	if char_id == "dragon_knight" and effect_id == "burn":
		return
	# 灼烧立刻解除冰冻（火克冰）：命中灼烧目标立即脱离冰冻
	if effect_id == "burn":
		for s in statuses:
			if s.id == "frozen":
				s.timer = 0  # 下一帧 update_statuses 自然移除（含 ice_hit_count 复位）
	# Prevent duplicate freeze application
	var def = _StatusEffectClass.STATUS_DEFS.get(effect_id, {})
	if def.get("freeze", false) and has_status("frozen"):
		return
	for s in statuses:
		if s.id == effect_id:
			s.timer = s.duration
			return
	var inst = _StatusEffectClass.new(effect_id)
	inst.apply(self)
	statuses.append(inst)

func has_status(effect_id: String) -> bool:
	for s in statuses:
		if s.id == effect_id and s.timer > 0:
			return true
	return false

func update_statuses():
	statuses = statuses.filter(func(s): return s.update(self))

func get_slowed_factor() -> float:
	# 多个减速状态可叠加（乘法）：如黑法师冰棱减速 10%×层数
	var factor := 1.0
	for s in statuses:
		if s.slow_factor < 1.0:
			factor *= s.slow_factor
	return factor

func is_movement_locked() -> bool:
	return has_status("frozen") or has_status("stun") or shield_active or dashing or state_flags.get("tendon_locked", false)

func get_hit_box() -> Rect2:
	# 刺客冲刺中扩大受击体积（沿冲刺方向延伸 25 像素），更容易触发闪避
	if char_id == "assassin" and dashing:
		if dash_dir > 0:
			return Rect2(pos_x + 4, pos_y + 4, w - 8 + 76, h - 8)
		else:
			return Rect2(pos_x + 4 - 76, pos_y + 4, w - 8 + 76, h - 8)
	return Rect2(pos_x + 4, pos_y + 4, w - 8, h - 8)

func get_attack_box() -> Rect2:
	var ox: float = w if facing == 1 else -attack_range
	return Rect2(pos_x + ox, pos_y + 6, attack_range, h - 16)

func apply_physics():
	# Update character components
	if components:
		components.update()
	
	# Witch flying state
	var witch_comp = components.get_component("witch") if components else null
	if witch_comp and witch_comp.ult_lock_timer > 0:
		vx = 0
		vy = 0
		set_animation_state("ult")
	else:
		# Passthrough timer: 穿透悬挂平台期间
		if passthrough_timer > 0:
			passthrough_timer -= 1
		else:
			passthrough_platform = null

		if attacking:
			pass
		if dashing:
			vx = dash_speed * dash_dir
		if witch_comp and witch_comp.is_flying:
			vy = 0
		elif not grounded:
			vy += 0.22 # GRAVITY
			# 领域减速效果：跳跃速度减少
			if vy < 0 and jump_reduction < 1.0 and absf(vy) > 8.0:
				vy = -10.0 * jump_reduction
		if grounded and absf(vx) > 0.1 and not dashing:
			vx *= 0.88 # FRICTION
		elif grounded and not dashing:
			vx = 0
		if is_movement_locked() and not dashing:
			vx = 0
			vy = 0
		pos_x += vx
		pos_y += vy
		# 墙壁碰撞：不可穿过 is_wall 地形块
		for p in GameWorld.platforms:
			if not p.get("is_wall", false):
				continue
			if pos_y + h > p["y"] and pos_y < p["y"] + p["h"] \
				and pos_x + w > p["x"] and pos_x < p["x"] + p["w"]:
				if vx > 0:
					pos_x = p["x"] - w
				else:
					pos_x = p["x"] + p["w"]
				vx = 0
		grounded = false
		# 虚空触碰 → 事件分发（天赋可拦截）
		for p in GameWorld.platforms:
			if p.get("terrain_type", -1) != 3:
				continue
			if pos_x + w > p["x"] + 4 and pos_x < p["x"] + p["w"] - 4 \
				and pos_y + h > p["y"] and pos_y < p["y"] + p["h"]:
				_on_void_touch()
				break
		for p in GameWorld.platforms:
			if p == passthrough_platform:
				continue  # 穿透当前悬挂平台
			if p.get("terrain_type", -1) == 3:
				continue  # 虚空：无碰撞，可穿过
			if vy >= 0 and pos_x + w > p["x"] + 4 and pos_x < p["x"] + p["w"] - 4 and \
			   pos_y + h >= p["y"] and pos_y + h <= p["y"] + p["h"] + 6:
				if not state_flags.get("necro_slam_crashing"):
					pos_y = p["y"] - h
					vy = 0
					grounded = true
					on_platform = p
				break
		if not grounded and pos_y >= 380 - h:
			# 检查下方是否有地面平台
			var has_ground_below = false
			for p in GameWorld.platforms:
				if p.get("is_ground", false) and p.get("terrain_type", -1) != 3 \
					and pos_x + w > p["x"] and pos_x < p["x"] + p["w"] \
					and absf((pos_y + h) - p["y"]) < 30:
					has_ground_below = true
					break
			if has_ground_below:
				pos_y = 380 - h
				vy = 0
				grounded = true
		# 虚空：掉落超过底线 → 受20伤害，传送回出生点（虚空亲和免疫伤害）
		if pos_y > 500:
			if not state_flags.get("void_damage_immune", false):
				hp -= 20
			else:
				state_flags["void_damage_immune"] = false
			pos_x = spawn_x
			pos_y = spawn_y
			vy = 0
			vx = 0
			grounded = true
		pos_x = clampf(pos_x, 10, 2400 - 10 - w) # MAP_W
		if char_id == "rose" and dashing and image_state == "skill1" and GameWorld.enemy:
			var clamped = clampf(pos_x, 10, 2400 - 10 - w)
			if absf(pos_x - clamped) > 0.5:
				print("[ROSE-GRAB] physics.clamp: rose.pos_x=", pos_x, " → ", clamped)
		if is_player == false and char_id != "rose":
			var clamped = clampf(pos_x, 10, 2400 - 10 - w)
			if absf(pos_x - clamped) > 0.5:
				print("[ROSE-GRAB] enemy.clamp: enemy.pos_x=", pos_x, " → ", clamped, " vx=", vx, " dashing=", dashing)
		if absf(vx) > 0.5 and not dashing:
			facing = 1 if vx > 0 else -1
		if dashing:
			facing = dash_dir

	if attacking:
		attack_timer -= 1
	if attack_delay > 0:
		attack_delay -= 1
		if attack_delay <= 0 and not attack_hit_dealt:
			attack_hit_dealt = true
			var target = GameWorld.get_opponent(self)
			if GameWorld.game_running and not GameWorld.game_over and target and target.hp > 0:
				# 刺客次元斩：使用 slash_x（启动时固定）作为攻击框，避免冲刺中 pos_x 偏移导致命中失败
				var box: Rect2
				var assassin_comp = components.get_component("assassin") if components else null
				if assassin_comp and char_id == "assassin" and assassin_comp.slash_active:
					box = Rect2(assassin_comp.slash_x, assassin_comp.slash_y, 100, 40)
				else:
					box = get_attack_box()
				if box.intersects(target.get_hit_box()):
					# 刺客强化次元斩：伤害提升至 8 点，命中恢复 5 能量
					var dmg: float = attack_damage
					if assassin_comp and char_id == "assassin" and assassin_comp.enhanced_slash and assassin_comp.enhanced_slash_timer > 0:
						dmg = 8
						energy = minf(max_energy, energy + 5)
						assassin_comp.enhanced_slash = false
						assassin_comp.enhanced_slash_timer = 0
					apply_damage(target, dmg, self)
				# 近战攻击也能命中影武者分身（之前只有投射物能打分身）
				#FIXED BUG: 影武者分身之前只能被投射物命中,近战角色完全无法伤害分身,导致"锁满血"
				if GameWorld.phantoms.size() > 0:
					var atk_dmg: float = attack_damage
					if assassin_comp and char_id == "assassin" and assassin_comp.enhanced_slash and assassin_comp.enhanced_slash_timer > 0:
						atk_dmg = 8
					for pi in range(GameWorld.phantoms.size() - 1, -1, -1):
						var ph = GameWorld.phantoms[pi]
						if ph.hp <= 0: continue
						if ph.get("owner") == self: continue  # 不打自己的分身
						var ph_rect = Rect2(ph["x"], ph["y"], ph["w"], ph["h"])
						if box.intersects(ph_rect):
							ph["hp"] -= atk_dmg
							emit_particles(ph["x"] + ph["w"] / 2.0, ph["y"] + ph["h"] / 2.0, 15, Color(0.53, 0.27, 0.8), 4, 6, "star", 0.8)
				#FIX END
	if attack_cooldown > 0:
		attack_cooldown -= 1
	if hit_cooldown > 0:
		hit_cooldown -= 1
	if damage_flash > 0:
		damage_flash -= 1
	# Component-managed timers are updated in components.update() at the start of apply_physics
	if blocking:
		block_timer -= 1
		if block_timer <= 0:
			blocking = false
	if shield_active:
		shield_timer -= 1
		if shield_timer <= 0:
			shield_active = false
	# 通用无敌计时（由 set_invincible 设置）
	if invincible_timer > 0:
		invincible_timer -= 1
		if invincible_timer <= 0:
			is_invincible = false
	# 通用霸体计时（由 set_super_armor 设置）
	if state_flags.get("super_armor_timer", 0) > 0:
		state_flags["super_armor_timer"] -= 1
		if state_flags["super_armor_timer"] <= 0:
			state_flags.erase("super_armor")
			state_flags.erase("super_armor_timer")
	# Dragon Knight: 龙鳞护体计时
	if dragon_scales_active:
		dragon_scales_timer -= 1
		if dragon_scales_timer <= 0:
			dragon_scales_active = false
	# Dragon Knight: 龙化形态计时与能量消耗
	if dragon_form_active:
		dragon_form_timer += 1
		if dragon_form_timer >= 60:
			dragon_form_timer = 0
			energy = maxf(0, energy - 10)
			if energy <= 0:
				dragon_form_active = false
	# Dragon Knight: 凌空/举盾/大招 重力跳过 (计时由 update_systems 管理)
	if dk_sky_rise_active or dk_crash_timer > 0 or dk_shield_active or dk_ult_active:
		pass
	# 技能冷却统一由 game.gd 固定 60Hz 逻辑帧更新，此处不重复调用（避免冷却 2 倍速）
	var regen = config.get("energy_regen", 0.083)
	if energy < max_energy:
		energy += regen
	if energy > max_energy:
		energy = max_energy
	if boost_timer > 0:
		boost_timer -= 1
		if boost_timer <= 0:
			attack_boost = 0
	if attacking and attack_timer <= 0 and not charging_attack:
		attacking = false
		state = "idle"
	if dk_ult_active:
		pass  # 龙魂大招期间动画由 update_systems 管理
	elif not grounded and attacking and image_state == "attack_air":
		pass  # 空中下砸动画由角色 update_systems 管理
	elif image_state.begins_with("skill"):
		pass  # 技能动画由角色 update_systems 保持（attacking 与否均不覆盖；否则施法中会被 645/659 覆盖成普攻/待机动画）
	elif image_state.begins_with("mounted_"):
		pass  # 骑乘状态动画由角色 handle_input 管理
	elif dashing or charging_skill1 or charging:
		set_animation_state("charge")
	elif attacking and not image_state.begins_with("skill"):
		set_animation_state("attack")
	elif state == "ult":
		set_animation_state("ult")
	elif state == "stance" or state == "windup":
		pass  # 剑豪乘岚斩霞蓄力架势 / 普攻起手：动画由角色 handle_input 管理，physics 不覆盖
	elif _update_jump_animation():
		pass  # 跳跃动画状态机（起跳→滞空→落地倒放）接管
	elif not grounded and state_flags.get("no_jump_anim", false):
		pass  # 飞行动画锁：空中动画由角色 update_systems 管理，不覆盖（如龙骑士凌空 in_air）
	elif not grounded:
		set_animation_state("jump")
	elif state == "walk":
		set_animation_state("walk")
	else:
		set_animation_state("idle")

# ===== Static damage function =====

# ── 体系统：技能打断优先级 ──
# 金刚体(3) > 霸体(2) > 技能体(1) > 普攻体(0)
const BODY_NORMAL := 0  # 普攻体：普攻/待机/移动/跳跃/普攻蓄力/强化形态
const BODY_SKILL := 1   # 技能体：释放技能状态
const BODY_ARMOR := 2   # 霸体：霸体天赋 / 带霸体描述的技能 / 变身霸体
const BODY_VAJRA := 3   # 金刚体：释放大招 / 天赋或特殊技能

## 目标当前体等级。先查角色专属覆盖（cls.body_priority），未实现时走通用规则。
## 打断规则：攻击体 >= 目标体 → 打断；攻击体 < 目标体 → 不打断且不击退/击飞（仍造成伤害）。
static func get_body_priority(f: Fighter) -> int:
	if not f:
		return BODY_NORMAL
	var prio = CharacterFactory.call_body_priority(f)
	if prio >= 0:
		return prio
	# 通用兜底
	if f.state_flags.get("super_armor", false):
		return BODY_ARMOR
	if f.state == "ult":
		return BODY_VAJRA
	if f.charging_skill1 or f.charging:
		return BODY_SKILL
	if f.attacking and f.image_state.begins_with("skill"):
		return BODY_SKILL
	return BODY_NORMAL

## 防御/招架类技能是否激活（免疫打断，伤害照常结算；招架触发由各角色自行处理）
static func is_defense_parry_active(f: Fighter) -> bool:
	if not f:
		return false
	if f.blocking:
		return true
	if f.shield_active:
		return true
	return CharacterFactory.call_is_defense_parry(f)

## 打断目标当前技能施放：恢复普通动画 + 清除通用施法状态 + 角色专属清理
static func interrupt_skill_cast(target: Fighter):
	if not target:
		return
	target.interrupt_skill_anim_on_hit()
	target.attacking = false
	target.attack_timer = 0
	target.attack_delay = 0
	target.charging = false
	target.charging_skill1 = false
	target.charging_attack = false
	if target.image_state.begins_with("skill") or target.image_state in target.config.get("skill_anim_states", []):
		target.set_animation_state("idle")
	CharacterFactory.call_on_interrupted(target)

static func apply_damage(target: Fighter, dmg: float, attacker: Fighter, knockback: bool = true, hit_color: Color = Color(1.0, 0.53, 0.27), sound_name: String = "hit_enemy", damage_source: String = "", recursion_depth: int = 0, hit_priority: int = -1):
	if not target or target.hp <= 0:
		return
	if attacker == target:
		return
	
	# Get character components
	var assassin_comp = target.components.get_component("assassin") if target.components else null
	var paladin_comp = target.components.get_component("paladin") if target.components else null
	var rose_comp = target.components.get_component("rose") if target.components else null
	
	# 调试日志：追踪伤害来源
	if assassin_comp:
		print("[DAMAGE-DEBUG]刺客受伤: dmg=", dmg, " attacker=", attacker.char_id if attacker else "null", " dashing=", target.dashing, " is_invincible=", assassin_comp.is_invincible, " invincible_timer=", assassin_comp.invincible_timer, " hp=", target.hp)

	# 刺客「一瞬」闪避：冲刺+无敌期间对所有伤害类型触发闪避，完全免疫
	if assassin_comp and target.dashing and assassin_comp.is_invincible:
		if not assassin_comp.dodge_success:
			assassin_comp.dodge_success = true
			assassin_comp.dodge_slow_mo = 30  # 0.5 秒慢动作
			# 积攒 1 格暗影能量，满格触发暗影游走
			assassin_comp.shadow_energy = minf(assassin_comp.shadow_energy_max, assassin_comp.shadow_energy + 1)
			if assassin_comp.shadow_energy >= assassin_comp.shadow_energy_max and not assassin_comp.shadow_stance:
				assassin_comp.shadow_stance = true
				assassin_comp.shadow_stance_timer = 480  # 8 秒
			emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 15, Color(0.667, 0.533, 1.0), 3, 5, "star", 0.8)
			print("[DODGE-DEBUG] ★ 闪避触发（apply_damage）！shadow_energy=", assassin_comp.shadow_energy, " dodge_slow_mo=", assassin_comp.dodge_slow_mo, " shadow_stance=", assassin_comp.shadow_stance)
		# 闪避期间免疫一切伤害
		return

	# 刺客「一瞬」无敌期间免疫伤害（非冲刺状态下的纯无敌）
	if assassin_comp and assassin_comp.is_invincible:
		print("[DAMAGE-DEBUG] ✓ 无敌免疫成功，伤害被拦截")
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 12, Color(0.667, 0.533, 1.0), 3, 5, "star", 0.6)
		return

	# Dragon Knight 鳞反：举盾吸收伤害
	if target.dk_shield_active:
		target.dk_shield_absorbed_damage += dmg
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 10, Color(1.0, 0.3, 0.1), 3, 5, "circle", 0.5)
		return

	# 通用无敌：所有角色 is_invincible 标志生效（玫瑰二技能等）
	if target.is_invincible:
		return

	# 格挡：隔开正前方的伤害，攻击者被弹开
	if target.blocking:
		if attacker and attacker != target:
			attacker.vx = -attacker.facing * 8
			attacker.vy = -5
			attacker.hit_cooldown = 20
			emit_explosion(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, Color(1.0, 0.867, 0.267), 50)
			AudioManager.play_sound("parry")
		return

	# 护盾吸收伤害（50%转化为治疗）
	if target.shield_active:
		var heal_amount: float = dmg * 0.5
		if heal_amount > 0:
			try_heal(target, heal_amount)
			emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 15, Color(0.267, 1.0, 0.533), 3, 5, "circle", 0.5)
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 10, Color(0.533, 0.867, 1.0), 3, 5, "circle", 0.5)
		return

	# 计算基础伤害
	var base_dmg: float = dmg
	if attacker:
		if attacker.attack_boost > 0:
			base_dmg *= (1.0 + attacker.attack_boost)
		var attacker_paladin = attacker.components.get_component("paladin") if attacker.components else null
		if attacker_paladin and attacker_paladin.holy_empower_active:
			base_dmg += 5
		if attacker.dragon_form_active:
			base_dmg += 8

	# 神圣壁垒：吸收伤害并转化为能量（1:3）
	if paladin_comp and paladin_comp.divine_shield_active:
		var holy_gain: float = base_dmg * 3
		paladin_comp.divine_shield_absorb += base_dmg
		target.energy = minf(target.max_energy, target.energy + holy_gain)
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 18, Color(1.0, 0.843, 0.0), 4, 6, "star", 0.8)
		AudioManager.play_sound("parry")
		return

	# 刺客暗影游走暴击判定（50%概率，1.5倍）
	var is_critical: bool = false
	var attacker_assassin = attacker.components.get_component("assassin") if attacker and attacker.components else null
	if attacker_assassin and attacker_assassin.shadow_stance:
		if randf() < 0.5:
			is_critical = true

	var final_dmg: float = base_dmg

	# 角色钩子：受伤前处理（格挡/消耗资源/减伤等，返回修正后伤害；如黑法师凛冬冰棱格挡只受 30%）
	final_dmg = _call_on_pre_damage(target, attacker, final_dmg)

	# 圣佑：免疫击退（减伤由防御力承担，激活时 defense+50）
	if paladin_comp and paladin_comp.holy_empower_active:
		knockback = false

	# 龙化形态：免疫击退（减伤由防御力承担）
	if target.dragon_form_active:
		knockback = false

	# 护甲减伤（护甲公式：减伤率 = defense / (defense + 50)，收益递减；高防御可完全减免伤害）
	if target.defense > 0.0:
		var armor_dr: float = target.defense / (target.defense + 50.0)
		final_dmg = final_dmg * (1.0 - armor_dr)

	# Dragon Knight 龙魂大招：免疫击退和击飞
	if target.dk_ult_active:
		knockback = false

	# 霸体：免疫击退和击飞
	if target.state_flags.get("super_armor", false):
		knockback = false

	# 冰棱格挡：凛冬状态下被命中消耗冰棱 → 免疫击退/击飞（伤害已在 on_pre_damage 减至 30%）
	if target.state_flags.get("bm_ice_block", false):
		knockback = false

	# ── 体系统：技能打断优先级 ──
	# 攻击体缺省取攻击者当前体；低优先级攻击命中高优先级体 → 不打断且不击退/击飞（仍造成伤害）
	var hit_p: int = hit_priority
	if hit_p < 0:
		hit_p = get_body_priority(attacker) if attacker else BODY_NORMAL
	var target_p: int = get_body_priority(target)
	var is_grab: bool = damage_source == "grab"
	var defense_active: bool = is_defense_parry_active(target)
	if not is_grab and hit_p < target_p:
		knockback = false
	# 打断判定：防御/招架类免疫打断；抓取打断除金刚体外一切；否则攻击体 >= 目标体才打断
	var should_interrupt: bool = false
	if not defense_active:
		if is_grab:
			should_interrupt = target_p < BODY_VAJRA
		elif hit_p >= target_p:
			should_interrupt = true

	# 暴击伤害倍率
	if is_critical:
		final_dmg = final_dmg * 1.5
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 30, Color(1.0, 0.867, 0.267), 6, 8, "star", 1.5)
		AudioManager.play_sound("ult")

	# 角色钩子：受伤时触发
	_call_on_damage_received(target, attacker, base_dmg)

	# Boss Modifier 全局倍率（唯一结算点：普攻/技能/投射物/区域/灼烧等一切伤害在此统一放大）。
	# 只放大最终结算，格挡/护盾/无敌等前置判定链不受影响；默认倍率 1.0 对 PVE/PVP 零影响。
	var _dm := attacker.damage_multiplier if attacker else 1.0
	final_dmg *= _dm * target.damage_taken_multiplier

	var old_hp = target.hp
	target.hp -= final_dmg
	target.damage_flash = 10
	target.hit_cooldown = 15
	target.hp_changed.emit(old_hp, target.hp)
	# 练习模式：累计玩家对敌人造成的实际伤害（伤害显示开关）
	if GameWorld.practice_mode and attacker and attacker == GameWorld.player \
			and target == GameWorld.enemy and final_dmg > 0:
		GameWorld.practice_damage_dealt += final_dmg
		GameWorld.practice_damage_last_frame = GameWorld.frame
	# 体系统打断：满足条件时目标立刻停止释放技能
	if should_interrupt:
		interrupt_skill_cast(target)
	if attacker:
		var attacker_rose = attacker.components.get_component("rose") if attacker.components else null
		if attacker_rose:
			# 建议：强化技能（强化一技能播片 / 强化二技能飞行）命中不恢复血渊——
			# 血渊作为强化消耗资源，不因命中返还（常态普攻/技能/大招仍恢复）
			var rose_enhancing: bool = attacker_rose.rose_skill1_enhanced_slashes.size() > 0 \
				or attacker_rose.rose_skill2_enhanced
			if not attacker_rose.rose_blood_abyss_suppressed and not rose_enhancing:
				attacker_rose.blood_abyss = minf(40.0, attacker_rose.blood_abyss + final_dmg)
			if attacker_rose.rose_blood_abyss_suppressed:
				attacker_rose.rose_blood_abyss_suppressed = false
		# 剑豪被动：造成伤害立即恢复等量能量（1 伤害 = 1 能量），上限 100
		var attacker_kensai = attacker.components.get_component("kensai") if attacker.components else null
		if attacker_kensai:
			attacker.energy = minf(100.0, attacker.energy + final_dmg)
	if knockback and attacker and attacker != target:
		target.vy = -4
		target.vx = (attacker.facing if attacker.facing != 0 else (1 if target.is_player else -1)) * 5
	# 领域伤害：无粒子效果和音效
	if damage_source != "domain":
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 25, hit_color, 6, 6, "circle", 0.8)
	if target.hp < 0:
		target.hp = 0
	target.hp_changed.emit(old_hp, target.hp)
	# ── 天赋事件广播 ──
	TalentEventBus.emit_damage_dealt(attacker, target, final_dmg, damage_source, recursion_depth)
	TalentEventBus.emit_damage_received(target, attacker, final_dmg, damage_source, recursion_depth)
	if target.hp <= 0:
		TalentEventBus.emit_kill(attacker, target)
	if damage_source != "domain":
		AudioManager.play_sound(sound_name)
	# updateHUD() would go here

# Call character-specific onDamageReceived hooks via components
static func _call_on_damage_received(target: Fighter, attacker: Fighter, dmg: float):
	if target.components:
		target.components.on_damage_received(attacker, dmg)

# Call character-specific pre-damage hooks via components (格挡/减免等，返回修正后伤害)
static func _call_on_pre_damage(target: Fighter, attacker: Fighter, dmg: float) -> float:
	if target.components:
		return target.components.on_pre_damage(attacker, dmg)
	return dmg

static func emit_particles(px: float, py: float, count: int, color: Color, speed: float, size: float, type: String = "circle", spread: float = 1.0):
	for i in count:
		var a = randf() * PI * 2
		var s = randf() * speed + 1
		var p_vx = cos(a) * s * spread
		var p_vy = sin(a) * s * spread - 1
		var life = 20 + randi() % 30
		var sz = size * (0.5 + randf() * 0.8)
		GameWorld.particles.append(GameParticle.new(px, py, p_vx, p_vy, color, life, sz, type))

static func emit_slash(x: float, y: float, dir: float, color: Color):
	for i in range(15):
		var a = dir + (randf() - 0.5) * 1.2
		var s = 2 + randf() * 5
		var p_vx = cos(a) * s
		var p_vy = sin(a) * s - 2
		var life = 10 + randf() * 20
		var sz = 4 + randf() * 8
		GameWorld.particles.append(GameParticle.new(x, y, p_vx, p_vy, color, life, sz, "star"))

static func emit_explosion(x: float, y: float, color: Color, count: int = 40):
	for i in range(count):
		var a = randf() * PI * 2
		var s = 2 + randf() * 6
		var p_vx = cos(a) * s
		var p_vy = sin(a) * s - 2
		var life = 15 + randf() * 25
		var sz = 3 + randf() * 8
		GameWorld.particles.append(GameParticle.new(x, y, p_vx, p_vy, color, life, sz, "star"))

# ===== Generic state & grab interface =====

## 无敌：开启 N 帧无敌（N<=0 表示持续直到手动 clear_invincible）
static func set_invincible(f: Fighter, frames: int = 0):
	f.is_invincible = true
	f.invincible_timer = frames if frames > 0 else 0

## 清除无敌
static func clear_invincible(f: Fighter):
	f.is_invincible = false
	f.invincible_timer = 0

## 霸体：开启 N 帧霸体（N<=0 表示持续直到手动 clear_super_armor）
static func set_super_armor(f: Fighter, frames: int = 0):
	f.state_flags["super_armor"] = true
	if frames > 0:
		f.state_flags["super_armor_timer"] = frames
	else:
		f.state_flags.erase("super_armor_timer")

## 清除霸体
static func clear_super_armor(f: Fighter):
	f.state_flags.erase("super_armor")
	f.state_flags.erase("super_armor_timer")

## 受击提前结束技能动画（全局规则：技能动画只能通过受击提前结束）。
## 仅作用于 config.skill_anim_states 声明的状态；霸体/无敌期间由调用方保证不触发。
func interrupt_skill_anim_on_hit():
	var anim = current_anim
	if anim == null or not anim.is_playing():
		return
	if image_state in config.get("skill_anim_states", []):
		set_animation_state("idle")

## 抓取对手到指定 x 坐标（以目标中心对齐），返回是否成功
static func grab_fighter(target: Fighter, teleport_x: float) -> bool:
	if not target or target.hp <= 0:
		return false
	if target.is_invincible:
		return false
	target.pos_x = clampf(teleport_x - target.w / 2.0, 10, 2390 - target.w)
	target.vx = 0
	target.vy = 0
	return true

## 持续锁定对手在指定 x 坐标（每帧调用保持定身），返回是否仍被锁定
static func hold_fighter_in_place(target: Fighter, x: float) -> bool:
	if not target or target.hp <= 0:
		return false
	if target.is_invincible:
		return false
	target.pos_x = clampf(x - target.w / 2.0, 10, 2390 - target.w)
	target.vx = 0
	target.vy = 0
	return true

## 抓取矩形区域内的对手，瞬移到指定x坐标。返回是否抓取成功。
static func grab_fighter_in_rect(grabber: Fighter, area: Rect2, teleport_x: float) -> bool:
	var target = GameWorld.get_opponent(grabber)
	if not target or target.hp <= 0:
		return false
	if target.is_invincible:
		return false
	if not area.intersects(target.get_hit_box()):
		return false
	return grab_fighter(target, teleport_x)

# ===== Collision helpers =====
static func rect_collide(a: Rect2, b: Rect2) -> bool:
	return a.position.x < b.position.x + b.size.x and a.position.x + a.size.x > b.position.x and a.position.y < b.position.y + b.size.y and a.position.y + a.size.y > b.position.y

static func check_hit(attack_box: Rect2, target: Fighter) -> bool:
	return rect_collide(attack_box, target.get_hit_box())

static func reflect_projectile(proj: Dictionary, defender: Fighter) -> bool:
	if not defender.blocking:
		return false
	proj["vx"] = -proj["vx"] * 1.1
	proj["owner"] = defender
	proj["color"] = Color(1.0, 0.867, 0.267)  # ~#ffdd44
	defender.energy = minf(defender.max_energy, defender.energy + 20)
	emit_particles(proj["x"] + proj["w"] / 2.0, proj["y"] + proj["h"] / 2.0, 25, Color(1.0, 0.867, 0.267), 5, 7, "star", 1.2)
	AudioManager.play_sound("parry")
	return true

## 虚空触碰：默认扣 20 血并回出生点；天赋可通过 on_in_void 拦截（如虚空亲和：落入虚空不受伤）
func _on_void_touch():
	# 广播虚空事件（天赋可设置 void_damage_immune 拦截本次伤害与回城）
	if talent_manager:
		talent_manager.on_in_void({"fighter": self, "pre_hp": hp})
	if state_flags.get("void_damage_immune", false):
		state_flags["void_damage_immune"] = false  # 天赋已处理（传送），本次不受伤不传送
		return
	hp -= 20
	pos_x = spawn_x
	pos_y = spawn_y
	vy = 0
	vx = 0
	grounded = true

## 虚空亲和：传送到随机地面位置
func _teleport_to_random_ground():
	var grounds: Array = []
	for p in GameWorld.platforms:
		if p.get("is_ground", false) or p.get("terrain_type", -1) == 0:
			grounds.append(p)
	if grounds.is_empty():
		pos_x = 400; pos_y = Constants.GROUND_Y - h
		return
	var g = grounds[randi() % grounds.size()]
	pos_x = clampf(g["x"] + (g["w"] - w) / 2.0, 10, 2400 - 10 - w)
	pos_y = g["y"] - h
	vx = 0; vy = 0
	dashing = false
	grounded = true
	emit_particles(pos_x + w / 2.0, pos_y, 20, Color(0.667, 0.267, 1.0), 3, 8, "circle")

## 全屏大招伤害判定（统一标准）：以释放者几何中心为圆心、size×size 矩形框内所有敌人命中。
## 所有全屏演出大招共用，跨角色范围统一（默认 600×600，即释放者 ±300px）。
## hit_priority 用于体系统（如千枫落华斩传 Fighter.BODY_SKILL）。
## center 可覆盖判定中心（如演出期释放者可能移动时，传释放瞬间位置快照）
static func apply_ult_damage_zone(attacker: Fighter, dmg: float, hit_color: Color = Color(1.0, 0.53, 0.27), size: float = 600.0, hit_priority: int = -1, center: Vector2 = Vector2.INF) -> void:
	var cx: float
	var cy: float
	if center != Vector2.INF:
		cx = center.x
		cy = center.y
	else:
		cx = attacker.pos_x + attacker.w / 2.0
		cy = attacker.pos_y + attacker.h / 2.0
	var half: float = size / 2.0
	for e in GameWorld.entities:
		if e == attacker or e.hp <= 0 or e.is_player == attacker.is_player:
			continue
		var ex: float = e.pos_x + e.w / 2.0
		var ey: float = e.pos_y + e.h / 2.0
		if absf(ex - cx) <= half and absf(ey - cy) <= half:
			apply_damage(e, dmg, attacker, false, hit_color, "hit_enemy", "ult", 0, hit_priority)

# ===== Movement helpers (used by character input strategies) =====
static func apply_movement(f: Fighter, mx: int, max_spd: float):
	if not f.has_status("frozen") and not f.dashing:
		f.vx += mx * 0.25
		if absf(f.vx) > max_spd * f.speed_multiplier: f.vx = max_spd * f.speed_multiplier * signf(f.vx)

static func update_state(p: Fighter, mx: int):
	if p.grounded and mx == 0 and not p.attacking and not p.dashing:
		p.state = "idle"
	elif p.grounded and mx != 0 and not p.attacking and not p.dashing:
		p.state = "walk"
	if p.attacking and p.attack_timer <= 0:
		p.attacking = false; p.state = "idle"
