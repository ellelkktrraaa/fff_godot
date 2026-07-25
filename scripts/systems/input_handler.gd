class_name InputHandler

const PROJ_LIGHT_IMG = preload("res://assets/10-20260702202815.png")

# ===== Player Input =====
static func update_player_input(world, keys: Dictionary):
	var p = world.player
	if p.hp > 0 and not p.has_status("frozen"):
		_handle_char_input(p, keys)

static func _handle_char_input(p: Fighter, keys: Dictionary):
	match p.char_id:
		"shadowwarrior": CharacterFactory.handle_input(p.char_id, p, keys)
		"rose": CharacterFactory.handle_input(p.char_id, p, keys)
		"knight": _input_knight(p, keys)
		"mage": _input_mage(p, keys)
		"archer": _input_archer(p, keys)
		"paladin": _input_paladin(p, keys)
		"witch": _input_witch(p, keys)
		"assassin": _input_assassin(p, keys)
		"evoker": _input_evoker(p, keys)

static func _input_knight(p: Fighter, keys: Dictionary):
	var mx = 0
	if not p.charging:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if keys.up and p.grounded and not p.shield_active:
			p.vy = -10; p.grounded = false
		if keys.attack and not p.shield_active and p.attack_cooldown <= 0 and not p.attacking:
			p.attacking = true; p.attack_timer = 68; p.attack_delay = 8
			p.attack_hit_dealt = false; p.attack_cooldown = 60; p.state = "attack"
			keys.attack = false
		if keys.skill1 and not p.shield_active:
			var s = p.get_skill("skill1")
			if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
		if keys.skill2 and not p.shield_active:
			var s = p.get_skill("skill2")
			if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	if keys.ult and not p.shield_active:
		var s = p.get_skill("ult")
		if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
	_apply_movement(p, mx, 2.25)
	_update_state(p, mx)

static func _input_mage(p: Fighter, keys: Dictionary):
	var mx = 0
	if not p.charging:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if keys.up and p.grounded and not p.shield_active:
			p.vy = -9; p.grounded = false
		if keys.attack and not p.shield_active and p.attack_cooldown <= 0 and not p.attacking:
			if p.energy >= 10:
				p.energy -= 10; p.attacking = true; p.attack_timer = 120
				p.attack_delay = 0; p.attack_hit_dealt = true; p.attack_cooldown = 120; p.state = "attack"
				var d = p.facing; var px2 = p.pos_x + (p.w if d == 1 else 0); var py2 = p.pos_y + 30
				GameWorld.projectiles.append({"x":px2-16,"y":py2-12,"w":32,"h":24,"vx":3*d,"vy":0,"life":120,"damage":3,"owner":p,"type":"mage_fire","color":Color(1,0.4,0),"reflected":false,"burn":true,"img":MageCharacter.PROJ_FIRE})
			keys.attack = false
		if keys.skill1 and not p.shield_active:
			var s = p.get_skill("skill1"); if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
		if keys.skill2 and not p.shield_active:
			var s = p.get_skill("skill2"); if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	var mage_ult = p.get_skill("ult")
	if keys.ult and not p.shield_active and not p.charging and (not mage_ult or mage_ult.cd <= 0) and p.energy >= 40:
		p.charging = true; p.charge_start = Time.get_ticks_msec()
	if not keys.ult and p.charging:
		var ct = (Time.get_ticks_msec() - p.charge_start) / 1000.0
		var dmg = 20; var cost = 40
		if ct > 3: dmg = 60; cost = 120
		elif ct > 1: dmg = 40; cost = 80
		if p.energy >= cost:
			p.energy -= cost
			var d = p.facing; var px2 = p.pos_x + (p.w if d == 1 else 0); var py2 = p.pos_y + 30
			GameWorld.projectiles.append({"x":px2-20,"y":py2-15,"w":40,"h":30,"vx":4*d,"vy":0,"life":200,"damage":dmg,"owner":p,"type":"mage_light","color":Color(1,1,0.27),"reflected":false,"img":PROJ_LIGHT_IMG})
			var ult = p.get_skill("ult"); if ult: ult.cd = ult.cooldown
		p.charging = false
	_apply_movement(p, mx, 2.25)
	_update_state(p, mx)

