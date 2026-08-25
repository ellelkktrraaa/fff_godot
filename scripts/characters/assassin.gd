# 刺客 (assassin)
class_name AssassinCharacter

const AssassinComponent = preload("res://scripts/components/assassin_component.gd")

const PROJ_SLASH2 = preload("res://assets/fx_assassin_slash.png")
const ASSASSIN_SLASH_SHEET = "res://assets/sheet.png"
const ASSASSIN_SKILL2_SHEET = "res://assets/sheet1.png"
const ASSASSIN_ANI_DIR = "res://assets/char_ani/assassin/"
const ASSASSIN_ULT_HEAD_FOOT_GAPS = preload("res://data/foot_gaps/assassin_ult_head_foot_gaps.gd")
const ASSASSIN_ULT_TAIL_FOOT_GAPS = preload("res://data/foot_gaps/assassin_ult_tail_foot_gaps.gd")
const ASSASSIN_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/assassin_idle_foot_gaps.gd")
const ASSASSIN_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/assassin_jump_foot_gaps.gd")
const ASSASSIN_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/assassin_attack_foot_gaps.gd")
const ASSASSIN_WALK_FOOT_GAPS = preload("res://data/foot_gaps/assassin_walk_foot_gaps.gd")

# 手感反馈
const SLASH_W := 150.0    # 普攻斩击动画绘制宽度（1.5 倍原 100）
const SLASH_H := 60.0     # 普攻斩击动画绘制高度（1.5 倍原 40）
const ATK_SHAKE := 5.0        # 普攻微弱震动强度
const ATK_SHAKE_DUR := 6      # 普攻微弱震动持续帧数
# 完美闪避演出常量见 assassin_component.gd（DODGE_SLOW_MO_* / DODGE_ZOOM*）
const SKILL2_SHAKE := 10.0   # 二技能释放震动强度（偏轻）
const SKILL2_SHAKE_DUR := 12 # 二技能释放震动持续帧数

static func get_config() -> Dictionary:
	return {
		"id": "assassin", "name": "刺客", "hp": 90, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.4, "attack_range": 50, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		"anim_scale": 0.8,
		"dash_image_scale": 2.0,  # 一瞬冲刺贴图放大2倍
		"skill_anim_states": ["skill2"],  # 技能动画：播放期间锁输入，受击可提前结束
		"fields": {"shadow_energy":0.0,"shadow_energy_max":5.0,"shadow_stance":false,"shadow_stance_timer":0,"shadow_energy_drain_rate":0.0104,"is_invincible":false,"invincible_timer":0,"enhanced_slash":false,"enhanced_slash_timer":0,"slash_active":false,"slash_timer":0,"slash_x":0.0,"slash_y":0.0,"slash_facing":1,"slash_damage_dealt":false,"skill2_active":false,"skill2_timer":0,"skill2_x":0.0,"skill2_y":0.0,"skill2_facing":1,"skill2_damage_dealt":false,"ult_active":false,"ult_timer":0,"ult_damage_timer":0,"time_stop":false,"time_stop_timer":0,"dodge_success":false,"dodge_slow_mo":0,"shadow_trail":[],"max_shadow_trail":12},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "idle/sheet.png", 4, 4, 16, 0.1, true, _assassin_idle_anchors()),
			"walk": FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "walk/sheet.png", 4, 4, 15, 0.1, true, _assassin_walk_anchors()),
			"jump": FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "jump/sheet.png", 5, 4, 20, 0.1, true, _assassin_jump_anchors()),
			"attack": FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "attack/sheet.png", 4, 4, 13, 0.04, false, _assassin_attack_anchors()),
			"skill1": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "skill1/", "assassin_skill1_f_", [{"index": 1, "duration": 0.5}], false),
			"skill2": FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "skill2/sheet.png", 4, 4, 13, 0.04, false, _assassin_attack_anchors()),
			"ult": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "ult/", "assassin_ult_f_", [
				{"index": 0, "duration": 0.2}, {"index": 1, "duration": 0.2}, {"index": 2, "duration": 0.2},
				{"index": 3, "duration": 0.2}, {"index": 4, "duration": 0.2}, {"index": 5, "duration": 0.2},
				{"index": 6, "duration": 0.2}, {"index": 7, "duration": 0.2}, {"index": 8, "duration": 0.2},
				{"index": 9, "duration": 0.2}, {"index": 10, "duration": 0.2}, {"index": 11, "duration": 0.2},
				{"index": 12, "duration": 0.2}, {"index": 13, "duration": 0.2}
			], false),
			"charge": FrameAnimation.load_from_frames(ASSASSIN_ANI_DIR + "charge/", "assassin_charge_f_", [{"index": 1, "duration": 999.0}], true),
			"ult_head": FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "ult_head/sheet.png", 7, 7, 43, 0.1, false, _assassin_ult_head_anchors()),
			"ult_tail": FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "ult_tail/sheet.png", 3, 2, 6, 0.06, false, _assassin_ult_tail_anchors()),
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

