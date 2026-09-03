# 血色蔷薇 (rose)
class_name RoseCharacter

const RoseComponent = preload("res://scripts/components/rose_component.gd")

const ROSE_SKILL1_IMG = preload("res://assets/fx_rose_skill1.png")
const ROSE_ANI_DIR = "res://assets/char_ani/rose/"
const ROSE_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/rose_idle_foot_gaps.gd")
const ROSE_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/rose_jump_foot_gaps.gd")
const ROSE_WALK_FOOT_GAPS = preload("res://data/foot_gaps/rose_walk_foot_gaps.gd")
const ROSE_SKILL1_PLUS_BLADEEFFECT_FOOT_GAPS = preload("res://data/foot_gaps/rose_skill1_plus_bladeeffect_foot_gaps.gd")
const ROSE_SKILL2_FOOT_GAPS = preload("res://data/foot_gaps/rose_skill2_foot_gaps.gd")
const ROSE_SKILL2_PLUS_FOOT_GAPS = preload("res://data/foot_gaps/rose_skill2_plus_foot_gaps.gd")
const ROSE_ULT_FOOT_GAPS = preload("res://data/foot_gaps/rose_ult_foot_gaps.gd")
const ROSE_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/rose_attack_foot_gaps.gd")

static func get_config() -> Dictionary:
	return {
		"id": "rose", "name": "血色蔷薇", "hp": 90, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.25, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		"image_scale": 1.2,
		"skill_anim_states": ["skill2"],  # 技能动画：播放期间锁输入，受击可提前结束（skill1 动画2s远超冲刺时长、skill2_enhanced 需方向操控，均不锁）
		"fields": {},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "idle/sheet.png", 4, 4, 15, 0.1, true, _rose_idle_anchors()),
			"walk": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "walk/sheet.png", 4, 3, 10, 0.1, true, _rose_walk_anchors()),
			"jump": FrameAnimation.load_jump_sheet(ROSE_ANI_DIR + "jump/sheet.png", 2, 2, 4, 0.2, _rose_jump_anchors()),
			"attack": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "attack/sheet.png", 4, 3, 10, 0.05, false, _rose_attack_anchors(), Vector2i(2, 1)),
			"skill1": _rose_skill1_anim(),
			"skill1_plus_bladeeffect": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill1_plus_bladeeffect/sheet.png", 4, 3, 11, 0.1, false, _rose_skill1_plus_bladeeffect_anchors()),
			"skill2": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill2/sheet.png", 3, 2, 6, 0.08, false, _rose_skill2_anchors()),
			"skill2_enhanced": FrameAnimation.load_from_frames(ROSE_ANI_DIR + "skill2_enhanced/", "rose_skill2_enhanced_f_", [{"index": 1, "duration": 3.0}], false),
			"skill2_plus": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill2_plus/sheet.png", 4, 3, 11, 0.1, false, _rose_skill2_plus_anchors()),
			"ult": FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "ult/sheet.png", 8, 7, 54, 0.1, false, _rose_ult_anchors(), Vector2i(3, 2)),
			"charge": _rose_charge_anim(),
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

