# 骑士 (knight)
class_name KnightCharacter

const KNIGHT_ANI_DIR = "res://assets/char_ani/knight/"
const KNIGHT_FOOT_GAPS = preload("res://data/foot_gaps/knight_attack_foot_gaps.gd")
const KNIGHT_SKILL2_FOOT_GAPS = preload("res://data/foot_gaps/knight_skill2_foot_gaps.gd")
const PROJ_RENDING = preload("res://assets/fx_knight_rending_wave.png")       # 裂空牙剑气（强化普攻）
const CHAR_ENHANCED_ATK = preload("res://assets/fx_knight_enhanced_rending.png")  # 强化普攻/蓄力结束角色贴图
const PROJ_RENDING_SKILL2 = preload("res://assets/fx_knight_rending_skill2.png")  # 二技能裂空剑气
const CHAR_CHARGE = preload("res://assets/fx_knight_charge.png")                  # 蓄力中角色贴图
const PROJ_HALF_MOON = preload("res://assets/fx_knight_half_moon.png")            # 半月斩剑气

# 技能二：不屈回响 — 招架
const PARRY_DEFENSE := 200.0        # 招架防御 +200（护甲公式等效减伤 80%）

# 大招：战至黎明
const ULT_ENERGY_COST := 0             # 强化模式能量消耗即为代价
const ULT_COOLDOWN := 300              # 5秒
const ENHANCED_ENERGY_DRAIN := 10.0     # 每秒消耗能量
const ENHANCED_DEFENSE := 12.5         # 强化模式防御 +12.5（护甲公式等效减伤 20%）
const ENHANCED_ATK_DMG := 5.0           # 裂空牙伤害
const ENHANCED_ATK_CD := 90             # 裂空牙冷却 1.5s
const ENHANCED_ATK_ENERGY := 5          # 命中回复能量
const ENHANCED_ATK_FLY := 300           # 裂空牙飞行距离（像素）
const ULT_FRAME_COUNT := 9

# 一技能：半月斩
const SKILL1_DMG := 12.0
const SKILL1_ENERGY := 15
const SKILL1_COOLDOWN := 720            # 12秒
const SKILL1_BASE_W := 90               # 剑气基础宽度（1.5倍原始）
const SKILL1_BASE_H := 45               # 剑气基础高度（1.5倍原始）
const SKILL1_FLY_SPD := 6.0             # 飞行速度
const SKILL1_FLY_DIST := 400            # 飞行距离（像素）

