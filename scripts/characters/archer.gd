# 弓箭手 (archer)
class_name ArcherCharacter

const ArcherComponent = preload("res://scripts/components/archer_component.gd")

const PROJ_ARROW = preload("res://assets/fx_arrow.png")
const PROJ_ARROW_FIRE = preload("res://assets/fx_arrow_fire.png")
const PROJ_ARROW_ULT = preload("res://assets/fx_arrow_ult.png")
const PROJ_ARROW_ULT_FIRE = preload("res://assets/fx_arrow_ult_fire.png")
const ARCHER_ANI_DIR = "res://assets/char_ani/archer/"
const ARCHER_ULT_FOOT_GAPS = preload("res://data/foot_gaps/archer_ult_foot_gaps.gd")
const ARCHER_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/archer_jump_foot_gaps.gd")
const ARCHER_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/archer_attack_foot_gaps.gd")
const ARCHER_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/archer_idle_foot_gaps.gd")
const ARCHER_WALK_FOOT_GAPS = preload("res://data/foot_gaps/archer_walk_foot_gaps.gd")

# 蓄力普攻演出
const FULL_CHARGE_TIME := 2.0    # 满力蓄力时间（秒），2s+ 为满力
const FULL_CHARGE_ZOOM_INC := 0.3  # 满力时镜头拉近增量（1.0 → 1.3，按蓄力程度渐进）

static func get_config() -> Dictionary:
	return {
		"id": "archer", "name": "弓箭手", "hp": 80, "max_energy": 100, "energy_regen": 0.07,
		"speed": 2.0, "attack_range": 0, "attack_damage": 0,
		"attack_cooldown": 0, "attack_delay": 0, "attack_duration": 0,
		"can_skill_while_attacking": true,
		"skill_anim_states": ["skill_ult"],  # 技能动画：播放期间锁输入，受击可提前结束
		"fields": {"arrows":10,"max_arrows":10,"arrow_regen_timer":0,"arrow_regen_rate":480,"fire_arrow_buff":false,"fire_arrow_timer":0,"tracking_buff":false,"tracking_timer":0,"charging_attack":false,"charge_start_time":0},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(ARCHER_ANI_DIR + "idle/sheet.png", 5, 5, 21, 0.1, true, _archer_idle_anchors()),
			"walk": FrameAnimation.load_from_sprite_sheet(ARCHER_ANI_DIR + "charge/sheet.png", 5, 4, 17, 0.1, true, _archer_walk_anchors()),
			"jump": FrameAnimation.load_from_sprite_sheet(ARCHER_ANI_DIR + "jump/sheet.png", 4, 4, 16, 0.1, true, _archer_jump_anchors()),
			"skill_attack": FrameAnimation.load_from_sprite_sheet(ARCHER_ANI_DIR + "attack/sheet.png", 5, 5, 22, 0.1, false, _archer_attack_anchors()),
			"skill_ult": FrameAnimation.load_from_sprite_sheet(ARCHER_ANI_DIR + "ult/sheet.png", 3, 2, 6, 0.1, false, _archer_ult_anchors()),
			"charge": FrameAnimation.load_from_frames(ARCHER_ANI_DIR + "charge/", "archer_charge_f_", [{"index": 1, "duration": 999.0}], true),
		},
		"dex": {
			"icon": "🏹",
			"intro": "箭羽无声，掠影无形。他的箭从不落空，就像风从不问方向——在你进入射程的那一刻，终点已被标记。距离是他的盟友，而你，只是靶心上的一个点。\n\"跑吧，我喜欢猎物挣扎的样子。\"",
			"stats": [{"label": "生命", "value": "80"}, {"label": "能量上限", "value": "100"}],
			"skills": [
				{"name": "射箭（普通攻击）", "desc": "长按蓄力，松开发射。蓄力时间影响伤害和能量消耗：0~1 秒：5 伤害 / 5 能量；1~2 秒：8 伤害 / 10 能量；2 秒以上：12 伤害 / 15 能量。可移动和跳跃。", "meta": "消耗：5~15 能量 ｜ 冷却：无"},
				{"name": "火矢（技能一）", "desc": "为射箭附加火焰效果，持续 7 秒。箭矢消失后产生一团火焰，对手站在火焰上每 0.5 秒受到 2 点伤害。", "meta": "消耗：20 能量 ｜ 冷却：15 秒"},
				{"name": "追踪（技能二）", "desc": "射出的箭矢具有轻微追踪效果，持续 10 秒。", "meta": "消耗：20 能量 ｜ 冷却：15 秒"},
				{"name": "箭雨（大招）", "desc": "从天上降下 20 支箭矢落在自身附近，每支造成 5 点伤害（受火矢加成，附带火焰效果）。", "meta": "消耗：100 能量 ｜ 冷却：8 秒"},
			]
		},
	}

