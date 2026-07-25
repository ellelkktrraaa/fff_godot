class_name AISystem

const DEFAULT_PROFILE := {"ideal_range": [0, 300], "kite": false}

# ===== AI System — character-aware difficulty =====
static func update_ai(ai_think_delay: int) -> int:
	if GameWorld.game_mode == "pvp" or GameWorld.enemy.hp <= 0:
		return ai_think_delay
	
	var f = GameWorld.enemy
	
	# Frozen / hit-stun → skip
	if f.has_status("frozen") or f.hit_cooldown > 0:
		return ai_think_delay
	
	var diff = Constants.AI_PRESETS.get(GameWorld.difficulty, Constants.AI_PRESETS["medium"])
	var profile = f.config.get("ai_profile", DEFAULT_PROFILE)
	var ideal_min = profile["ideal_range"][0]
	var ideal_max = profile["ideal_range"][1]
	var is_hell = GameWorld.difficulty == "hell"
	var prefer_air = profile.get("prefer_air", false)
	var kite_mult = 1.5 if is_hell else 1.0
	
	# Phantom target selection — AI prefers nearest alive phantom
	var target = GameWorld.player
	if GameWorld.phantoms.size() > 0:
		var nearest = null
		var nd = INF
		for ph in GameWorld.phantoms:
			if not ph or ph.hp <= 0:
				continue
			var d = absf(f.pos_x - ph.x)
			if d < nd:
				nd = d
				nearest = ph
		if nearest:
			target = nearest
	
	var tx = target.x if target is Dictionary else target.pos_x
	var dx = tx - f.pos_x
	var dist = absf(dx)
	var dir_to_target = 1 if dx > 0 else -1
	
	# Think delay
	if ai_think_delay > 0:
		return ai_think_delay - 1
	var new_delay = int(diff["react"] / 16) + randi() % 8
	if is_hell:
		new_delay = maxi(2, new_delay - 2)  # Hell: react even faster
	
	var rand = randf()
	
	# ---- Skill usage (profile-aware ranges) ----
	var skill1 = f.get_skill("skill1")
	var skill2 = f.get_skill("skill2")
	var ult = f.get_skill("ult")
	
	# Defensive skill2: projectile parry / shield
	if skill2 and skill2.can_use(f) and f.grounded:
		var proj_near = false
		for p in GameWorld.projectiles:
			if p.get("owner") == GameWorld.player and absf(p.get("x", 0) - f.pos_x) < 200:
				proj_near = true
				break
		if proj_near:
			skill2.try_use(f)
			return new_delay
	
	# Hell: kiting characters use skill2 defensively when enemy closes in
	if is_hell and profile["kite"] and dist < ideal_min and skill2 and skill2.can_use(f) and randf() < 0.4:
		skill2.try_use(f)
		return new_delay
	
	# Ult usage (profile-aware range)
	var ult_range = ideal_max * 1.3
	if dist < ult_range and ult and ult.can_use(f) and randf() < diff["skill_rate"] * 0.8:
		ult.try_use(f)
		if is_hell:
			ult.cd = maxi(ult.cd, 200)
		return new_delay
	
	# Skill1 at their preferred engagement range
	if dist > ideal_min * 0.6 and dist < ideal_max * 1.5 and skill1 and skill1.can_use(f) and randf() < diff["skill_rate"]:
		skill1.try_use(f)
		if is_hell:
			skill1.cd = maxi(skill1.cd, 200)
		return new_delay
	
	# ---- Attack when close ----
	if dist < maxf(80, ideal_min) and rand < diff["aggro"]:
		if f.char_id == "assassin":
			var atk_skill = f.get_skill("attack")
			if atk_skill and atk_skill.can_use(f):
				atk_skill.try_use(f)
		else:
			if f.attack_cooldown <= 0 and not f.attacking:
				f.attacking = true
				f.attack_timer = 68
				f.attack_delay = 8
				f.attack_hit_dealt = false
				f.attack_cooldown = 60
				f.state = "attack"
		return new_delay
	
	# ---- Distance management (profile-driven) ----
	var move_speed = diff["move_speed"]
	if is_hell:
		move_speed *= 1.1  # Hell: even faster reaction
	
	if profile["kite"]:
		# Kite character: maintain ideal distance
		var jump_chance = diff["jump_rate"] * (3.0 if prefer_air else 1.5)
		if dist < ideal_min:
			# Too close → retreat
			f.vx = -dir_to_target * move_speed * kite_mult
			if f.grounded and randf() < jump_chance:
				f.vy = -9
			_update_state(f, -dir_to_target)
		elif dist > ideal_max:
			# Too far → approach cautiously
			f.vx = dir_to_target * move_speed * 0.6
			if prefer_air and f.grounded and randf() < jump_chance * 0.6:
				f.vy = -9
			_update_state(f, dir_to_target)
		else:
			# In sweet spot → slight positional adjustment, jump to stay airborne
			if prefer_air and f.grounded and randf() < jump_chance:
				f.vy = -9
			if randf() < 0.3:
				f.vx = (1 if randf() < 0.5 else -1) * move_speed * 0.3
			_update_state(f, 0)
	else:
		# Aggressive character: close distance, occasional dodge
		if dist > ideal_max * 2:
			# Very far → rush
			f.vx = dir_to_target * move_speed * 1.3
			if f.grounded and randf() < diff["jump_rate"] * 2:
				f.vy = -8
			_update_state(f, dir_to_target)
		elif dist > ideal_max:
			# Moderately far → approach
			f.vx = dir_to_target * move_speed
			_update_state(f, dir_to_target)
		elif rand < diff["dodge"] and dist < ideal_min + 30:
			# In melee → dodge
			f.vx = -dir_to_target * move_speed * 1.8
			if f.grounded and randf() < 0.15:
				f.vy = -7
			_update_state(f, -dir_to_target)
		elif dist < ideal_min:
			# In ideal range → hold position, slight adjustment
			f.vx = 0
			_update_state(f, dir_to_target)
		else:
			# Within range → slow approach
			f.vx = dir_to_target * move_speed * 0.5
			_update_state(f, dir_to_target)
	
	# Hell: occasionally try to cut off escape with jump
	if is_hell and dist < 300 and f.grounded and randf() < 0.08:
		f.vy = -10
	
	return new_delay

static func _update_state(p: Fighter, mx: int):
	if p.grounded and mx == 0 and not p.attacking and not p.dashing:
		p.state = "idle"
	elif p.grounded and mx != 0 and not p.attacking and not p.dashing:
		p.state = "walk"
	if p.attacking and p.attack_timer <= 0:
		p.attacking = false; p.state = "idle"
