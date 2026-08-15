# 影武者 (shadowwarrior)
class_name ShadowwarriorCharacter

const ShadowwarriorComponent = preload("res://scripts/components/shadowwarrior_component.gd")

# Draw preloads (从 game.gd 迁移至此)
const SW_TRAP_A        = preload("res://assets/fx_shadow_trap_a.png")
const SW_TRAP_B        = preload("res://assets/fx_shadow_trap_b.png")
const SW_CLONE_REVEAL  = preload("res://assets/fx_shadow_clone_reveal.png")
const SW_IAIDO_SLASH   = preload("res://assets/fx_shadow_iaido_slash.png")
const SW_RETREAT       = preload("res://assets/fx_shadow_retreat.png")
const SW_BREAK_STRIKE  = preload("res://assets/fx_shadow_break_strike.png")
const SW_GRAB          = preload("res://assets/fx_shadow_grab.png")
const SW_GRAB_BURST    = preload("res://assets/fx_shadow_grab_burst.png")
const SW_IDLE_IMG      = preload("res://assets/char_ani/shadowwarrior/idle/shadowwarrior_idle_f_1.png")
const SW_WALK_IMG      = preload("res://assets/char_ani/shadowwarrior/walk/shadowwarrior_walk_f_1.png")
const SW_ATTACK_IMG    = preload("res://assets/char_ani/shadowwarrior/attack/shadowwarrior_attack_f_1.png")
const SW_ULT_IMG       = preload("res://assets/char_ani/shadowwarrior/ult/shadowwarrior_ult_f_1.png")
const SW_BREAK_SHADOW  = preload("res://assets/char_ani/shadowwarrior/break_shadow.png")
const SW_FADE_IN_SHADOW = preload("res://assets/char_ani/shadowwarrior/fade_in_shadow.png")

const SHADOWWARRIOR_ANI_DIR = "res://assets/char_ani/shadowwarrior/"
const SHADOWWARRIOR_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/shadowwarrior_idle_foot_gaps.gd")
const SHADOWWARRIOR_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/shadowwarrior_jump_foot_gaps.gd")
const SHADOWWARRIOR_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/shadowwarrior_attack_foot_gaps.gd")