static func _input_archer(p: Fighter, keys: Dictionary):
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and p.grounded and not p.shield_active:
		p.vy = -10; p.grounded = false
	if keys.attack and not p.shield_active and p.arrows > 0 and not p.charging_attack:
		p.charging_attack = true; p.charge_start_time = Time.get_ticks_msec()
		p.attacking = true; p.attack_timer = 9999; p.state = "attack"
	if not keys.attack and p.charging_attack:
		var ct = (Time.get_ticks_msec() - p.charge_start_time) / 1000.0
		var dmg: float; var cost: float
		if ct < 1: dmg = 5; cost = 5
		elif ct < 2: dmg = 8; cost = 10
		else: dmg = 12; cost = 15
		if p.energy >= cost:
			p.energy -= cost; p.arrows -= 1
			var d = p.facing; var px2 = p.pos_x + (p.w if d == 1 else 0); var py2 = p.pos_y + 30
			var spd = minf(4 + ct * 2, 10)
			var c = Color(1,0.53,0) if p.fire_arrow_buff else Color(0.67,0.67,0.67)
			var arr_img = ArcherCharacter.PROJ_ARROW_FIRE if p.fire_arrow_buff else ArcherCharacter.PROJ_ARROW
			GameWorld.projectiles.append({"x":px2-16,"y":py2-10,"w":32,"h":20,"vx":spd*d,"vy":0,"life":120,"damage":dmg,"owner":p,"type":"arrow","color":c,"reflected":false,"is_fire":p.fire_arrow_buff,"tracking":p.tracking_buff,"trackingTarget":GameWorld.get_opponent(p),"img":arr_img})
		p.charging_attack = false; p.attacking = false; p.state = "idle"
	if keys.skill1 and not p.shield_active and not p.charging_attack:
		var s = p.get_skill("skill1"); if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
	if keys.skill2 and not p.shield_active and not p.charging_attack:
		var s = p.get_skill("skill2"); if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	if keys.ult and not p.shield_active and not p.charging_attack:
		var s = p.get_skill("ult"); if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
	var spd2 = 1.25 if p.charging_attack else 2.25
	_apply_movement(p, mx, spd2)
	_update_state(p, mx)

static func _input_paladin(p: Fighter, keys: Dictionary):
	var mx = 0
	if not p.dashing:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if not p.charging_skill1 and keys.up and p.grounded:
			p.vy = -10; p.grounded = false
		if keys.attack and not p.charging_skill1 and p.attack_cooldown <= 0 and not p.attacking:
			p.attacking = true; p.attack_timer = 68; p.attack_delay = 8
			p.attack_hit_dealt = false; p.attack_cooldown = 60; p.state = "attack"
			keys.attack = false
		if keys.skill1 and not p.charging_skill1 and p.grounded:
			var s = p.get_skill("skill1"); if s: s.try_use(p)
		if not keys.skill1 and p.charging_skill1:
			_release_paladin_charge(p)
		if keys.skill2:
			var s = p.get_skill("skill2"); if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
		if keys.ult:
			var s = p.get_skill("ult"); if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
		var ms = 1.2 * 2.1 if p.charging_skill1 else 2.1
		if not p.has_status("frozen"):
			p.vx += mx * (0.3 if p.charging_skill1 else 0.25)
			if absf(p.vx) > ms: p.vx = ms * signf(p.vx)
		_update_state(p, mx)

static func _release_paladin_charge(owner: Fighter):
	if not owner.charging_skill1: return
	var ct = (Time.get_ticks_msec() - owner.charge_start_time) / 1000.0
	var dist = 100 + minf(ct, 2.0) * 150
	var d = owner.facing if owner.facing != 0 else 1
	owner.charging_skill1 = false; owner.state = "idle"
	owner.dashing = true; owner.dash_remaining = dist; owner.dash_dir = d
	owner.dash_speed = 4.2; owner.dash_damage_dealt = false
	var s1 = owner.get_skill("skill1"); if s1: s1.cd = s1.cooldown

static func _input_witch(p: Fighter, keys: Dictionary):
	var mx = 0
	if keys.up:
		if p.grounded and not p.is_flying:
			p.vy = p.jump_reduction * -10; p.grounded = false; keys.up = false
		elif not p.grounded and not p.is_flying and not p.attacking:
			if p.energy > 0: p.is_flying = true; p.vy = 0; keys.up = false
		elif p.is_flying:
			p.is_flying = false; keys.up = false
	if p.is_flying:
		p.energy -= p.fly_energy_drain
		if p.energy <= 0: p.energy = 0; p.is_flying = false
	if keys.left: mx = -1
	if keys.right: mx = 1
	if mx != 0: p.facing = 1 if mx > 0 else -1
	if not p.has_status("frozen") and not p.dashing:
		var sp = 1.8 if p.is_flying else 2.0
		p.vx += mx * 0.25
		if absf(p.vx) > sp: p.vx = sp * signf(p.vx)
	if keys.attack and not p.attacking and p.attack_cooldown <= 0:
		var s = p.get_skill("attack"); if s: var r = s.try_use(p); if r.get("success"): keys.attack = false
	if keys.skill1 and not p.attacking:
		var s = p.get_skill("skill1"); if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
	if keys.skill2 and not p.attacking and p.grounded:
		var s = p.get_skill("skill2"); if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	if keys.ult and not p.attacking:
		var s = p.get_skill("ult"); if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
	_update_state(p, mx)

