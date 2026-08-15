# 刺客 (assassin)
class_name AssassinCharacter

const AssassinComponent = preload("res://scripts/components/assassin_component.gd")

const PROJ_SLASH2 = preload("res://assets/fx_assassin_slash.png")
const ASSASSIN_ANI_DIR = "res://assets/char_ani/assassin/"
const ASSASSIN_ULT_HEAD_FOOT_GAPS = preload("res://data/foot_gaps/assassin_ult_head_foot_gaps.gd")
const ASSASSIN_ULT_TAIL_FOOT_GAPS = preload("res://data/foot_gaps/assassin_ult_tail_foot_gaps.gd")

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
	var comp: AssassinComponent = owner.components.get_component("assassin") if owner.components else null
	if comp:
		comp.slash_active = true
		comp.slash_timer = 30
		comp.slash_facing = owner.facing
		comp.slash_damage_dealt = false
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

static func _skill2(owner: Fighter) -> Dictionary:
	var dir = owner.facing
	var start_x = owner.pos_x + (owner.w if dir==1 else 0)
	var start_y = owner.pos_y + 20
	#FIXED BUG: 裂空斩(技能二)需要屏幕抖动效果,使用GameWorld.set()绕过Godot4 autoload静态赋值限制
	GameWorld.set("screen_shake_intensity", 20.0)
	GameWorld.set("screen_shake_duration", 20)
	#FIX END
	# 裂空斩为飞行物：life=240（4 秒）持续飞行，穿透性攻击
	GameWorld.projectiles.append({"x":start_x,"y":start_y,"w":60,"h":30,"vx":8*dir,"vy":0,"life":240,"damage":15,"owner":owner,"type":"assassin_skill2","color":Color(0.53,0.27,0.8),"reflected":false,"piercing":true,"hit_targets":[],"img":PROJ_SLASH2})
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

## 系统更新：大招持续伤害 + 注册/注销绘制回调
static func update_systems(f: Fighter):
	var comp: AssassinComponent = f.components.get_component("assassin") if f.components else null
	if not comp:
		return
	# 次元斩：活跃时注册绘制回调
	if comp.slash_active:
		GameWorld.register_draw_effect(str(f.get_instance_id()) + "_slash", func(font, cam_x, _cam_y = 0.0):
			var items: Array = []
			var sx = comp.slash_x - cam_x
			if sx > -120 and sx < Constants.W + 120:
				var tex = preload("res://assets/fx_assassin_slash_ult.png")
				if comp.slash_facing < 0:
					items.append({"type": "set_transform", "pos": Vector2(sx + 100, comp.slash_y - _cam_y), "scale": Vector2(-1, 1)})
					items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, 100, 40), "color": Color(1,1,1,0.9)})
					items.append({"type": "reset_transform"})
				else:
					items.append({"type": "tex", "tex": tex, "rect": Rect2(sx, comp.slash_y - _cam_y, 100, 40), "color": Color(1,1,1,0.9)})
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
					if anim and anim.current_texture:
						items.append({"type": "tex", "tex": anim.current_texture, "rect": Rect2(0, 0, f.w, f.h), "color": Color(0.4, 0.27, 0.6, alpha * 0.5)})
					items.append({"type": "reset_transform"})
			return items
		, 1)
	else:
		GameWorld.unregister_draw_effect(str(f.get_instance_id()) + "_trail")
	# 大招持续伤害
	if not comp.ult_active:
		return
	# 每 15 帧（0.25s）造成 3 点伤害，全程约 2.8s → ~ 33.6 点
	comp.ult_damage_timer += 1
	if comp.ult_damage_timer >= 15:
		comp.ult_damage_timer = 0
		var target = GameWorld.get_opponent(f)
		if target and target.hp > 0:
			Fighter.apply_damage(target, 3, f, false, Color(0.53, 0.27, 0.8))
	# 冲刺回调注入：一瞬闪避
	if f.dashing and comp.is_invincible:
		f.dash_step_callbacks = [func(old_x, new_x): _check_dodge_through_projectiles(f, old_x, new_x, comp)]
	else:
		f.dash_step_callbacks.clear()

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
				Fighter.emit_particles(f.pos_x + f.w / 2.0, f.pos_y + f.h / 2.0, 15, Color(0.667, 0.533, 1.0), 3, 5, "star", 0.8)
				print("[DODGE-DEBUG] ★ 闪避触发（路径检测）！shadow_energy=", comp.shadow_energy, " dodge_slow_mo=", comp.dodge_slow_mo)
			break