## ult_head 动画锚点：把 GDScript 常量组装成 FrameAnimation 需要的字典数组
static func _assassin_ult_head_anchors() -> Array:
	var anchors: Array = []
	for i in range(ASSASSIN_ULT_HEAD_FOOT_GAPS.ASSASSIN_ULT_HEAD_FOOT.size()):
		anchors.append({
			"foot_gap": ASSASSIN_ULT_HEAD_FOOT_GAPS.ASSASSIN_ULT_HEAD_FOOT[i],
			"head_gap": ASSASSIN_ULT_HEAD_FOOT_GAPS.ASSASSIN_ULT_HEAD_HEAD[i],
			"center_dx": ASSASSIN_ULT_HEAD_FOOT_GAPS.ASSASSIN_ULT_HEAD_CENTER[i],
			"content_w": ASSASSIN_ULT_HEAD_FOOT_GAPS.ASSASSIN_ULT_HEAD_CONTENT_W[i],
			"content_h": ASSASSIN_ULT_HEAD_FOOT_GAPS.ASSASSIN_ULT_HEAD_CONTENT_H[i],
		})
	return anchors

## ult_tail 动画锚点：同 _assassin_ult_head_anchors 写法
static func _assassin_ult_tail_anchors() -> Array:
	var anchors: Array = []
	for i in range(ASSASSIN_ULT_TAIL_FOOT_GAPS.ASSASSIN_ULT_TAIL_FOOT.size()):
		anchors.append({
			"foot_gap": ASSASSIN_ULT_TAIL_FOOT_GAPS.ASSASSIN_ULT_TAIL_FOOT[i],
			"head_gap": ASSASSIN_ULT_TAIL_FOOT_GAPS.ASSASSIN_ULT_TAIL_HEAD[i],
			"center_dx": ASSASSIN_ULT_TAIL_FOOT_GAPS.ASSASSIN_ULT_TAIL_CENTER[i],
			"content_w": ASSASSIN_ULT_TAIL_FOOT_GAPS.ASSASSIN_ULT_TAIL_CONTENT_W[i],
			"content_h": ASSASSIN_ULT_TAIL_FOOT_GAPS.ASSASSIN_ULT_TAIL_CONTENT_H[i],
		})
	return anchors

## 待机动画锚点：同 _assassin_ult_head_anchors 写法
static func _assassin_idle_anchors() -> Array:
	var anchors: Array = []
	for i in range(ASSASSIN_IDLE_FOOT_GAPS.ASSASSIN_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": ASSASSIN_IDLE_FOOT_GAPS.ASSASSIN_IDLE_FOOT[i],
			"head_gap": ASSASSIN_IDLE_FOOT_GAPS.ASSASSIN_IDLE_HEAD[i],
			"center_dx": ASSASSIN_IDLE_FOOT_GAPS.ASSASSIN_IDLE_CENTER[i],
			"content_w": ASSASSIN_IDLE_FOOT_GAPS.ASSASSIN_IDLE_CONTENT_W[i],
			"content_h": ASSASSIN_IDLE_FOOT_GAPS.ASSASSIN_IDLE_CONTENT_H[i],
		})
	return anchors