static func get_config() -> Dictionary:
	return {
		"id": "shadowwarrior", "name": "影武者", "hp": 90, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.1, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		"fields": {"stealth_active":false,"stealth_timer":0,"last_skill_time":-999,"retreat_timer":0,"retreat_dir":1,"break_strike_timer":0,"pending_trap":false,"shadow_trap_active":false,"shadow_trap":{},"pending_clones":false,"clone_reveal_timer":0,"iaido_active":false,"iaido_timer":0,"iaido_frozen":false,"iaido_dir":1,"iaido_slash":{}},
		"world_arrays": ["phantoms"],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(SHADOWWARRIOR_ANI_DIR + "idle/sheet.png", 3, 3, 8, 0.1, true, _shadowwarrior_idle_anchors()),
			"walk": FrameAnimation.load_from_frames(SHADOWWARRIOR_ANI_DIR + "walk/", "shadowwarrior_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_jump_sheet(SHADOWWARRIOR_ANI_DIR + "jump/sheet.png", 3, 2, 4, 0.2, _shadowwarrior_jump_anchors()),
			"attack": FrameAnimation.load_from_sprite_sheet(SHADOWWARRIOR_ANI_DIR + "attack/sheet.png", 4, 3, 10, 0.05, false, _shadowwarrior_attack_anchors()),
			"ult": FrameAnimation.load_from_frames(SHADOWWARRIOR_ANI_DIR + "ult/", "shadowwarrior_ult_f_", [{"index": 1, "duration": 3.0}], false),
		},
		"dex": {
			"icon": "🥷",
			"intro": "影随身动，刃自暗生。他不与你正面相搏，只在你的呼吸之间往返穿梭——当你终于看清那道残影时，刀锋早已归鞘。\n\"你砍中的，从来都不是我。\"",
			"stats": [{"label": "生命", "value": "90"}, {"label": "能量上限", "value": "100"}],
			"skills": [
				{"name": "胧月·斩（普通攻击）", "desc": "挥刀劈砍，造成 5 点伤害。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "影缚·袭（技能一）", "desc": "在原地生成暗影替身陷阱（存在 5 秒）。敌人靠近时替身化为影球包裹并抓取敌人，包裹造成 5 点伤害，随后炸裂造成 10 点伤害。", "meta": "消耗：15 能量 ｜ 冷却：12 秒"},
				{"name": "幻影·舞（技能二）", "desc": "生成 2 个幻影分身（各 5 点血量），以 0.8 倍移速冲向敌人，仅能使用胧月·斩。敌方会优先攻击分身。分身存在时，本体移速提升至 1.1 倍。", "meta": "消耗：25 能量 ｜ 冷却：20 秒"},
				{"name": "影舞流·居合（大招）", "desc": "向前快速位移并留下一道刀光，自身姿态定格。刀光命中造成 10 点伤害并抓取，3 秒后爆炸造成 30 点伤害。", "meta": "消耗：100 能量 ｜ 冷却：8 秒"},
				{"name": "夜樱·隐（特殊机制）", "desc": "使用技能1/2 后 1 秒内使用胧月·斩，改为后撤并隐身（对手视角消失），获得 1 秒无敌，最多维持 6 秒。隐身下胧月·斩变为破影一击（前冲，10 点伤害）。任意攻击/技能/大招都会解除隐身。", "meta": "—"},
			]
		},
	}

## idle 动画锚点：把 GDScript 常量组装成 FrameAnimation 需要的字典数组
static func _shadowwarrior_idle_anchors() -> Array:
	var anchors: Array = []
	for i in range(SHADOWWARRIOR_IDLE_FOOT_GAPS.SHADOWWARRIOR_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": SHADOWWARRIOR_IDLE_FOOT_GAPS.SHADOWWARRIOR_IDLE_FOOT[i],
			"head_gap": SHADOWWARRIOR_IDLE_FOOT_GAPS.SHADOWWARRIOR_IDLE_HEAD[i],
			"center_dx": SHADOWWARRIOR_IDLE_FOOT_GAPS.SHADOWWARRIOR_IDLE_CENTER[i],
			"content_w": SHADOWWARRIOR_IDLE_FOOT_GAPS.SHADOWWARRIOR_IDLE_CONTENT_W[i],
			"content_h": SHADOWWARRIOR_IDLE_FOOT_GAPS.SHADOWWARRIOR_IDLE_CONTENT_H[i],
		})
	return anchors

## jump 动画锚点：同 _shadowwarrior_idle_anchors 写法
static func _shadowwarrior_jump_anchors() -> Array:
	var anchors: Array = []
	for i in range(SHADOWWARRIOR_JUMP_FOOT_GAPS.SHADOWWARRIOR_JUMP_FOOT.size()):
		anchors.append({
			"foot_gap": SHADOWWARRIOR_JUMP_FOOT_GAPS.SHADOWWARRIOR_JUMP_FOOT[i],
			"head_gap": SHADOWWARRIOR_JUMP_FOOT_GAPS.SHADOWWARRIOR_JUMP_HEAD[i],
			"center_dx": SHADOWWARRIOR_JUMP_FOOT_GAPS.SHADOWWARRIOR_JUMP_CENTER[i],
			"content_w": SHADOWWARRIOR_JUMP_FOOT_GAPS.SHADOWWARRIOR_JUMP_CONTENT_W[i],
			"content_h": SHADOWWARRIOR_JUMP_FOOT_GAPS.SHADOWWARRIOR_JUMP_CONTENT_H[i],
		})
	return anchors

