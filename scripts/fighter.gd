class_name Fighter
extends Node2D

# Position & physics
var pos_x: float = 0
var pos_y: float = 0
var w: float = 32.0
var h: float = 56.0
var vx: float = 0
var vy: float = 0
var facing: int = 1
var on_platform = null

# Identity
var display_name: String = ""
var is_player: bool = false
var char_id: String = "knight"
var config: Dictionary = {}
var skills: Array = [] # Array of Skill objects
var skill_map: Dictionary = {}

# Health & energy
var hp: float = 100
var max_hp: float = 100
var energy: float = 0
var max_energy: float = 100
var energy_regen: float = 0.05

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

# State
var grounded: bool = false
var state: String = "idle"
var image_state: String = "idle"
var current_anim: FrameAnimation = null
var desired_image_state: String = ""  # 技能代码设置的覆盖状态，优先级高于 apply_physics 推导
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

# Archer fields
var arrows: int = 10
var max_arrows: int = 10
var arrow_regen_timer: int = 0
var arrow_regen_rate: int = 480
var fire_arrow_buff: bool = false
var fire_arrow_timer: int = 0
var tracking_buff: bool = false
var tracking_timer: int = 0

# Paladin
var divine_shield_active: bool = false
var divine_shield_timer: int = 0
var divine_shield_absorb: float = 0
var holy_empower_active: bool = false
var holy_empower_timer: int = 0

# Witch
var is_flying: bool = false
var fly_energy_drain: float = 8.0 / 60.0
var gravity_debuff: bool = false
var jump_reduction: float = 1.0
var is_casting_ult: bool = false
var cast_ult_x: float = 0
var cast_ult_y: float = 0

# Assassin
var shadow_energy: float = 0
var shadow_energy_max: float = 5
var shadow_stance: bool = false
var shadow_stance_timer: int = 0
var shadow_energy_drain_rate: float = 5.0 / 480.0
var is_invincible: bool = false
var invincible_timer: int = 0
var enhanced_slash: bool = false
var enhanced_slash_timer: int = 0
var slash_active: bool = false
var slash_timer: int = 0
var slash_x: float = 0
var slash_y: float = 0
var slash_facing: int = 1
var slash_damage_dealt: bool = false
var skill2_active: bool = false
var skill2_timer: int = 0
var skill2_x: float = 0
var skill2_y: float = 0
var skill2_facing: int = 1
var skill2_damage_dealt: bool = false
var ult_active: bool = false
var ult_timer: int = 0
var ult_damage_timer: int = 0
var time_stop: bool = false
var time_stop_timer: int = 0
var dodge_success: bool = false
var dodge_slow_mo: int = 0
var shadow_trail: Array = []
var max_shadow_trail: int = 12

# Shadowwarrior
var stealth_active: bool = false
var stealth_timer: int = 0
var last_skill_time: int = -999
var retreat_timer: int = 0
var retreat_dir: int = 1
var break_strike_timer: int = 0
var pending_trap: bool = false
var shadow_trap_active: bool = false
var shadow_trap: Dictionary = {}
var pending_clones: bool = false
var clone_reveal_timer: int = 0
var iaido_active: bool = false
var iaido_timer: int = 0
var iaido_frozen: bool = false
var iaido_dir: int = 1
var iaido_slash: Dictionary = {}

# Evoker
var last_summon_type: int = -1
var summon_dead1: bool = false
var summon_dead2: bool = false
var summon_dead3: bool = false
var slow_timer: int = 0
var slow_percent: float = 0.0
var burn_timer: int = 0
var bleed_timer: int = 0
var blind_timer: int = 0
var evoker_gazed: bool = false

# Rose: blood_abyss
var blood_abyss: float = 0.0
var blood_heal_timer: int = 0
var rose_skill2_active: bool = false
var rose_skill2_damage_tick: int = 0
var rose_skill2_tick_damage: float = 3.0
var rose_skill2_enhanced: bool = false
var rose_skill2_fly_timer: int = 0
var rose_grab_center_x: float = -9999.0
var rose_skill1_enhanced_slashes: Array = []  # pending slashes for enhanced skill1
var rose_skill1_slash_spawn_timer: int = 0

# Forced skill timer
var forced_skill_timer: int = 0

func setup(p_x: float, p_y: float, p_is_player: bool, p_char_id: String, p_skills: Array):
	pos_x = p_x
	pos_y = p_y
	is_player = p_is_player
	display_name = "玩家" if is_player else "AI"
	char_id = p_char_id
	# evoker-specific field initialization
	if char_id == "evoker":
		slow_timer = 0
		slow_percent = 0.0
		burn_timer = 0
		bleed_timer = 0
		blind_timer = 0
	skills = p_skills
	skill_map.clear()
	for s in skills:
		skill_map[s.key] = s
	facing = 1 if is_player else -1
	on_platform = null
	_init_from_config()