## 跳跃动画锚点：同 _assassin_ult_head_anchors 写法
static func _assassin_jump_anchors() -> Array:
	var anchors: Array = []
	for i in range(ASSASSIN_JUMP_FOOT_GAPS.ASSASSIN_JUMP_FOOT.size()):
		anchors.append({
			"foot_gap": ASSASSIN_JUMP_FOOT_GAPS.ASSASSIN_JUMP_FOOT[i],
			"head_gap": ASSASSIN_JUMP_FOOT_GAPS.ASSASSIN_JUMP_HEAD[i],
			"center_dx": ASSASSIN_JUMP_FOOT_GAPS.ASSASSIN_JUMP_CENTER[i],
			"content_w": ASSASSIN_JUMP_FOOT_GAPS.ASSASSIN_JUMP_CONTENT_W[i],
			"content_h": ASSASSIN_JUMP_FOOT_GAPS.ASSASSIN_JUMP_CONTENT_H[i],
		})
	return anchors

## 普攻/二技能动画锚点：同 _assassin_ult_head_anchors 写法（两动画共用同一张 sheet）
static func _assassin_attack_anchors() -> Array:
	var anchors: Array = []
	for i in range(ASSASSIN_ATTACK_FOOT_GAPS.ASSASSIN_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": ASSASSIN_ATTACK_FOOT_GAPS.ASSASSIN_ATTACK_FOOT[i],
			"head_gap": ASSASSIN_ATTACK_FOOT_GAPS.ASSASSIN_ATTACK_HEAD[i],
			"center_dx": ASSASSIN_ATTACK_FOOT_GAPS.ASSASSIN_ATTACK_CENTER[i],
			"content_w": ASSASSIN_ATTACK_FOOT_GAPS.ASSASSIN_ATTACK_CONTENT_W[i],
			"content_h": ASSASSIN_ATTACK_FOOT_GAPS.ASSASSIN_ATTACK_CONTENT_H[i],
		})
	return anchors

## 移动动画锚点：同 _assassin_ult_head_anchors 写法
static func _assassin_walk_anchors() -> Array:
	var anchors: Array = []
	for i in range(ASSASSIN_WALK_FOOT_GAPS.ASSASSIN_WALK_FOOT.size()):
		anchors.append({
			"foot_gap": ASSASSIN_WALK_FOOT_GAPS.ASSASSIN_WALK_FOOT[i],
			"head_gap": ASSASSIN_WALK_FOOT_GAPS.ASSASSIN_WALK_HEAD[i],
			"center_dx": ASSASSIN_WALK_FOOT_GAPS.ASSASSIN_WALK_CENTER[i],
			"content_w": ASSASSIN_WALK_FOOT_GAPS.ASSASSIN_WALK_CONTENT_W[i],
			"content_h": ASSASSIN_WALK_FOOT_GAPS.ASSASSIN_WALK_CONTENT_H[i],
		})
	return anchors

static func _can_use_attack(owner: Fighter) -> bool:
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	return owner.attack_cooldown <= 0 and not owner.attacking and (not comp or not comp.ult_active)

static func _can_use_skill1(owner: Fighter) -> bool:
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	return not owner.dashing and not owner.attacking and (not comp or not comp.ult_active)

static func _can_use_skill2(owner: Fighter) -> bool:
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	return not owner.attacking and not owner.dashing and (not comp or (not comp.ult_active and not comp.skill2_active))

static func _can_use_ult(owner: Fighter) -> bool:
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	return not owner.attacking and not owner.dashing and (not comp or not comp.ult_active)

static func create_skills() -> Array:
	return [
		Skill.new("attack", "次元斩", 60, 0, Callable(_can_use_attack), Callable(_attack)),
		Skill.new("skill1", "一瞬", 0, 25, Callable(_can_use_skill1), Callable(_skill1)),
		Skill.new("skill2", "裂空斩", 780, 20, Callable(_can_use_skill2), Callable(_skill2)),
		Skill.new("ult", "天地灭尽", 0, 100, Callable(_can_use_ult), Callable(_ult)),
	]

