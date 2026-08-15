# 血色蔷薇 (rose)
class_name RoseCharacter

const RoseComponent = preload("res://scripts/components/rose_component.gd")

const ROSE_SLASH_IMG = preload("res://assets/fx_rose_slash.png")
const ROSE_SKILL1_IMG = preload("res://assets/fx_rose_skill1.png")
const ROSE_ENH_SLASH1 = preload("res://assets/fx_rose_enh_slash1.png")
const ROSE_ENH_SLASH2 = preload("res://assets/fx_rose_enh_slash2.png")
const ROSE_ENH_SLASH3 = preload("res://assets/fx_rose_enh_slash3.png")
const ROSE_ENH_SLASH4 = preload("res://assets/fx_rose_enh_slash4.png")
const ROSE_ANI_DIR = "res://assets/char_ani/rose/"
const ROSE_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/rose_idle_foot_gaps.gd")
const ROSE_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/rose_jump_foot_gaps.gd")
const ROSE_WALK_FOOT_GAPS = preload("res://data/foot_gaps/rose_walk_foot_gaps.gd")
const ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS = preload("res://data/foot_gaps/rose_skill1_plus_bladeeffect_foot_gaps.gd")
const ROSE_SKILL2_FOOT_GAPS = preload("res://data/foot_gaps/rose_skill2_foot_gaps.gd")
const ROSE_SKILL2_PLUS_FOOT_GAPS = preload("res://data/foot_gaps/rose_skill2_plus_foot_gaps.gd")
const ROSE_ULT_FOOT_GAPS = preload("res://data/foot_gaps/rose_ult_foot_gaps.gd")

## 从预加载贴图创建单帧 FrameAnimation（用于角色变身等替换人物贴图的场景）
static func _single_frame_anim(tex: Texture2D, dur: float, loop: bool = false) -> FrameAnimation:
	var a = FrameAnimation.new()
	a.add_frame(tex, dur)
	a.loop = loop
	return a

static func get_config() -> Dictionary:
	return {
		"id": "rose", "name": "血色蔷薇", "hp": 90, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.25, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		"image_scale": 1.2,
		"fields": {},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "idle/sheet.png", 4, 4, 15, 0.1, true, _rose_idle_anchors()),
			"walk": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "walk/sheet.png", 4, 3, 10, 0.1, true, _rose_walk_anchors()),
			"jump": FrameAnimation.load_jump_sheet(ROSE_ANI_DIR + "jump/sheet.png", 2, 2, 4, 0.2, _rose_jump_anchors()),
			"attack": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "attack/", "rose_attack_f_", [{"index": 1, "duration": 0.5}], false),
			"skill1": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "skill1/", "rose_skill1_f_", [{"index": 1, "duration": 2.0}], false),
			"skill1_plus_bladeeffect": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill1_plus_bladeeffect/sheet.png", 4, 3, 11, 0.1, false, _rose_skill1_plus_bladeeffect_anchors()),
			"skill2": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill2/sheet.png", 3, 2, 6, 0.08, false, _rose_skill2_anchors()),
			"skill2_enhanced": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "skill2_enhanced/", "rose_skill2_enhanced_f_", [{"index": 1, "duration": 3.0}], false),
			"skill2_plus": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill2_plus/sheet.png", 4, 3, 11, 0.1, false, _rose_skill2_plus_anchors()),
			"ult": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "ult/sheet.png", 8, 7, 54, 0.1, false, _rose_ult_anchors()),
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
			{"name": "暗夜华尔兹（大招）", "desc": "展开血之领域，全屏暗红特效覆盖战场。释放期间蔷薇免疫一切伤害，时间近乎停滞，对敌人持续造成约 40 点总伤害。六段斩击过后，舞步终了，暗夜重归寂静。", "meta": "消耗：100 能 ｜ 冷却：5 秒"},
			]
		},
	}

## idle 动画锚点：把 GDScript 常量组装成 FrameAnimation 需要的字典数组
static func _rose_idle_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_IDLE_FOOT_GAPS.ROSE_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_IDLE_FOOT_GAPS.ROSE_IDLE_FOOT[i],
			"head_gap": ROSE_IDLE_FOOT_GAPS.ROSE_IDLE_HEAD[i],
			"center_dx": ROSE_IDLE_FOOT_GAPS.ROSE_IDLE_CENTER[i],
			"content_w": ROSE_IDLE_FOOT_GAPS.ROSE_IDLE_CONTENT_W[i],
			"content_h": ROSE_IDLE_FOOT_GAPS.ROSE_IDLE_CONTENT_H[i],
		})
	return anchors