static func _input_assassin(p: Fighter, keys: Dictionary):
	var mx = 0
	if not p.skill2_active:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if keys.up and p.grounded: p.vy = -10; p.grounded = false
	if keys.attack and not p.attacking and p.attack_cooldown <= 0 and not p.ult_active:
		var s = p.get_skill("attack"); if s: var r = s.try_use(p); if r.get("success"): keys.attack = false
	if keys.skill1 and not p.attacking and not p.ult_active and not p.dashing:
		var s = p.get_skill("skill1"); if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
	if keys.skill2 and not p.attacking and not p.ult_active and not p.dashing:
		var s = p.get_skill("skill2"); if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	if keys.ult and not p.attacking and not p.ult_active and not p.dashing:
		var s = p.get_skill("ult"); if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
	if not p.has_status("frozen") and not p.dashing and not p.ult_active and not p.skill2_active:
		p.vx += mx * 0.25
		if absf(p.vx) > 2.4: p.vx = 2.4 * signf(p.vx)
	elif p.skill2_active:
		p.vx = 0
	_update_state(p, mx)

static func _input_evoker(p: Fighter, keys: Dictionary):
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and p.grounded: p.vy = -10; p.grounded = false
	# Bypass Skill.can_use's "attacking" check — evoker's attack cooldown is managed by attack_cooldown, not attacking
	if keys.attack:
		var s = p.get_skill("attack")
		# Don't call can_use_func (which checks p.attacking); check attack_cooldown directly
		if s and p.attack_cooldown <= 0:
			# Determine energy cost based on summon presence (matching _can_attack logic without attacking check)
			var has_summon := false
			for sm in GameWorld.evoker_summons:
				if sm.get("owner") == p:
					has_summon = true
					break
			var cost: float = 20.0 if has_summon else 10.0
			if p.energy >= cost:
				if s.execute_func.is_valid():
					s.execute_func.call(p)
				keys.attack = false
	if keys.skill1:
		var s = p.get_skill("skill1")
		if s and s.cd <= 0 and p.energy >= s.energy_cost:
			if s.can_use_func.is_valid() and s.can_use_func.call(p):
				p.energy -= s.energy_cost
				s.cd = s.cooldown
				if s.execute_func.is_valid():
					s.execute_func.call(p)
				keys.skill1 = false
	if keys.skill2:
		var s = p.get_skill("skill2")
		if s and s.cd <= 0 and p.energy >= s.energy_cost:
			if s.can_use_func.is_valid() and s.can_use_func.call(p):
				p.energy -= s.energy_cost
				s.cd = s.cooldown
				if s.execute_func.is_valid():
					s.execute_func.call(p)
				keys.skill2 = false
	if keys.ult:
		var s = p.get_skill("ult")
		if s and s.cd <= 0 and p.energy >= s.energy_cost:
			if s.can_use_func.is_valid() and s.can_use_func.call(p):
				p.energy -= s.energy_cost
				s.cd = s.cooldown
				if s.execute_func.is_valid():
					s.execute_func.call(p)
				keys.ult = false
	_apply_movement(p, mx, 2.25)
	_update_state(p, mx)

static func _input_rose(p: Fighter, keys: Dictionary):
	# During enhanced skill2, WASD controls flight direction
	if p.rose_skill2_enhanced:
		var jx = 0.0; var jy = 0.0
		if keys.left: jx -= 1.0
		if keys.right: jx += 1.0
		if keys.up: jy -= 1.0
		if keys.down: jy += 1.0
		if jx != 0 or jy != 0:
			GameWorld.rose_joystick_dir = Vector2(jx, jy).normalized()
		else:
			GameWorld.rose_joystick_dir = Vector2.ZERO
		_apply_movement(p, 0, 2.25)
		_update_state(p, 0)
		return
	
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and p.grounded: p.vy = -10; p.grounded = false
	if keys.attack and p.attack_cooldown <= 0 and not p.attacking:
		p.attacking = true; p.attack_timer = 68; p.attack_delay = 8
		p.attack_hit_dealt = false; p.attack_cooldown = 60; p.state = "attack"
		keys.attack = false
	if keys.skill1 and not p.dashing:
		var s = p.get_skill("skill1")
		if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
	if keys.skill2 and not p.dashing:
		var s = p.get_skill("skill2")
		if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	if keys.ult:
		var s = p.get_skill("ult")
		if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
	_apply_movement(p, mx, 2.25)
	_update_state(p, mx)

static func _apply_movement(p: Fighter, mx: int, max_spd: float):
	Fighter.apply_movement(p, mx, max_spd)

static func _update_state(p: Fighter, mx: int):
	Fighter.update_state(p, mx)