static func _attack(owner: Fighter) -> Dictionary:
	owner.attacking = true
	owner.attack_timer = 30
	owner.attack_delay = 8
	owner.attack_hit_dealt = false
	owner.attack_cooldown = 60
	owner.state = "attack"
	# 普攻微弱震动（手感反馈）
	GameWorld.trigger_shake(ATK_SHAKE, ATK_SHAKE_DUR)
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	if comp:
		comp.slash_active = true
		comp.slash_timer = 30
		comp.slash_facing = owner.facing
		comp.slash_damage_dealt = false
		# 斩击动画：懒加载一次，每次攻击从头播放（14 帧 × 0.035s ≈ 0.5s 匹配斩击窗口）
		if comp.slash_anim == null:
			comp.slash_anim = FrameAnimation.load_from_sprite_sheet(ASSASSIN_SLASH_SHEET, 4, 4, 14, 0.035, false)
		comp.slash_anim.play()
		if comp.enhanced_slash and comp.enhanced_slash_timer > 0:
			comp.slash_x = owner.pos_x - (owner.facing * 40) + owner.w/2 - 50
			comp.slash_y = owner.pos_y + 10
		else:
			comp.slash_x = owner.pos_x + (owner.w if owner.facing>0 else -60) + 10
			comp.slash_y = owner.pos_y + 10
	return {"success": true}

static func _skill1(owner: Fighter) -> Dictionary:
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	if comp:
		comp.is_invincible = true
		comp.invincible_timer = 40
		comp.dodge_success = false
		comp.enhanced_slash = true
		comp.enhanced_slash_timer = 30
	owner.dashing = true
	owner.dash_remaining = 80
	owner.dash_dir = owner.facing
	owner.dash_speed = 5
	owner.dash_damage_dealt = true  # 一瞬是位移技，不造成伤害和击退
	owner.attack_cooldown = 0
	print("[DODGE-DEBUG] 一瞬释放: dashing=", owner.dashing, " is_invincible=", comp.is_invincible if comp else false, " invincible_timer=", comp.invincible_timer if comp else 0, " dash_remaining=", owner.dash_remaining)
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 20, Color(0.67,0.53,1.0), 4, 6, "star")
	return {"success": true}

## 二技能剑气动画：每道剑气独立的 FrameAnimation（循环播放），避免同角色对局共享帧状态
static func _make_skill2_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(ASSASSIN_SKILL2_SHEET, 4, 3, 10, 0.1, true)

static func _skill2(owner: Fighter) -> Dictionary:
	var dir = owner.facing
	var start_x = owner.pos_x + (owner.w if dir==1 else 0)
	var start_y = owner.pos_y + 20
	# 裂空斩（技能二）释放瞬间：中度屏幕震动
	GameWorld.trigger_shake(SKILL2_SHAKE, SKILL2_SHAKE_DUR)
	owner.set_animation_state("skill2")  # 二技能动画：播放一次，播完由 update_systems 回 idle
	# 剑气延迟 6 帧后生成（先存入组件，由 update_systems 计时生成）
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	if comp:
		comp.skill2_delay_timer = 6
		comp.skill2_pending = {"x":start_x,"y":start_y,"w":60,"h":30,"vx":8*dir,"vy":0,"life":240,"damage":15,"owner":owner,"type":"assassin_skill2","color":Color(0.53,0.27,0.8),"reflected":false,"piercing":true,"hit_targets":[],"img":_make_skill2_anim(),"priority":1}
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "assassin_ult":
			return {"success": false}
	
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	
	# 大招动画：先播 ult_head（43 帧），播完立即接 ult_tail（6 帧），合并为一段连续动画
	var head_anim = FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "ult_head/sheet.png", 7, 7, 43, 0.1, false, _assassin_ult_head_anchors())
	var tail_anim = FrameAnimation.load_from_sprite_sheet(ASSASSIN_ANI_DIR + "ult_tail/sheet.png", 3, 2, 6, 0.06, false, _assassin_ult_tail_anchors())
	var ult_anim := FrameAnimation.new()
	ult_anim.loop = false
	for f in head_anim.frames:
		ult_anim.add_frame(f.texture, f.duration_seconds, f.foot_gap, f.head_gap, f.center_dx, f.content_w, f.content_h)
	for f in tail_anim.frames:
		ult_anim.add_frame(f.texture, f.duration_seconds, f.foot_gap, f.head_gap, f.center_dx, f.content_w, f.content_h)
	if ult_anim.frames.is_empty():
		return {"success": false}
	ult_anim.total_duration = head_anim.total_duration + tail_anim.total_duration
	ult_anim.play()
	
	GameWorld.active_overlays.append({
		"anim": ult_anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "assassin_ult",
		"border_color": Color(0.53, 0.27, 0.8),
		"on_finish": func():
			if comp:
				comp.ult_active = false
				comp.time_stop = false
				comp.time_stop_timer = 0
			owner.state_flags["time_stop"] = false
			owner.state = "idle"
	})
	
	if comp:
		comp.ult_active = true
		comp.ult_timer = int(ult_anim.total_duration * 60)
		comp.ult_damage_timer = 0
		comp.time_stop = true
		comp.time_stop_timer = int(ult_anim.total_duration * 60)
	owner.state = "ult"
	owner.image_state = "ult"
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 120, Color(0.53, 0.27, 0.8), 14, 18, "star")
	return {"success": true}