## attack 动画锚点：同 _rose_idle_anchors 写法（10 帧，格 1080x1080）
static func _rose_attack_anchors() -> Array:
	var anchors: Array = []
	for i in range(ROSE_ATTACK_FOOT_GAPS.ROSE_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": ROSE_ATTACK_FOOT_GAPS.ROSE_ATTACK_FOOT[i],
			"head_gap": ROSE_ATTACK_FOOT_GAPS.ROSE_ATTACK_HEAD[i],
			"center_dx": ROSE_ATTACK_FOOT_GAPS.ROSE_ATTACK_CENTER[i],
			"content_w": ROSE_ATTACK_FOOT_GAPS.ROSE_ATTACK_CONTENT_W[i],
			"content_h": ROSE_ATTACK_FOOT_GAPS.ROSE_ATTACK_CONTENT_H[i],
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
		# 出伤时机：普攻动画第 3 帧（斩击弧最宽处）→ 0.05s/帧 × 2 = 0.1s 起手 + 判定延迟对齐，attack_delay=9 ≈ 0.15s
		p.attacking = true; p.attack_timer = 30; p.attack_delay = 9
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
	
	# Ult: 六段斩击按动画帧出伤（亮像素峰值帧 22/29/39/46/47/48，0-based 索引 21/28/38/45/46/47）
	# 大招为全屏 overlay 时停，GameWorld.frame 冻结，不能按全局帧 tick；用动画当前帧索引驱动
	var has_ult_overlay = false
	var ult_anim: FrameAnimation = null
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "rose_ult":
			has_ult_overlay = true
			ult_anim = entry.get("anim")
			break
	if has_ult_overlay and ult_anim and comp.ult_hits.size() == 6:
		var target = GameWorld.get_opponent(f)
		if target and target.hp > 0:
			var slash_idx := [21, 28, 38, 45, 46, 47]
			var slash_dmg := [5.0, 5.0, 6.0, 7.0, 8.0, 8.0]  # 总 39，终结连斩更重
			var cur_idx: int = ult_anim.get_current_index()
			for s in range(6):
				if not comp.ult_hits[s] and cur_idx >= slash_idx[s]:
					comp.ult_hits[s] = true
					Fighter.apply_ult_damage_zone(f, slash_dmg[s], Color(0.9, 0.15, 0.15))
					Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 12, Color(0.9, 0.15, 0.15), 5, 7, "star", 0.8)
	# Skill2: bat swarm
	if comp.rose_skill2_active:
		# 强化飞行需方向操控：image_state 保持 skill2_enhanced（不在 skill_anim_states，
		# 否则全局输入锁会禁用摇杆移动，导致强化二技能不能自由移动）
		f.image_state = "skill2_enhanced" if comp.rose_skill2_enhanced else "skill2"
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
	# 非强化冲刺结束后：常态一技能生成 sheet1 刀光动画拖尾（16 帧），并清除 image_state。
	# 拖尾第1帧（索引0）与最后1帧（索引15）各出伤一次（总伤不变），最后1帧击退；
	# 第14帧（索引13）抓取效果结束，第15帧（索引14）屏幕中震。
	if not f.dashing and f.image_state == "skill1" and comp.rose_skill1_enhanced_slashes.size() == 0 \
			and not comp.rose_skill1_enhanced_used:
		if not comp.rose_skill1_trail_spawned:
			comp.rose_skill1_trail_spawned = true
			var n_anim = _rose_skill1_blade_anim()
			n_anim.play()
			GameWorld.rose_slash_trails.append({
				"anim": n_anim,
				"x": comp.rose_skill1_grab_pos_x - 90.0,  # 常态刀光宽 180，居中于抓取点
				"y": f.pos_y - 4,
				"w": 180.0,
				"h": f.h + 8,
				"dir": f.facing,
				"hit_dealt": false,
				"timer": 100,  # 覆盖完整动画时长（16帧 × 0.1s ≈ 96 帧）
				"damage": 10.0,
				"owner": f,
				"normal_blade": true,
			})
		f.image_state = ""
	# 强化播片超时保护（复用原四连斩生成计时器）：超过 2s 强制结束，防止任何路径卡死
	if comp.rose_skill1_enhanced_slashes.size() > 0:
		comp.rose_skill1_slash_spawn_timer += 1
		if comp.rose_skill1_slash_spawn_timer >= 120:
			comp.rose_skill1_enhanced_slashes = []
			comp.rose_skill1_trail_spawned = false
			comp.rose_skill1_slash_spawn_timer = 0
	else:
		comp.rose_skill1_slash_spawn_timer = 0
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
		# 强化四连斩：一次性生成 sheet.png 刀光动画拖尾（11 帧），
		# 第1/4/6/9帧（索引0/3/5/8）出伤 + 屏幕微震由 update_rose_trails 处理
		if not f.dashing and not comp.rose_skill1_trail_spawned:
			comp.rose_skill1_trail_spawned = true
			var e_anim = _rose_enh_blade_anim()
			e_anim.play()
			var slash_w = 220.0
			var slash_cx = comp.rose_skill1_grab_pos_x
			GameWorld.rose_slash_trails.append({
				"anim": e_anim,
				"x": slash_cx - slash_w / 2.0,
				"y": f.pos_y - 4,
				"w": slash_w,
				"h": f.h + 8,
				"dir": f.facing,
				"hit_dealt": false,
				"timer": 66,  # 11帧 × 0.1s ≈ 66 游戏帧
				"damage": 4.0,
				"frame_hits": [0, 3, 5, 8],  # 第1/4/6/9帧（索引），各 4 点 = 总 16
				"owner": f,
				"enhanced_blade": true,
			})
	# 常态抓取持续锁定：冲刺期间敌人被定身
	if comp.rose_skill1_holding and comp.rose_skill1_enhanced_slashes.size() == 0 and not _has_active_enhanced_trails(f) and f.dashing:
		var enemy = GameWorld.get_opponent(f)
		if enemy and enemy.hp > 0:
			Fighter.hold_fighter_in_place(enemy, comp.rose_skill1_grab_pos_x)
	# 释放抓取：常态冲刺结束后释放 | 强化刀光全部结束后释放
	# （常态刀光拖尾播放期间，抓取由 update_rose_trails 持续锁定至刀光第14帧）
	if comp.rose_skill1_holding and comp.rose_skill1_enhanced_slashes.size() == 0 and not _has_active_enhanced_trails(f) and not f.dashing and not _has_normal_blade(f):
		comp.rose_skill1_holding = false