func _init_from_config():
	var cfg = CharConfigs.configs.get(char_id, {})
	config = cfg
	hp = cfg.get("hp", 100)
	max_hp = cfg.get("hp", 100)
	max_energy = cfg.get("max_energy", 100)
	energy_regen = cfg.get("energy_regen", 0.05)
	attack_speed = cfg.get("speed", 2.25)
	attack_range = cfg.get("attack_range", 44)
	attack_damage = cfg.get("attack_damage", 5)
	var fields = cfg.get("fields", {})
	for key in fields:
		var val = fields[key]
		if val is Array:
			set(key, val.duplicate())
		elif val is Dictionary:
			set(key, val.duplicate())
		else:
			set(key, val)
	var anims = config.get("animations", {})
	if anims.has("idle"):
		current_anim = anims["idle"]
		current_anim.play()
		image_state = "idle"

func set_animation_state(state_key: String):
	image_state = state_key
	var anims = config.get("animations", {})
	var new_anim = anims.get(state_key)
	if new_anim:
		current_anim = new_anim
		if not current_anim.is_playing():
			current_anim.play()

func get_skill(key: String) -> Skill:
	return skill_map.get(key)

func add_status(effect_id: String):
	# Prevent duplicate freeze application
	var def = StatusEffect.STATUS_DEFS.get(effect_id, {})
	if def.get("freeze", false) and has_status("frozen"):
		return
	for s in statuses:
		if s.id == effect_id:
			s.timer = s.duration
			return
	var inst = StatusEffect.new(effect_id)
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
	for s in statuses:
		if s.slow_factor < 1.0:
			return s.slow_factor
	return 1.0

func is_movement_locked() -> bool:
	return has_status("frozen") or shield_active or dashing

func get_hit_box() -> Rect2:
	return Rect2(pos_x + 4, pos_y + 4, w - 8, h - 8)

func get_attack_box() -> Rect2:
	var ox: float = w if facing == 1 else -attack_range
	return Rect2(pos_x + ox, pos_y + 6, attack_range, h - 16)

func apply_physics():
	if is_casting_ult:
		vx = 0
		vy = 0
		set_animation_state("ult")
	else:
		if attacking:
			pass
		if dashing:
			vx = dash_speed * dash_dir
		if is_flying:
			vy = 0
		elif not grounded:
			vy += 0.22 # GRAVITY
		if grounded and absf(vx) > 0.1 and not dashing:
			vx *= 0.88 # FRICTION
		elif grounded and not dashing:
			vx = 0
		if is_movement_locked() and not dashing:
			vx = 0
			vy = 0
		pos_x += vx
		pos_y += vy
		grounded = false
		for p in GameWorld.platforms:
			if vy >= 0 and pos_x + w > p["x"] + 4 and pos_x < p["x"] + p["w"] - 4 and \
			   pos_y + h >= p["y"] and pos_y + h <= p["y"] + p["h"] + 6:
				pos_y = p["y"] - h
				vy = 0
				grounded = true
				on_platform = p
				break
		if not grounded and pos_y >= 380 - h: # GROUND_Y
			pos_y = 380 - h
			vy = 0
			grounded = true
		pos_x = clampf(pos_x, 10, 2400 - 10 - w) # MAP_W
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
				var box = get_attack_box()
				if box.intersects(target.get_hit_box()):
					Fighter.apply_damage(target, attack_damage, self)
	if attack_cooldown > 0:
		attack_cooldown -= 1
	if hit_cooldown > 0:
		hit_cooldown -= 1
	if damage_flash > 0:
		damage_flash -= 1
	if blocking:
		block_timer -= 1
		if block_timer <= 0:
			blocking = false
	if shield_active:
		shield_timer -= 1
		if shield_timer <= 0:
			shield_active = false
	if divine_shield_active:
		divine_shield_timer -= 1
		if divine_shield_timer <= 0:
			divine_shield_active = false
	if holy_empower_active:
		holy_empower_timer += 1
		if holy_empower_timer >= 60:
			holy_empower_timer = 0
			energy = maxf(0, energy - 10)
			if energy <= 0:
				holy_empower_active = false
	update_statuses()
	for s in skills:
		s.update()
	# Blood Abyss healing (1 HP per 120 frames = 2 seconds, when > 0 and HP not full)
	if char_id == "rose" and blood_abyss > 0 and hp < max_hp:
		blood_heal_timer += 1
		if blood_heal_timer >= 120:
			blood_heal_timer = 0
			blood_abyss -= 1
			hp = minf(max_hp, hp + 1)
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
	if dashing or charging_skill1 or charging:
		set_animation_state("charge")
	elif attacking:
		set_animation_state("attack")
	elif state == "ult":
		set_animation_state("ult")
	elif not grounded:
		set_animation_state("jump")
	elif state == "walk":
		set_animation_state("walk")
	else:
		set_animation_state("idle")

