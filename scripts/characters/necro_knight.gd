class_name NecroKnightCharacter

const NECRO_ANI_DIR = "res://assets/char_ani/necro_knight/"
const TEX_FALLBACK = preload("res://assets/char_ani/necro_knight/idle/necro_knight_idle_f_1.png")

static func _fa(tex: Texture2D, dur: float = 999.0, loop: bool = true) -> FrameAnimation:
	var a = FrameAnimation.new(); a.add_frame(tex, dur); a.loop = loop; return a

# ── 亡灵战马 ──
const HORSE_W := 120.0
const HORSE_H := 80.0
const HORSE_SPEED := 2.5
const HORSE_ATK_DMG := 8.0
const HORSE_ATK_RANGE := 50
const HORSE_ATK_CD := 90
const MOUNTED_SPEED := 4.0
const MOUNTED_JUMP_BOOST := 1.1
const HORSE_CHARGE_SPEED := 4.0
const HORSE_CHARGE_DMG := 1.0
const HORSE_CHARGE_DIST := 400
const HORSE_HIT_CD := 8  # 同目标冷却帧数，实现多次撞击
static var horses: Array = []

# ── 骑士常量 ──
const ATK_DMG := 6.0
const ATK_COOLDOWN := 60  # 1s
const SKILL1_ENERGY := 20
const SKILL1_COOLDOWN := 900  # 15s
const SKILL2_ENERGY := 25
const SKILL2_COOLDOWN := 300  # 5s
const ULT_ENERGY_COST := 120
const ULT_COOLDOWN := 600

# ── 大招：亡者行军 ──
const ULT_FRAME_COUNT := 17
const ULT_FRAME_DUR := 0.355
const ULT_DAMAGE_START_FRAME := 9   # 第9帧开始出伤
const ULT_TOTAL_DAMAGE := 40.0

