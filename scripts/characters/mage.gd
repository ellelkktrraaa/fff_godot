# 法师 (mage)
class_name MageCharacter

const PROJ_FIRE = preload("res://assets/fx_fire_projectile.png")
const PROJ_ICE = preload("res://assets/fx_ice_projectile.png")
const PROJ_LIGHT = preload("res://assets/fx_lightning_projectile.png")
const MAGE_ANI_DIR = "res://assets/char_ani/mage/"

static func get_config() -> Dictionary:
	return {
		"id": "mage", "name": "法师", "hp": 70, "max_energy": 120, "energy_regen": 0.07,
		"speed": 1.9, "attack_range": 30, "attack_damage": 0,
		"attack_cooldown": 120, "attack_delay": 0, "attack_duration": 30,
		"fields": {}, "world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_frames(MAGE_ANI_DIR + "idle/", "mage_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk": FrameAnimation.load_from_frames(MAGE_ANI_DIR + "walk/", "mage_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_from_frames(MAGE_ANI_DIR + "jump/", "mage_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(MAGE_ANI_DIR + "attack/", "mage_attack_f_", [{"index": 1, "duration": 0.5}], false),
			"ult": FrameAnimation.load_from_frames(MAGE_ANI_DIR + "ult/", "mage_ult_f_", [{"index": 1, "duration": 3.0}], false),
			"charge": FrameAnimation.load_from_frames(MAGE_ANI_DIR + "attack/", "mage_attack_f_", [{"index": 1, "duration": 0.5}], true),
		},
		"dex": {
			"icon": "🔮",
			"intro": "指尖勾动元素洪流，咒语编织法则牢笼。他的目光穿透虚妄，每一道法术都是精心计算的毁灭——火焰跳舞，冰霜筑墙，雷电为鞭。在知识面前，蛮力不过是未开化的低语。\n\"要我教你，什么叫真正的秩序吗？\"",
			"stats": [{"label": "生命", "value": "70"}, {"label": "能量上限", "value": "120"}],
			"skills": [
				{"name": "火球（普通攻击）", "desc": "向前方发射一枚火球，造成 3 点伤害，命中后附加灼烧效果（持续 3 秒，每秒 0.5 点伤害）。", "meta": "消耗：10 能量 ｜ 冷却：2 秒"},
				{"name": "冰晶（技能一）", "desc": "向前方发射冰晶，造成 7 点直接伤害，并附加减速效果（持续 3 秒，移动速度降低 20%）。", "meta": "消耗：15 能量 ｜ 冷却：12 秒"},
				{"name": "护罩（技能二）", "desc": "生成一个持续 2 秒的护盾，期间免疫所有伤害，并回复所受伤害量 50% 的生命值。", "meta": "消耗：20 能量 ｜ 冷却：15 秒"},
				{"name": "光波蓄力（大招）", "desc": "长按大招键蓄力，松开后发射光波。蓄力时间越长，伤害和能量消耗越高：蓄力 1 秒内：伤害 20，消耗 40；1~3 秒：伤害 40，消耗 80；超过 3 秒：伤害 60，消耗 120。", "meta": "消耗：40~120 能量 ｜ 冷却：8 秒"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "冰晶", 720, 15, Callable(), Callable(_skill1)),
		Skill.new("skill2", "护罩", 900, 20, func(owner: Fighter): return not owner.shield_active, Callable(_skill2)),
		Skill.new("ult", "光波蓄力", 480, 0, Callable(), Callable(_ult)),
	]

static func _skill1(owner: Fighter) -> Dictionary:
	var dir = owner.facing
	var px = owner.pos_x + (owner.w if dir==1 else 0)
	var py = owner.pos_y + 30
	GameWorld.projectiles.append({"x":px-16,"y":py-12,"w":32,"h":24,"vx":4*dir,"vy":0,"life":150,"damage":7,"owner":owner,"type":"mage_ice","color":Color(0.4,0.8,1.0),"reflected":false,"slow":true,"img":PROJ_ICE,"priority":1})
	Fighter.emit_particles(px, py, 25, Color(0.4,0.8,1.0), 4, 6, "star")
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	owner.shield_active = true
	owner.shield_timer = 120
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 40, Color(0.53,0.87,1.0), 6, 8, "circle")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	return {"success": false}

## 输入处理（替代 input_handler.gd 中的 _input_mage）
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var mx = 0
	if not owner.charging:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if keys.up and owner.grounded and not owner.shield_active:
			owner.vy = -9
			owner.grounded = false
		if keys.attack and not owner.shield_active and owner.attack_cooldown <= 0 and not owner.attacking:
			if owner.energy >= 10:
				owner.energy -= 10
				owner.attacking = true
				owner.attack_timer = 30
				owner.attack_delay = 0
				owner.attack_hit_dealt = true
				owner.attack_cooldown = 120
				owner.state = "attack"
				var d = owner.facing
				var px2 = owner.pos_x + (owner.w if d == 1 else 0)
				var py2 = owner.pos_y + 30
				GameWorld.projectiles.append({"x":px2-16,"y":py2-12,"w":32,"h":24,"vx":3*d,"vy":0,"life":120,"damage":3,"owner":owner,"type":"mage_fire","color":Color(1,0.4,0),"reflected":false,"burn":true,"img":PROJ_FIRE})
			keys.attack = false
		if keys.skill1 and not owner.shield_active:
			var s = owner.get_skill("skill1")
			if s:
				var r = s.try_use(owner)
				if r.get("success"):
					keys.skill1 = false
		if keys.skill2 and not owner.shield_active:
			var s = owner.get_skill("skill2")
			if s:
				var r = s.try_use(owner)
				if r.get("success"):
					keys.skill2 = false
	var mage_ult = owner.get_skill("ult")
	if keys.ult and not owner.shield_active and not owner.charging and (not mage_ult or mage_ult.cd <= 0) and owner.energy >= 40:
		owner.charging = true
		owner.charge_start = Time.get_ticks_msec()
	if not keys.ult and owner.charging:
		var ct = (Time.get_ticks_msec() - owner.charge_start) / 1000.0
		var dmg = 20
		var cost = 40
		if ct > 3:
			dmg = 60
			cost = 120
		elif ct > 1:
			dmg = 40
			cost = 80
		if owner.energy >= cost:
			owner.energy -= cost
			var d = owner.facing
			var px2 = owner.pos_x + (owner.w if d == 1 else 0)
			var py2 = owner.pos_y + 30
			GameWorld.projectiles.append({"x":px2-20,"y":py2-15,"w":40,"h":30,"vx":4*d,"vy":0,"life":200,"damage":dmg,"owner":owner,"type":"mage_light","color":Color(1,1,0.27),"reflected":false,"img":PROJ_LIGHT})
			var ult = owner.get_skill("ult")
			if ult:
				ult.cd = ult.cooldown
		owner.charging = false
	Fighter.apply_movement(owner, mx, 2.25)
	Fighter.update_state(owner, mx)
	return mx

## 体系统：法师状态分类（技能打断优先级）
static func body_priority(f: Fighter) -> int:
	if f.charging:
		return Fighter.BODY_VAJRA  # 光波蓄力 = 大招释放
	if f.shield_active:
		return Fighter.BODY_SKILL  # 护罩 = 防御类技能体
	return -1