## 大招动画锚点：把扫描生成的 GDScript 常量组装成 FrameAnimation 需要的字典数组
static func _archer_ult_anchors() -> Array:
	var anchors := []
	for i in range(ARCHER_ULT_FOOT_GAPS.ARCHER_ULT_FOOT.size()):
		anchors.append({
			"foot_gap": ARCHER_ULT_FOOT_GAPS.ARCHER_ULT_FOOT[i],
			"head_gap": ARCHER_ULT_FOOT_GAPS.ARCHER_ULT_HEAD[i],
			"center_dx": ARCHER_ULT_FOOT_GAPS.ARCHER_ULT_CENTER[i],
			"content_w": ARCHER_ULT_FOOT_GAPS.ARCHER_ULT_CONTENT_W[i],
			"content_h": ARCHER_ULT_FOOT_GAPS.ARCHER_ULT_CONTENT_H[i],
		})
	return anchors

## 跳跃动画锚点：同 _archer_ult_anchors 写法
static func _archer_jump_anchors() -> Array:
	var anchors := []
	for i in range(ARCHER_JUMP_FOOT_GAPS.ARCHER_JUMP_FOOT.size()):
		anchors.append({
			"foot_gap": ARCHER_JUMP_FOOT_GAPS.ARCHER_JUMP_FOOT[i],
			"head_gap": ARCHER_JUMP_FOOT_GAPS.ARCHER_JUMP_HEAD[i],
			"center_dx": ARCHER_JUMP_FOOT_GAPS.ARCHER_JUMP_CENTER[i],
			"content_w": ARCHER_JUMP_FOOT_GAPS.ARCHER_JUMP_CONTENT_W[i],
			"content_h": ARCHER_JUMP_FOOT_GAPS.ARCHER_JUMP_CONTENT_H[i],
		})
	return anchors

## 普攻动画锚点：同 _archer_jump_anchors 写法
static func _archer_attack_anchors() -> Array:
	var anchors := []
	for i in range(ARCHER_ATTACK_FOOT_GAPS.ARCHER_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": ARCHER_ATTACK_FOOT_GAPS.ARCHER_ATTACK_FOOT[i],
			"head_gap": ARCHER_ATTACK_FOOT_GAPS.ARCHER_ATTACK_HEAD[i],
			"center_dx": ARCHER_ATTACK_FOOT_GAPS.ARCHER_ATTACK_CENTER[i],
			"content_w": ARCHER_ATTACK_FOOT_GAPS.ARCHER_ATTACK_CONTENT_W[i],
			"content_h": ARCHER_ATTACK_FOOT_GAPS.ARCHER_ATTACK_CONTENT_H[i],
		})
	return anchors

## 待机动画锚点：同 _archer_jump_anchors 写法
static func _archer_idle_anchors() -> Array:
	var anchors := []
	for i in range(ARCHER_IDLE_FOOT_GAPS.ARCHER_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": ARCHER_IDLE_FOOT_GAPS.ARCHER_IDLE_FOOT[i],
			"head_gap": ARCHER_IDLE_FOOT_GAPS.ARCHER_IDLE_HEAD[i],
			"center_dx": ARCHER_IDLE_FOOT_GAPS.ARCHER_IDLE_CENTER[i],
			"content_w": ARCHER_IDLE_FOOT_GAPS.ARCHER_IDLE_CONTENT_W[i],
			"content_h": ARCHER_IDLE_FOOT_GAPS.ARCHER_IDLE_CONTENT_H[i],
		})
	return anchors

## 移动动画锚点：同 _archer_jump_anchors 写法
static func _archer_walk_anchors() -> Array:
	var anchors := []
	for i in range(ARCHER_WALK_FOOT_GAPS.ARCHER_WALK_FOOT.size()):
		anchors.append({
			"foot_gap": ARCHER_WALK_FOOT_GAPS.ARCHER_WALK_FOOT[i],
			"head_gap": ARCHER_WALK_FOOT_GAPS.ARCHER_WALK_HEAD[i],
			"center_dx": ARCHER_WALK_FOOT_GAPS.ARCHER_WALK_CENTER[i],
			"content_w": ARCHER_WALK_FOOT_GAPS.ARCHER_WALK_CONTENT_W[i],
			"content_h": ARCHER_WALK_FOOT_GAPS.ARCHER_WALK_CONTENT_H[i],
		})
	return anchors