## attack 动画锚点：同 _shadowwarrior_idle_anchors 写法
static func _shadowwarrior_attack_anchors() -> Array:
	var anchors: Array = []
	for i in range(SHADOWWARRIOR_ATTACK_FOOT_GAPS.SHADOWWARRIOR_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": SHADOWWARRIOR_ATTACK_FOOT_GAPS.SHADOWWARRIOR_ATTACK_FOOT[i],
			"head_gap": SHADOWWARRIOR_ATTACK_FOOT_GAPS.SHADOWWARRIOR_ATTACK_HEAD[i],
			"center_dx": SHADOWWARRIOR_ATTACK_FOOT_GAPS.SHADOWWARRIOR_ATTACK_CENTER[i],
			"content_w": SHADOWWARRIOR_ATTACK_FOOT_GAPS.SHADOWWARRIOR_ATTACK_CONTENT_W[i],
			"content_h": SHADOWWARRIOR_ATTACK_FOOT_GAPS.SHADOWWARRIOR_ATTACK_CONTENT_H[i],
		})
	return anchors

static func _can_use_skill1(owner: Fighter) -> bool:
	var comp: ShadowwarriorComponent = owner.components.get_component("shadowwarrior") if owner.components else null
	return not owner.attacking and (not comp or not comp.shadow_trap_active)

static func _can_use_ult(owner: Fighter) -> bool:
	var comp: ShadowwarriorComponent = owner.components.get_component("shadowwarrior") if owner.components else null
	return owner.energy >= 100 and not owner.attacking and (not comp or not comp.iaido_active)

static func create_skills() -> Array:
	return [
		Skill.new("attack", "胧月·斩", 60, 0, func(owner: Fighter): return owner.attack_cooldown <= 0 and not owner.attacking, Callable(_attack)),
		Skill.new("skill1", "影缚·袭", 720, 15, Callable(_can_use_skill1), Callable(_skill1)),
		Skill.new("skill2", "幻影·舞", 1200, 25, Callable(), Callable(_skill2)),
		Skill.new("ult", "影舞流·居合", 480, 100, Callable(_can_use_ult), Callable(_ult)),
	]

static func _attack(owner: Fighter) -> Dictionary:
	owner.attacking = true
	owner.attack_timer = 30
	owner.attack_delay = 8
	owner.attack_hit_dealt = false
	owner.attack_cooldown = 60
	owner.state = "attack"
	return {"success": true}

static func _skill1(owner: Fighter) -> Dictionary:
	var comp: ShadowwarriorComponent = owner.components.get_component("shadowwarrior") if owner.components else null
	if comp:
		comp.pending_trap = true
		comp.last_skill_time = GameWorld.frame
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 20, Color(0.4,0.2,0.67), 4, 6, "star")
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	var comp: ShadowwarriorComponent = owner.components.get_component("shadowwarrior") if owner.components else null
	if comp:
		comp.pending_clones = true
		comp.last_skill_time = GameWorld.frame
	Fighter.emit_particles(owner.pos_x+owner.w/2, owner.pos_y+owner.h/2, 30, Color(0.53,0.27,0.8), 5, 7, "star")
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	var comp: ShadowwarriorComponent = owner.components.get_component("shadowwarrior") if owner.components else null
	if not comp:
		return {"success": false}
	# 居合进行中则不能再放
	if comp.iaido_active:
		return {"success": false}

	var dir = owner.facing
	comp.iaido_active = true
	comp.iaido_timer = 150
	comp.iaido_dir = dir
	comp.iaido_frozen = true
	# 刀光：从角色当前位置起，沿 facing 方向延伸 360 像素
	comp.iaido_slash = {
		"x": owner.pos_x + (owner.w if dir == 1 else -360),
		"y": owner.pos_y - 4,
		"w": 360,
		"h": owner.h + 8,
		"dir": dir,
		"hit_dealt": false,
		"start_x": owner.pos_x,  # 姿态贴图平移起点
	}

	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 40, Color(0.53, 0.27, 0.8), 8, 10, "star")
	return {"success": true}