## jump 动画锚点：同 _rose_idle_anchors 写法
static func _rose_jump_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_JUMP_FOOT_GAPS.ROSE_JUMP_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_JUMP_FOOT_GAPS.ROSE_JUMP_FOOT[i],
			"head_gap": ROSE_JUMP_FOOT_GAPS.ROSE_JUMP_HEAD[i],
			"center_dx": ROSE_JUMP_FOOT_GAPS.ROSE_JUMP_CENTER[i],
			"content_w": ROSE_JUMP_FOOT_GAPS.ROSE_JUMP_CONTENT_W[i],
			"content_h": ROSE_JUMP_FOOT_GAPS.ROSE_JUMP_CONTENT_H[i],
		})
	return anchors

## walk 动画锚点：同 _rose_idle_anchors 写法
static func _rose_walk_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_WALK_FOOT_GAPS.ROSE_WALK_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_WALK_FOOT_GAPS.ROSE_WALK_FOOT[i],
			"head_gap": ROSE_WALK_FOOT_GAPS.ROSE_WALK_HEAD[i],
			"center_dx": ROSE_WALK_FOOT_GAPS.ROSE_WALK_CENTER[i],
			"content_w": ROSE_WALK_FOOT_GAPS.ROSE_WALK_CONTENT_W[i],
			"content_h": ROSE_WALK_FOOT_GAPS.ROSE_WALK_CONTENT_H[i],
		})
	return anchors

## skill1_plus_bladeeffect 动画锚点：同 _rose_idle_anchors 写法
static func _rose_skill1_plus_bladeeffect_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS.ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS.ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT[i],
			"head_gap": ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS.ROSE_SKILL1_PLUS_BLADEEFFECT_HEAD[i],
			"center_dx": ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS.ROSE_SKILL1_PLUS_BLADEEFFECT_CENTER[i],
			"content_w": ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS.ROSE_SKILL1_PLUS_BLADEEFFECT_CONTENT_W[i],
			"content_h": ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS.ROSE_SKILL1_PLUS_BLADEEFFECT_CONTENT_H[i],
		})
	return anchors

## skill2 动画锚点：同 _rose_idle_anchors 写法
static func _rose_skill2_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_SKILL2_FOOT_GAPS.ROSE_SKILL2_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_SKILL2_FOOT_GAPS.ROSE_SKILL2_FOOT[i],
			"head_gap": ROSE_SKILL2_FOOT_GAPS.ROSE_SKILL2_HEAD[i],
			"center_dx": ROSE_SKILL2_FOOT_GAPS.ROSE_SKILL2_CENTER[i],
			"content_w": ROSE_SKILL2_FOOT_GAPS.ROSE_SKILL2_CONTENT_W[i],
			"content_h": ROSE_SKILL2_FOOT_GAPS.ROSE_SKILL2_CONTENT_H[i],
		})
	return anchors

## skill2_plus 动画锚点：同 _rose_idle_anchors 写法
static func _rose_skill2_plus_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_SKILL2_PLUS_FOOT_GAPS.ROSE_SKILL2_PLUS_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_SKILL2_PLUS_FOOT_GAPS.ROSE_SKILL2_PLUS_FOOT[i],
			"head_gap": ROSE_SKILL2_PLUS_FOOT_GAPS.ROSE_SKILL2_PLUS_HEAD[i],
			"center_dx": ROSE_SKILL2_PLUS_FOOT_GAPS.ROSE_SKILL2_PLUS_CENTER[i],
			"content_w": ROSE_SKILL2_PLUS_FOOT_GAPS.ROSE_SKILL2_PLUS_CONTENT_W[i],
			"content_h": ROSE_SKILL2_PLUS_FOOT_GAPS.ROSE_SKILL2_PLUS_CONTENT_H[i],
		})
	return anchors

## ult 动画锚点：同 _rose_idle_anchors 写法
static func _rose_ult_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_ULT_FOOT_GAPS.ROSE_ULT_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_ULT_FOOT_GAPS.ROSE_ULT_FOOT[i],
			"head_gap": ROSE_ULT_FOOT_GAPS.ROSE_ULT_HEAD[i],
			"center_dx": ROSE_ULT_FOOT_GAPS.ROSE_ULT_CENTER[i],
			"content_w": ROSE_ULT_FOOT_GAPS.ROSE_ULT_CONTENT_W[i],
			"content_h": ROSE_ULT_FOOT_GAPS.ROSE_ULT_CONTENT_H[i],
		})
	return anchors