static func handle_input(p: Fighter, keys: Dictionary) -> int:
	var mx = 0
	var comp: ArcherComponent = p.components.get_component("archer") if p.components else null
	var arrows = comp.arrows if comp else 10
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and p.grounded and not p.shield_active:
		p.vy = -10; p.grounded = false
	if keys.attack and not p.shield_active and arrows > 0 and not p.charging_attack:
		p.charging_attack = true; p.charge_start_time = Time.get_ticks_msec()
		p.attacking = true; p.attack_timer = 9999; p.state = "attack"
		p.set_animation_state("skill_attack")  # 普攻动画开始播放一次；播完定格末帧，蓄力期间不重复
	if not keys.attack and p.charging_attack:
		var ct = (Time.get_ticks_msec() - p.charge_start_time) / 1000.0
		var dmg: float; var cost: float
		if ct < 1: dmg = 5; cost = 5
		elif ct < 2: dmg = 8; cost = 10
		else: dmg = 12; cost = 15
		if p.energy >= cost and comp:
			p.energy -= cost; comp.arrows -= 1
			var d = p.facing; var px2 = p.pos_x + (p.w if d == 1 else 0); var py2 = p.pos_y  # 箭矢位置较原 pos_y+30 上移 30 像素
			var spd = minf(4 + ct * 2, 10)
			var c = Color(1,0.53,0) if comp.fire_arrow_buff else Color(0.67,0.67,0.67)
			var arr_img = ArcherCharacter.PROJ_ARROW_FIRE if comp.fire_arrow_buff else ArcherCharacter.PROJ_ARROW
			var tracking = comp.tracking_buff
			GameWorld.projectiles.append({"x":px2-16,"y":py2-10,"w":32,"h":20,"vx":spd*d,"vy":0,"life":120,"damage":dmg,"owner":p,"type":"arrow","color":c,"reflected":false,"is_fire":comp.fire_arrow_buff,"tracking":tracking,"trackingTarget":GameWorld.get_opponent(p),"img":arr_img})
		# 释放后立刻恢复镜头（蓄力渐进拉近结束）
		GameWorld.restore_camera_zoom()
		p.charging_attack = false; p.attacking = false; p.state = "idle"
	if keys.skill1 and not p.shield_active and not p.charging_attack:
		var s = p.get_skill("skill1"); if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
	if keys.skill2 and not p.shield_active and not p.charging_attack:
		var s = p.get_skill("skill2"); if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	if keys.ult and not p.shield_active and not p.charging_attack:
		var s = p.get_skill("ult"); if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
	var spd2 = 1.25 if p.charging_attack else 2.25
	Fighter.apply_movement(p, mx, spd2)
	Fighter.update_state(p, mx)
	return mx

static func _can_use_skill1(owner: Fighter) -> bool:
	var comp: ArcherComponent = owner.components.get_component("archer") if owner.components else null
	return not owner.attacking and (not comp or not comp.fire_arrow_buff)

static func _can_use_skill2(owner: Fighter) -> bool:
	var comp: ArcherComponent = owner.components.get_component("archer") if owner.components else null
	return not owner.attacking and (not comp or not comp.tracking_buff)

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "火矢", 900, 20, Callable(_can_use_skill1), Callable(_skill1)),
		Skill.new("skill2", "追踪", 900, 20, Callable(_can_use_skill2), Callable(_skill2)),
		Skill.new("ult", "箭雨", 480, 100, Callable(), Callable(_ult)),
	]

static func _skill1(owner: Fighter) -> Dictionary:
	var comp: ArcherComponent = owner.components.get_component("archer") if owner.components else null
	if comp:
		comp.fire_arrow_buff = true
		comp.fire_arrow_timer = 600
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 30, Color(1.0,0.27,0.0), 4, 6, "star")
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	var comp: ArcherComponent = owner.components.get_component("archer") if owner.components else null
	if comp:
		comp.tracking_buff = true
		comp.tracking_timer = 600
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 30, Color(0.27,0.87,1.0), 4, 6, "star")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	var comp: ArcherComponent = owner.components.get_component("archer") if owner.components else null
	var is_fire = comp.fire_arrow_buff if comp else false
	for i in 20:
		var angle = randf() * PI * 2
		var dist = randf() * 150
		var center_x = owner.pos_x + owner.w/2
		var tx = center_x + cos(angle) * dist
		var ult_img = PROJ_ARROW_ULT_FIRE if is_fire else PROJ_ARROW_ULT
		GameWorld.projectiles.append({"x":tx-16,"y":-30-randf()*50,"w":32,"h":20,"vx":(randf()-0.5)*0.5,"vy":3+randf()*2,"life":120,"damage":5,"owner":owner,"type":"arrow_ult","color":Color(0.8,0.53,0.0),"reflected":false,"img":ult_img,"is_fire":is_fire,"priority":3})
	owner.set_animation_state("skill_ult")  # 触发大招动画（skill 分支保持，播完由 update_systems 回 idle）
	return {"success": true}