## 影武者系统更新：技能1陷阱 + 技能2分身 + 大招居合
static func update_systems(f: Fighter):
	var comp: ShadowwarriorComponent = f.components.get_component("shadowwarrior") if f.components else null
	if not comp:
		return
	# 动画帧推进（多帧 sprite-sheet 动画需要每帧 update 才能换帧）
	if f.current_anim and f.current_anim.is_playing():
		f.current_anim.update(1.0)
	# ── 绘制注入（每帧更新）──
	_inject_draw(f, comp)
	# ── 冲刺伤害覆盖：破影一击 10 点 ──
	f.dash_damage_override = 10.0 if comp.break_strike_timer > 0 else 0.0
	
	# ── 居合全局冻结：委托中断器管理计时（定格 30f / 停留 90f）──
	if comp.iaido_active:
		var t = comp.iaido_timer
		if t == 150:
			FrameInterrupter.add("iaido", 30)
		elif t == 90:
			FrameInterrupter.add("iaido", 90)
		comp.iaido_timer -= 1
	
	# === 技能1：影缚·袭 - 创建陷阱 ===
	if comp.pending_trap:
		comp.pending_trap = false
		comp.shadow_trap_active = true
		comp.shadow_trap = {
			"x": f.pos_x,
			"y": f.pos_y,
			"w": f.w,
			"h": f.h,
			"phase": "idle",
			"timer": 300,  # 5 秒存在时间
			"anim": 0,
			"captured": null,
			"vy": f.vy,
			"grounded": f.grounded,
		}

	# === 技能2：幻影·舞 - 创建分身 ===
	if comp.pending_clones:
		comp.pending_clones = false
		var opp = GameWorld.get_opponent(f)
		for i in range(2):
			var offset_x = (i - 0.5) * 30
			var ph = {
				"x": f.pos_x + offset_x,
				"y": f.pos_y,
				"w": f.w,
				"h": f.h,
				"hp": 5.0,
				"max_hp": 5.0,
				"life": 300,  # 5秒存活
				"facing": f.facing,
				"image_state": "walk",
				"attack_cooldown": 0,
				"attack_timer": 0,
				"attack_delay": 0,
				"attack_hit_dealt": false,
				"attacking": false,
				"owner": f,
				"vy": f.vy,
				"grounded": f.grounded,
			}
			GameWorld.phantoms.append(ph)

	# === 技能1：陷阱逻辑更新 ===
	if comp.shadow_trap_active and not comp.shadow_trap.is_empty():
		_update_shadow_trap(f, comp)
	# === 技能2：分身逻辑更新 ===
	_update_phantoms(f)

	# === 大招：居合刀光命中 + 到期爆炸 ===
	if comp.iaido_active:
		_update_iaido(f, comp)