static func handle_input(p: Fighter, keys: Dictionary) -> int:
	var comp: RoseComponent = p.components.get_component("rose") if p.components else null
	# 强化一技能播片期间锁定所有操作
	if comp and comp.rose_skill1_enhanced_slashes.size() > 0:
		return 0
	var rose_skill2_enhanced = comp.rose_skill2_enhanced if comp else false
	if rose_skill2_enhanced:
		var jx = 0.0; var jy = 0.0
		if keys.left: jx -= 1.0
		if keys.right: jx += 1.0
		if keys.up: jy -= 1.0
		if keys.down: jy += 1.0
		if jx != 0 or jy != 0:
			GameWorld.rose_joystick_dir = Vector2(jx, jy).normalized()
		else:
			GameWorld.rose_joystick_dir = Vector2.ZERO
		Fighter.apply_movement(p, 0, 2.25)
		Fighter.update_state(p, 0)
		return 0
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and p.grounded: p.vy = -10; p.grounded = false
	if keys.attack and p.attack_cooldown <= 0 and not p.attacking:
		p.attacking = true; p.attack_timer = 30; p.attack_delay = 8
		p.attack_hit_dealt = false; p.attack_cooldown = 60; p.state = "attack"
		keys.attack = false
	if keys.skill1 and not p.dashing:
		var s = p.get_skill("skill1")
		if s: var r = s.try_use(p); if r.get("success"): keys.skill1 = false
	if keys.skill2 and not p.dashing:
		var s = p.get_skill("skill2")
		if s: var r = s.try_use(p); if r.get("success"): keys.skill2 = false
	if keys.ult:
		var s = p.get_skill("ult")
		if s: var r = s.try_use(p); if r.get("success"): keys.ult = false
	Fighter.apply_movement(p, mx, 2.25)
	Fighter.update_state(p, mx)
	return mx