static func get_config() -> Dictionary:
	return {
		"id": "necro_knight", "name": "死灵骑士", "hp": 100, "max_energy": 120, "energy_regen": 0.05,
		"speed": 2.2, "attack_range": 44, "attack_damage": ATK_DMG,
		"attack_cooldown": ATK_COOLDOWN, "attack_delay": 8, "attack_duration": 30,
		"image_scale": 1.5,
		"image_offset_y": 5,
		"fields": {"horse_idx": -1, "horse_atk_cd": 0},
		"world_arrays": [],
		"animations": {
			"idle":   FrameAnimation.load_from_frames(NECRO_ANI_DIR + "idle/", "necro_knight_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk":   FrameAnimation.load_from_frames(NECRO_ANI_DIR + "walk/", "necro_knight_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump":   FrameAnimation.load_from_frames(NECRO_ANI_DIR + "jump/", "necro_knight_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(NECRO_ANI_DIR + "attack/", "necro_knight_attack_f_", [{"index": 1, "duration": 0.5}], false),
			"ult":    _fa(TEX_FALLBACK, 2.0, false),
			"mounted_idle": FrameAnimation.load_from_frames(NECRO_ANI_DIR + "mounted_idle/", "necro_knight_mounted_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"mounted_walk": FrameAnimation.load_from_frames(NECRO_ANI_DIR + "mounted_walk/", "necro_knight_mounted_walk_f_", [{"index": 1, "duration": 0.3}, {"index": 2, "duration": 0.3}], true),
			"mounted_jump": FrameAnimation.load_from_frames(NECRO_ANI_DIR + "mounted_jump/", "necro_knight_mounted_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"mounted_attack": FrameAnimation.load_from_frames(NECRO_ANI_DIR + "mounted_attack/", "necro_knight_mounted_attack_f_", [{"index": 1, "duration": 0.5}], false),
		},
		"dex": {
			"icon": "💀",
			"intro": "他勒住马，在雾中停了一会儿。骷髅马安静地立在他身侧，颌骨微张，像是也在看着远方。\n\n硝烟从焦土上升起，带着铁锈、血、以及另一种更古老的气味。他早已习惯这种气味，就像习惯自己的剑永远冰冷。\n\n\"汝等举剑时……可曾想过，什么也不会改变。\"",
			"stats": [{"label": "生命", "value": "100"}, {"label": "能量上限", "value": "120"}, {"label": "战马生命", "value": "80"}],
			"skills": [
				{"name": "普攻：幽冥斩", "desc": "死灵骑士挥动冥剑攻击。", "meta": "6伤害 · 冷却1s"},
				{"name": "技能一：铁骑·地裂", "desc": "【分离】缚命裁决：吸附身前300px内敌人，拉至100px内终结。【骑乘】跳起后40°斜下坠地，AOE伤害15。", "meta": "消耗20能量 · 冷却15s"},
				{"name": "技能二：终焉盟约", "desc": "切换死契形态。【分离】战马冲回骑士身边（速度4），沿途撞击敌人（3伤害，可多次撞击），抵达后上马。【骑乘】下马，战马向前冲刺400像素撞击敌人（同上），二者分离。", "meta": "消耗25能量 · 冷却5s"},
				{"name": "大招：亡者行军", "desc": "打开冥界之门召唤大量死灵攻击敌人，逐帧出伤40点。", "meta": "消耗120能量 · 冷却10s"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "亡者进军", SKILL1_COOLDOWN, SKILL1_ENERGY, Callable(), Callable(NecroKnightCharacter, "_skill1")),
		Skill.new("skill2", "终焉盟约", SKILL2_COOLDOWN, SKILL2_ENERGY, Callable(), Callable(NecroKnightCharacter, "_skill2")),
		Skill.new("ult", "冥界降临", ULT_COOLDOWN, ULT_ENERGY_COST, Callable(), Callable(NecroKnightCharacter, "_ult")),
	]

# ── 组件辅助 ──

static func _get_comp(fighter: Fighter):
	if not fighter.components:
		return null
	return fighter.components.get_component("necro_knight")

static func _is_mounted(fighter: Fighter) -> bool:
	var comp = _get_comp(fighter)
	if comp and comp.has_method("is_mounted"):
		return comp.is_mounted()
	return false

static func _comp_mount(fighter: Fighter):
	var comp = _get_comp(fighter)
	if comp and comp.has_method("mount"):
		comp.mount()

static func _comp_dismount(fighter: Fighter, forced: bool = false):
	var comp = _get_comp(fighter)
	if comp and comp.has_method("dismount"):
		comp.dismount(forced)
	fighter.config["image_scale"] = 1.5
	fighter.set_animation_state("idle")

# ── 战马管理 ──

static func _spawn_horse(owner: Fighter) -> Dictionary:
	# 找到离骑士最近的地面（不含平台）
	var ground_y = _find_nearest_ground_y(owner.pos_x)
	var horse = {
		"x": owner.pos_x + owner.w + 10,
		"y": ground_y - HORSE_H,
		"w": HORSE_W, "h": HORSE_H,
		"vx": 0.0, "vy": 0.0, "grounded": true,
		"facing": 1, "atk_cd": 0,
		"owner": owner,
		# 冲锋状态
		"charge_target_x": -9999.0,
		"charge_speed": 0.0,
		"charge_on_arrive": "",  # "mount" / "" / null
		"charge_hit_list": {},
	}
	horses.append(horse)
	owner.set_meta("horse_idx", horses.size() - 1)
	return horse

## 找到离给定x最近的地面Y（terrain_type==0 的地面块顶部）
static func _find_nearest_ground_y(x: float) -> float:
	var best_y = Constants.GROUND_Y
	var best_dist = INF
	for pl in GameWorld.platforms:
		if not pl is Dictionary:
			continue
		var pd: Dictionary = pl
		if pd.get("terrain_type", -1) != 0:
			continue
		var cx = pd["x"] + pd["w"] / 2.0
		var dist = absf(x - cx)
		if dist < best_dist:
			best_dist = dist
			best_y = pd["y"]
	return best_y if best_dist < INF else Constants.GROUND_Y

static func _get_horse(owner: Fighter):
	var idx = owner.get_meta("horse_idx")
	if idx == null or idx < 0 or idx >= horses.size():
		return null
	var h = horses[idx]
	if h.owner != owner:
		return null
	return h

# ── 战马物理 ──

static func _horse_physics(horse: Dictionary):
	if horse == null:
		return
	if horse.charge_speed > 0:
		return  # 冲锋时不跑物理
	var hw: float = horse.w
	var hh: float = horse.h
	# 重力
	if not horse.grounded:
		horse.vy += 0.22
	horse.x += horse.vx
	horse.y += horse.vy
	# 摩擦
	if horse.grounded and absf(horse.vx) > 0.1:
		horse.vx *= 0.88
	elif horse.grounded:
		horse.vx = 0
	# 平台碰撞：只站地面（terrain_type==0）
	horse.grounded = false
	for pl in GameWorld.platforms:
		if not pl is Dictionary:
			continue
		var pd: Dictionary = pl
		if pd.get("terrain_type", -1) != 0:
			continue  # 只检测地面
		var px: float = pd["x"]; var py: float = pd["y"]
		var pw: float = pd["w"]; var ph: float = pd["h"]
		if horse.x + hw > px and horse.x < px + pw:
			if horse.y + hh >= py and horse.y + hh - horse.vy <= py + 2:
				horse.y = py - hh
				horse.vy = 0
				horse.grounded = true
				break
	# 兜底：默认地面高度
	if not horse.grounded and horse.y + hh >= Constants.GROUND_Y:
		horse.y = Constants.GROUND_Y - hh
		horse.vy = 0
		horse.grounded = true
	# 虚空传送
	if horse.y > 500:
		var owner: Fighter = horse.owner
		if is_instance_valid(owner):
			var gy = _find_nearest_ground_y(owner.spawn_x)
			horse.x = owner.spawn_x
			horse.y = gy - hh
		else:
			horse.x = 200
			horse.y = Constants.GROUND_Y - hh
		horse.vy = 0
		horse.vx = 0
		horse.grounded = true
	if horse.vx != 0:
		horse.facing = 1 if horse.vx > 0 else -1
	horse.x = clampf(horse.x, 10, 2400 - hw)

# ── 每帧更新 ──

static func update_systems(owner: Fighter):
	var horse = _get_horse(owner)
	var comp = _get_comp(owner)
	if not horse:
		_spawn_horse(owner)
		horse = _get_horse(owner)
	if horse and horse.atk_cd > 0:
		horse.atk_cd -= 1
	if comp and comp.has_method("update"):
		comp.update()
		_update_soul_binding(owner)
		# 终结贴图倒计时
		if comp.skill1_execute_flash > 0:
			comp.skill1_execute_flash -= 1
			if comp.skill1_execute_flash <= 0:
				owner.state_flags.erase("draw_texture_override")
	_update_mounted_slam(owner)
	_update_ult(owner)
	_update_undying(owner)
	
	# ── 战马冲锋更新 ──
	if horse and horse.charge_speed > 0:
		# 追踪模式：持续更新目标为骑士位置
		if horse.charge_on_arrive == "mount":
			horse.charge_target_x = owner.pos_x
		var dir = 1 if horse.charge_target_x > horse.x else -1
		horse.vx = dir * horse.charge_speed
		horse.facing = dir
		horse.x += horse.vx
		horse.y = clampf(horse.y, 0, Constants.GROUND_Y - horse.h)
		horse.x = clampf(horse.x, 10, 2400 - horse.w)
		# 沿途撞击敌人
		_horse_charge_hit(horse, owner)
		# 到达目标
		if absf(horse.x - horse.charge_target_x) < 12:
			_horse_stop_charge(horse, owner)
	elif horse and not _is_mounted(owner):
		_horse_physics(horse)
	# ── 战马动画更新 ──
	if _horse_idle_anim and _horse_idle_anim.is_playing():
		_horse_idle_anim.update()
	if _horse_walk_anim and _horse_walk_anim.is_playing():
		_horse_walk_anim.update()
	# ── 骑乘动画帧推进（多帧动画需要每帧 update） ──
	if owner.current_anim:
		owner.current_anim.update(1.0)
	# ── 骑乘状态缩放 ──
	if _is_mounted(owner):
		owner.config["image_scale"] = 3.5
		owner.config["camera_offset_x"] = 140.0
		# 攻击结束后恢复默认攻击参数
		if not owner.attacking:
			owner.attack_range = 44
			owner.attack_damage = ATK_DMG
	else:
		owner.config["image_scale"] = 1.5
		owner.config.erase("camera_offset_x")

# ── 冲锋辅助 ──

## 沿途撞击敌人
static func _horse_charge_hit(horse: Dictionary, owner: Fighter):
	var hx = horse.x + horse.w / 2.0
	var hy = horse.y + horse.h / 2.0
	var hit_range = HORSE_ATK_RANGE
	var frame = GameWorld.frame
	var hit_list: Dictionary = horse.charge_hit_list
	for f in GameWorld.entities:
		if f == owner or f.hp <= 0:
			continue
		var fid = f.get_instance_id()
		var last_hit: int = hit_list.get(fid, -9999)
		if frame - last_hit < HORSE_HIT_CD:
			continue
		var fx = f.pos_x + f.w / 2.0
		var fy = f.pos_y + f.h / 2.0
		if absf(hx - fx) < hit_range and absf(hy - fy) < hit_range:
			hit_list[fid] = frame
			var dir = 1 if horse.vx > 0 else -1
			f.vy = 0
			f.vx = horse.vx * 2.0
			f.hp -= HORSE_CHARGE_DMG
			f.damage_flash = 8
			Fighter.emit_particles(fx, fy, 8, Color(0.2, 0.3, 0.8), 4, 6, "circle")

## 停止冲锋
static func _horse_stop_charge(horse: Dictionary, owner: Fighter):
	var action: String = horse.charge_on_arrive
	horse.charge_speed = 0
	horse.charge_target_x = -9999.0
	horse.charge_hit_list.clear()
	horse.vx = 0
	if action == "mount":
		_comp_mount(owner)

## 开始冲锋
static func _horse_start_charge(horse: Dictionary, target_x: float, on_arrive: String = ""):
	horse.charge_target_x = target_x
	horse.charge_speed = HORSE_CHARGE_SPEED
	horse.charge_on_arrive = on_arrive
	horse.charge_hit_list.clear()

static func _skill1(owner: Fighter):
	if _is_mounted(owner):
		_mounted_slam(owner)
	else:
		_soul_binding(owner)

## 铁骑·地裂：跳起后 40° 斜下坠地，AOE 伤害 15
static var _slam_rise_tex = preload("res://assets/char_ani/necro_knight/mounted_jump/necro_knight_mounted_jump_f_1.png")
static var _slam_crash_tex = preload("res://assets/fx_necro_slam.png")

static func _mounted_slam(owner: Fighter):
	if not owner.grounded:
		# 已在空中：直接坠地
		owner.state_flags["draw_texture_override"] = _slam_crash_tex
		_start_slam_crash(owner)
	else:
		# 跳起
		owner.vy = -7
		owner.vx = owner.facing * 3
		owner.grounded = false
		owner.state_flags["necro_slam_rising"] = true
		owner.state_flags["draw_texture_override"] = _slam_rise_tex
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 15, Color(0.3, 0.4, 0.9), 5, 8, "circle")

static func _start_slam_crash(owner: Fighter):
	owner.state_flags.erase("necro_slam_rising")
	owner.state_flags["necro_slam_crashing"] = true
	owner.state_flags["draw_texture_override"] = _slam_crash_tex
	var angle = deg_to_rad(30.0)
	var speed := 12.0
	owner.vy = speed * sin(angle)
	owner.vx = owner.facing * speed * cos(angle)
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 10, Color(0.2, 0.3, 0.8), 4, 6, "star")

static func _update_mounted_slam(owner: Fighter):
	if owner.state_flags.get("necro_slam_rising"):
		if owner.vy >= 0:
			_start_slam_crash(owner)
	elif owner.state_flags.get("necro_slam_crashing"):
		# 坠地途中吸附途径敌人
		var cx = owner.pos_x + owner.w / 2.0
		var cy = owner.pos_y + owner.h / 2.0
		for f in GameWorld.entities:
			if f == owner or f.hp <= 0:
				continue
			var fx = f.pos_x + f.w / 2.0
			var fy = f.pos_y + f.h / 2.0
			if absf(fx - cx) < 120 and absf(fy - cy) < 100:
				f.vx += owner.vx * 0.3
				f.vy += owner.vy * 0.3
		if owner.grounded:
			owner.state_flags["draw_texture_override"] = _slam_crash_tex
			# 着陆 AOE 伤害
			cx = owner.pos_x + owner.w / 2.0
			cy = owner.pos_y + owner.h / 2.0
			var SLAM_RANGE := 160.0
			var SLAM_DMG := 15.0
			for f in GameWorld.entities:
				if f == owner or f.hp <= 0:
					continue
				var fx = f.pos_x + f.w / 2.0
				var fy = f.pos_y + f.h / 2.0
				if absf(fx - cx) < SLAM_RANGE and absf(fy - cy) < SLAM_RANGE:
					f.hp -= SLAM_DMG
					f.vy = -8
					f.vx = owner.facing * 6
					f.damage_flash = 12
			owner.state_flags.erase("necro_slam_crashing")
			owner.state_flags["necro_slam_landed"] = 30  # 落地后保持坠地贴图 0.5s
			# 视觉特效
			Fighter.emit_particles(cx, cy, 30, Color(0.3, 0.4, 0.9), 6, 10, "circle")
			GameWorld.screen_shake_intensity = 6
			GameWorld.screen_shake_duration = 8
	# 落地贴图倒计时
	if owner.state_flags.get("necro_slam_landed", 0) > 0:
		owner.state_flags["necro_slam_landed"] -= 1
		if owner.state_flags["necro_slam_landed"] <= 0:
			owner.state_flags.erase("necro_slam_landed")
			owner.state_flags.erase("draw_texture_override")

## 缚命裁决：吸附身前 300px 敌人，若拉至 100px 内则终结

static func _soul_binding(owner: Fighter):
	var comp = _get_comp(owner)
	if not comp:
		return
	comp.skill1_pull_active = true
	comp.skill1_pull_timer = 30  # 0.5s
	comp.skill1_pull_dmg.clear()
	comp.skill1_finisher = false
	# 切换为吸附贴图
	var tex = preload("res://assets/fx_necro_pull.png")
	owner.state_flags["draw_texture_override"] = tex
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 20, Color(0.2, 0.3, 0.8), 5, 8, "circle")

static func _update_soul_binding(owner: Fighter):
	var comp = _get_comp(owner)
	if not comp or not comp.skill1_pull_active:
		return
	comp.skill1_pull_timer -= 1
	var knight_cx = owner.pos_x + owner.w / 2.0
	var front_center = knight_cx + owner.facing * 150
	var PULL_RANGE := 150.0
	var PULL_SPEED := 15.0
	var FINISHER_RANGE := 160.0
	var MAX_PULL_DMG := 5.0
	var FINISHER_DMG := 10.0
	
	for f in GameWorld.entities:
		if f == owner or f.hp <= 0:
			continue
		var fx = f.pos_x + f.w / 2.0
		if absf(fx - front_center) > PULL_RANGE:
			continue
		var fid = f.get_instance_id()
		var dmg_dealt: float = comp.skill1_pull_dmg.get(fid, 0.0)
		# 吸附力
		var dir = 1 if knight_cx > fx else -1
		f.vx += dir * PULL_SPEED * 0.15
		# 帧伤害
		if dmg_dealt < MAX_PULL_DMG:
			var frame_dmg = minf(0.17, MAX_PULL_DMG - dmg_dealt)
			f.hp -= frame_dmg
			f.damage_flash = 4
			comp.skill1_pull_dmg[fid] = dmg_dealt + frame_dmg
		# 检测终结
		if absf(fx - knight_cx) < FINISHER_RANGE:
			comp.skill1_finisher = true
	
	# 持续绘制吸附效果粒子
	if comp.skill1_pull_timer % 3 == 0:
		Fighter.emit_particles(knight_cx, owner.pos_y + owner.h / 2.0, 3, Color(0.2, 0.3, 0.9), 3, 4, "circle")
	
	# 吸附结束
	if comp.skill1_pull_timer <= 0:
		if comp.skill1_finisher:
			_execute_finisher(owner, FINISHER_DMG)
		else:
			owner.state_flags.erase("draw_texture_override")
		comp.skill1_pull_active = false

static func _execute_finisher(owner: Fighter, dmg: float):
	var knight_cx = owner.pos_x + owner.w / 2.0
	# 切换为终结贴图
	var tex = preload("res://assets/fx_necro_execute.png")
	owner.state_flags["draw_texture_override"] = tex
	var comp = _get_comp(owner)
	if comp:
		comp.skill1_execute_flash = 45  # 0.75s
	# 终结伤害
	for f in GameWorld.entities:
		if f == owner or f.hp <= 0:
			continue
		var fx = f.pos_x + f.w / 2.0
		if absf(fx - knight_cx) < 160:
			f.hp -= dmg
			f.vy = -6
			f.vx = owner.facing * 6
			f.damage_flash = 15
			Fighter.emit_particles(fx, f.pos_y + f.h / 2.0, 25, Color(0.3, 0.5, 1.0), 6, 10, "star")

## 技能二：终焉盟约 — 切换死契形态
static func _skill2(owner: Fighter):
	var horse = _get_horse(owner)
	if not horse:
		_spawn_horse(owner)
		horse = _get_horse(owner)
		if not horse:
			return
	if _is_mounted(owner):
		# 骑乘 → 分离：下马 + 战马向前冲刺
		_comp_dismount(owner, false)
		var target_x = owner.pos_x + owner.facing * HORSE_CHARGE_DIST
		_horse_start_charge(horse, target_x)
	else:
		# 分离 → 骑乘：战马冲回骑士身边
		_horse_start_charge(horse, owner.pos_x, "mount")

## 大招：亡者行军 — 帧规格（仿 Bard 模式）
static func _ult_frame_specs() -> Array:
	var specs := []
	for i in range(1, ULT_FRAME_COUNT + 1):
		var dur := ULT_FRAME_DUR
		if i == ULT_FRAME_COUNT:
			dur = 1.0
		specs.append({"index": i, "duration": dur, "filename": "output_%04d.png" % i})
	return specs

## 大招：亡者行军 — 执行（仿 Bard 模式）
static func _ult(owner: Fighter) -> Dictionary:
	var comp = _get_comp(owner)
	if not comp:
		return {"success": false}
	
	var ult_anim = FrameAnimation.load_from_frames(NECRO_ANI_DIR + "ult/", "", _ult_frame_specs(), false)
	if ult_anim.frames.is_empty():
		printerr("[NecroKnight] ult animation failed to load frames")
		return {"success": false}
	ult_anim.play()
	
	# 运行时注入 ult 动画到 config 中供 update_state 使用
	owner.config["animations"]["ult"] = ult_anim
	
	comp.ult_active = true
	comp.ult_timer = 0
	comp.ult_damage_acc = 0.0
	comp.ult_anim_obj = ult_anim
	owner.state = "ult"
	GameWorld.hit_stop = 20
	
	GameWorld.active_overlays.append({
		"anim": ult_anim,
		"position": {"type": "fullscreen"},
		"overlay_id": "necro_ult",
		"on_finish": func():
			comp.ult_active = false
			comp.ult_anim_obj = null
			owner.state = "idle"
	})
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 60, Color(0.2, 0.3, 0.8), 8, 14, "circle", 1.5)
	return {"success": true}

## 大招：亡者行军 — 逐帧出伤更新（仿 Bard 模式）
static func _update_ult(owner: Fighter):
	var comp = _get_comp(owner)
	if not comp or not comp.ult_active:
		return
	# 出伤窗口：第 ULT_DAMAGE_START_FRAME 帧～末尾（末尾帧 1.0s）
	const DAMAGE_START := int(ULT_DAMAGE_START_FRAME * ULT_FRAME_DUR * 60)
	const TOTAL_DUR := int((ULT_FRAME_COUNT - 1) * ULT_FRAME_DUR * 60 + 60)
	const DAMAGE_WINDOW := TOTAL_DUR - DAMAGE_START
	const DAMAGE_PER_TICK := ULT_TOTAL_DAMAGE / float(DAMAGE_WINDOW)
	
	comp.ult_timer += 1
	if comp.ult_timer >= DAMAGE_START:
		comp.ult_damage_acc += DAMAGE_PER_TICK
		var dmg = floori(comp.ult_damage_acc)
		if dmg > 0:
			var enemy = GameWorld.get_opponent(owner)
			if enemy and enemy.hp > 0:
				Fighter.apply_damage(enemy, float(dmg), owner, false, Color(0.2, 0.3, 0.8), "hit_enemy", "ult", 0)
			comp.ult_damage_acc -= dmg
	# overlay 动画结束后由 on_finish 回调清理 ult_active

# ── 不死之身 ──
static var _undying_anim: FrameAnimation = null

## 不死之身动画更新
static func _update_undying(owner: Fighter):
	var comp = _get_comp(owner)
	if not comp or not comp.undying_active:
		return
	comp.undying_timer -= 1
	# 首帧：创建全屏 overlay
	if not _undying_anim:
		_undying_anim = FrameAnimation.new()
		_undying_anim.add_frame(preload("res://assets/fx_necro_undying_1.png"), 0.333)
		_undying_anim.add_frame(preload("res://assets/fx_necro_undying_2.png"), 0.333)
		_undying_anim.add_frame(preload("res://assets/fx_necro_undying_3.png"), 0.333)
		_undying_anim.loop = true
		_undying_anim.play()
		GameWorld.active_overlays.append({
			"anim": _undying_anim,
			"position": {"type": "fullscreen"},
			"overlay_id": "necro_undying",
		})
	# 动画结束：复活
	if comp.undying_timer <= 0:
		comp.undying_active = false
		comp.undying_triggered = true
		_undying_anim.stop()
		_undying_anim = null
		owner.hp = 20
		owner.energy = minf(owner.max_energy, owner.energy + 40)
		# 振飞所有敌人到板边
		var knight_cx = owner.pos_x + owner.w / 2.0
		for f in GameWorld.entities:
			if f == owner or f.hp <= 0:
				continue
			var fx = f.pos_x + f.w / 2.0
			if fx < knight_cx:
				f.pos_x = 10
			else:
				f.pos_x = 2400 - 10 - f.w
			f.vy = -6
			f.damage_flash = 12
		Fighter.emit_particles(knight_cx, owner.pos_y + owner.h / 2.0, 50, Color(0.3, 0.5, 1.0), 8, 12, "circle", 2.0)
		GameWorld.screen_shake_intensity = 12
		GameWorld.screen_shake_duration = 15

# ── 输入 ──

static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var horse = _get_horse(owner)
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	var mounted = _is_mounted(owner)  # 跳前用骑乘状态判断
	if keys.up and owner.grounded:
		var jump_speed = -10.0
		if mounted:
			jump_speed *= MOUNTED_JUMP_BOOST
		owner.vy = jump_speed
		owner.grounded = false
	if keys.attack and owner.attack_cooldown <= 0 and not owner.attacking and not owner.dashing:
		owner.attacking = true; owner.attack_timer = 30; owner.attack_delay = 8
		owner.attack_hit_dealt = false; owner.attack_cooldown = ATK_COOLDOWN
		if mounted:
			owner.attack_range = 60
			owner.attack_damage = ATK_DMG * (1.2 if mx != 0 else 1.0)
	# 技能触发
	if keys.skill1:
		var s1 = owner.get_skill("skill1")
		if s1: var r1 = s1.try_use(owner); if r1.get("success"): keys.skill1 = false
	if keys.skill2:
		var s2 = owner.get_skill("skill2")
		if s2: var r2 = s2.try_use(owner); if r2.get("success"): keys.skill2 = false
	if keys.ult:
		var s3 = owner.get_skill("ult")
		if s3: var r3 = s3.try_use(owner); if r3.get("success"): keys.ult = false
	# 技能可能改变骑乘状态，重新读取
	mounted = _is_mounted(owner)
	var speed = MOUNTED_SPEED if mounted else 2.2
	Fighter.apply_movement(owner, mx, speed)
	if horse and mounted:
		horse.x = owner.pos_x
		horse.y = owner.pos_y
	if mounted:
		if owner.attacking:
			if owner.image_state != "mounted_attack":
				owner.set_animation_state("mounted_attack")
		else:
			var new_state = "mounted_idle"
			if not owner.grounded:
				new_state = "mounted_jump"
			elif mx != 0:
				new_state = "mounted_walk"
			if owner.image_state != new_state:
				owner.set_animation_state(new_state)
	else:
		# 从骑乘切到分离时，强制重置为普通动画状态
		if owner.image_state.begins_with("mounted_"):
			owner.image_state = ""
			Fighter.update_state(owner, mx)
		else:
			Fighter.update_state(owner, mx)
	return mx

# ── 绘制 ──

static var _horse_idle_anim: FrameAnimation = null
static var _horse_walk_anim: FrameAnimation = null

static func _load_animations():
	if _horse_idle_anim:
		return
	_horse_idle_anim = FrameAnimation.load_from_frames(NECRO_ANI_DIR + "horse_idle/", "necro_knight_horse_idle_f_", [{"index": 1, "duration": 999.0}], true)
	_horse_walk_anim = FrameAnimation.load_from_frames(NECRO_ANI_DIR + "horse_walk/", "necro_knight_horse_walk_f_", [{"index": 1, "duration": 0.333}, {"index": 2, "duration": 0.333}], true)

static func _draw_horses(_font, cam_x, _cam_y = 0.0):
	_load_animations()
	var items: Array = []
	for h in horses:
		if not h is Dictionary:
			continue
		var hd: Dictionary = h
		var h_owner: Fighter = hd["owner"]
		if is_instance_valid(h_owner) and _is_mounted(h_owner):
			continue
		var hx = hd["x"] - cam_x
		var hy = hd["y"] - _cam_y + 20
		var h_vx: float = hd["vx"]
		var h_grounded: bool = hd["grounded"]
		var anim: FrameAnimation = _horse_walk_anim if absf(h_vx) > 0.1 and h_grounded else _horse_idle_anim
		if anim and not anim.is_playing():
			anim.play()
		var tex: Texture2D = anim.get_current_texture() if anim else null
		var hw: float = hd["w"] * 0.8
		var hh: float = hd["h"] * 0.8
		if tex:
			var h_facing: int = hd.get("facing", 1)
			if h_facing < 0:
				items.append({"type": "set_transform", "pos": Vector2(hx + hw, hy), "rot": 0.0, "scale": Vector2(-1, 1)})
				items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, hw, hh), "color": Color.WHITE})
				items.append({"type": "reset_transform"})
			else:
				items.append({"type": "tex", "tex": tex, "rect": Rect2(hx, hy, hw, hh), "color": Color.WHITE})
		else:
			items.append({"type": "rect", "rect": Rect2(hx, hy, hw, hh), "color": Color(0.2, 0.3, 0.8, 0.5), "filled": true})
	return items