## 输入处理（替代 input_handler.gd 中的 _input_assassin）
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var mx = 0
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	var skill2_active = comp.skill2_active if comp else false
	var ult_active = comp.ult_active if comp else false
	if not skill2_active:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if keys.up and owner.grounded:
			owner.vy = -10
			owner.grounded = false
	if keys.attack and not owner.attacking and owner.attack_cooldown <= 0 and not ult_active:
		var s = owner.get_skill("attack")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.attack = false
	if keys.skill1 and not owner.attacking and not ult_active and not owner.dashing:
		var s = owner.get_skill("skill1")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill1 = false
	if keys.skill2 and not owner.attacking and not ult_active and not owner.dashing:
		var s = owner.get_skill("skill2")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill2 = false
	if keys.ult and not owner.attacking and not ult_active and not owner.dashing:
		var s = owner.get_skill("ult")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.ult = false
	if not owner.has_status("frozen") and not owner.dashing and not ult_active and not skill2_active:
		owner.vx += mx * 0.25
		if absf(owner.vx) > 2.4:
			owner.vx = 2.4 * signf(owner.vx)
	elif skill2_active:
		owner.vx = 0
	Fighter.update_state(owner, mx)
	return mx

## 系统更新：动画帧推进 + 大招持续伤害 + 注册/注销绘制回调
static func update_systems(f: Fighter):
	# 动画帧推进（多帧 sheet 动画需要每帧 update 才能换帧）
	if f.current_anim and f.current_anim.is_playing():
		f.current_anim.update(1.0)
	var comp: AssassinComponent = f.components.get_component("assassin") if f.components else null
	if not comp:
		return
	# 二技能动画（非循环）播完自动回到普通状态
	if f.image_state == "skill2" and f.current_anim and f.current_anim.is_finished():
		f.set_animation_state("idle")
	# 二技能剑气延迟出现：释放后 6 帧生成
	if comp.skill2_delay_timer > 0:
		comp.skill2_delay_timer -= 1
		if comp.skill2_delay_timer <= 0 and not comp.skill2_pending.is_empty():
			GameWorld.projectiles.append(comp.skill2_pending)
			comp.skill2_pending = {}
	# 次元斩：活跃时推进斩击动画并注册绘制回调
	if comp.slash_active:
		var slash_anim: FrameAnimation = comp.slash_anim
		if slash_anim and slash_anim.is_playing():
			slash_anim.update(1.0)
		GameWorld.register_draw_effect(str(f.get_instance_id()) + "_slash", func(font, cam_x, _cam_y = 0.0):
			var items: Array = []
			var sx = comp.slash_x - cam_x
			if sx > -120 and sx < Constants.W + 120:
				var tex = slash_anim.get_current_texture() if slash_anim else null
				if tex:
					if comp.slash_facing < 0:
						items.append({"type": "set_transform", "pos": Vector2(sx + SLASH_W, comp.slash_y - _cam_y), "scale": Vector2(-1, 1)})
						items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, SLASH_W, SLASH_H), "color": Color(1,1,1,0.9)})
						items.append({"type": "reset_transform"})
					else:
						items.append({"type": "tex", "tex": tex, "rect": Rect2(sx, comp.slash_y - _cam_y, SLASH_W, SLASH_H), "color": Color(1,1,1,0.9)})
			return items
		, 0)
	else:
		GameWorld.unregister_draw_effect(str(f.get_instance_id()) + "_slash")
	# 暗影游走残影：活跃时注册绘制回调
	if comp.shadow_stance and comp.shadow_trail.size() > 0:
		GameWorld.register_draw_effect(str(f.get_instance_id()) + "_trail", func(font, cam_x, _cam_y = 0.0):
			var items: Array = []
			for trail in comp.shadow_trail:
				var tx = trail["x"] - cam_x
				if tx > -60 and tx < Constants.W + 60:
					var alpha = trail["life"] / 12.0
					if trail["facing"] < 0:
						items.append({"type": "set_transform", "pos": Vector2(tx + f.w, trail["y"] - _cam_y), "scale": Vector2(-1, 1)})
					else:
						items.append({"type": "set_transform", "pos": Vector2(tx, trail["y"] - _cam_y), "scale": Vector2.ONE})
					var anim = f.current_anim
					var trail_tex = anim.get_current_texture() if anim else null
					if trail_tex:
						items.append({"type": "tex", "tex": trail_tex, "rect": Rect2(0, 0, f.w, f.h), "color": Color(0.4, 0.27, 0.6, alpha * 0.5)})
					items.append({"type": "reset_transform"})
			return items
		, 1)
	else:
		GameWorld.unregister_draw_effect(str(f.get_instance_id()) + "_trail")
	# 冲刺回调注入：一瞬闪避（必须放在 ult 提前 return 之前，保证非大招时也注入路径检测）
	if f.dashing and comp.is_invincible:
		f.dash_step_callbacks = [func(old_x, new_x): _check_dodge_through_projectiles(f, old_x, new_x, comp)]
	else:
		f.dash_step_callbacks.clear()
	# 大招持续伤害
	if not comp.ult_active:
		return
	# 大招持续伤害：每 15 帧（0.25s）造成 3 点伤害，全程约 2.8s → ~ 33.6 点
	comp.ult_damage_timer += 1
	if comp.ult_damage_timer >= 15:
		comp.ult_damage_timer = 0
		Fighter.apply_ult_damage_zone(f, 3, Color(0.53, 0.27, 0.8))

