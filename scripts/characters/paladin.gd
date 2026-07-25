# 圣骑士 (paladin)
class_name PaladinCharacter

const PALADIN_ANI_DIR = "res://assets/char_ani/paladin/"

static func get_config() -> Dictionary:
	return {
		"id": "paladin", "name": "圣骑士", "hp": 120, "max_energy": 100, "energy_regen": 0,
		"speed": 2.1, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 68,
		"fields": {"divine_shield_active":false,"divine_shield_timer":0,"divine_shield_absorb":0.0,"holy_empower_active":false,"holy_empower_timer":0,"charging_skill1":false,"skill1_charge_time":0},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "idle/", "paladin_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "walk/", "paladin_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "jump/", "paladin_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "attack/", "paladin_attack_f_", [{"index": 1, "duration": 2.0}], false),
			"charge": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "charge/", "paladin_charge_f_", [{"index": 1, "duration": 999.0}], true),
			"ult": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "ult/", "paladin_ult_f_", [{"index": 1, "duration": 3.0}], false),
		},
		"dex": {
			"icon": "🛡️",
			"intro": "圣光铸就血肉，信仰化作城墙。每一道伤痕都是新的冠冕，每一次冲击都被转化为前行的力量——他站在这里，不是为了进攻，而是为了证明，什么是无法逾越的。敌人的猛攻，不过是为他加冕的礼炮。\n\"你的攻击不错，但我的信仰，比你的刀刃更坚硬。\"",
			"stats": [{"label": "生命", "value": "120"}, {"label": "圣光值（能量）", "value": "100"}],
			"skills": [
				{"name": "劈砍（普通攻击）", "desc": "向前劈砍，造成 5 点伤害。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "正义冲锋（技能一）", "desc": "长按蓄力，松开发动冲锋撞击敌人，蓄力越久冲刺越远（最大约 400 像素），造成 15 点伤害。冷却在蓄力结束后开始计算。", "meta": "消耗：无 ｜ 冷却：10 秒"},
				{"name": "神圣壁垒（技能二）", "desc": "生成持续 4 秒的无敌护盾，吸收所有伤害并以 1:3 比例转化为圣光值（能量）。期间可移动、跳跃、攻击。", "meta": "消耗：无 ｜ 冷却：12 秒"},
				{"name": "圣佑（大招）", "desc": "需满圣光值释放。进入强化状态，伤害 +5，受伤减半，免疫击飞，持续消耗圣光值（15 点 / 秒）。", "meta": "消耗：15 圣光 / 秒 ｜ 冷却：无"},
			]
		},
		"ai_profile": {"ideal_range": [0, 130], "kite": false},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "正义冲锋", 600, 0, func(owner: Fighter): return owner.grounded and not owner.charging_skill1 and not owner.dashing, Callable(_skill1)),
		Skill.new("skill2", "神圣壁垒", 720, 0, func(owner: Fighter): return not owner.divine_shield_active, Callable(_skill2)),
		Skill.new("ult", "圣佑", 0, 0, func(owner: Fighter): return owner.energy >= owner.max_energy and not owner.holy_empower_active, Callable(_ult)),
	]

static func _skill1(owner: Fighter) -> Dictionary:
	owner.charging_skill1 = true
	owner.charge_start_time = Time.get_ticks_msec()
	owner.state = "idle"
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 16, Color(1.0,0.84,0.0), 3, 5, "star")
	return {"success": true, "needs_charge": true}

static func _skill2(owner: Fighter) -> Dictionary:
	owner.divine_shield_active = true
	owner.divine_shield_timer = 240
	owner.divine_shield_absorb = 0
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 40, Color(1.0,0.84,0.0), 6, 8, "star")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	owner.holy_empower_active = true
	owner.holy_empower_timer = 0
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 120, Color(1.0,0.84,0.0), 14, 18, "star")
	return {"success": true}
