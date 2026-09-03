# 圣骑士 (paladin)
class_name PaladinCharacter

const PaladinComponent = preload("res://scripts/components/paladin_component.gd")

const PALADIN_ANI_DIR = "res://assets/char_ani/paladin/"
const PALADIN_WALK_FOOT_GAPS = preload("res://data/foot_gaps/paladin_walk_foot_gaps.gd")
const PALADIN_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/paladin_jump_foot_gaps.gd")
const PALADIN_CHARGE_FOOT_GAPS = preload("res://data/foot_gaps/paladin_charge_foot_gaps.gd")
const PALADIN_ULT_FOOT_GAPS = preload("res://data/foot_gaps/paladin_ult_foot_gaps.gd")

static func get_config() -> Dictionary:
	return {
		"id": "paladin", "name": "圣骑士", "hp": 120, "max_energy": 100, "energy_regen": 0,
		"speed": 2.1, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		# idle/attack 仍是单帧贴图（无锚点，走整帧缩放路径）；放大 1.5 倍与新的多帧动画观感对齐
		"image_scale": 1.9,
		"attack_image_scale": 1.9,
		"fields": {"divine_shield_active":false,"divine_shield_timer":0,"divine_shield_absorb":0.0,"holy_empower_active":false,"holy_empower_timer":0,"charging_skill1":false,"skill1_charge_time":0},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "idle/", "paladin_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk": FrameAnimation.load_from_sprite_sheet(PALADIN_ANI_DIR + "walk/sheet.png", 4, 3, 10, 0.1, true, _paladin_walk_anchors()),
			"jump": FrameAnimation.load_jump_sheet(PALADIN_ANI_DIR + "jump/sheet.png", 3, 2, 5, 0.2, _paladin_jump_anchors()),
			"attack": FrameAnimation.load_from_frames(PALADIN_ANI_DIR + "attack/", "paladin_attack_f_", [{"index": 1, "duration": 0.5}], false),
			"charge": FrameAnimation.load_from_sprite_sheet(PALADIN_ANI_DIR + "charge/sheet.png", 3, 3, 8, 0.1, true, _paladin_charge_anchors()),
			"ult": FrameAnimation.load_from_sprite_sheet(PALADIN_ANI_DIR + "ult/sheet.png", 5, 5, 24, 0.1, false, _paladin_ult_anchors(), Vector2i(1, 2)),
		},
		"dex": {
			"icon": "🛡️",
			"intro": "圣光铸就血肉，信仰化作城墙。每一道伤痕都是新的冠冕，每一次冲击都被转化为前行的力量——他站在这里，不是为了进攻，而是为了证明，什么是无法逾越的。敌人的猛攻，不过是为他加冕的礼炮。\n\"你的攻击不错，但我的信仰，比你的刀刃更坚硬。\"",
			"stats": [{"label": "生命", "value": "120"}, {"label": "圣光值（能量）", "value": "100"}],
			"skills": [
				{"name": "劈砍（普通攻击）", "desc": "向前劈砍，造成 5 点伤害。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "正义冲锋（技能一）", "desc": "长按蓄力，松开发动冲锋撞击敌人，蓄力越久冲刺越远（最大约 280 像素），造成 15 点伤害。冷却在蓄力结束后开始计算。", "meta": "消耗：无 ｜ 冷却：10 秒"},
				{"name": "神圣壁垒（技能二）", "desc": "生成持续 4 秒的无敌护盾，吸收所有伤害并以 1:3 比例转化为圣光值（能量）。期间可移动、跳跃、攻击。", "meta": "消耗：无 ｜ 冷却：12 秒"},
				{"name": "圣佑（大招）", "desc": "需满圣光值释放。进入强化状态，伤害 +5，防御力 +50，免疫击飞，持续消耗圣光值（15 点 / 秒）。", "meta": "消耗：15 圣光 / 秒 ｜ 冷却：无"},
			]
		},
	}

## 锚点辅助函数：把 tools/import_more.py 生成的 foot_gaps 常量组装成 FrameAnimation 锚点数组
static func _build_anchors(foot: Array, head: Array, center: Array, cw: Array, ch: Array) -> Array:
	var anchors := []
	for i in range(foot.size()):
		anchors.append({
			"foot_gap": foot[i], "head_gap": head[i], "center_dx": center[i],
			"content_w": cw[i], "content_h": ch[i],
		})
	return anchors

