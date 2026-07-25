class_name CharacterSystems

## 通用调度：遍历所有实体，调用各自的 update_systems
static func update_characters():
	for f in GameWorld.entities:
		if f.hp > 0:
			CharacterFactory.update_char_systems(f)

# ===== Character-Specific Logic (遗留代码，逐步迁移到各角色脚本中) =====

static func update_assassin_logic():
	for f in GameWorld.entities:
		if f.char_id != "assassin" or f.hp <= 0: continue
		if f.is_invincible:
			f.invincible_timer -= 1
			if f.invincible_timer <= 0: f.is_invincible = false
		if f.dodge_slow_mo > 0:
			f.dodge_slow_mo -= 1
		if f.enhanced_slash:
			f.enhanced_slash_timer -= 1
			if f.enhanced_slash_timer <= 0: f.enhanced_slash = false
		
		# 暗影游走：dodge detection during 一瞬 dash
		if f.dashing and f.is_invincible:
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0 and not f.dodge_success:
				if enemy.attacking and f.get_hit_box().intersects(enemy.get_attack_box()):
					f.dodge_success = true
					f.shadow_energy = minf(f.shadow_energy_max, f.shadow_energy + 1)
					f.dodge_slow_mo = 15  # Slow-mo frames on successful dodge
					GameWorld.trigger_slow_motion(15)
					Fighter.emit_particles(f.pos_x + f.w/2, f.pos_y + f.h/2, 15, Color(0.67, 0.53, 1.0), 4, 6, "star")
			# Reset dodge_success when invincibility ends (dash over)
			if f.invincible_timer <= 0:
				f.dodge_success = false
		
		# 暗影游走：activate shadow stance when energy is full
		if f.shadow_energy >= f.shadow_energy_max and not f.shadow_stance:
			f.shadow_stance = true
			f.shadow_stance_timer = 480  # 8 seconds
			f.shadow_energy = f.shadow_energy_max
			Fighter.emit_particles(f.pos_x + f.w/2, f.pos_y + f.h/2, 40, Color(0.53, 0.27, 0.8), 6, 10, "star")
		
		if f.slash_active:
			f.slash_timer -= 1
			# Collision: check if slash hitbox hits enemy
			if not f.slash_damage_dealt:
				var enemy = GameWorld.get_opponent(f)
				if enemy and enemy.hp > 0:
					var slash_rect = Rect2(f.slash_x, f.slash_y, 100, 40)
					if slash_rect.intersects(enemy.get_hit_box()):
						var dmg = 8.0 if f.enhanced_slash else 5.0
						Fighter.apply_damage(enemy, dmg, f, true, Color(0.67, 0.53, 1.0))
						f.slash_damage_dealt = true
						if f.enhanced_slash:
							f.energy = minf(f.max_energy, f.energy + 5)
			if f.slash_timer <= 0:
				f.slash_active = false; f.attacking = false; f.state = "idle"
		if f.ult_active:
			f.ult_timer -= 1; f.ult_damage_timer += 1
			if f.ult_damage_timer >= 15:
				f.ult_damage_timer = 0
				var tgt = GameWorld.get_opponent(f)
				if tgt and tgt.hp > 0:
					var dx = tgt.pos_x + tgt.w/2 - f.pos_x - f.w/2
					var dy = tgt.pos_y + tgt.h/2 - f.pos_y - f.h/2
					if sqrt(dx*dx + dy*dy) < 200:  # Range check
						Fighter.apply_damage(tgt, 2.5, f)
			if f.ult_timer <= 0:
				f.ult_active = false; f.time_stop = false; f.state = "idle"
		if f.shadow_stance:
			f.shadow_stance_timer -= 1
			f.shadow_energy = maxf(0, f.shadow_energy - f.shadow_energy_drain_rate)
			if f.shadow_stance_timer <= 0 or f.shadow_energy <= 0:
				f.shadow_stance = false; f.shadow_energy = 0; f.shadow_trail.clear()

static func update_shadowwarrior_logic():
	for f in GameWorld.entities:
		if f.char_id != "shadowwarrior" or f.hp <= 0: continue
		if f.is_invincible:
			f.invincible_timer -= 1
			if f.invincible_timer <= 0: f.is_invincible = false
		if f.retreat_timer > 0: f.retreat_timer -= 1
		if f.break_strike_timer > 0:
			if not f.dashing: f.break_strike_timer = 0
			else: f.break_strike_timer -= 1
		if f.stealth_active:
			f.stealth_timer -= 1
			if f.stealth_timer <= 0: f.stealth_active = false
		if f.iaido_active:
			if f.iaido_timer > 160:
				f.pos_x = clampf(f.pos_x + f.iaido_dir * 14, 10, 2390 - f.w)
			f.vx = 0; f.vy = 0
			f.iaido_timer -= 1
			if f.iaido_timer <= 0:
				f.iaido_active = false; f.iaido_frozen = false; f.state = "idle"
		if f.pending_trap:
			f.shadow_trap = {"x":f.pos_x,"y":f.pos_y,"w":40,"h":56,"timer":500}
			f.shadow_trap_active = true; f.pending_trap = false
		if f.shadow_trap_active and f.shadow_trap.has("timer"):
			f.shadow_trap["timer"] -= 1
			if f.shadow_trap["timer"] <= 0:
				f.shadow_trap_active = false; f.shadow_trap.clear()
		if f.pending_clones:
			for ci in 2:
				GameWorld.phantoms.append({
					"x":f.pos_x+(-40 if ci==0 else 40),"y":f.pos_y,
					"w":32,"h":56,"hp":5.0,"max_hp":5.0,
					"facing":f.facing,"owner":f,"state":"idle",
					"attacking":false,"attack_timer":0,"attack_cooldown":30,
					"attack_delay":0,"attack_hit_dealt":false,"life":300,
				})
			f.pending_clones = false