# 技能1：暗影替身陷阱更新
static func _update_shadow_trap(f: Fighter, comp: ShadowwarriorComponent):
	var trap = comp.shadow_trap
	trap["anim"] += 1
	trap["timer"] -= 1
	
	# 重力 & 落地（空中释放的陷阱自动下落）
	if not trap.get("grounded", true):
		trap["vy"] = trap.get("vy", 0.0) + 0.22
		trap["y"] += trap["vy"]
		if trap["y"] + trap["h"] >= Constants.GROUND_Y:
			trap["y"] = Constants.GROUND_Y - trap["h"]
			trap["vy"] = 0.0
			trap["grounded"] = true

	match trap["phase"]:
		"idle":
			# 检测敌人是否进入陷阱矩形范围
			var opp = GameWorld.get_opponent(f)
			if opp and opp.hp > 0 and not opp.is_invincible:
				# 陷阱碰撞箱：以陷阱位置为中心，120×h 的矩形
				var trap_rect = Rect2(trap["x"] + trap["w"] / 2.0 - 60, trap["y"], 120, trap["h"])
				if trap_rect.intersects(opp.get_hit_box()):
					trap["phase"] = "capture"
					trap["timer"] = 60  # 包裹持续 1 秒
					trap["captured"] = opp
					Fighter.apply_damage(opp, 5.0, f)
		"capture":
			var cap = trap["captured"]
			if cap and cap.hp > 0:
				# 固定被抓取的敌人（通用锁定接口）
				Fighter.hold_fighter_in_place(cap, trap["x"] + trap["w"] / 2.0)
			if trap["timer"] <= 0:
				trap["phase"] = "burst"
				trap["timer"] = 20  # 爆炸动画 0.33 秒
				if cap and cap.hp > 0:
					Fighter.apply_damage(cap, 10.0, f)
					cap.vx = (1 if cap.pos_x > trap["x"] else -1) * 5
					cap.vy = -4
				Fighter.emit_particles(trap["x"] + trap["w"] / 2.0, trap["y"] + trap["h"] / 2.0, 30, Color(0.4, 0.2, 0.67), 6, 8, "star", 0.8)
		"burst":
			if trap["timer"] <= 0:
				comp.shadow_trap_active = false
				comp.shadow_trap = {}

	# 5 秒后陷阱消失
	if trap["timer"] <= 0 and trap["phase"] == "idle":
		comp.shadow_trap_active = false
		comp.shadow_trap = {}

# 技能2：幻影分身更新
static func _update_phantoms(f: Fighter):
	if GameWorld.phantoms.is_empty():
		return
	var opp = GameWorld.get_opponent(f)
	var to_remove = []
	for ph in GameWorld.phantoms:
		if ph.hp <= 0:
			to_remove.append(ph)
			continue
		# 存活计时（5秒）
		if ph.has("life"):
			ph["life"] -= 1
			if ph["life"] <= 0:
				to_remove.append(ph)
				continue
		# 重力 & 落地（空中释放/走出平台边缘的分身自动下落）
		if not ph.get("grounded", true):
			ph["vy"] += 0.22  # 与角色重力一致
			ph["y"] += ph["vy"]
			# 检测是否落到任意平台上
			var landed = false
			for p in GameWorld.platforms:
				if p.get("terrain_type", -1) == 3: continue
				if ph["vy"] >= 0 and ph["x"] + ph["w"] > p["x"] + 4 and ph["x"] < p["x"] + p["w"] - 4 \
					and ph["y"] + ph["h"] >= p["y"] and ph["y"] + ph["h"] <= p["y"] + p["h"] + 6:
					ph["y"] = p["y"] - ph["h"]
					ph["vy"] = 0.0
					ph["grounded"] = true
					landed = true
					break
			if not landed and ph["y"] + ph["h"] >= Constants.GROUND_Y:
				ph["y"] = Constants.GROUND_Y - ph["h"]
				ph["vy"] = 0.0
				ph["grounded"] = true
		# 落地后才能移动和攻击
		if ph.get("grounded", true):
			var prev_x = ph["x"]
			# 向敌人移动
			if opp and opp.hp > 0:
				var dx = opp.pos_x - ph["x"]
				var dist = absf(dx)
				var dir = 1 if dx > 0 else -1
				ph["facing"] = dir
				if not ph["attacking"]:
					if dist > 44:  # 攻击范围外
						ph["x"] += dir * 2.1 * 0.8  # 0.8 倍移速
						ph["image_state"] = "walk"
					else:
						# 攻击
						if ph["attack_cooldown"] <= 0:
							ph["attacking"] = true
							ph["attack_timer"] = 30
							ph["attack_delay"] = 8
							ph["attack_hit_dealt"] = false
							ph["attack_cooldown"] = 60
							ph["image_state"] = "attack"
			# 移动后检测是否还在平台上，否则取消 grounded
			if ph["x"] != prev_x:
				var still_on_plat = false
				for p in GameWorld.platforms:
					if p.get("terrain_type", -1) == 3: continue
					if ph["x"] + ph["w"] > p["x"] + 4 and ph["x"] < p["x"] + p["w"] - 4 \
						and absf(ph["y"] + ph["h"] - p["y"]) < 6:
						still_on_plat = true
						break
				if not still_on_plat:
					ph["grounded"] = false
			if ph["attacking"]:
				ph["attack_timer"] -= 1
				if ph["attack_delay"] > 0:
					ph["attack_delay"] -= 1
					if ph["attack_delay"] <= 0 and not ph["attack_hit_dealt"]:
						ph["attack_hit_dealt"] = true
						if opp and opp.hp > 0:
							var box = Rect2(ph["x"] + (4 if ph["facing"] > 0 else -40), ph["y"] + 4, 44, ph["h"] - 8)
							if box.intersects(opp.get_hit_box()):
								Fighter.apply_damage(opp, 5.0, f)
				if ph["attack_timer"] <= 0:
					ph["attacking"] = false
					ph["image_state"] = "idle"
			if ph["attack_cooldown"] > 0:
				ph["attack_cooldown"] -= 1
	for ph in to_remove:
		GameWorld.phantoms.erase(ph)