## 每帧更新：动画帧推进（多帧 sheet 动画需要每帧 update 才能换帧）
static func update_systems(owner: Fighter):
	# 蓄力普攻镜头（仅玩家）：按蓄力程度渐进拉近，非蓄力立即恢复
	if owner.is_player:
		_update_charge_zoom(owner)
	# [TEMP-DEBUG] 排查跳跃动画只显示第一帧：jump 状态下每帧输出推进状态（诊断后删除）
	if owner.image_state == "jump":
		var a = owner.current_anim
		print("[DBG-JUMP] frame=", GameWorld.frame, " idx=", (a.get_current_index() if a else -1), "/", (a.frames.size() if a else 0), " timer=", (a._timer if a else -1.0), " playing=", (a.is_playing() if a else false), " loop=", (a.loop if a else false))
	if owner.current_anim and owner.current_anim.is_playing():
		owner.current_anim.update(1.0)
	# 大招动画（非循环）播完自动回到普通状态，避免卡在 ult 姿态
	if owner.image_state == "skill_ult" and owner.current_anim and owner.current_anim.is_finished():
		owner.set_animation_state("idle")

## 蓄力普攻镜头拉近（独立函数）：按蓄力程度渐进拉近（0→满力 1.0→1.3，以角色为中心）；
## 非蓄力（释放/打断/死亡）立即恢复
static func _update_charge_zoom(owner: Fighter) -> void:
	if owner.charging_attack:
		var ct = (Time.get_ticks_msec() - owner.charge_start_time) / 1000.0
		var prog = clampf(ct / FULL_CHARGE_TIME, 0.0, 1.0)
		GameWorld.zoom_character_centered(1.0 + FULL_CHARGE_ZOOM_INC * prog)
	elif GameWorld.camera_zoom != 1.0:
		GameWorld.restore_camera_zoom()

## AI 弓箭手射箭：直接创建箭矢投射物，绕过 handle_input 的按键模拟
static func ai_fire_arrow(owner: Fighter, charge_time: float):
	var comp: ArcherComponent = owner.components.get_component("archer") if owner.components else null
	if not comp or comp.arrows <= 0:
		owner.charging_attack = false; owner.attacking = false; owner.state = "idle"
		return
	var dmg: float; var cost: float
	if charge_time < 1.0: dmg = 5; cost = 5
	elif charge_time < 2.0: dmg = 8; cost = 10
	else: dmg = 12; cost = 15
	if owner.energy < cost:
		owner.charging_attack = false; owner.attacking = false; owner.state = "idle"
		return
	owner.energy -= cost; comp.arrows -= 1
	var d = owner.facing
	var px2 = owner.pos_x + (owner.w if d == 1 else 0)
	var py2 = owner.pos_y  # 箭矢位置较原 pos_y+30 上移 30 像素
	var spd = minf(4 + charge_time * 2, 10)
	var c = Color(1,0.53,0) if comp.fire_arrow_buff else Color(0.67,0.67,0.67)
	var arr_img = PROJ_ARROW_FIRE if comp.fire_arrow_buff else PROJ_ARROW
	var tracking = comp.tracking_buff
	GameWorld.projectiles.append({"x":px2-16,"y":py2-10,"w":32,"h":20,"vx":spd*d,"vy":0,"life":120,"damage":dmg,"owner":owner,"type":"arrow","color":c,"reflected":false,"is_fire":comp.fire_arrow_buff,"tracking":tracking,"trackingTarget":GameWorld.get_opponent(owner),"img":arr_img})
	owner.charging_attack = false; owner.attacking = false; owner.state = "idle"

## 体系统：弓箭手状态分类（技能打断优先级）
static func body_priority(f: Fighter) -> int:
	if f.image_state == "skill_ult":
		return Fighter.BODY_VAJRA  # 箭雨施放
	return -1  # 普攻蓄力 = 普攻体