static func _paladin_walk_anchors() -> Array:
	return _build_anchors(
		PALADIN_WALK_FOOT_GAPS.PALADIN_WALK_FOOT, PALADIN_WALK_FOOT_GAPS.PALADIN_WALK_HEAD,
		PALADIN_WALK_FOOT_GAPS.PALADIN_WALK_CENTER, PALADIN_WALK_FOOT_GAPS.PALADIN_WALK_CONTENT_W,
		PALADIN_WALK_FOOT_GAPS.PALADIN_WALK_CONTENT_H)

static func _paladin_jump_anchors() -> Array:
	return _build_anchors(
		PALADIN_JUMP_FOOT_GAPS.PALADIN_JUMP_FOOT, PALADIN_JUMP_FOOT_GAPS.PALADIN_JUMP_HEAD,
		PALADIN_JUMP_FOOT_GAPS.PALADIN_JUMP_CENTER, PALADIN_JUMP_FOOT_GAPS.PALADIN_JUMP_CONTENT_W,
		PALADIN_JUMP_FOOT_GAPS.PALADIN_JUMP_CONTENT_H)

static func _paladin_charge_anchors() -> Array:
	return _build_anchors(
		PALADIN_CHARGE_FOOT_GAPS.PALADIN_CHARGE_FOOT, PALADIN_CHARGE_FOOT_GAPS.PALADIN_CHARGE_HEAD,
		PALADIN_CHARGE_FOOT_GAPS.PALADIN_CHARGE_CENTER, PALADIN_CHARGE_FOOT_GAPS.PALADIN_CHARGE_CONTENT_W,
		PALADIN_CHARGE_FOOT_GAPS.PALADIN_CHARGE_CONTENT_H)

static func _paladin_ult_anchors() -> Array:
	return _build_anchors(
		PALADIN_ULT_FOOT_GAPS.PALADIN_ULT_FOOT, PALADIN_ULT_FOOT_GAPS.PALADIN_ULT_HEAD,
		PALADIN_ULT_FOOT_GAPS.PALADIN_ULT_CENTER, PALADIN_ULT_FOOT_GAPS.PALADIN_ULT_CONTENT_W,
		PALADIN_ULT_FOOT_GAPS.PALADIN_ULT_CONTENT_H)

static func _can_use_skill2(owner: Fighter) -> bool:
	var comp: PaladinComponent = owner.components.get_component("paladin") if owner.components else null
	return not owner.attacking and (not comp or not comp.divine_shield_active)

static func _can_use_ult(owner: Fighter) -> bool:
	var comp: PaladinComponent = owner.components.get_component("paladin") if owner.components else null
	return owner.energy >= owner.max_energy and not owner.attacking and (not comp or not comp.holy_empower_active)

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "正义冲锋", 600, 0, func(owner: Fighter): return owner.grounded and not owner.charging_skill1 and not owner.dashing, Callable(_skill1)),
		Skill.new("skill2", "神圣壁垒", 720, 0, Callable(_can_use_skill2), Callable(_skill2)),
		Skill.new("ult", "圣佑", 0, 0, Callable(_can_use_ult), Callable(_ult)),
	]

static func _skill1(owner: Fighter) -> Dictionary:
	owner.charging_skill1 = true
	owner.charge_start_time = Time.get_ticks_msec()
	owner.state = "idle"
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 16, Color(1.0,0.84,0.0), 3, 5, "star")
	return {"success": true, "needs_charge": true}

static func _skill2(owner: Fighter) -> Dictionary:
	var comp: PaladinComponent = owner.components.get_component("paladin") if owner.components else null
	if comp:
		comp.divine_shield_active = true
		comp.divine_shield_timer = 240
		comp.divine_shield_absorb = 0
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 40, Color(1.0,0.84,0.0), 6, 8, "star")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	var comp: PaladinComponent = owner.components.get_component("paladin") if owner.components else null
	if comp:
		comp.holy_empower_active = true
		comp.holy_empower_timer = 0
	owner.defense += 50.0  # 圣佑防御 +50（护甲公式等效减伤 50%）
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 120, Color(1.0,0.84,0.0), 14, 18, "star")
	return {"success": true}