# 大招：居合刀光命中 + 到期爆炸
static func _update_iaido(f: Fighter, comp: ShadowwarriorComponent):
	var slash = comp.iaido_slash
	if slash.is_empty():
		return

	# 刀光命中：造成 10 点伤害（仅一次）
	if not slash.get("hit_dealt", false):
		var target = GameWorld.get_opponent(f)
		if target and target.hp > 0:
			var slash_rect = Rect2(slash["x"], slash["y"], slash["w"], slash["h"])
			if slash_rect.intersects(target.get_hit_box()):
				Fighter.apply_damage(target, 10.0, f)
				slash["hit_dealt"] = true
				# 抓取效果：固定对手在刀光中心（通用锁定接口）
				Fighter.hold_fighter_in_place(target, slash["x"] + slash["w"] / 2.0)
				slash["captured"] = target

	# 到期爆炸：iaido_timer 归零时造成 30 点伤害
	if comp.iaido_timer <= 0:
		var cap = slash.get("captured")
		if cap and cap.hp > 0:
			Fighter.apply_damage(cap, 30.0, f)
			# 爆炸击退
			cap.vx = comp.iaido_dir * 6
			cap.vy = -5
		# 爆炸特效
		var cx = slash["x"] + slash["w"] / 2.0
		var cy = slash["y"] + slash["h"] / 2.0
		Fighter.emit_particles(cx, cy, 50, Color(0.67, 0.2, 0.93), 10, 14, "star", 1.0)
		# 重置状态，角色停留在终点
		comp.iaido_active = false
		comp.iaido_frozen = false
		comp.iaido_slash = {}
		# 将角色位置更新到刀光终点（大招结束后停留在终点）
		var end_x = slash.get("start_x", f.pos_x) + slash["dir"] * slash["w"]
		f.pos_x = clampf(end_x, 10, 2390 - f.w)

