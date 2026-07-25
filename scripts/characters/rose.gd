# 血色蔷薇 (rose)
class_name RoseCharacter

const ROSE_SLASH_IMG = preload("res://assets/%E6%97%A0%E6%A0%87%E9%A2%9893_20260721203233.png")
const ROSE_SKILL1_IMG = preload("res://assets/无标题108_20260722172633.png")
const ROSE_SKILL2_IMG = preload("res://assets/无标题96_20260721235635.png")
const ROSE_ENH_SLASH1 = preload("res://assets/%E6%97%A0%E6%A0%87%E9%A2%9894_20260721204629.png")
const ROSE_ENH_SLASH2 = preload("res://assets/%E6%97%A0%E6%A0%87%E9%A2%9894_20260721204754.png")
const ROSE_ENH_SLASH3 = preload("res://assets/%E6%97%A0%E6%A0%87%E9%A2%9894_20260721204800.png")
const ROSE_ENH_SLASH4 = preload("res://assets/%E6%97%A0%E6%A0%87%E9%A2%9894_20260721204804.png")
const ROSE_ANI_DIR = "res://assets/char_ani/rose/"

static func get_config() -> Dictionary:
	return {
		"id": "rose", "name": "血色蔷薇", "hp": 90, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.25, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 68,
		"image_scale": 1.2,
		"fields": {},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "idle/", "rose_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "walk/", "rose_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "jump/", "rose_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "attack/", "rose_attack_f_", [{"index": 1, "duration": 1.0}], false),
			"skill1": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "skill1/", "rose_skill1_f_", [{"index": 1, "duration": 2.0}], false),
			"skill2": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "skill2/", "rose_skill2_f_", [{"index": 1, "duration": 3.0}], false),
			"skill2_enhanced": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "skill2_enhanced/", "rose_skill2_enhanced_f_", [{"index": 1, "duration": 3.0}], false),
			"ult": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "ult/", "rose_ult_f_", [
				{"index": 1, "duration": 0.797}, {"index": 2, "duration": 0.114}, {"index": 3, "duration": 0.341},
				{"index": 4, "duration": 0.569}, {"index": 5, "duration": 0.683}, {"index": 6, "duration": 1.0}
			], false),
			"charge": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "charge/", "rose_charge_f_", [{"index": 1, "duration": 999.0}], true),
		},
		"dex": {
			"icon": "🌹",
			"intro": "月色浸透裙摆，蔷薇在暗处盛放——那是血的印记，也是狩猎的序曲。她无需疾行，暗影自会托举她的脚步；化作蝙蝠的瞬息，便是审判降临的宣告。血刃划破长夜，刀光如月华倾泻，将敌人送入永恒的寂静。\n\"今夜月色真美，适合凋零。\"\n特殊机制「嗜血」：造成伤害积蓄血渊（上限40），血渊自动疗伤（2秒1HP），满20可强化技能。",
			"stats": [{"label": "生命", "value": "90"}, {"label": "能量上限", "value": "100"}, {"label": "血渊上限", "value": "40"}],
			"skills": [
				{"name": "血刃（普通攻击）", "desc": "向前挥砍，造成 5 点伤害。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "血之月华（技能一）", "desc": "突进抓取敌人，身后留下刀光（10伤害）。血渊≥20 时强化，消耗 20 血渊。", "meta": "消耗：15 能 / 20 血渊 ｜ 冷却：8 秒"},
				{"name": "夜翼瞬袭（技能二）", "desc": "【常态】化身蝙蝠群向前突进吸附敌人造成伤害。\n【强化·血渊≥20】化身蝙蝠群自由飞行3秒，接近敌人造成持续伤害。", "meta": "常态：20能 / 12秒 ｜ 强化：30能 / 18秒"},
			{"name": "暗夜华尔兹（大招）", "desc": "技能设计中...", "meta": "消耗：100 能 ｜ 冷却：5 秒"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "血之月华", 480, 0, func(owner: Fighter): return (owner.energy >= 15 or owner.blood_abyss >= 20.0) and not owner.dashing, Callable(_skill1)),
		Skill.new("skill2", "夜翼瞬袭", 720, 0, func(owner: Fighter): return (owner.energy >= 20 or owner.blood_abyss >= 20.0) and not owner.dashing and not owner.rose_skill2_active, Callable(_skill2)),
		Skill.new("ult", "暗夜华尔兹", 600, 100, Callable(), Callable(_ult)),
	]

static func _is_blood_enhanced(owner: Fighter) -> bool:
	return owner.blood_abyss >= 20.0

static func _skill1(owner: Fighter) -> Dictionary:
	var enhanced = _is_blood_enhanced(owner)
	var skill = owner.get_skill("skill1")
	
	if enhanced:
		if owner.energy < 20 or owner.blood_abyss < 20.0:
			return {"success": false}
		owner.energy -= 20
		owner.blood_abyss -= 20.0
	else:
		if owner.energy < 15:
			return {"success": false}
		owner.energy -= 15
	
	var dir = owner.facing
	var slash_w = 220 if enhanced else 180
	var slash_damage = 15 if enhanced else 10
	
	# Start dash with grab (prevent default dash damage, handle in character_systems)
	owner.dashing = true
	owner.dash_remaining = 120
	owner.dash_dir = dir
	owner.dash_speed = 6.0
	owner.dash_damage_dealt = true  # Skip default dash damage, use grab logic
	owner.set_animation_state("skill1")
	
	if enhanced:
		# Schedule 4 sequential slashes (spawned in character_systems after dash)
		if skill: skill.cd = 900  # 15 second cooldown
		owner.rose_skill1_enhanced_slashes = [
			{"img": ROSE_ENH_SLASH1, "timer": 80},
			{"img": ROSE_ENH_SLASH2, "timer": 80},
			{"img": ROSE_ENH_SLASH3, "timer": 80},
			{"img": ROSE_ENH_SLASH4, "timer": 80},
		]
		owner.rose_skill1_slash_spawn_timer = 0
	else:
		# Normal: create single slash trail behind the character
		var slash = {
			"x": owner.pos_x + (owner.w if dir == 1 else -slash_w),
			"y": owner.pos_y - 4,
			"w": slash_w,
			"h": owner.h + 8,
			"dir": dir,
			"hit_dealt": false,
			"timer": 60,  # 1 second
			"damage": slash_damage,
			"owner": owner,  # Track who created this slash
		}
		GameWorld.rose_slash_trails.append(slash)
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 30, Color(1.0, 0.1, 0.1), 5, 7, "star")
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	var enhanced = _is_blood_enhanced(owner)
	var skill = owner.get_skill("skill2")
	
	if enhanced:
		# Enhanced: bat swarm free flight (3s, 30 energy, 18s cd)
		owner.blood_abyss -= 20.0
		if skill: skill.cd = 1080  # 18 seconds
		owner.rose_skill2_active = true
		owner.rose_skill2_enhanced = true
		owner.rose_skill2_fly_timer = 180  # 3 seconds
		owner.rose_skill2_damage_tick = 0
		owner.rose_skill2_tick_damage = 20.0 / 15.0
		owner.is_invincible = true
		owner.set_animation_state("skill2_enhanced")
	else:
		# Normal: dash forward (1.2s, 20 energy, 12s cd)
		if owner.energy < 20:
			return {"success": false}
		owner.energy -= 20
		var dir = owner.facing
		var dash_dist = 180  # 2.5 speed * 72 frames
		owner.dashing = true
		owner.dash_remaining = dash_dist
		owner.dash_dir = dir
		owner.dash_speed = 2.5
		owner.dash_damage_dealt = true
		owner.is_invincible = true
		owner.rose_skill2_active = true
		owner.rose_skill2_enhanced = false
		owner.rose_skill2_damage_tick = 0
		owner.rose_skill2_tick_damage = 2.5
		owner.set_animation_state("skill2")
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 25, Color(0.6, 0.1, 0.6), 4, 6, "star")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "rose_ult":
			return {"success": false}
	
	var anim = FrameAnimation.load_from_frames(ROSE_ANI_DIR + "ult/", "rose_ult_f_", [
		{"index": 1, "duration": 0.797}, {"index": 2, "duration": 0.114}, {"index": 3, "duration": 0.341},
		{"index": 4, "duration": 0.569}, {"index": 5, "duration": 0.683}, {"index": 6, "duration": 1.0}
	], false)
	if anim.frames.is_empty():
		return {"success": false}
	anim.play()
	
	GameWorld.active_overlays.append({
		"anim": anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "rose_ult",
		"on_finish": func():
			owner.is_invincible = false
			owner.time_stop = false
			owner.time_stop_timer = 0
			owner.state = "idle"
	})
	
	owner.state = "ult"
	owner.image_state = "ult"
	owner.is_invincible = true
	owner.time_stop = true
	owner.time_stop_timer = int(anim.total_duration * 60)
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(0.9, 0.15, 0.15), 12, 16, "star", 2.0)
	return {"success": true}