static func _inject_draw():
	GameWorld.register_draw_effect("necro_horses", func(font, cam_x, _cam_y = 0.0):
		return _draw_horses(font, cam_x, _cam_y)
	, 1)

# ===== 地狱模式 AI（由 AISystem 通过 CharacterFactory 调度，配置驱动） =====

## 地狱模式 AI 战术钩子
## ctx 字段: target / dist / dir / rand / diff / player / skill1 / skill2 / ult / can_use_s1 / can_use_s2 / can_use_ult
## 返回已处理的状态（"ATTACK"/"DODGE"/"DEFEND"），返回 "" 表示未处理走默认 AI
static func ai_hell_tactics(f: Fighter, ctx: Dictionary) -> String:
	var player = ctx.get("player")
	var dist = ctx.get("dist", 99999.0)
	var dir = ctx.get("dir", 1)
	var rand = ctx.get("rand", 0.0)
	var skill1: Skill = ctx.get("skill1")
	var skill2: Skill = ctx.get("skill2")
	var ult: Skill = ctx.get("ult")
	var can_use_s1 = ctx.get("can_use_s1", false)
	var can_use_s2 = ctx.get("can_use_s2", false)
	var can_use_ult = ctx.get("can_use_ult", false)
	var mounted = _is_mounted(f)

	# ① 玩家残血 → 大招亡者行军斩杀
	if can_use_ult and player and player.hp > 0 and player.hp < player.max_hp * 0.45 and dist < 300 and rand < 0.5:
		f.facing = dir
		ult.try_use(f)
		return "ATTACK"

	if mounted:
		# ② 骑乘中：近身跳斩（铁骑·地裂），远处维持追击（由走位钩子控制）
		if can_use_s1 and dist < 200 and rand < 0.5:
			f.facing = dir
			skill1.try_use(f)
			return "ATTACK"
		# ③ 贴脸 → 骑乘普攻（攻击范围更大）
		if dist < 100:
			f.facing = dir
			if f.attack_cooldown <= 0 and not f.attacking:
				f.attacking = true; f.attack_timer = 30; f.attack_delay = 8
				f.attack_hit_dealt = false; f.attack_cooldown = ATK_COOLDOWN
				f.attack_range = 60
				f.attack_damage = ATK_DMG * 1.2
			return "ATTACK"
		return ""

	# 分离（未骑乘）：
	# ④ 远距离 → 上马冲阵（战马冲回→骑乘）
	if dist > 250 and can_use_s2 and rand < 0.4:
		f.facing = dir
		skill2.try_use(f)
		return "ATTACK"
	# ⑤ 中距离 → 缚命裁决（吸附身前敌人 + 终结）
	if can_use_s1 and dist < 320 and dist > 60 and rand < 0.4:
		f.facing = dir
		skill1.try_use(f)
		return "ATTACK"
	# ⑥ 贴脸 → 普通普攻
	if dist < 90:
		f.facing = dir
		if f.attack_cooldown <= 0 and not f.attacking:
			f.attacking = true; f.attack_timer = 30; f.attack_delay = 8
			f.attack_hit_dealt = false; f.attack_cooldown = ATK_COOLDOWN
			f.attack_range = 44
		return "ATTACK"

	return ""

## 地狱模式专属走位参数（空字典表示不覆盖）
static func ai_hell_desire(f: Fighter) -> Dictionary:
	if _is_mounted(f):
		return {"min": 0, "max": 60}  # 骑乘冲阵贴脸
	return {"min": 0, "max": 80}