# ── 绘制注入 ──
static var _draw_registered := false
static func _inject_draw(f: Fighter, comp: ShadowwarriorComponent):
	var fid = str(f.get_instance_id())
	# Fighter 本体绘制注入
	f.state_flags["skip_fighter_draw"] = comp.iaido_active
	if comp.stealth_active:
		if f == GameWorld.player:
			f.state_flags["draw_alpha_mod"] = 0.5  # 操作者看半透明
		else:
			f.state_flags["skip_fighter_draw"] = true  # 对手看全透明
	else:
		f.state_flags.erase("draw_alpha_mod")
	if comp.stealth_active and f.dashing:
		f.state_flags["draw_texture_override"] = SW_FADE_IN_SHADOW
	elif comp.break_strike_timer > 0:
		f.state_flags["draw_texture_override"] = SW_BREAK_SHADOW
	else:
		f.state_flags.erase("draw_texture_override")
	# 世界级绘制：替身陷阱 + 居合刀光
	GameWorld.register_draw_effect(fid + "_sw", func(font, cam_x, _cam_y = 0.0):
		var items: Array = []
		# 暗影替身
		if comp.shadow_trap_active and not comp.shadow_trap.is_empty():
			var trap = comp.shadow_trap
			match trap["phase"]:
				"idle":
					var img = SW_TRAP_A if (trap["anim"] / 30) % 2 == 0 else SW_TRAP_B
					items += _sw_draw_items(img, trap["x"], trap["y"]+f.h*0.4 - _cam_y, f.w, f.h*0.6, cam_x, f.facing, 0.7)
				"capture":
					if trap["captured"] and trap["captured"] is Fighter and trap["captured"].hp > 0:
						var cap = trap["captured"]
						items += _sw_draw_items(SW_GRAB, cap.pos_x - 10, cap.pos_y - 10 - _cam_y, cap.w + 20, cap.h + 20, cam_x, 1, 0.95)
				"burst":
					var cap = trap["captured"]
					var bx = cap.pos_x - 10 if (cap and cap is Fighter) else trap["x"] - 10
					var by = (cap.pos_y - 10 if (cap and cap is Fighter) else trap["y"] - 10) - _cam_y
					var bw = (cap.w + 20 if (cap and cap is Fighter) else trap["w"] + 20)
					var bh = (cap.h + 20 if (cap and cap is Fighter) else trap["h"] + 20)
					items += _sw_draw_items(SW_GRAB_BURST, bx, by, bw, bh, cam_x, 1, 1.0)
		# 居合刀光
		if comp.iaido_active and not comp.iaido_slash.is_empty():
			var slash = comp.iaido_slash
			items += _sw_draw_items(SW_IAIDO_SLASH, slash["x"], slash["y"] - _cam_y, slash["w"], slash["h"], cam_x, slash.get("dir", 1), 0.85)
			var t = comp.iaido_timer
			var progress: float
			if t > 120: progress = 0.0
			elif t > 90: progress = (120 - t) / 30.0
			else: progress = 1.0
			var start_x: float = slash.get("start_x", f.pos_x)
			var end_x = start_x + slash["dir"] * slash["w"]
			var pose_x = start_x + (end_x - start_x) * progress
			var iw = SW_ULT_IMG.get_width(); var ih = SW_ULT_IMG.get_height()
			var s = minf(f.w / iw, f.h / ih)
			items += _sw_draw_items(SW_ULT_IMG, pose_x + (f.w - iw*s) / 2.0, f.pos_y + f.h - ih*s*1.5 - _cam_y, iw*s, ih*s*1.5, cam_x, f.facing, 1.0)
		return items
	, 5)
	# 分身绘制
	GameWorld.register_draw_effect(fid + "_phantoms", func(font, cam_x, _cam_y = 0.0):
		var items: Array = []
		for ph in GameWorld.phantoms:
			if ph.get("hp", 0) <= 0: continue
			var state = ph.get("image_state", "idle")
			var img: Texture2D = SW_IDLE_IMG
			match state:
				"attack": img = SW_ATTACK_IMG
				"walk":   img = SW_WALK_IMG
			var px = ph["x"] - cam_x
			if px < -ph["w"] or px > Constants.W + ph["w"]: continue
			var py = ph["y"] + ph["h"] * 0.5 - _cam_y
			var dh = ph["h"] * 0.6
			if ph["facing"] < 0:
				items.append({"type": "set_transform", "pos": Vector2(px + ph["w"], py), "scale": Vector2(-1, 1)})
				items.append({"type": "tex", "tex": img, "rect": Rect2(0, 0, ph["w"], dh), "color": Color(1,1,1,0.75)})
				items.append({"type": "reset_transform"})
			else:
				items.append({"type": "tex", "tex": img, "rect": Rect2(px, py, ph["w"], dh), "color": Color(1,1,1,0.75)})
			var hp_pct = maxf(0, ph["hp"] / maxf(ph.get("max_hp", 1.0), 1.0))
			items.append({"type": "rect", "rect": Rect2(px, py - 8, ph["w"], 4), "color": Color(0, 0, 0, 0.5)})
			items.append({"type": "rect", "rect": Rect2(px, py - 8, ph["w"] * hp_pct, 4), "color": Color(0.53, 0.27, 0.8)})
		return items
	, 4)
	_draw_registered = true