static func get_config() -> Dictionary:
	return {
		"id": "knight", "name": "骑士", "hp": 100, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.25, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		"image_scale": 1.2,
		"attack_image_scale": 1.7,  # 普攻贴图独立缩放
		"fields": {}, "world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_frames(KNIGHT_ANI_DIR + "idle/", "knight_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk": FrameAnimation.load_from_frames(KNIGHT_ANI_DIR + "walk/", "knight_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_from_frames(KNIGHT_ANI_DIR + "jump/", "knight_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_sprite_sheet(KNIGHT_ANI_DIR + "attack_sheet.png", 3, 3, 8, 0.1, false, _knight_attack_anchors()),
			"skill2": FrameAnimation.load_from_sprite_sheet(KNIGHT_ANI_DIR + "skill2/sheet.png", 3, 2, 6, 0.1, false, _knight_skill2_anchors()),
			"ult": FrameAnimation.load_from_frames(KNIGHT_ANI_DIR + "ult/", "knight_ult_f_", _ult_frame_specs(), false),
		},
		"dex": {
			"icon": "⚔️",
			"intro": "剑锋划破硝烟，盾面刻满战痕。他从不闪避，因为身后即是王座——凡人之躯，亦可铸就城墙。冲锋的号角撕裂长夜，铁蹄踏碎一切犹豫。\n\"难道你只有这点觉悟吗？\"",
			"stats": [{"label": "生命", "value": "100"}, {"label": "能量上限", "value": "100"}],
			"skills": [
				{"name": "正义穿刺（普通攻击）", "desc": "用剑刺穿敌人，附带 50 像素前冲位移，造成 5 点伤害。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "半月斩（技能一）", "desc": "蓄力打出半月形剑气。蓄力 <1s：正常大小；1~2s：1.5倍；2~3s：2倍。伤害12，飞行距离400。", "meta": "消耗：15 能 ｜ 冷却：12 秒"},
				{"name": "不屈回响（技能二）", "desc": "举盾招架1.5s，防御力+200。招架飞行物反弹（速度5）；招架近战释放淡蓝冲击波击退+眩晕2s+降伤20%持续5s。成功回复15能量+伤害提升10%持续5s。若未招架到，可按下普攻释放裂空剑气（穿透+15伤），但冷却+3s（仅单次）。招架结束进入12s冷却。", "meta": "消耗：20 能 ｜ 冷却：12 秒"},
				{"name": "战至黎明（大招）", "desc": "散发蓝色能量进入强化模式：防御力+12.5，普攻变为裂空牙（穿透剑气，5伤，冷却1.5s），命中回复5能量。强化模式下能量消耗10/秒，能量耗尽后结束。", "meta": "消耗：无（强化模式消耗能量） ｜ 冷却：5 秒"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("ult", "战至黎明", ULT_COOLDOWN, ULT_ENERGY_COST, Callable(), Callable(_ult)),
		Skill.new("skill1", "半月斩", SKILL1_COOLDOWN, SKILL1_ENERGY, func(owner: Fighter): return owner.grounded, Callable(_skill1)),
		Skill.new("skill2", "不屈回响", 720, 20, func(owner: Fighter): return owner.grounded, Callable(_skill2)),
	]

## 技能二：不屈回响 — 招架 1.5s，防御+200（等效减伤80%），成功反弹/眩晕+回能+加伤
static func _skill2(owner: Fighter) -> Dictionary:
	var comp: KnightComponent = owner.components.get_component("knight") if owner.components else null
	if not comp:
		return {"success": false}
	comp.parry_active = true
	comp.parry_timer = 90  # 1.5秒
	comp.parry_hit = false
	comp.parry_cd_on_end = true
	comp.rending_used = false
	owner.defense += PARRY_DEFENSE  # 招架防御 +200（等效减伤 80%）
	owner.state_flags["parry_reflect"] = true  # 招架期间反弹飞行物
	owner.set_animation_state("skill2")  # 招架贴图
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 25, Color(1.0, 0.87, 0.27), 4, 6, "star")
	return {"success": true}

## 技能一：半月斩 — 开始蓄力，松开 U 键后释放
static func _skill1(owner: Fighter) -> Dictionary:
	var comp: KnightComponent = owner.components.get_component("knight") if owner.components else null
	if not comp:
		return {"success": false}
	comp.charging_skill1 = true
	comp.charge_start = Time.get_ticks_msec()
	owner.charging_skill1 = true
	owner.charge_start_time = comp.charge_start
	# 切换蓄力贴图
	var charge_anim = FrameAnimation.new()
	charge_anim.add_frame(CHAR_CHARGE, 999.0)
	charge_anim.loop = true
	owner.config["animations"]["skill1_charge"] = charge_anim
	owner.set_animation_state("skill1_charge")
	return {"success": true}

## 半月斩发射
static func _fire_half_moon(owner: Fighter, comp: KnightComponent):
	comp.charging_skill1 = false
	owner.charging_skill1 = false
	
	var elapsed = (Time.get_ticks_msec() - comp.charge_start) / 1000.0  # 秒
	var scale: float = 1.0
	if elapsed >= 3.0:
		scale = 2.0
	elif elapsed >= 1.0:
		scale = 1.5
	
	var dir = owner.facing
	var px = owner.pos_x + (owner.w if dir == 1 else 0)
	var py = owner.pos_y + 40
	var bw = SKILL1_BASE_W * scale
	var bh = SKILL1_BASE_H * scale
	var life_frames = int(SKILL1_FLY_DIST / SKILL1_FLY_SPD)
	
	GameWorld.projectiles.append({
		"x": px - bw / 2.0, "y": py - bh / 2.0,
		"w": bw, "h": bh,
		"vx": SKILL1_FLY_SPD * dir, "vy": 0.0,
		"life": life_frames, "damage": SKILL1_DMG,
		"owner": owner, "type": "knight_half_moon",
		"color": Color(1.0, 0.87, 0.27),
		"piercing": true,
		"reflected": false,
		"img": PROJ_HALF_MOON,
	})
	Fighter.emit_particles(px, py, 25, Color(1.0, 0.87, 0.27), 6, 8, "star")
	
	# 蓄力结束贴图（10帧 ≈ 0.17s）
	comp.charge_end_pose_timer = 10
	var end_anim = FrameAnimation.new()
	end_anim.add_frame(CHAR_ENHANCED_ATK, 0.3)
	end_anim.loop = false
	owner.config["animations"]["skill1_end"] = end_anim
	owner.set_animation_state("skill1_end")

## 大招：战至黎明 — 进入强化模式（防御+12.5，普攻变裂空牙，能量持续消耗）
static func _ult(owner: Fighter) -> Dictionary:
	var comp: KnightComponent = owner.components.get_component("knight") if owner.components else null
	if not comp:
		return {"success": false}
	if comp.enhanced_mode:
		return {"success": false}
	# 需要至少 30 能量才能激活（否则强化模式瞬间结束）
	if owner.energy < 100:
		return {"success": false}

	# 播放全屏 overlay 大招动画
	var ult_anim = FrameAnimation.load_from_frames(KNIGHT_ANI_DIR + "ult/", "knight_ult_f_", _ult_frame_specs(), false)
	if ult_anim.frames.is_empty():
		return {"success": false}
	ult_anim.play()
	owner.config["animations"]["ult"] = ult_anim

	# 激活强化模式
	comp.enhanced_mode = true
	comp.enhanced_drain_timer = 0
	comp.enhanced_attack_cd = 0
	owner.defense += ENHANCED_DEFENSE  # 强化模式防御 +12.5（等效减伤 20%）
	owner.state = "ult"
	GameWorld.hit_stop = 20

	GameWorld.active_overlays.append({
		"anim": ult_anim,
		"position": {"type": "fullscreen"},
		"overlay_id": "knight_ult",
		"on_finish": func():
			owner.state = "idle"
	})

	# 蓝色能量粒子特效
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(0.2, 0.4, 1.0, 0.3), 10, 12, "star", 2.0)
	return {"success": true}

## 大招帧规格（9帧，含时长数据）
static func _ult_frame_specs() -> Array:
	var specs := []
	# timetable: f1~f7 0.248s, f8 0.497s, f9 1.0s
	for i in range(1, ULT_FRAME_COUNT + 1):
		var dur: float = 0.248
		if i == 8: dur = 0.497
		elif i == 9: dur = 1.0
		specs.append({"index": i, "duration": dur})
	return specs

## 攻击动画锚点：把扫描生成的 GDScript 常量组装成 FrameAnimation 需要的字典数组
static func _knight_attack_anchors() -> Array:
	var anchors := []
	for i in range(KNIGHT_FOOT_GAPS.KNIGHT_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": KNIGHT_FOOT_GAPS.KNIGHT_ATTACK_FOOT[i],
			"head_gap": KNIGHT_FOOT_GAPS.KNIGHT_ATTACK_HEAD[i],
			"center_dx": KNIGHT_FOOT_GAPS.KNIGHT_ATTACK_CENTER[i],
			"content_w": KNIGHT_FOOT_GAPS.KNIGHT_ATTACK_CONTENT_W[i],
			"content_h": KNIGHT_FOOT_GAPS.KNIGHT_ATTACK_CONTENT_H[i],
		})
	return anchors

## 技能2动画锚点：同 _knight_attack_anchors 写法，常量来自 knight_skill2_foot_gaps.gd
static func _knight_skill2_anchors() -> Array:
	var anchors := []
	for i in range(KNIGHT_SKILL2_FOOT_GAPS.KNIGHT_SKILL2_FOOT.size()):
		anchors.append({
			"foot_gap": KNIGHT_SKILL2_FOOT_GAPS.KNIGHT_SKILL2_FOOT[i],
			"head_gap": KNIGHT_SKILL2_FOOT_GAPS.KNIGHT_SKILL2_HEAD[i],
			"center_dx": KNIGHT_SKILL2_FOOT_GAPS.KNIGHT_SKILL2_CENTER[i],
			"content_w": KNIGHT_SKILL2_FOOT_GAPS.KNIGHT_SKILL2_CONTENT_W[i],
			"content_h": KNIGHT_SKILL2_FOOT_GAPS.KNIGHT_SKILL2_CONTENT_H[i],
		})
	return anchors

## 输入处理
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and owner.grounded:
		owner.vy = -10
		owner.grounded = false
	# 普攻：正义穿刺（强化模式：裂空牙）
	if keys.attack:
		var comp: KnightComponent = owner.components.get_component("knight") if owner.components else null
		if comp and comp.enhanced_mode:
			# 强化普攻：裂空牙
			if comp.enhanced_attack_cd <= 0 and not owner.attacking and not owner.dashing:
				_fire_enhanced_rending(owner, comp)
				keys.attack = false
		elif comp and comp.parry_active and not comp.parry_hit and not comp.rending_used:
			_fire_rending_wave(owner, comp)
			keys.attack = false
		elif owner.attack_cooldown <= 0 and not owner.attacking and not owner.dashing:
			owner.attacking = true
			owner.attack_timer = 30
			owner.attack_delay = 8
			owner.attack_hit_dealt = false
			owner.attack_cooldown = 60
			owner.dashing = true
			owner.dash_remaining = 10
			owner.dash_dir = owner.facing
			owner.dash_speed = 5.0
			owner.state = "attack"
			keys.attack = false
	# 技能一：半月斩 — 按住 U 蓄力，松开释放
	var comp: KnightComponent = owner.components.get_component("knight") if owner.components else null
	if comp:
		if keys.skill1 and not comp.charging_skill1:
			var s = owner.get_skill("skill1")
			if s:
				var _r = s.try_use(owner)
		elif not keys.skill1 and comp.charging_skill1:
			_fire_half_moon(owner, comp)
	# 大招：战至黎明
	if keys.ult:
		var s = owner.get_skill("ult")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.ult = false
	# 技能二：不屈回响
	if keys.skill2:
		var s = owner.get_skill("skill2")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill2 = false
	# 蓄力中移速减40%
	Fighter.apply_movement(owner, mx, 2.25 * (0.6 if comp.charging_skill1 else 1.0))
	Fighter.update_state(owner, mx)
	return mx

## 裂空：招架中普攻释放穿透剑气（15伤，冷却+3s仅单次）
static func _fire_rending_wave(owner: Fighter, comp: KnightComponent):
	comp.rending_used = true
	var dir = owner.facing
	var px = owner.pos_x + (owner.w if dir == 1 else 0)
	var py = owner.pos_y + 40
	GameWorld.projectiles.append({
		"x": px - 30, "y": py - 15,
		"w": 60, "h": 30,
		"vx": 8.0 * dir, "vy": 0.0,
		"life": 60, "damage": 15.0,
		"owner": owner, "type": "knight_rending",
		"color": Color(0.53, 0.87, 1.0),
		"piercing": true,
		"reflected": false,
		"img": PROJ_RENDING_SKILL2,
	})
	Fighter.emit_particles(px, py, 20, Color(0.53, 0.87, 1.0), 5, 6, "circle")
	# 冷却加3秒
	var s = owner.get_skill("skill2")
	if s:
		s.cd += 180

## 裂空牙：强化普攻 — 切换角色贴图 + 穿透剑气（5伤，冷却1.5s，命中回5能量）
static func _fire_enhanced_rending(owner: Fighter, comp: KnightComponent):
	comp.enhanced_attack_cd = ENHANCED_ATK_CD
	
	# 切换为强化普攻角色贴图（持续 0.3s）
	var atk_anim = FrameAnimation.new()
	atk_anim.add_frame(CHAR_ENHANCED_ATK, 0.3)
	atk_anim.loop = false
	owner.config["animations"]["skill_enhanced_attack"] = atk_anim
	owner.set_animation_state("skill_enhanced_attack")
	comp.enhanced_atk_pose_timer = 18  # 0.3s
	
	var dir = owner.facing
	var px = owner.pos_x + (owner.w if dir == 1 else 0)
	var py = owner.pos_y + 40
	GameWorld.projectiles.append({
		"x": px - 30, "y": py - 15,
		"w": 60, "h": 30,
		"vx": 6.0 * dir, "vy": 0.0,
		"life": 50, "damage": ENHANCED_ATK_DMG,
		"owner": owner, "type": "knight_enhanced_rending",
		"color": Color(0.5, 0.6, 1.0),
		"piercing": true,
		"on_hit_energy": ENHANCED_ATK_ENERGY,
		"reflected": false,
		"img": PROJ_RENDING,
	})
	Fighter.emit_particles(px, py, 15, Color(0.5, 0.6, 1.0), 4, 5, "star")

## 每帧更新：招架计时 + 增益/减益管理
static func update_systems(owner: Fighter):
	# 动画帧推进：循环动画（walk/idle）需要每帧 update 才能换帧；
	# 非循环动画（attack/ult）播放中同样推进，播完后由状态机切回 idle。
	if owner.current_anim and owner.current_anim.is_playing():
		owner.current_anim.update(1.0)

	var comp: KnightComponent = owner.components.get_component("knight") if owner.components else null
	if not comp:
		return

	# 蓄力结束姿态计时（到时还原为 idle）
	if comp.charge_end_pose_timer > 0:
		comp.charge_end_pose_timer -= 1
		if comp.charge_end_pose_timer <= 0 and owner.image_state == "skill1_end":
			owner.set_animation_state("idle")

	# AI 蓄力自动释放：最多蓄 3 秒后自动发射
	if comp.charging_skill1 and not owner.is_player:
		var ct = (Time.get_ticks_msec() - comp.charge_start) / 1000.0
		if ct >= 3.0:
			_fire_half_moon(owner, comp)

	# 招架倒计时
	if comp.parry_active:
		comp.parry_timer -= 1
		if comp.parry_timer <= 0:
			comp.parry_active = false
			owner.defense = maxf(0.0, owner.defense - PARRY_DEFENSE)  # 还原招架防御（保留其他来源如强化模式）
			owner.state_flags.erase("parry_reflect")
			if owner.image_state == "skill2":
				owner.image_state = ""
			# 招架结束（无论成功失败）→ 进入冷却
			if comp.parry_cd_on_end:
				comp.parry_cd_on_end = false
				var s = owner.get_skill("skill2")
				if s:
					s.cd = s.cooldown

	# 骑士攻击提升计时（10%）
	if comp.atk_boost_timer > 0:
		comp.atk_boost_timer -= 1
		if comp.atk_boost_timer <= 0:
			owner.attack_boost = maxf(0, owner.attack_boost - comp.atk_boost_amt)
			comp.atk_boost_amt = 0.0

	# 敌人伤害降低计时（20%）
	if comp.debuff_timer > 0:
		comp.debuff_timer -= 1
		if comp.debuff_timer <= 0 and comp.debuff_target:
			comp.debuff_target.attack_damage = comp._debuff_original_dmg
			comp.debuff_target = null

	# 强化模式：能量消耗 + 普攻冷却 + 粒子特效
	if comp.enhanced_mode:
		# 裂空牙冷却
		if comp.enhanced_attack_cd > 0:
			comp.enhanced_attack_cd -= 1
		# 强化普攻姿态计时（到时还原为 idle）
		if comp.enhanced_atk_pose_timer > 0:
			comp.enhanced_atk_pose_timer -= 1
			if comp.enhanced_atk_pose_timer <= 0 and owner.image_state == "skill_enhanced_attack":
				owner.set_animation_state("idle")
		# 能量消耗：10/秒 = 10/60 每帧
		owner.energy = maxf(0, owner.energy - ENHANCED_ENERGY_DRAIN / 60.0)
		# 淡蓝色光晕粒子（每帧）
		Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 5, Color(0.3, 0.5, 1.0, 0.35), 4, 7, "circle", 1.0)
		Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 2, Color(0.2, 0.4, 1.0, 0.2), 6, 10, "star", 1.5)
		# 能量耗尽 → 退出强化模式
		if owner.energy <= 0:
			comp.enhanced_mode = false
			owner.defense = maxf(0.0, owner.defense - ENHANCED_DEFENSE)
			owner.energy = 0