static func update_systems(f: Fighter):
	if f.hp <= 0: return
	# 动画帧推进（多帧 sprite-sheet 动画需要每帧 update 才能换帧）
	if f.current_anim and f.current_anim.is_playing():
		f.current_anim.update(1.0)
	# ── HUD 标签注入 ──
	f.hud_skill_labels = {"attack": "J 血刃", "skill1": "U 血之月华", "skill2": "I 夜翼瞬袭", "ult": "O 暗夜华尔兹"}
	var comp: RoseComponent = f.components.get_component("rose") if f.components else null
	if not comp: return
	
	# Ult: overlay damage
	var has_ult_overlay = false
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "rose_ult":
			has_ult_overlay = true
			break
	if has_ult_overlay and GameWorld.frame % 16 == 0:
		#FIXED BUG: 大招原伤偏高,调整为40总伤害(每16帧3.0,约13跳≈39)
		var target = GameWorld.get_opponent(f)
		if target and target.hp > 0:
			Fighter.apply_damage(target, 3.0, f, false, Color(0.9, 0.15, 0.15))
			Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 12, Color(0.9, 0.15, 0.15), 5, 7, "star", 0.8)
	# Skill2: bat swarm
	if comp.rose_skill2_active:
		f.image_state = "skill2"
		if comp.rose_skill2_enhanced:
			f.vx = 0; f.vy = 0
			var jd = GameWorld.rose_joystick_dir
			var fly_speed = 3.5
			f.pos_x = clampf(f.pos_x + jd.x * fly_speed, 10, 2390 - f.w)
			f.pos_y = clampf(f.pos_y + jd.y * fly_speed, 40, 380 - f.h)
			f.facing = 1 if jd.x >= 0 else (-1 if jd.x < 0 else f.facing)
			comp.rose_skill2_damage_tick += 1
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0:
				var dist = absf(enemy.pos_x + enemy.w/2 - f.pos_x - f.w/2)
				if dist < 80:
					if comp.rose_skill2_damage_tick >= 12:
						comp.rose_skill2_damage_tick = 0
						Fighter.apply_damage(enemy, comp.rose_skill2_tick_damage, f, false, Color(0.6, 0.1, 0.6))
			comp.rose_skill2_fly_timer -= 1
			if comp.rose_skill2_fly_timer <= 0:
				comp.rose_skill2_active = false
				comp.rose_skill2_enhanced = false
				Fighter.clear_invincible(f)
				f.image_state = ""
				GameWorld.rose_joystick_dir = Vector2.ZERO
		else:
			comp.rose_skill2_damage_tick += 1
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0:
				if f.get_hit_box().intersects(enemy.get_hit_box()):
					enemy.pos_x = f.pos_x + f.w * f.facing + f.facing * 4
					enemy.vy = 0
					if comp.rose_skill2_damage_tick >= 12:
						comp.rose_skill2_damage_tick = 0
						Fighter.apply_damage(enemy, comp.rose_skill2_tick_damage, f, true, Color(0.6, 0.1, 0.6))
						enemy.vy = 0
			if not f.dashing:
				comp.rose_skill2_active = false
				Fighter.clear_invincible(f)
				f.image_state = ""
	# Skill1: dash 阶段向前抓取（一次判定）
	elif f.dashing and f.image_state == "skill1" and not comp.rose_skill1_grab_done:
		var rx = f.pos_x if f.dash_dir > 0 else f.pos_x - 120
		var grab_rect = Rect2(rx, f.pos_y - 4, 120, f.h + 8)  # 与刀光拖尾同高
		var teleport_x = clampf(comp.rose_skill1_grab_pos_x, 20, 2380)
		if Fighter.grab_fighter_in_rect(f, grab_rect, teleport_x):
			print("[ROSE-GRAB] 向前抓取成功: frame=", GameWorld.frame)
			comp.rose_skill1_holding = true
		comp.rose_skill1_grab_done = true
	# 冲刺帧计时器：20f 后强制结束冲刺，Rose 静止
	if f.dashing and f.image_state == "skill1":
		comp.rose_dash_frame_timer -= 1
		if comp.rose_dash_frame_timer <= 0:
			f.dashing = false
			f.state = "idle"
			f.vx = 0
	# 非强化冲刺结束后清除 image_state
	if not f.dashing and f.image_state == "skill1" and comp.rose_skill1_enhanced_slashes.size() == 0:
		f.image_state = ""
	# Skill1 enhanced: 播片阶段持续抓取 + 向后判定 + 刀光生成
	if comp.rose_skill1_enhanced_slashes.size() > 0 or _has_active_enhanced_trails(f):
		var enemy = GameWorld.get_opponent(f)
		if enemy and enemy.hp > 0:
			if comp.rose_skill1_holding:
				# 持续锁定敌方位置（可放防御技能）
				Fighter.hold_fighter_in_place(enemy, comp.rose_skill1_grab_pos_x)
			else:
				# 向后判定：刀光区域抓取
				var slash_w = 220.0
				var slash_center = comp.rose_skill1_grab_pos_x
				var sx = slash_center - slash_w / 2.0
				var slash_rect = Rect2(sx, f.pos_y - 4, slash_w, f.h + 8)
				if slash_rect.intersects(enemy.get_hit_box()):
					var tp = clampf(slash_center, 20, 2380)
					if Fighter.grab_fighter_in_rect(f, slash_rect, tp):
						print("[ROSE-GRAB] 向后抓取成功: frame=", GameWorld.frame)
						comp.rose_skill1_holding = true
		# Rose 播片期锁定
		f.vx = 0
		f.vy = 0
		# 四连斩快速生成（0.25s/道）
		comp.rose_skill1_slash_spawn_timer += 1
		if comp.rose_skill1_slash_spawn_timer >= 15:
			comp.rose_skill1_slash_spawn_timer = 0
			var slash_data: Dictionary = comp.rose_skill1_enhanced_slashes.pop_front()
			var slash_img: Texture2D = slash_data.get("img")
			if slash_img:
				var slash_anim = _single_frame_anim(slash_img, 15.0 / 60.0)
				slash_anim.play()
				var slash_w = 220.0
				var slash_cx = comp.rose_skill1_grab_pos_x
				GameWorld.rose_slash_trails.append({
					"anim": slash_anim,
					"x": slash_cx - slash_w / 2.0,
					"y": f.pos_y - 4,
					"w": slash_w,
					"h": f.h + 8,
					"dir": f.facing,
					"hit_dealt": false,
					"timer": 15,
					"damage": 7.0,
					"owner": f,
				})
	# 常态抓取持续锁定：冲刺期间敌人被定身
	if comp.rose_skill1_holding and comp.rose_skill1_enhanced_slashes.size() == 0 and not _has_active_enhanced_trails(f) and f.dashing:
		var enemy = GameWorld.get_opponent(f)
		if enemy and enemy.hp > 0:
			Fighter.hold_fighter_in_place(enemy, comp.rose_skill1_grab_pos_x)
	# 释放抓取：常态冲刺结束后释放 | 强化刀光全部结束后释放
	if comp.rose_skill1_holding and comp.rose_skill1_enhanced_slashes.size() == 0 and not _has_active_enhanced_trails(f) and not f.dashing:
		comp.rose_skill1_holding = false