static func _unregister_draw(f: Fighter):
	var fid = str(f.get_instance_id())
	GameWorld.unregister_draw_effect(fid + "_sw")
	GameWorld.unregister_draw_effect(fid + "_phantoms")

static func _sw_draw_items(img: Texture2D, wx: float, wy: float, w: float, h: float, cam_x: float, facing: int = 1, alpha: float = 1.0) -> Array:
	if not img: return []
	var px = wx - cam_x
	var cx = px + w / 2.0; var cy = wy + h / 2.0
	var sc = Vector2(-1 if facing < 0 else 1, 1)
	return [
		{"type": "set_transform", "pos": Vector2(cx, cy), "scale": sc},
		{"type": "tex", "tex": img, "rect": Rect2(-w / 2.0, -h / 2.0, w, h), "color": Color(1, 1, 1, alpha)},
		{"type": "reset_transform"},
	]

## 输入处理（替代 input_handler.gd 中的 _input_shadowwarrior）
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var comp: ShadowwarriorComponent = owner.components.get_component("shadowwarrior") if owner.components else null
	var iaido_active = comp.iaido_active if comp else false
	var iaido_frozen = comp.iaido_frozen if comp else false
	if iaido_active and iaido_frozen:
		owner.vx = 0
		return 0
	var mx = 0
	if not owner.dashing:
		if keys.left: mx = -1
		if keys.right: mx = 1
		if keys.up and owner.grounded:
			owner.vy = -10
			owner.grounded = false
	if keys.attack and not owner.attacking:
		var stealth_active = comp.stealth_active if comp else false
		if stealth_active:
			# 破影一击：前冲攻击
			owner.dashing = true
			owner.dash_remaining = 60
			owner.dash_dir = owner.facing
			owner.dash_speed = 4
			owner.dash_damage_dealt = false
			if comp:
				comp.break_strike_timer = 60
				comp.stealth_active = false
			keys.attack = false
		elif comp and GameWorld.frame - comp.last_skill_time <= 60:
			# 技能后 1 秒内攻击：后撤隐身
			comp.stealth_active = true
			comp.stealth_timer = 360
			comp.retreat_timer = 15
			comp.retreat_dir = owner.facing
			owner.dashing = true
			owner.dash_remaining = 80
			owner.dash_dir = -owner.facing
			owner.dash_speed = 2.52
			owner.dash_damage_dealt = true
			comp.last_skill_time = -999
			keys.attack = false
		else:
			var s = owner.get_skill("attack")
			if s:
				var r = s.try_use(owner)
				if r.get("success"):
					keys.attack = false
	if keys.skill1:
		var s = owner.get_skill("skill1")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				if comp:
					comp.stealth_active = false
				keys.skill1 = false
	if keys.skill2:
		var s = owner.get_skill("skill2")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				if comp:
					comp.stealth_active = false
				keys.skill2 = false
	if keys.ult:
		var s = owner.get_skill("ult")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				if comp:
					comp.stealth_active = false
				keys.ult = false
	if not owner.has_status("frozen") and not owner.dashing:
		var has_ph = GameWorld.phantoms.size() > 0
		var boost = 1.1 if has_ph else 1.0
		owner.vx += mx * 0.25 * boost
		if absf(owner.vx) > 2.25 * boost:
			owner.vx = 2.25 * boost * signf(owner.vx)
	Fighter.update_state(owner, mx)
	return mx
