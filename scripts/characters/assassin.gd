# 刺客 (assassin)
class_name AssassinCharacter

const PROJ_SLASH2 = preload("res://assets/54.png")
const ASSASSIN_ANI_DIR = "res://assets/char_ani/assassin/"

static func get_config() -> Dictionary:
	return {
		"id": "assassin", "name": "刺客", "hp": 90, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.4, "attack_range": 50, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		"fields": {"shadow_energy":0.0,"shadow_energy_max":5.0,"shadow_stance":false,"shadow_stance_timer":0,"shadow_energy_drain_rate":0.0104,"is_invincible":false,"invincible_timer":0,"enhanced_slash":false,"enhanced_slash_timer":0,"slash_active":false,"slash_timer":0,"slash_x":0.0,"slash_y":0.0,"slash_facing":1,"slash_damage_dealt":false,"skill2_active":false,"skill2_timer":0,"skill2_x":0.0,"skill2_y":0.0,"skill2_facing":1,"skill2_damage_dealt":false,"ult_active":false,"ult_timer":0,"ult_damage_timer":0,"time_stop":false,"time_stop_timer":0,"dodge_success":false,"dodge_slow_mo":0,"shadow_trail":[],"max_shadow_trail":12},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "idle/", "assassin_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "walk/", "assassin_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "jump/", "assassin_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "attack/", "assassin_attack_f_", [{"index": 1, "duration": 0.5}], false),
			"skill1": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "skill1/", "assassin_skill1_f_", [{"index": 1, "duration": 0.5}], false),
			"skill2": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "skill2/", "assassin_skill2_f_", [{"index": 1, "duration": 0.5}], false),
			"ult": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "ult/", "assassin_ult_f_", [
				{"index": 0, "duration": 0.2}, {"index": 1, "duration": 0.2}, {"index": 2, "duration": 0.2},
				{"index": 3, "duration": 0.2}, {"index": 4, "duration": 0.2}, {"index": 5, "duration": 0.2},
				{"index": 6, "duration": 0.2}, {"index": 7, "duration": 0.2}, {"index": 8, "duration": 0.2},
				{"index": 9, "duration": 0.2}, {"index": 10, "duration": 0.2}, {"index": 11, "duration": 0.2},
				{"index": 12, "duration": 0.2}, {"index": 13, "duration": 0.2}
			], false),
			"charge": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "charge/", "assassin_charge_f_", [{"index": 1, "duration": 999.0}], true),
		},
		"dex": {
			"icon": "🗡️",
			"intro": "刃光掠过，胜负已分。他不在光明中战斗，只在阴影里收割——每一次呼吸都可能是最后一击，每一次闪避都为下一次绝杀埋下伏笔。\n\"没有痛苦……一瞬间就会结束。\"",
			"stats": [{"label": "生命", "value": "90"}, {"label": "能量上限", "value": "100"}],
			"skills": [
				{"name": "次元斩（普通攻击）", "desc": "挥刀切割空间，在面前生成一道持续 0.5 秒的斩击，造成 5 点伤害。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "一瞬（技能一）", "desc": "向前瞬移一小段距离（速度 5），期间无敌。立即刷新次元斩冷却，并在 0.5 秒内强化下次次元斩——斩击出现在身后，伤害提升至 8 点，命中恢复 5 能量。", "meta": "消耗：15 能量 ｜ 冷却：无"},
				{"name": "裂空斩（技能二）", "desc": "斩出一道穿透一切的剑气（非飞行物），对路径上所有敌人造成 15 点伤害。释放时屏幕剧烈抖动。", "meta": "消耗：20 能量 ｜ 冷却：13 秒"},
				{"name": "天地灭尽（大招）", "desc": "斩出大面积刀光，持续 3 秒。期间时间停止，敌我双方无法行动，每 0.25 秒造成 2.5 点伤害（共约 30 点）。", "meta": "消耗：100 能量 ｜ 冷却：无"},
				{"name": "暗影游走（特殊机制）", "desc": "使用「一瞬」穿过敌人攻击时触发闪避，积攒 1 格暗影能量（共 5 格）。满格后进入暗影游走状态，移动留下残影，攻击有 50% 概率暴击（伤害 1.5 倍），持续消耗暗影能量，8 秒后耗尽。", "meta": "闪避成功恢复 1 格 ｜ 满格触发强化"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("attack", "次元斩", 60, 0, func(owner: Fighter): return owner.attack_cooldown <= 0 and not owner.attacking and not owner.ult_active, Callable(_attack)),
		Skill.new("skill1", "一瞬", 0, 25, func(owner: Fighter): return not owner.dashing and not owner.ult_active and not owner.attacking, Callable(_skill1)),
		Skill.new("skill2", "裂空斩", 780, 20, func(owner: Fighter): return not owner.attacking and not owner.ult_active and not owner.dashing, Callable(_skill2)),
		Skill.new("ult", "天地灭尽", 0, 100, func(owner: Fighter): return not owner.ult_active and not owner.attacking and not owner.dashing, Callable(_ult)),
	]

static func _attack(owner: Fighter) -> Dictionary:
	owner.attacking = true
	owner.attack_timer = 30
	owner.attack_delay = 8
	owner.attack_hit_dealt = false
	owner.attack_cooldown = 60
	owner.state = "attack"
	owner.slash_active = true
	owner.slash_timer = 30
	owner.slash_facing = owner.facing
	owner.slash_damage_dealt = false
	if owner.enhanced_slash and owner.enhanced_slash_timer > 0:
		owner.slash_x = owner.pos_x - (owner.facing * 40) + owner.w/2 - 50
		owner.slash_y = owner.pos_y + 10
		owner.enhanced_slash = false
		owner.enhanced_slash_timer = 0
	else:
		owner.slash_x = owner.pos_x + (owner.w if owner.facing>0 else -60) + 10
		owner.slash_y = owner.pos_y + 10
	return {"success": true}

static func _skill1(owner: Fighter) -> Dictionary:
	owner.is_invincible = true
	owner.invincible_timer = 20
	owner.dodge_success = false
	owner.dashing = true
	owner.dash_remaining = 80
	owner.dash_dir = owner.facing
	owner.dash_speed = 5
	owner.dash_damage_dealt = true  # 一瞬是位移技，不造成伤害和击退
	owner.attack_cooldown = 0
	owner.enhanced_slash = true
	owner.enhanced_slash_timer = 30
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 20, Color(0.67,0.53,1.0), 4, 6, "star")
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	var dir = owner.facing
	var start_x = owner.pos_x + (owner.w if dir==1 else 0)
	var start_y = owner.pos_y + 20
	GameWorld.projectiles.append({"x":start_x,"y":start_y,"w":60,"h":30,"vx":8*dir,"vy":0,"life":240,"damage":15,"owner":owner,"type":"assassin_skill2","color":Color(0.53,0.27,0.8),"reflected":false,"piercing":true,"hit_targets":[],"img":PROJ_SLASH2})
	# Screen shake
	GameWorld.screen_shake_intensity = 8.0
	GameWorld.screen_shake_duration = 12
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "assassin_ult":
			return {"success": false}
	
	var anim = FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "ult/", "assassin_ult_f_", [
		{"index": 0, "duration": 0.2}, {"index": 1, "duration": 0.2}, {"index": 2, "duration": 0.2},
		{"index": 3, "duration": 0.2}, {"index": 4, "duration": 0.2}, {"index": 5, "duration": 0.2},
		{"index": 6, "duration": 0.2}, {"index": 7, "duration": 0.2}, {"index": 8, "duration": 0.2},
		{"index": 9, "duration": 0.2}, {"index": 10, "duration": 0.2}, {"index": 11, "duration": 0.2},
		{"index": 12, "duration": 0.2}, {"index": 13, "duration": 0.2}
	], false)
	if anim.frames.is_empty():
		return {"success": false}
	anim.play()
	
	GameWorld.active_overlays.append({
		"anim": anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "assassin_ult",
		"on_finish": func():
			owner.ult_active = false
			owner.time_stop = false
			owner.time_stop_timer = 0
			owner.state = "idle"
	})
	
	owner.ult_active = true
	owner.ult_timer = int(anim.total_duration * 60)
	owner.ult_damage_timer = 0
	owner.time_stop = true
	owner.time_stop_timer = int(anim.total_duration * 60)
	owner.state = "ult"
	owner.image_state = "ult"
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 120, Color(0.53, 0.27, 0.8), 14, 18, "star")
	return {"success": true}