## 判断是否还有未消失的强化刀光拖尾
static func _has_active_enhanced_trails(f: Fighter) -> bool:
	for trail in GameWorld.rose_slash_trails:
		if trail.get("owner") == f and trail.has("anim"):
			return true
	return false

## 刀光拖尾更新 + 绘制回调注册（rose 专属，从 character_systems 移出）
static func update_rose_trails():
	var to_remove: Array = []
	for trail in GameWorld.rose_slash_trails:
		trail["timer"] -= 1
		var anim: FrameAnimation = trail.get("anim")
		if anim: anim.update(1.0)
		if trail["timer"] <= 0:
			to_remove.append(trail)
			continue
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
	# 注册/注销绘制回调（有拖尾就画，没就注销）
	if GameWorld.rose_slash_trails.is_empty():
		GameWorld.unregister_draw_effect("rose_slash_trails")
	else:
		GameWorld.register_draw_effect("rose_slash_trails", func(font, cam_x, _cam_y = 0.0):
			var items: Array = []
			for trail in GameWorld.rose_slash_trails:
				var tx = trail["x"] - cam_x
				if tx > -200 and tx < Constants.W + 200:
					var tex: Texture2D = null
					var trail_anim: FrameAnimation = trail.get("anim")
					if trail_anim:
						tex = trail_anim.get_current_texture()
					if not tex:
						tex = trail.get("img")
					if tex:
						var dir = trail.get("dir", 1)
						if dir < 0:
							items.append({"type": "set_transform", "pos": Vector2(tx + trail["w"], trail["y"] - _cam_y), "scale": Vector2(-1, 1)})
							items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, trail["w"], trail["h"]), "color": Color(1,1,1,0.85)})
							items.append({"type": "reset_transform"})
						else:
							items.append({"type": "tex", "tex": tex, "rect": Rect2(tx, trail["y"] - _cam_y, trail["w"], trail["h"]), "color": Color(1,1,1,0.85)})
			return items
		, 0)

static func _can_use_skill1(owner: Fighter) -> bool:
	var comp: RoseComponent = owner.components.get_component("rose") if owner.components else null
	var blood_abyss = comp.blood_abyss if comp else 0.0
	return (owner.energy >= 15 or blood_abyss >= 20.0) and not owner.dashing

static func _can_use_skill2(owner: Fighter) -> bool:
	var comp: RoseComponent = owner.components.get_component("rose") if owner.components else null
	var blood_abyss = comp.blood_abyss if comp else 0.0
	var rose_skill2_active = comp.rose_skill2_active if comp else false
	return (owner.energy >= 20 or blood_abyss >= 20.0) and not owner.dashing and not rose_skill2_active

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "血之月华", 480, 0, Callable(_can_use_skill1), Callable(_skill1)),
		Skill.new("skill2", "夜翼瞬袭", 720, 0, Callable(_can_use_skill2), Callable(_skill2)),
		Skill.new("ult", "暗夜华尔兹", 600, 100, Callable(), Callable(_ult)),
	]

static func _is_blood_enhanced(owner: Fighter) -> bool:
	var comp: RoseComponent = owner.components.get_component("rose") if owner.components else null
	return (comp.blood_abyss if comp else 0.0) >= 20.0