# ===== Static damage function =====
static func apply_damage(target: Fighter, dmg: float, attacker: Fighter, knockback: bool = true, hit_color: Color = Color(1.0, 0.53, 0.27), sound_name: String = "hit_enemy"):
	if not target or target.hp <= 0:
		return
	if attacker == target:
		return

	# 刺客「一瞬」无敌期间免疫伤害
	if target.is_invincible:
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 12, Color(0.667, 0.533, 1.0), 3, 5, "star", 0.6)
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
		var heal_amount: int = int(dmg * 0.5)
		if heal_amount > 0:
			target.hp = minf(target.max_hp, target.hp + heal_amount)
			emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 15, Color(0.267, 1.0, 0.533), 3, 5, "circle", 0.5)
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 10, Color(0.533, 0.867, 1.0), 3, 5, "circle", 0.5)
		# updateHUD() would go here
		return

	# 计算基础伤害
	var base_dmg: float = dmg
	if attacker:
		base_dmg += attacker.attack_boost
		if attacker.holy_empower_active:
			base_dmg += 5

	# 神圣壁垒：吸收伤害并转化为能量（1:3）
	if target.divine_shield_active:
		var holy_gain: int = int(base_dmg * 3)
		target.divine_shield_absorb += base_dmg
		target.energy = minf(target.max_energy, target.energy + holy_gain)
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 18, Color(1.0, 0.843, 0.0), 4, 6, "star", 0.8)
		AudioManager.play_sound("parry")
		# updateHUD() would go here
		return

	# 刺客暗影游走暴击判定（50%概率，1.5倍）
	var is_critical: bool = false
	if attacker and attacker.char_id == "assassin" and attacker.shadow_stance:
		if randf() < 0.5:
			is_critical = true

	var final_dmg: float = base_dmg

	# 圣佑：减免50%伤害，免疫击退
	if target.holy_empower_active:
		final_dmg = maxf(1.0, floorf(base_dmg * 0.5))
		knockback = false

	# 暴击伤害倍率
	if is_critical:
		final_dmg = floorf(final_dmg * 1.5)
		emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 30, Color(1.0, 0.867, 0.267), 6, 8, "star", 1.5)
		AudioManager.play_sound("ult")

	# 角色钩子：受伤时触发
	_call_on_damage_received(target, attacker, base_dmg)

	target.hp -= final_dmg
	target.damage_flash = 10
	target.hit_cooldown = 15
	# Blood Abyss: attacker gains blood_abyss equal to damage dealt
	if attacker and attacker.char_id == "rose":
		attacker.blood_abyss = minf(40.0, attacker.blood_abyss + final_dmg)
	if knockback and attacker and attacker != target:
		target.vy = -4
		target.vx = (attacker.facing if attacker.facing != 0 else (1 if target.is_player else -1)) * 5
	emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 25, hit_color, 6, 6, "circle", 0.8)
	if target.hp < 0:
		target.hp = 0
	AudioManager.play_sound(sound_name)
	# updateHUD() would go here

# Call character-specific onDamageReceived hooks
static func _call_on_damage_received(target: Fighter, attacker: Fighter, dmg: float):
	# Paladin: gain energy equal to damage received
	if target.char_id == "paladin":
		target.energy = minf(target.max_energy, target.energy + dmg)
	# Evoker: summon damage transfer + mute damage reduction
	if target.char_id == "evoker":
		_call_evoker_damage_received(target, attacker, dmg)

# Evoker onDamageReceived: summon damage transfer + mute debuff
static func _call_evoker_damage_received(target: Fighter, attacker: Fighter, dmg: float):
	var summon = null
	for s in GameWorld.evoker_summons:
		if s.get("owner") == target:
			summon = s
			break
	if not summon:
		return
	if summon.get("hp", 0) <= 0:
		return
	# 随行：转移60%伤害给召唤物
	if summon.get("state", "") == "随行":
		var transfer: int = min(int(dmg * 0.6), int(summon["hp"]))
		summon["hp"] -= transfer
		target.hp += transfer
		Fighter.emit_particles(summon["x"] + summon["w"] / 2.0, summon["y"] + summon["h"] / 2.0, 8, Color.RED, 2, 10)
	# 1号噤声：减伤20%
	if summon.get("type", -1) == 0 and attacker:
		if signf(attacker.pos_x - summon["x"]) == signf(target.pos_x - summon["x"]):
			target.hp += floorf(dmg * 0.2)

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

static func apply_movement(f: Fighter, mx: int, max_spd: float):
	if not f.has_status("frozen") and not f.dashing:
		f.vx += mx * 0.25
		if absf(f.vx) > max_spd: f.vx = max_spd * signf(f.vx)

static func update_state(f: Fighter, mx: int):
	if f.grounded and mx == 0 and not f.attacking and not f.dashing:
		f.state = "idle"
	elif f.grounded and mx != 0 and not f.attacking and not f.dashing:
		f.state = "walk"
	if f.attacking and f.attack_timer <= 0:
		f.attacking = false; f.state = "idle"