## 输入处理（替代 input_handler.gd 中的 _input_paladin）
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var mx = 0
	if not owner.dashing:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if not owner.charging_skill1 and keys.up and owner.grounded:
			owner.vy = -10
			owner.grounded = false
		if keys.attack and not owner.charging_skill1 and owner.attack_cooldown <= 0 and not owner.attacking:
			owner.attacking = true
			owner.attack_timer = 30
			owner.attack_delay = 8
			owner.attack_hit_dealt = false
			owner.attack_cooldown = 60
			owner.state = "attack"
			keys.attack = false
		if keys.skill1 and not owner.charging_skill1 and owner.grounded:
			var s = owner.get_skill("skill1")
			if s:
				s.try_use(owner)
		if not keys.skill1 and owner.charging_skill1:
			_release_paladin_charge(owner)
		if keys.skill2:
			var s = owner.get_skill("skill2")
			if s:
				var r = s.try_use(owner)
				if r.get("success"):
					keys.skill2 = false
		if keys.ult:
			var s = owner.get_skill("ult")
			if s:
				var r = s.try_use(owner)
				if r.get("success"):
					keys.ult = false
		var ms = 1.2 * 2.1 if owner.charging_skill1 else 2.1
		if not owner.has_status("frozen"):
			owner.vx += mx * (0.3 if owner.charging_skill1 else 0.25)
			if absf(owner.vx) > ms:
				owner.vx = ms * signf(owner.vx)
		Fighter.update_state(owner, mx)
	return mx

## 释放圣骑士蓄力
static func _release_paladin_charge(owner: Fighter):
	if not owner.charging_skill1:
		return
	var ct = (Time.get_ticks_msec() - owner.charge_start_time) / 1000.0
	var dist = (100 + minf(ct, 2.0) * 150) * 0.7
	var d = owner.facing if owner.facing != 0 else 1
	owner.charging_skill1 = false
	owner.state = "idle"
	owner.dashing = true
	owner.dash_remaining = dist
	owner.dash_dir = d
	owner.dash_speed = 4.2
	owner.dash_damage_dealt = false
	var s1 = owner.get_skill("skill1")
	if s1:
		s1.cd = s1.cooldown

#FIXED BUG: 圣骑士一技能正义冲锋结束后charge贴图不重置,因为之前完全没有update_systems
#修复:冲刺+蓄力都结束后清空image_state,下一帧apply_physics自动恢复idle/walk
static func update_systems(f: Fighter):
	if f.hp <= 0: return
	# 多帧 sheet 动画需要每帧 update 才能换帧（paladin 于 2026-09-03 换用多帧 sheet 后必须推进）
	if f.current_anim and f.current_anim.is_playing():
		f.current_anim.update(1.0)
	# ── 绘制注入 ──
	f.hud_resource_color = Color(1.0, 0.843, 0.0)  # 能量条金色
	var comp = f.components.get_component("paladin") if f.components else null
	if comp and (comp.divine_shield_active or comp.holy_empower_active):
		f.state_flags["paladin_aura"] = {
			"shield_alpha": 0.32 if comp.divine_shield_active else 0.24,
			"holy_active": comp.holy_empower_active
		}
	else:
		f.state_flags.erase("paladin_aura")
	# AI 自动释放蓄力：最大蓄力 2 秒后自动冲锋
	if f.charging_skill1:
		var ct = (Time.get_ticks_msec() - f.charge_start_time) / 1000.0
		if ct >= 2.0:
			_release_paladin_charge(f)
	if not f.dashing and not f.charging_skill1 and f.image_state == "charge":
		f.image_state = ""
#FIX END

## 体系统：圣骑士状态分类（技能打断优先级）
static func body_priority(f: Fighter) -> int:
	var comp: PaladinComponent = f.components.get_component("paladin") if f.components else null
	if comp and comp.holy_empower_active:
		return Fighter.BODY_ARMOR  # 圣佑 = 霸体
	if f.charging_skill1:
		return Fighter.BODY_SKILL  # 正义冲锋蓄力
	if comp and comp.divine_shield_active:
		return Fighter.BODY_SKILL  # 神圣壁垒 = 防御类技能体
	return -1

## 防御/招架类：神圣壁垒免疫打断
static func is_defense_parry(f: Fighter) -> bool:
	var comp: PaladinComponent = f.components.get_component("paladin") if f.components else null
	return comp != null and comp.divine_shield_active
