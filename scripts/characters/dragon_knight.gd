# 龙骑士 (dragon_knight)
class_name DragonKnightCharacter

const DK_ANI_DIR = "res://assets/char_ani/dragon_knight/"

static func get_config() -> Dictionary:
	return {
		"id": "dragon_knight", "name": "龙骑士", "hp": 110, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.15, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 68,
		"fields": {
			"dragon_scales_active": false,
			"dragon_scales_timer": 0,
			"dragon_form_active": false,
			"dragon_form_timer": 0,
		},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_frames(DK_ANI_DIR + "idle/", "dragon_knight_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk": FrameAnimation.load_from_frames(DK_ANI_DIR + "walk/", "dragon_knight_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_from_frames(DK_ANI_DIR + "jump/", "dragon_knight_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(DK_ANI_DIR + "attack/", "dragon_knight_attack_f_", [{"index": 1, "duration": 2.0}], false),
			"ult": FrameAnimation.load_from_frames(DK_ANI_DIR + "ult/", "dragon_knight_ult_f_", [{"index": 1, "duration": 3.0}], false),
		},
		"dex": {
			"icon": "🐉",
			"intro": "龙血在脉搏中燃烧，鳞片在日光下闪耀。他既是骑士，亦是龙裔——枪尖所指，烈焰所至。每一次吐息都是龙的低语，每一次冲锋都是天灾的预演。\n\"龙从不乞求胜利，只宣告毁灭。\"",
			"stats": [
				{"label": "生命", "value": "110"},
				{"label": "龙怒（能量）", "value": "100"},
			],
			"skills": [
				{"name": "龙爪（普通攻击）", "desc": "以龙爪之势挥击，造成 5 点伤害。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "龙息（技能一）", "desc": "向前方扇形范围喷吐龙焰，造成 12 点伤害并附加 3 秒灼烧效果（每秒 2 点伤害）。", "meta": "消耗：25 能量 ｜ 冷却：10 秒"},
				{"name": "龙鳞护体（技能二）", "desc": "龙鳞硬化，持续 3 秒内减免 40% 所受伤害。期间移动速度降低 30%。", "meta": "消耗：20 能量 ｜ 冷却：12 秒"},
				{"name": "龙化（大招）", "desc": "进入龙化形态，攻击力 +8，受伤减免 30%，免疫击退。持续消耗龙怒（10 点 / 秒），可随时再次按大招键取消。", "meta": "消耗：10 龙怒 / 秒 ｜ 冷却：无"},
			]
		},
		"ai_profile": {"ideal_range": [0, 140], "kite": false},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "龙息", 600, 25, func(owner: Fighter): return owner.grounded and not owner.dashing, Callable(_skill1)),
		Skill.new("skill2", "龙鳞护体", 720, 20, func(owner: Fighter): return not owner.dragon_scales_active, Callable(_skill2)),
		Skill.new("ult", "龙化", 0, 0, func(owner: Fighter): return owner.energy >= 30 or owner.dragon_form_active, Callable(_ult)),
	]

static func _skill1(owner: Fighter) -> Dictionary:
	# 龙息：向前方扇形范围喷火
	var breath_range = 130.0
	var dir = owner.facing
	var cx = owner.pos_x + owner.w / 2.0
	var cy = owner.pos_y + owner.h / 2.0
	var target = GameWorld.get_opponent(owner)
	if target and target.hp > 0:
		var tx = target.pos_x + target.w / 2.0
		var ty = target.pos_y + target.h / 2.0
		var dx = tx - cx
		var dy = ty - cy
		var dist = sqrt(dx * dx + dy * dy)
		if dist <= breath_range and (dx * dir) > 0:
			Fighter.apply_damage(target, 12, owner)
			# 附加灼烧效果 3秒，每秒2点伤害
			var burn = StatusEffect.new("burn")
			burn.tick_damage = 2.0
			target.statuses.append(burn)
			burn.apply(target)
	Fighter.emit_particles(cx + dir * 30, cy, 30, Color(1.0, 0.4, 0.1), 6, 8, "circle")
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	# 龙鳞护体：减伤40%，持续3秒
	owner.dragon_scales_active = true
	owner.dragon_scales_timer = 180
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 25, Color(0.8, 0.3, 0.1), 5, 7, "star")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	# 龙化：切换龙化形态
	if owner.dragon_form_active:
		# 取消龙化
		owner.dragon_form_active = false
		Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 30, Color(1.0, 0.3, 0.1), 6, 8, "circle")
		return {"success": true}
	else:
		# 激活龙化，消耗 30 能量
		owner.energy -= 30
		owner.dragon_form_active = true
		owner.dragon_form_timer = 0
		Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(1.0, 0.3, 0.1), 12, 16, "star")
		GameWorld.hit_stop = 12
		return {"success": true}