# ===== Rose (血色蔷薇) Logic =====
static func update_rose_logic():
	for f in GameWorld.entities:
		if f.char_id != "rose" or f.hp <= 0:
			continue
		
		# Ult: 全屏大招持续伤害
		var has_ult_overlay = false
		for entry in GameWorld.active_overlays:
			if entry.get("overlay_id") == "rose_ult":
				has_ult_overlay = true
				break
		if has_ult_overlay and GameWorld.frame % 15 == 0:
			var target = GameWorld.get_opponent(f)
			if target and target.hp > 0:
				Fighter.apply_damage(target, 4.0, f, false, Color(0.9, 0.15, 0.15))
				Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 12, Color(0.9, 0.15, 0.15), 5, 7, "star", 0.8)
		
		# Skill2: bat swarm logic
		if f.rose_skill2_active:
			f.is_invincible = true
			f.image_state = "skill2"
			
			if f.rose_skill2_enhanced:
				# Enhanced: free flight via joystick (3 seconds)
				f.vx = 0; f.vy = 0  # Disable normal physics
				var jd = GameWorld.rose_joystick_dir
				var fly_speed = 3.5
				f.pos_x = clampf(f.pos_x + jd.x * fly_speed, 10, 2390 - f.w)
				f.pos_y = clampf(f.pos_y + jd.y * fly_speed, 40, 380 - f.h)
				f.facing = 1 if jd.x >= 0 else (-1 if jd.x < 0 else f.facing)
				# Proximity damage
				f.rose_skill2_damage_tick += 1
				var enemy = GameWorld.get_opponent(f)
				if enemy and enemy.hp > 0:
					var dist = absf(enemy.pos_x + enemy.w/2 - f.pos_x - f.w/2)
					if dist < 80:
						if f.rose_skill2_damage_tick >= 12:
							f.rose_skill2_damage_tick = 0
							Fighter.apply_damage(enemy, f.rose_skill2_tick_damage, f, false, Color(0.6, 0.1, 0.6))
				# Timer countdown
				f.rose_skill2_fly_timer -= 1
				if f.rose_skill2_fly_timer <= 0:
					f.rose_skill2_active = false
					f.rose_skill2_enhanced = false
					f.is_invincible = false
					GameWorld.rose_joystick_dir = Vector2.ZERO
			else:
				# Normal: dash forward with suction
				f.rose_skill2_damage_tick += 1
				var enemy = GameWorld.get_opponent(f)
				if enemy and enemy.hp > 0:
					if f.get_hit_box().intersects(enemy.get_hit_box()):
						# Suction: drag enemy along with character
						enemy.pos_x = f.pos_x + f.w * f.facing + f.facing * 4
						enemy.vy = 0
						# Periodic damage every 12 frames
						if f.rose_skill2_damage_tick >= 12:
							f.rose_skill2_damage_tick = 0
							Fighter.apply_damage(enemy, f.rose_skill2_tick_damage, f, true, Color(0.6, 0.1, 0.6))
							enemy.vy = 0  # Knockback only, no knock-up
				if not f.dashing:
					f.rose_skill2_active = false
					f.is_invincible = false
		
		# Skill1: grab effect — pin enemy to slash center
		elif f.dashing:
			if f.image_state != "skill1":
				f.image_state = "skill1"
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0:
				if f.get_hit_box().intersects(enemy.get_hit_box()):
					# Pin enemy to the center of the slash trail
					enemy.pos_x = f.rose_grab_center_x - enemy.w / 2.0
					enemy.vx = 0
					enemy.vy = 0
		
		# Continue grab after dash ends (slash persists for 1 second)
		if f.rose_grab_center_x > -9998 and GameWorld.rose_slash_trails.size() > 0:
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0:
				enemy.pos_x = f.rose_grab_center_x - enemy.w / 2.0
				enemy.vx = 0
				enemy.vy = 0
		elif f.rose_grab_center_x > -9998 and GameWorld.rose_slash_trails.size() == 0:
			f.rose_grab_center_x = -9999.0  # Release grab

static func update_active_overlays():
	var to_remove: Array = []
	for entry in GameWorld.active_overlays:
		var anim: FrameAnimation = entry["anim"]
		var should_remove = false
		if not anim or not anim.is_playing():
			should_remove = true
		else:
			anim.update(1)
			if anim.is_finished():
				should_remove = true
		if should_remove:
			to_remove.append(entry)
			var cb: Callable = entry.get("on_finish", Callable())
			if cb.is_valid():
				cb.call()
	for e in to_remove:
		GameWorld.active_overlays.erase(e)

static func update_rose_trails():
	var to_remove: Array = []
	for trail in GameWorld.rose_slash_trails:
		trail["timer"] -= 1
		if trail["timer"] <= 0:
			to_remove.append(trail)
			continue
		# Collision check with enemy
		var slash_owner = trail.get("owner")
		if not trail["hit_dealt"] and slash_owner:
			var target = GameWorld.get_opponent(slash_owner)
			if target and target.hp > 0:
				var hitbox = Rect2(trail["x"], trail["y"], trail["w"], trail["h"])
				if hitbox.intersects(target.get_hit_box()):
					Fighter.apply_damage(target, trail.get("damage", 10), slash_owner)
					trail["hit_dealt"] = true
	for t in to_remove:
		GameWorld.rose_slash_trails.erase(t)