## 判断是否还有未消失的强化刀光拖尾（sheet.png 四连斩）
static func _has_active_enhanced_trails(f: Fighter) -> bool:
	for trail in GameWorld.rose_slash_trails:
		if trail.get("owner") == f and trail.has("anim") and trail.get("enhanced_blade", false):
			return true
	return false

## 判断是否还有未消失的常态刀光拖尾（sheet1.png 动画）
static func _has_normal_blade(f: Fighter) -> bool:
	for trail in GameWorld.rose_slash_trails:
		if trail.get("owner") == f and trail.get("normal_blade", false):
			return true
	return false

## 常态一技能刀光动画（sheet1.png，4x4=16 帧，替代原 fx_rose_slash.png 静态贴图）
static func _rose_skill1_blade_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill1_plus_bladeeffect/sheet1.png", 4, 4, 16, 0.1, false, [], Vector2i(2, 1))

## 强化一技能四连斩刀光动画（sheet.png，4x3=11 帧，替代原 fx_rose_enh_slash1~4.png）
static func _rose_enh_blade_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(ROSE_ANI_DIR + "skill1_plus_bladeeffect/sheet.png", 4, 3, 11, 0.1, false)

## 冲刺待机贴图（charge）：单帧静态，按内容锚点渲染放大至碰撞盒大小（内容高 → f.h）
static func _rose_charge_anim() -> FrameAnimation:
	return _rose_static_anim(ROSE_ANI_DIR + "charge/rose_charge_f_1.png", 999.0, true)

## 技能一冲刺姿态（skill1）：与 charge 同一张贴图，同样按内容锚点放大至碰撞盒大小
static func _rose_skill1_anim() -> FrameAnimation:
	return _rose_static_anim(ROSE_ANI_DIR + "skill1/rose_skill1_f_1.png", 2.0, false)

## 单帧静态动画：按 PIL 实测锚点渲染，内容高映射为 f.h（放大至碰撞盒大小）
static func _rose_static_anim(img_path: String, dur: float, p_loop: bool) -> FrameAnimation:
	var a := FrameAnimation.new()
	var tex: Texture2D = load(img_path)
	if tex:
		# 锚点（PIL 实测 2048 图）：内容 1808×1833，foot_gap=32，head_gap=183，center_dx=-58.5
		a.add_frame(tex, dur, 32, 183, -58.5, 1808, 1833)
		a.loop = p_loop
		a._calc_total_duration()
		a._calc_content_h_ref()
	return a