# ── 刺客闪避（从 DashSystem 迁移至此）──
static func _check_dodge_through_projectiles(f: Fighter, old_x: float, new_x: float, comp: AssassinComponent):
	var top = f.pos_y + 4
	var bottom = f.pos_y + f.h - 4
	var path_x = minf(old_x, new_x)
	var path_w = absf(new_x - old_x) + f.w
	var path_rect = Rect2(path_x, top, path_w, bottom - top)
	for p in GameWorld.projectiles:
		var owner = p.get("owner")
		if owner == null or owner == f: continue
		var opp = GameWorld.get_opponent(f)
		if owner != opp: continue
		var proj_rect = Rect2(p["x"], p["y"], p["w"], p["h"])
		if path_rect.intersects(proj_rect):
			if not comp.dodge_success:
				comp.dodge_success = true
				comp.dodge_slow_mo = 30
				comp.shadow_energy = minf(comp.shadow_energy_max, comp.shadow_energy + 1)
				if comp.shadow_energy >= comp.shadow_energy_max and not comp.shadow_stance:
					comp.shadow_stance = true
					comp.shadow_stance_timer = 480
				# 完美闪避演出（时缓+拉近）由组件 update() 统一触发（无论哪条闪避路径先置位）
				Fighter.emit_particles(f.pos_x + f.w / 2.0, f.pos_y + f.h / 2.0, 15, Color(0.667, 0.533, 1.0), 3, 5, "star", 0.8)
				print("[DODGE-DEBUG] ★ 闪避触发（路径检测）！shadow_energy=", comp.shadow_energy, " dodge_slow_mo=", comp.dodge_slow_mo)
			break

## 体系统：刺客状态分类（技能打断优先级）
static func body_priority(f: Fighter) -> int:
	var comp: AssassinComponent = f.components.get_component("assassin") if f.components else null
	if comp and comp.ult_active:
		return Fighter.BODY_VAJRA  # 天地灭尽
	if f.image_state == "skill2":
		return Fighter.BODY_SKILL  # 裂空斩
	return -1