static func _skill1(owner: Fighter) -> Dictionary:
	var enhanced = _is_blood_enhanced(owner)
	var skill = owner.get_skill("skill1")
	var comp: RoseComponent = owner.components.get_component("rose") if owner.components else null
	
	if enhanced:
		if owner.energy < 20 or (not comp or comp.blood_abyss < 20.0):
			return {"success": false}
		owner.energy -= 20
		if comp:
			comp.blood_abyss -= 20.0
	else:
		if owner.energy < 15:
			return {"success": false}
		owner.energy -= 15
	
	var dir = owner.facing
	var slash_w = 220 if enhanced else 180
	var slash_damage = 15 if enhanced else 10
	
	# Start dash with grab (prevent default dash damage, handle in character_systems)
	owner.dashing = true
	owner.dash_remaining = 120  # DashSystem 每帧消耗 dash_speed(6)，实际 20f
	owner.dash_dir = dir
	owner.dash_speed = 6.0
	owner.dash_damage_dealt = true  # Skip default dash damage, use grab logic
	owner.set_animation_state("skill1")
	if comp:
		comp.rose_dash_frame_timer = 20  # 20f 冲刺后静止
		comp.rose_skill1_grab_done = false  # 重置向前判定
		comp.rose_skill1_holding = false    # 重置持续抓取
		comp.rose_skill1_grab_pos_x = owner.pos_x + dir * 60.0  # 冲刺轨迹中点
	
	# 冲刺轨迹中点（normal 刀光位置基准）
	var slash_center = comp.rose_skill1_grab_pos_x if comp else (owner.pos_x + dir * 60.0)
	
	if enhanced and comp:
		# Schedule 4 sequential slashes (spawned in character_systems after dash)
		if skill: skill.cd = 900  # 15 second cooldown
		comp.rose_skill1_enhanced_slashes = [
			{"img": ROSE_ENH_SLASH1, "timer": 80},
			{"img": ROSE_ENH_SLASH2, "timer": 80},
			{"img": ROSE_ENH_SLASH3, "timer": 80},
			{"img": ROSE_ENH_SLASH4, "timer": 80},
		]
		comp.rose_skill1_slash_spawn_timer = 0
	else:
		# Normal: create single slash trail at dash trajectory center
		var slash = {
			"x": slash_center - slash_w / 2.0,
			"y": owner.pos_y - 4,
			"w": slash_w,
			"h": owner.h + 8,
			"dir": dir,
			"hit_dealt": false,
			"timer": 60,  # 1 second
			"damage": slash_damage,
			"owner": owner,  # Track who created this slash
			"img": ROSE_SLASH_IMG
		}
		GameWorld.rose_slash_trails.append(slash)
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 30, Color(1.0, 0.1, 0.1), 5, 7, "star")
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	var enhanced = _is_blood_enhanced(owner)
	var skill = owner.get_skill("skill2")
	var comp: RoseComponent = owner.components.get_component("rose") if owner.components else null
	
	if enhanced and comp:
		# Enhanced: bat swarm free flight (3s, 30 energy, 18s cd)
		comp.blood_abyss -= 20.0
		if skill: skill.cd = 1080  # 18 seconds
		comp.rose_skill2_active = true
		comp.rose_skill2_enhanced = true
		comp.rose_skill2_fly_timer = 180  # 3 seconds
		comp.rose_skill2_damage_tick = 0
		comp.rose_skill2_tick_damage = 20.0 / 15.0
		Fighter.set_invincible(owner)  # 持续无敌直到技能结束
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
		Fighter.set_invincible(owner)  # 持续无敌直到技能结束
		if comp:
			comp.rose_skill2_active = true
			comp.rose_skill2_enhanced = false
			comp.rose_skill2_damage_tick = 0
			comp.rose_skill2_tick_damage = 2.5
		owner.set_animation_state("skill2")
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 25, Color(0.6, 0.1, 0.6), 4, 6, "star")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "rose_ult":
			return {"success": false}
	
	var anim = FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "ult/sheet.png", 8, 7, 54, 0.1, false, _rose_ult_anchors())
	if anim.frames.is_empty():
		return {"success": false}
	anim.play()
	
	var comp: RoseComponent = owner.components.get_component("rose") if owner.components else null
	
	GameWorld.active_overlays.append({
		"anim": anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "rose_ult",
		"on_finish": func():
			Fighter.clear_invincible(owner)
			if comp:
				comp.time_stop = false
				comp.time_stop_timer = 0
			owner.state_flags["time_stop"] = false
			owner.state = "idle"
	})
	
	owner.state = "ult"
	owner.image_state = "ult"
	Fighter.set_invincible(owner)  # 大招期间持续无敌
	if comp:
		comp.time_stop = true
		comp.time_stop_timer = int(anim.total_duration * 60)
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(0.9, 0.15, 0.15), 12, 16, "star", 2.0)
	return {"success": true}