## 刀光拖尾更新 + 绘制回调注册（rose 专属，从 character_systems 移出）
static func update_rose_trails():
	var to_remove: Array = []
	for trail in GameWorld.rose_slash_trails:
		trail["timer"] -= 1
		var anim: FrameAnimation = trail.get("anim")
		if anim: anim.update(1.0)
		var slash_owner = trail.get("owner")
		# 常态一技能刀光（sheet1）：
		# 第14帧（索引13）抓取效果结束；第15帧（索引14）屏幕中震；
		# 第1帧（索引0）与最后1帧（索引15）各出伤一次（总伤不变），最后1帧附加击退
		if trail.get("normal_blade", false) and slash_owner and anim:
			var n_comp: RoseComponent = slash_owner.components.get_component("rose") if slash_owner.components else null
			var n_bi: int = anim.get_current_index()
			if n_comp and n_bi >= 0:
				var n_enemy = GameWorld.get_opponent(slash_owner)
				# 第14帧前持续锁定敌人（抓取效果），之后释放
				if n_comp.rose_skill1_holding and n_bi < 13:
					if n_enemy and n_enemy.hp > 0:
						Fighter.hold_fighter_in_place(n_enemy, n_comp.rose_skill1_grab_pos_x)
				else:
					n_comp.rose_skill1_holding = false
				# 帧跳变检测（每帧只触发一次帧事件）
				if n_bi != n_comp.rose_skill1_prev_blade_idx:
					n_comp.rose_skill1_prev_blade_idx = n_bi
					# 第15帧（索引14）屏幕中震
					if n_bi == 14:
						GameWorld.trigger_shake(10.0, 12)
					# 第1帧 / 最后1帧 各出伤一次（5+5=10，总伤不变）
					if (n_bi == 0 or n_bi == 15) and n_enemy and n_enemy.hp > 0:
						var n_hitbox = Rect2(trail["x"], trail["y"], trail["w"], trail["h"])
						if n_hitbox.intersects(n_enemy.get_hit_box()):
							Fighter.apply_damage(n_enemy, trail.get("damage", 10.0) * 0.5, slash_owner)
							trail["hit_dealt"] = true
							# 最后1帧：击退
							if n_bi == 15:
								n_enemy.vx = trail.get("dir", 1) * 6.0
								n_enemy.vy = -3.0
		# 强化四连斩刀光（sheet.png）：第1/4/6/9帧（索引0/3/5/8）出伤 + 屏幕微震
		elif trail.get("enhanced_blade", false) and slash_owner and anim:
			var e_bi: int = anim.get_current_index()
			var e_hits: Array = trail.get("frame_hits", [0, 3, 5, 8])
			var e_flags: Dictionary = trail.get("hit_flags", {})
			if e_bi >= 0 and e_hits.has(e_bi) and not e_flags.has(e_bi):
				e_flags[e_bi] = true
				trail["hit_flags"] = e_flags
				var e_target = GameWorld.get_opponent(slash_owner)
				if e_target and e_target.hp > 0:
					var e_hitbox = Rect2(trail["x"], trail["y"], trail["w"], trail["h"])
					if e_hitbox.intersects(e_target.get_hit_box()):
						Fighter.apply_damage(e_target, trail.get("damage", 4.0), slash_owner)
				GameWorld.trigger_shake(5.0, 6)  # 屏幕微震
		if trail["timer"] <= 0:
			# 强化四连斩拖尾结束：同步结束播片（基于计时器而非动画 is_finished，
			# 保证输入锁定/播片状态必然复位，避免释放强化一技能后动不了）
			if trail.get("enhanced_blade", false) and slash_owner:
				var e_comp: RoseComponent = slash_owner.components.get_component("rose") if slash_owner.components else null
				if e_comp:
					e_comp.rose_skill1_enhanced_slashes = []
					e_comp.rose_skill1_trail_spawned = false
					e_comp.rose_skill1_prev_blade_idx = -1
			to_remove.append(trail)
			continue
		# 通用单次命中（无帧事件的普通拖尾）
		if not trail.get("enhanced_blade", false) and not trail.get("normal_blade", false) and not trail["hit_dealt"] and slash_owner:
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
		comp.rose_skill1_trail_spawned = false  # 刀光拖尾在冲刺结束后生成
		comp.rose_skill1_enhanced_used = enhanced  # 记录本次是否为强化（防止强化播片后误生成常态刀光）
	
	if enhanced and comp:
		# 强化四连斩：sheet.png 动画拖尾（播片期一次性生成），第1/4/6/9帧出伤 + 微震
		if skill: skill.cd = 900  # 15 second cooldown
		comp.rose_skill1_enhanced_slashes = [1, 2, 3, 4]  # 播片期占位标记（驱动播片/锁定/体系统）
	# 常态一技能的刀光拖尾在冲刺结束后由 update_systems 生成（保证第1帧出伤命中已抓取的敌人）
	
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
		comp.ult_hits = [false, false, false, false, false, false]  # 重置六段斩击命中标记
	
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(0.9, 0.15, 0.15), 12, 16, "star", 2.0)
	return {"success": true}

## 体系统：蔷薇状态分类（技能打断优先级）
static func body_priority(f: Fighter) -> int:
	var comp: RoseComponent = f.components.get_component("rose") if f.components else null
	if comp and (comp.time_stop or f.state == "ult"):
		return Fighter.BODY_VAJRA  # 暗夜华尔兹
	if comp:
		if f.image_state == "skill1":
			# 强化分支（四连斩）期间 = 普攻体；释放瞬间 = 技能体
			return Fighter.BODY_NORMAL if not comp.rose_skill1_enhanced_slashes.is_empty() else Fighter.BODY_SKILL
		if f.image_state == "skill2" and not comp.rose_skill2_enhanced:
			return Fighter.BODY_SKILL  # 夜翼瞬袭（常态）
	return -1

## 被中断时：结束一技能冲刺/抓取与二技能状态
static func on_interrupted(f: Fighter):
	var comp: RoseComponent = f.components.get_component("rose") if f.components else null
	if comp:
		comp.rose_skill1_holding = false
		comp.rose_skill1_grab_pos_x = 0.0
		comp.rose_skill1_enhanced_slashes = []
		comp.rose_skill1_trail_spawned = false
		comp.rose_skill1_enhanced_used = false
		comp.rose_skill1_prev_blade_idx = -1
		comp.rose_skill2_active = false
		comp.rose_skill2_enhanced = false
		f.dash_remaining = 0
		f.dashing = false
