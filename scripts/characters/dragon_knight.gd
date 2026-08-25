# 龙骑士 (dragon_knight)
class_name DragonKnightCharacter

const DK_ANI_DIR = "res://assets/char_ani/dragon_knight/"
const DK_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_idle_foot_gaps.gd")
const DK_IN_AIR_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_in_air_foot_gaps.gd")
const DK_SKILL2_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_skill2_foot_gaps.gd")
const DK_SKILL1_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_skill1_foot_gaps.gd")
const DK_WALK_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_walk_foot_gaps.gd")
const DK_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_jump_foot_gaps.gd")
const DK_DRAGON_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_dragon_foot_gaps.gd")
const DK_DRAGON_SHEET = "res://assets/sheet.dragon.png"  # 巨龙形态振翅循环动画（4x4，前14格）
const DK_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/dragon_knight_attack_sheet_foot_gaps.gd")
const DK_ATTACK_SHEET = "res://assets/sheet.attack.png"  # 巨龙形态普攻吐息动画（4x4，16格）
const DK_SKY_RISE_ANIM_DURATION := 91   # 上挑动画实际时长（舍弃前2帧后 sheet 15帧×6+1）
# 鳞反格挡成功演出（参考骑士二技能招架成功效果）：时缓 + 时缓结束后中震
const DK_BLOCK_SLOW_MO := 90        # 格挡成功时缓帧数（90 帧 ≈ 1.5s 实机时间）
const DK_BLOCK_SLOW_MO_FACTOR := 12 # 时缓力度：12 倍慢速（与骑士招架一致）
const DK_BLOCK_SHAKE := 8.0         # 格挡成功屏幕震动强度（中等偏轻）
const DK_BLOCK_SHAKE_DUR := 12      # 格挡成功屏幕震动持续帧数
# 大招一段（化龙）演出：时缓 + 时缓结束后中震
const DK_ULT1_SLOW_MO := 60         # 化龙时缓帧数（60 帧 = 1s 实机时间）
const DK_ULT1_SLOW_MO_FACTOR := 12  # 时缓力度：12 倍慢速
const DK_ULT1_SHAKE := 10.0         # 化龙屏幕震动强度（中等）
const DK_ULT1_SHAKE_DUR := 12       # 化龙屏幕震动持续帧数
const DK_FIRE_STAB = preload("res://assets/fx_dragon_knight_fire_stab.png")
const DK_SKY_SPLIT = preload("res://assets/char_ani/dragon_knight/attack/dragon_knight_attack_air_f_1.png")
const DK_DIVE_STRIKE = preload("res://assets/fx_dragon_knight_dive_strike.png")
const DK_SHIELD = preload("res://assets/fx_dragon_knight_scale_counter.png")
const DK_FIREBALL_GROUND = preload("res://assets/fx_dragon_knight_fireball_ground.png")
const DK_FIREBALL_AIR = preload("res://assets/fx_dragon_knight_fireball_air.png")

# ── 单帧动画锚点（保持人物大小与多帧 sheet 一致：内容高度 → 碰撞体高度） ──
const DK_FIRE_STAB_ANCHOR = {"foot_gap": 231, "head_gap": 407, "center_dx": 35.5, "content_w": 1977, "content_h": 1410}
const DK_SKY_SPLIT_ANCHOR = {"foot_gap": 0, "head_gap": 144, "center_dx": -1.0, "content_w": 2022, "content_h": 1904}
const DK_DIVE_STRIKE_ANCHOR = {"foot_gap": 161, "head_gap": 325, "center_dx": -22.5, "content_w": 2003, "content_h": 1562}

## 从预加载贴图创建单帧 FrameAnimation（anchor 可选：{foot_gap, head_gap, center_dx, content_w, content_h}）
static func _make_anim(tex: Texture2D, dur: float, loop: bool = false, anchor: Dictionary = {}) -> FrameAnimation:
	var a = FrameAnimation.new()
	a.add_frame(tex, dur, anchor.get("foot_gap", 0), anchor.get("head_gap", 0), anchor.get("center_dx", 0.0), anchor.get("content_w", 0), anchor.get("content_h", 0))
	a.loop = loop
	return a

## idle 动画锚点：从 foot_gaps 常量组装 FrameAnimation 需要的字典数组
static func _dragon_knight_idle_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_FOOT_GAPS.DRAGON_KNIGHT_IDLE_FOOT.size():
		anchors.append({
			"foot_gap": DK_FOOT_GAPS.DRAGON_KNIGHT_IDLE_FOOT[i],
			"head_gap": DK_FOOT_GAPS.DRAGON_KNIGHT_IDLE_HEAD[i],
			"center_dx": DK_FOOT_GAPS.DRAGON_KNIGHT_IDLE_CENTER[i],
			"content_w": DK_FOOT_GAPS.DRAGON_KNIGHT_IDLE_CONTENT_W[i],
			"content_h": DK_FOOT_GAPS.DRAGON_KNIGHT_IDLE_CONTENT_H[i],
		})
	return anchors

## walk 动画锚点：同 _dragon_knight_idle_anchors 写法
static func _dragon_knight_walk_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_WALK_FOOT_GAPS.DRAGON_KNIGHT_WALK_FOOT.size():
		anchors.append({
			"foot_gap": DK_WALK_FOOT_GAPS.DRAGON_KNIGHT_WALK_FOOT[i],
			"head_gap": DK_WALK_FOOT_GAPS.DRAGON_KNIGHT_WALK_HEAD[i],
			"center_dx": DK_WALK_FOOT_GAPS.DRAGON_KNIGHT_WALK_CENTER[i],
			"content_w": DK_WALK_FOOT_GAPS.DRAGON_KNIGHT_WALK_CONTENT_W[i],
			"content_h": DK_WALK_FOOT_GAPS.DRAGON_KNIGHT_WALK_CONTENT_H[i],
		})
	return anchors

## jump 动画锚点：同 _dragon_knight_idle_anchors 写法
static func _dragon_knight_jump_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_JUMP_FOOT_GAPS.DRAGON_KNIGHT_JUMP_FOOT.size():
		anchors.append({
			"foot_gap": DK_JUMP_FOOT_GAPS.DRAGON_KNIGHT_JUMP_FOOT[i],
			"head_gap": DK_JUMP_FOOT_GAPS.DRAGON_KNIGHT_JUMP_HEAD[i],
			"center_dx": DK_JUMP_FOOT_GAPS.DRAGON_KNIGHT_JUMP_CENTER[i],
			"content_w": DK_JUMP_FOOT_GAPS.DRAGON_KNIGHT_JUMP_CONTENT_W[i],
			"content_h": DK_JUMP_FOOT_GAPS.DRAGON_KNIGHT_JUMP_CONTENT_H[i],
		})
	return anchors

## in_air 动画锚点：同 _dragon_knight_idle_anchors 写法
static func _dragon_knight_in_air_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_IN_AIR_FOOT_GAPS.DRAGON_KNIGHT_IN_AIR_FOOT.size():
		anchors.append({
			"foot_gap": DK_IN_AIR_FOOT_GAPS.DRAGON_KNIGHT_IN_AIR_FOOT[i],
			"head_gap": DK_IN_AIR_FOOT_GAPS.DRAGON_KNIGHT_IN_AIR_HEAD[i],
			"center_dx": DK_IN_AIR_FOOT_GAPS.DRAGON_KNIGHT_IN_AIR_CENTER[i],
			"content_w": DK_IN_AIR_FOOT_GAPS.DRAGON_KNIGHT_IN_AIR_CONTENT_W[i],
			"content_h": DK_IN_AIR_FOOT_GAPS.DRAGON_KNIGHT_IN_AIR_CONTENT_H[i],
		})
	return anchors

## skill2 动画锚点：同 _dragon_knight_idle_anchors 写法
static func _dragon_knight_skill2_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_SKILL2_FOOT_GAPS.DRAGON_KNIGHT_SKILL2_FOOT.size():
		anchors.append({
			"foot_gap": DK_SKILL2_FOOT_GAPS.DRAGON_KNIGHT_SKILL2_FOOT[i],
			"head_gap": DK_SKILL2_FOOT_GAPS.DRAGON_KNIGHT_SKILL2_HEAD[i],
			"center_dx": DK_SKILL2_FOOT_GAPS.DRAGON_KNIGHT_SKILL2_CENTER[i],
			"content_w": DK_SKILL2_FOOT_GAPS.DRAGON_KNIGHT_SKILL2_CONTENT_W[i],
			"content_h": DK_SKILL2_FOOT_GAPS.DRAGON_KNIGHT_SKILL2_CONTENT_H[i],
		})
	return anchors

## 技能一（上挑）动画锚点：同 _dragon_knight_idle_anchors 写法
static func _dragon_knight_skill1_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_SKILL1_FOOT_GAPS.DRAGON_KNIGHT_SKILL1_FOOT.size():
		anchors.append({
			"foot_gap": DK_SKILL1_FOOT_GAPS.DRAGON_KNIGHT_SKILL1_FOOT[i],
			"head_gap": DK_SKILL1_FOOT_GAPS.DRAGON_KNIGHT_SKILL1_HEAD[i],
			"center_dx": DK_SKILL1_FOOT_GAPS.DRAGON_KNIGHT_SKILL1_CENTER[i],
			"content_w": DK_SKILL1_FOOT_GAPS.DRAGON_KNIGHT_SKILL1_CONTENT_W[i],
			"content_h": DK_SKILL1_FOOT_GAPS.DRAGON_KNIGHT_SKILL1_CONTENT_H[i],
		})
	return anchors

## 技能一动画：加载 sheet 后舍弃前两帧（蓄力帧），保留原第 3~17 帧共 15 帧（锚点随帧携带）
static func _dragon_knight_skill1_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(DK_ANI_DIR + "skill1/sheet.png", 5, 4, 17, 0.1, false, _dragon_knight_skill1_anchors())
	if anim.frames.size() > 2:
		anim.frames = anim.frames.slice(2, anim.frames.size())
		anim._calc_total_duration()
		anim._calc_content_h_ref()
	return anim

## 巨龙形态振翅循环动画锚点（sheet.dragon.png 4x4 网格前 14 格）
static func _dragon_knight_dragon_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_DRAGON_FOOT_GAPS.DRAGON_KNIGHT_DRAGON_FOOT.size():
		anchors.append({
			"foot_gap": DK_DRAGON_FOOT_GAPS.DRAGON_KNIGHT_DRAGON_FOOT[i],
			"head_gap": DK_DRAGON_FOOT_GAPS.DRAGON_KNIGHT_DRAGON_HEAD[i],
			"center_dx": DK_DRAGON_FOOT_GAPS.DRAGON_KNIGHT_DRAGON_CENTER[i],
			"content_w": DK_DRAGON_FOOT_GAPS.DRAGON_KNIGHT_DRAGON_CONTENT_W[i],
			"content_h": DK_DRAGON_FOOT_GAPS.DRAGON_KNIGHT_DRAGON_CONTENT_H[i],
		})
	return anchors

## 巨龙形态普攻吐息动画锚点（sheet.attack.png 4x3 网格 12 格）
static func _dragon_knight_attack_sheet_anchors() -> Array[Dictionary]:
	var anchors: Array[Dictionary] = []
	for i in DK_ATTACK_FOOT_GAPS.DRAGON_KNIGHT_ATTACK_SHEET_FOOT.size():
		anchors.append({
			"foot_gap": DK_ATTACK_FOOT_GAPS.DRAGON_KNIGHT_ATTACK_SHEET_FOOT[i],
			"head_gap": DK_ATTACK_FOOT_GAPS.DRAGON_KNIGHT_ATTACK_SHEET_HEAD[i],
			"center_dx": DK_ATTACK_FOOT_GAPS.DRAGON_KNIGHT_ATTACK_SHEET_CENTER[i],
			"content_w": DK_ATTACK_FOOT_GAPS.DRAGON_KNIGHT_ATTACK_SHEET_CONTENT_W[i],
			"content_h": DK_ATTACK_FOOT_GAPS.DRAGON_KNIGHT_ATTACK_SHEET_CONTENT_H[i],
		})
	return anchors

static func get_config() -> Dictionary:
	return {
		"id": "dragon_knight", "name": "龙骑士", "hp": 100, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.2, "attack_range": 44, "attack_damage": 5,
		"attack_cooldown": 60, "attack_delay": 8, "attack_duration": 30,
		"image_scale": 1.2,
		# 一技能上挑动画放大 1.2 倍：蓄力/起跳帧内容高度偏矮，放大后填满碰撞盒
		# 巨龙形态 3.6 倍：锚点基准(56px内容高)放大后渲染约 202px，比原 336px 缩小 40%
		"anim_scale_states": {"skill1": 1.2, "ult": 3.6, "ult_flight": 3.6, "ult_attack": 3.6},
		"fields": {
			"dragon_scales_active": false,
			"dragon_scales_timer": 0,
			"dragon_form_active": false,
			"dragon_form_timer": 0,
			"dk_burn_applied": false,
			"dk_ult_phase2_active": false,
			"dk_ult_phase2_timer": 0,
			"dk_ult_fire_tick": 0,
			"dk_ult_fire_total": 0.0,
			"dk_ult_claw_dealt": false,
			"dk_ult_target_locked": false,
		},
		"world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(DK_ANI_DIR + "idle/sheet.png", 4, 3, 11, 0.1, true, _dragon_knight_idle_anchors()),
			"walk": FrameAnimation.load_from_sprite_sheet(DK_ANI_DIR + "walk/sheet.png", 4, 3, 11, 0.1, true, _dragon_knight_walk_anchors()),
			"jump": FrameAnimation.load_jump_sheet(DK_ANI_DIR + "jump/sheet.png", 3, 3, 4, 0.2, _dragon_knight_jump_anchors()),
			"attack": _make_anim(DK_FIRE_STAB, 0.5, false, DK_FIRE_STAB_ANCHOR),
			"attack_air": _make_anim(DK_SKY_SPLIT, 0.5, false, DK_SKY_SPLIT_ANCHOR),
			"skill1": _dragon_knight_skill1_anim(),
			"skill1_phase2": _make_anim(DK_DIVE_STRIKE, 0.5, false, DK_DIVE_STRIKE_ANCHOR),
			"skill2": FrameAnimation.load_from_sprite_sheet(DK_ANI_DIR + "skill2/sheet.png", 5, 5, 24, 0.02, false, _dragon_knight_skill2_anchors()),
			"in_air": FrameAnimation.load_from_sprite_sheet(DK_ANI_DIR + "in_air/sheet.png", 3, 3, 9, 0.1, true, _dragon_knight_in_air_anchors()),
			"ult": FrameAnimation.load_from_sprite_sheet(DK_DRAGON_SHEET, 4, 4, 14, 0.1, true, _dragon_knight_dragon_anchors()),
			"ult_flight": FrameAnimation.load_from_sprite_sheet(DK_DRAGON_SHEET, 4, 4, 14, 0.1, true, _dragon_knight_dragon_anchors()),
			"ult_attack": FrameAnimation.load_from_sprite_sheet(DK_ATTACK_SHEET, 4, 3, 12, 0.05, false, _dragon_knight_attack_sheet_anchors()),
		},
		"dex": {
			"icon": "🐉",
			"intro": "龙息灼烧天穹，长枪洞穿虚伪——他踏碎城墙而来，以龙之名，行使暴烈的正义。他化作火龙，用熔岩般的怒意将一切傲慢焚尽。他站在废墟之上，如同不可逾越的山岳，连神明都要侧目。\n\"蝼蚁……不配知晓我的名字。\"\n特殊机制「龙鳞」：免疫一切灼烧效果。",
			"stats": [
				{"label": "生命", "value": "100"},
				{"label": "龙怒（能量）", "value": "100"},
				{"label": "龙鳞", "value": "灼烧免疫"},
			],
			"skills": [
				{"name": "烈焰（普通攻击）", "desc": "地面：将火焰缠绕长枪向前猛刺，造成 5 点伤害并附加灼烧。空中：裂空——向下猛击。", "meta": "消耗：无 ｜ 冷却：1 秒"},
				{"name": "凌空 / 寂灭（技能一）", "desc": "【凌空】举枪上挑，击飞敌人并造成 5 点伤害+灼烧，自身进入 3 秒凌空飞行状态。\n【寂灭】凌空期间再次释放，斜向下冲刺重击敌人，造成 10 点伤害+灼烧，结束凌空。", "meta": "消耗：15 能量 ｜ 冷却：15 秒"},
				{"name": "鳞反（技能二）", "desc": "举盾防御，免疫所有伤害并吸收伤害值。防御结束后释放红色冲击波击飞敌人，造成 10 + 吸收伤害。点按举盾1秒，长按最多3秒（松手结束）。", "meta": "消耗：15 能量 ｜ 冷却：15 秒"},
				{"name": "龙魂（大招）", "desc": "化身为巨龙，免疫击退击飞，自由飞行 10 秒。飞行中只能使用火球普攻：喷射火球造成 7 伤害+灼烧。再次释放大招触发二段龙魂爆发，播放动画并造成 25 点大范围伤害，之后退出龙形态。", "meta": "消耗：40 能量 ｜ 冷却：20 秒"},
			]
		},
		"ai_profile": {"ideal_range": [0, 140], "kite": false},
	}

static func create_skills() -> Array:
	# 多段技能：凌空（一段）→ 寂灭（二段），二段窗口 = 凌空飞行时长（10s）
	var s1 = Skill.make_staged("skill1", "凌空/寂灭", 900, 15, func(owner: Fighter): return true,
		[Callable(_skill1_phase1), Callable(_skill1_phase2)], 600)
	return [
		s1,
		Skill.new("skill2", "鳞反", 900, 15, Callable(_can_use_skill2), Callable(_skill2)),
		Skill.new("ult", "龙魂", 1200, 40, Callable(_can_use_ult), Callable(_ult)),
	]

# ===== 技能一：凌空（一段）/ 寂灭（二段） =====
## 一段：凌空 — 上挑击飞 + 自身跳起 + 进入飞行（由 Skill 多段框架调用）
## 伤害/震动不在释放瞬间触发，改为动画第 6 帧（update_systems 中）同步出手
static func _skill1_phase1(owner: Fighter) -> Dictionary:
	owner.energy -= 15
	var cx = owner.pos_x + owner.w / 2.0
	var cy = owner.pos_y + owner.h / 2.0
	owner.dk_skill1_hit_dealt = false  # 重置第6帧出伤标记

	# 进入凌空状态：动画前 3 帧贴地，动画第 4 帧（idx≥3）起离地（上升由 update_systems 控制）
	owner.dk_sky_rise_active = true
	owner.dk_sky_rise_anim_timer = DK_SKY_RISE_ANIM_DURATION  # 上挑动画播放一遍
	owner.dk_flight_timer = 600  # 飞行倒计时（不占用技能cd，确保寂灭可释放）
	owner.jump_phase = 0  # 清除跳跃动画阶段残留，避免跳跃状态机接管凌空
	owner.state_flags["no_jump_anim"] = true  # 飞行动画锁：凌空期间跳过跳跃动画状态机
	owner.set_animation_state("skill1")
	Fighter.emit_particles(cx, cy, 30, Color(1.0, 0.5, 0.1), 6, 10, "star")
	return {"success": true}

## 二段：寂灭 — 斜向下冲刺重击，10伤害+灼烧（仅凌空状态下可释放）
static func _skill1_phase2(owner: Fighter) -> Dictionary:
	if not owner.dk_sky_rise_active:
		return {"success": false}
	owner.dk_sky_rise_active = false
	owner.dk_crash_timer = 20  # 20帧斜下冲刺
	owner.dk_burn_applied = false
	owner.set_animation_state("skill1_phase2")
	# 初始速度：斜向下
	owner.vx = owner.facing * 6.0
	owner.vy = 8.0
	GameWorld.trigger_shake(5.0, 6)  # 释放二段（寂灭）：屏幕微震
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 25, Color(1.0, 0.2, 0.05), 8, 12, "star")
	return {"success": true}

# ===== 技能二：鳞反 =====
static func _can_use_skill2(owner: Fighter) -> bool:
	return not owner.dk_shield_active and not owner.dk_sky_rise_active and owner.dk_crash_timer <= 0 and not owner.dashing

static func _skill2(owner: Fighter) -> Dictionary:
	owner.energy -= 15
	owner.dk_shield_active = true
	owner.dk_shield_timer = 0
	owner.dk_shield_held = true
	owner.dk_shield_absorbed_damage = 0.0
	owner.dk_shield_block_fx = false      # 重置格挡成功演出标记（每次举盾触发一次）
	owner.dk_shield_shake_pending = false
	owner.set_animation_state("skill2")
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 15, Color(1.0, 0.3, 0.1), 5, 8, "circle")
	return {"success": true}

# ===== 大招：龙魂 =====
static func _can_use_ult(owner: Fighter) -> bool:
	return not owner.dk_ult_active and not owner.dk_shield_active and not owner.dk_sky_rise_active and owner.dk_crash_timer <= 0 and not owner.dashing

static func _ult(owner: Fighter) -> Dictionary:
	owner.energy -= 40
	owner.dk_ult_active = true
	owner.dk_ult_timer = 600  # 10 秒
	owner.set_animation_state("ult")
	owner.config["image_scale"] = 6.0  # 巨龙 5 倍大小
	# 大招一段（化龙）演出：时缓 + 时缓结束后中震
	GameWorld.trigger_slow_motion(DK_ULT1_SLOW_MO, DK_ULT1_SLOW_MO_FACTOR)
	owner.dk_ult1_shake_pending = true
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 60, Color(1.0, 0.15, 0.05), 14, 20, "star")
	return {"success": true}

## 大招二段：龙魂动画攻击（变龙后再次按键触发）— 全屏 overlay 动画
static func _start_ult_phase2(owner: Fighter):
	# 防重复
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "dk_ult":
			return

	var anim = FrameAnimation.load_from_frames(DK_ANI_DIR + "ult/", "dragon_knight_ult_f_", [
		{"index": 1, "duration": 0.507},
		{"index": 2, "duration": 0.338},
		{"index": 3, "duration": 0.338},
		{"index": 4, "duration": 0.169},
		{"index": 5, "duration": 0.507},
		{"index": 6, "duration": 0.338},
		{"index": 7, "duration": 0.507},
		{"index": 8, "duration": 0.507},
		{"index": 9, "duration": 0.338},
		{"index": 10, "duration": 0.338},
		{"index": 11, "duration": 0.169},
		{"index": 12, "duration": 0.169},
		{"index": 13, "duration": 0.169},
		{"index": 14, "duration": 0.169},
		{"index": 15, "duration": 0.169},
		{"index": 16, "duration": 1.000},
	], false)
	if anim.frames.is_empty():
		return
	anim.play()

	owner.dk_ult_phase2_active = true
	owner.dk_ult_phase2_timer = int(anim.total_duration * 60)
	owner.dk_ult_fire_tick = 0
	owner.dk_ult_fire_total = 0.0
	owner.dk_ult_claw_dealt = false
	# 锁敌：开大瞬间在范围内的敌人必吃满全部伤害
	var target_check = GameWorld.get_opponent(owner)
	owner.dk_ult_target_locked = target_check and target_check.hp > 0 and \
		absf(target_check.pos_x + target_check.w / 2.0 - owner.pos_x - owner.w / 2.0) < 300 and \
		absf(target_check.pos_y + target_check.h / 2.0 - owner.pos_y - owner.h / 2.0) < 400
	owner.vx = 0; owner.vy = 0

	GameWorld.active_overlays.append({
		"anim": anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "dk_ult",
		"border_color": Color(1.0, 0.1, 0.0),
		"on_finish": func():
			owner.dk_ult_active = false
			owner.dk_ult_phase2_active = false
			owner.config["image_scale"] = 1.2
			owner.set_animation_state("idle"); owner.state = "idle"
			var s3 = owner.get_skill("ult")
			if s3: s3.cd = s3.cooldown
	})

	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(1.0, 0.1, 0.0), 16, 25, "star")

# ===== 输入处理 =====
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	if owner.dk_crash_timer > 0:
		return 0
	if owner.dk_shield_active:
		owner.dk_shield_held = keys.skill2
		return 0
	if owner.dk_ult_active:
		return _input_ult(owner, keys)
	if owner.dk_sky_rise_active:
		return _input_sky_rise(owner, keys)

	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and owner.grounded: owner.vy = -10; owner.grounded = false
	if keys.attack and owner.attack_cooldown <= 0 and not owner.attacking:
		# 空中跳劈消耗 10 能量
		if not owner.grounded and owner.energy < 10:
			keys.attack = false
		else:
			if not owner.grounded:
				owner.energy -= 10
			owner.attacking = true; owner.attack_timer = 30; owner.attack_delay = 8
			owner.attack_hit_dealt = false; owner.attack_cooldown = 60
			owner.dk_burn_applied = false
			owner.state = "attack"
			Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 15, Color(1.0, 0.4, 0.1), 4, 6, "star")
			keys.attack = false
	if keys.skill1:
		var s = owner.get_skill("skill1")
		if s: var r = s.try_use(owner); if r.get("success"): keys.skill1 = false
	if keys.skill2:
		var s2 = owner.get_skill("skill2")
		if s2: var r = s2.try_use(owner); if r.get("success"): keys.skill2 = false
	if keys.ult:
		var s3 = owner.get_skill("ult")
		if s3: var r = s3.try_use(owner); if r.get("success"): keys.ult = false
	Fighter.apply_movement(owner, mx, owner.config.get("speed", 2.2))
	Fighter.update_state(owner, mx)
	return mx

## 凌空状态输入：自由飞行 + 裂空普攻
static func _input_sky_rise(owner: Fighter, keys: Dictionary) -> int:
	# 起跳阶段：不干预飞行，让物理自然处理跳跃
	if owner.dk_sky_rise_anim_timer > 0:
		return 0

	owner.set_animation_state("in_air")
	var fly_speed = 4.0
	var jx = 0.0; var jy = 0.0
	if keys.left: jx -= 1.0
	if keys.right: jx += 1.0
	if keys.up: jy -= 1.0
	if keys.down: jy += 1.0

	# 参考蔷薇强化二技能：直接修改坐标飞行
	owner.vx = 0; owner.vy = 0
	owner.pos_x = clampf(owner.pos_x + jx * fly_speed, 10, 2390 - owner.w)
	owner.pos_y = clampf(owner.pos_y + jy * fly_speed, 40, 380 - owner.h)
	if jx != 0: owner.facing = 1 if jx > 0 else -1

	# 普攻 → 裂空（独立计时器，绕过标准普攻流程）
	if keys.attack and owner.attack_cooldown <= 0 and not owner.attacking:
		owner.attacking = true; owner.attack_timer = 30
		owner.attack_delay = 999  # 阻止 fighter.gd 标准处理
		owner.attack_hit_dealt = true
		owner.attack_cooldown = 60
		owner.dk_burn_applied = false
		owner.dk_dive_attack_timer = 300  # 向下冲刺距离（参考圣骑士冲刺）
		owner.dk_crack_ends_flight = true  # 裂空结束后结束飞行
		owner.set_animation_state("attack_air")
		Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h, 12, Color(1.0, 0.5, 0.1), 4, 6, "circle")
		keys.attack = false

	# 技能一 → 寂灭（二段）：由多段框架释放下一段（窗口内不受 cd/能量限制）
	if keys.skill1:
		var s1 = owner.get_skill("skill1")
		if s1:
			s1.try_use(owner)
		keys.skill1 = false

	return 0

## 龙魂火球（地面/空中）——供玩家输入与 AI 共用
static func _ult_fireball(owner: Fighter):
	if owner.attack_cooldown > 0 or owner.attacking:
		return
	owner.attacking = true; owner.attack_timer = 20
	owner.attack_delay = 999  # 阻止 fighter.gd 标准攻击判定
	owner.attack_hit_dealt = true
	owner.attack_cooldown = 60
	owner.dk_burn_applied = false
	owner.set_animation_state("ult_attack")  # 巨龙形态普攻：吐息动画

	var px = owner.pos_x + (owner.w if owner.facing == 1 else 0)
	if owner.grounded:
		# 地面火球从口部偏高位置发射
		var py = owner.pos_y - 110
		GameWorld.projectiles.append({
			"x": px, "y": py-18, "w": 150, "h": 150,
			"vx": 5.0 * owner.facing, "vy": 0.0,
			"life": 120, "damage": 7, "owner": owner,
			"type": "dk_fireball", "color": Color(1.0, 0.3, 0.1),
			"img": DK_FIREBALL_GROUND, "burn": true,
			"reflected": false,
		})
	else:
		var py = owner.pos_y - 110  # 空中火球从口部发射
		GameWorld.projectiles.append({
			"x": px, "y": py, "w": 150, "h": 150,
			"vx": 4.0 * owner.facing, "vy": 3.0,  # 斜向下（参考魔女）
			"life": 120, "damage": 7, "owner": owner,
			"type": "dk_fireball", "color": Color(1.0, 0.3, 0.1),
			"img": DK_FIREBALL_AIR, "burn": true,
			"reflected": false,
		})
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 10, Color(1.0, 0.4, 0.1), 4, 6, "circle")
	GameWorld.trigger_shake(5.0, 6)  # 巨龙吐火：屏幕微震

## 龙魂大招输入：自由飞行 + 火球普攻 + 二段动画大招
static func _input_ult(owner: Fighter, keys: Dictionary) -> int:
	# 二段动画大招中：锁定所有输入
	if owner.dk_ult_phase2_active:
		keys.ult = false
		return 0

	# 再次按下大招 → 触发二段动画大招
	if keys.ult:
		_start_ult_phase2(owner)
		keys.ult = false
		return 0

	var fly_speed = 3.5
	var jx = 0.0; var jy = 0.0
	if keys.left: jx -= 1.0
	if keys.right: jx += 1.0
	if keys.up: jy -= 1.0
	if keys.down: jy += 1.0

	owner.vx = jx * fly_speed
	owner.vy = jy * fly_speed
	if jx != 0: owner.facing = 1 if jx > 0 else -1

	owner.pos_x = clampf(owner.pos_x, 10, 2390 - owner.w)
	owner.pos_y = clampf(owner.pos_y, 20, 380 - owner.h)

	# 火球普攻（唯一可用攻击，巨龙贴图保持待机/飞行不变）
	if keys.attack:
		_ult_fireball(owner)
		keys.attack = false

	return 0

# ===== 系统更新 =====
static func update_systems(owner: Fighter):
	# 空中普攻落地瞬间：屏幕微震（从空中攻击状态转为落地时触发一次）
	if owner.grounded:
		if owner.dk_air_atk_prev_air:
			owner.dk_air_atk_prev_air = false
			GameWorld.trigger_shake(5.0, 6)  # 屏幕微震
	else:
		if owner.attacking:
			owner.dk_air_atk_prev_air = true
	# 落地且不在凌空状态 → 解除飞行动画锁，恢复跳跃状态机接管（凌空/寂灭冲刺期间保持锁定）
	if owner.grounded and not owner.dk_sky_rise_active:
		owner.state_flags.erase("no_jump_anim")
	# 动画帧推进（多帧 sheet 动画需要每帧 update 才能换帧）
	if owner.current_anim and owner.current_anim.is_playing():
		owner.current_anim.update(1.0)
	# 鳞反：举盾吸收伤害
	if owner.dk_shield_active:
		owner.dk_shield_timer += 1
		owner.vx = 0
		owner.vy = 0
		# 格挡成功演出（参考骑士二技能招架成功效果）：首次吸收伤害 → 时缓，时缓结束后中震
		if owner.dk_shield_absorbed_damage > 0 and not owner.dk_shield_block_fx:
			owner.dk_shield_block_fx = true
			GameWorld.trigger_slow_motion(DK_BLOCK_SLOW_MO, DK_BLOCK_SLOW_MO_FACTOR)
			owner.dk_shield_shake_pending = true
		# 结束条件：满3秒 或 松手且满1秒
		var should_end = false
		if owner.dk_shield_timer >= 180:
			should_end = true
		elif not owner.dk_shield_held and owner.dk_shield_timer >= 60:
			should_end = true
		if should_end:
			owner.dk_shield_active = false
			owner.set_animation_state("idle"); owner.state = "idle"
			var total_dmg = 10.0 + owner.dk_shield_absorbed_damage
			var target = GameWorld.get_opponent(owner)
			if target and target.hp > 0:
				var dx = absf(target.pos_x + target.w / 2.0 - owner.pos_x - owner.w / 2.0)
				var dy = absf(target.pos_y + target.h / 2.0 - owner.pos_y - owner.h / 2.0)
				if dx < 250 and dy < 200:
					Fighter.apply_damage(target, total_dmg, owner)
					target.vy = -10
					target.vx = owner.facing * 6
			Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 40, Color(1.0, 0.15, 0.05), 12, 18, "circle")
			var s2 = owner.get_skill("skill2")
			if s2: s2.cd = s2.cooldown
		return

	# 格挡成功震动：时缓结束后再触发（格挡成功 > 时缓 > 震动，不与时缓同时；即使鳞反提前结束也补触发）
	if owner.dk_shield_shake_pending and GameWorld.slow_mo_timer <= 0:
		owner.dk_shield_shake_pending = false
		GameWorld.trigger_shake(DK_BLOCK_SHAKE, DK_BLOCK_SHAKE_DUR)

	# 大招一段（化龙）震动：时缓结束后再触发
	if owner.dk_ult1_shake_pending and GameWorld.slow_mo_timer <= 0:
		owner.dk_ult1_shake_pending = false
		GameWorld.trigger_shake(DK_ULT1_SHAKE, DK_ULT1_SHAKE_DUR)

	# 龙魂大招：倒计时 + 飞行动画交替 + 二段（全屏 overlay）
	if owner.dk_ult_active:
		# 二段：吐火 + 爪击两段伤害（动画由 overlay 系统管理）
		if owner.dk_ult_phase2_active:
			owner.vx = 0; owner.vy = 0
			owner.dk_ult_phase2_timer -= 1
			# ── 吐火阶段（frame3 ~ frame10，timer 292 → 110）：每15帧出伤，共15伤 ──
			if owner.dk_ult_phase2_timer <= 292 and owner.dk_ult_phase2_timer > 110 and owner.dk_ult_fire_total < 15.0:
				owner.dk_ult_fire_tick += 1
				if owner.dk_ult_fire_tick >= 15:
					owner.dk_ult_fire_tick = 0
					var dmg = minf(1.25, 15.0 - owner.dk_ult_fire_total)
					owner.dk_ult_fire_total += dmg
					if owner.dk_ult_target_locked:
						Fighter.apply_ult_damage_zone(owner, dmg)
			# ── 爪击（frame13，timer ≤ 90）：瞬间 10 伤 ──
			if not owner.dk_ult_claw_dealt and owner.dk_ult_phase2_timer <= 90:
				owner.dk_ult_claw_dealt = true
				if owner.dk_ult_target_locked:
					Fighter.apply_ult_damage_zone(owner, 10)
					var target = GameWorld.get_opponent(owner)
					if target and target.hp > 0:
						target.vy = -16
						target.vx = owner.facing * 10
				Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(1.0, 0.1, 0.0), 16, 24, "star")
			return

		owner.dk_ult_timer -= 1
		# 普攻 → 吐息动画；攻击结束等吐息动画播完再回振翅循环（ult/ult_flight 共用同一 sheet 循环）
		if owner.attacking:
			owner.set_animation_state("ult_attack")
		elif owner.image_state == "ult_attack":
			if owner.current_anim and owner.current_anim.is_finished():
				owner.set_animation_state("ult")
		else:
			owner.set_animation_state("ult")
		if owner.dk_ult_timer <= 0:
			owner.dk_ult_active = false
			owner.config["image_scale"] = 1.2  # 恢复原始大小
			owner.set_animation_state("idle"); owner.state = "idle"
			var s3 = owner.get_skill("ult")
			if s3: s3.cd = s3.cooldown
		return

	# 寂灭：斜下冲刺碰撞检测（优先于凌空飞行）
	if owner.dk_crash_timer > 0:
		owner.dk_crash_timer -= 1
		owner.vx = owner.facing * 8.0
		owner.vy = 6.0
		var target = GameWorld.get_opponent(owner)
		if target and target.hp > 0 and not owner.dk_burn_applied:
			var dx = absf(target.pos_x + target.w / 2.0 - owner.pos_x - owner.w / 2.0)
			var dy = target.pos_y + target.h / 2.0 - owner.pos_y - owner.h / 2.0
			if dx < 160 and dy > -40 and dy < 400:
				Fighter.apply_damage(target, 10, owner)
				target.add_status("burn")
				var burn = target.statuses.back()
				if burn and burn.id == "burn":
					burn.duration = 240; burn.timer = 240
					burn.tick_damage = 1.0; burn.tick_interval = 120
				owner.dk_burn_applied = true
		# 冲刺结束 → 落地，进入冷却
		if owner.dk_crash_timer <= 0:
			owner.dk_crash_timer = 0
			owner.set_animation_state("idle"); owner.state = "idle"
			var s = owner.get_skill("skill1")
			if s:
				s.end_stage_flow()  # 寂灭已释放，多段流程结束
				s.cd = s.cooldown
		return

	# 凌空飞行中
	if owner.dk_sky_rise_active:
		# 上挑动画播放期间（已舍弃前2帧蓄力帧）：动画第 4 帧（idx≥3 = 原第5帧）起离地持续上升，播完立即切 in_air
		if owner.dk_sky_rise_anim_timer > 0:
			owner.dk_sky_rise_anim_timer -= 1
			owner.set_animation_state("skill1")
			# 动画第 6 帧（idx≥5）出伤 + 微震（替换原释放瞬间立即出伤）
			if not owner.dk_skill1_hit_dealt and owner.current_anim and owner.current_anim.get_current_index() >= 5:
				owner.dk_skill1_hit_dealt = true
				GameWorld.trigger_shake(5.0, 6)  # 出伤瞬间屏幕微震
				var tgt = GameWorld.get_opponent(owner)
				if tgt and tgt.hp > 0:
					var cx2 = owner.pos_x + owner.w / 2.0
					var cy2 = owner.pos_y + owner.h / 2.0
					var dx2 = tgt.pos_x + tgt.w / 2.0 - cx2
					var dy2 = tgt.pos_y + tgt.h / 2.0 - cy2
					if absf(dx2) < 80 and absf(dy2) < 100:
						Fighter.apply_damage(tgt, 5, owner)
						tgt.vy = -9    # 击飞高度降低（原 -14）
						tgt.vx = owner.facing * 2  # 击退程度降低（原 4）
						tgt.add_status("burn")
						var burn2 = tgt.statuses.back()
						if burn2 and burn2.id == "burn":
							burn2.duration = 240
							burn2.timer = 240
							burn2.tick_damage = 1.0
							burn2.tick_interval = 120
			if owner.current_anim and owner.current_anim.get_current_index() >= 3:
				owner.grounded = false
				owner.vy = 0
				owner.pos_y = clampf(owner.pos_y - 3.0, 40, 380 - owner.h)
		else:
			owner.set_animation_state("in_air")
		# 飞行倒计时
		if owner.dk_flight_timer > 0:
			owner.dk_flight_timer -= 1
		if owner.dk_flight_timer <= 0 and owner.dk_sky_rise_active:
			owner.dk_sky_rise_active = false
			owner.set_animation_state("idle"); owner.state = "idle"
			var s = owner.get_skill("skill1")
			if s:
				s.end_stage_flow()  # 极限时间未释放寂灭 → 黄标消失
				s.cd = s.cooldown
		# 裂空：向下冲刺（距离驱动，参考圣骑士冲刺）
		if owner.dk_dive_attack_timer > 0:
			var step = minf(18.0, owner.dk_dive_attack_timer)
			owner.pos_y += step
			owner.dk_dive_attack_timer -= step
			owner.vy = 0
			var target = GameWorld.get_opponent(owner)
			if target and target.hp > 0:
				var dx = absf(target.pos_x + target.w / 2.0 - owner.pos_x - owner.w / 2.0)
				var dy = target.pos_y + target.h / 2.0 - owner.pos_y - owner.h / 2.0
				if dx < 180 and dy > -60 and dy < 500:
					Fighter.apply_damage(target, 5, owner)
					target.add_status("burn")
					var burn = target.statuses.back()
					if burn and burn.id == "burn":
						burn.duration = 240; burn.timer = 240
						burn.tick_damage = 1.0; burn.tick_interval = 120
					owner.dk_dive_attack_timer = 0  # 命中后停止检查
		# 裂空结束后结束飞行
		if owner.dk_crack_ends_flight and owner.dk_dive_attack_timer <= 0:
			owner.dk_sky_rise_active = false
			owner.dk_crack_ends_flight = false
			owner.set_animation_state("idle"); owner.state = "idle"
			var s2 = owner.get_skill("skill1")
			if s2:
				s2.end_stage_flow()  # 裂空结束飞行 → 未释放二段，流程结束
				s2.cd = s2.cooldown
		return

	if not owner.attacking:
		owner.dk_burn_applied = false
		return

	# 凌空状态下由 _input_sky_rise 控制，跳过地面/空中位移逻辑
	if owner.dk_sky_rise_active:
		return

	# 空中攻击时强制覆盖贴图为裂空
	if not owner.grounded:
		owner.set_animation_state("attack_air")

	# 空中下砸：完全接管命中判定，禁用 fighter.gd 的方向性攻击框
	if not owner.grounded and owner.attacking and not owner.dk_burn_applied:
		owner.attack_hit_dealt = true  # 阻止 fighter.gd 标准攻击判定
		if owner.attack_delay <= 0:
			var target = GameWorld.get_opponent(owner)
			if target and target.hp > 0:
				# 以玩家正下方为中心，160×160 范围区域伤害
				var cx = owner.pos_x + owner.w / 2.0
				var cy = owner.pos_y + owner.h
				var impact_area = Rect2(cx - 5, cy - 5, 10, 10)
				if impact_area.intersects(target.get_hit_box()):
					owner.dk_burn_applied = true
					Fighter.apply_damage(target, owner.attack_damage, owner)
					target.add_status("burn")
					var burn = target.statuses.back()
					if burn and burn.id == "burn":
						burn.duration = 240; burn.timer = 240
						burn.tick_damage = 1.0; burn.tick_interval = 120

	# 地面普攻：2 帧后向前突刺
	if not owner.dashing and owner.attack_timer == 28:
		if owner.grounded:
			owner.dashing = true
			owner.dash_remaining = 10
			owner.dash_dir = owner.facing
			owner.dash_speed = 4.0
			owner.dash_damage_dealt = true
		else:
			owner.vy = 16.0
			Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h, 12, Color(1.0, 0.5, 0.1), 4, 6, "circle")

	# 命中灼烧
	if owner.attack_delay <= 0 and not owner.dk_burn_applied:
		var target = GameWorld.get_opponent(owner)
		if target and target.hp > 0:
			if owner.get_attack_box().intersects(target.get_hit_box()):
				owner.dk_burn_applied = true
				target.add_status("burn")
				var burn = target.statuses.back()
				if burn and burn.id == "burn":
					burn.duration = 240
					burn.timer = 240
					burn.tick_damage = 1.0
					burn.tick_interval = 120

# ===== 地狱模式 AI（由 AISystem 通过 CharacterFactory 调度，配置驱动） =====

## 地狱模式 AI 战术钩子
## ctx 字段: target / dist / dir / rand / diff / player / skill1 / skill2 / ult / can_use_s1 / can_use_s2 / can_use_ult
## 返回已处理的状态（"ATTACK"/"DODGE"/"DEFEND"），返回 "" 表示未处理走默认 AI
static func ai_hell_tactics(f: Fighter, ctx: Dictionary) -> String:
	var target = ctx.get("target")
	var dist = ctx.get("dist", 99999.0)
	var dir = ctx.get("dir", 1)
	var rand = ctx.get("rand", 0.0)
	var player = ctx.get("player")
	var skill1: Skill = ctx.get("skill1")
	var skill2: Skill = ctx.get("skill2")
	var ult: Skill = ctx.get("ult")
	var can_use_s1 = ctx.get("can_use_s1", false)
	var can_use_s2 = ctx.get("can_use_s2", false)
	var can_use_ult = ctx.get("can_use_ult", false)

	# 龙魂状态：追击 + 火球压制 + 残血二段斩杀
	if f.dk_ult_active:
		if f.dk_ult_phase2_active:
			return "ATTACK"  # 二段动画中锁定
		var tx = target.pos_x if target is Fighter else target.get("x", 0.0)
		f.facing = 1 if tx > f.pos_x else -1
		# 低空悬停逼近玩家
		f.vx = f.facing * ctx["diff"]["move_speed"] * 0.7
		f.vy = -3.0
		_ult_fireball(f)
		# 玩家残血或贴脸 → 二段龙魂爆发
		if player and player.hp > 0 and (player.hp < player.max_hp * 0.4 or absf(player.pos_x - f.pos_x) < 120):
			_start_ult_phase2(f)
		return "ATTACK"

	# 鳞反中：原地防御
	if f.dk_shield_active:
		return "DEFEND"

	# 凌空飞行中：主动释放寂灭俯冲（与玩家操作一致，绕过 cd 直接触发）
	if f.dk_sky_rise_active:
		if f.dk_sky_rise_anim_timer <= 0:
			_skill1_phase2(f)
		return "ATTACK"

	# ① 玩家攻击中 + 贴脸 → 鳞反反伤（55%）
	if can_use_s2 and player and player.hp > 0 and player.attacking and dist < 120 and rand < 0.55:
		f.facing = dir
		skill2.try_use(f)
		return "DEFEND"

	# ② 能量充足 → 龙魂变身压制（中近距离或玩家残血）
	if can_use_ult and (dist < 250 or (player and player.hp > 0 and player.hp < player.max_hp * 0.4)) and rand < 0.4:
		f.facing = dir
		ult.try_use(f)
		return "ATTACK"

	# ③ 中距离 → 凌空上挑，抢占空中优势（为寂灭俯冲做铺垫）
	if can_use_s1 and dist < 260 and dist > 40 and rand < 0.4:
		f.facing = dir
		skill1.try_use(f)
		return "ATTACK"

	# ④ 贴脸 → 地面普攻（火焰突刺 + 灼烧）
	if dist < 80:
		f.facing = dir
		if f.attack_cooldown <= 0 and not f.attacking:
			f.attacking = true; f.attack_timer = 30; f.attack_delay = 8
			f.attack_hit_dealt = false; f.attack_cooldown = 60
			f.dk_burn_applied = false
			f.state = "attack"
		return "ATTACK"

	return ""

## 地狱模式专属走位参数（空字典表示不覆盖）
static func ai_hell_desire(f: Fighter) -> Dictionary:
	return {"min": 0, "max": 140}

## 体系统：龙骑士状态分类（技能打断优先级）
static func body_priority(f: Fighter) -> int:
	if f.dk_ult_active:
		return Fighter.BODY_ARMOR  # 龙魂 = 霸体
	if f.dk_shield_active:
		return Fighter.BODY_SKILL  # 鳞反 = 防御类技能体
	if f.dk_sky_rise_active or f.dk_crash_timer > 0:
		return Fighter.BODY_SKILL  # 凌空 / 寂灭
	return -1  # 龙化形态不加优先级（普攻体）

## 防御/招架类：鳞反免疫打断
static func is_defense_parry(f: Fighter) -> bool:
	return f.dk_shield_active

## 被中断时：取消凌空飞行/坠击
static func on_interrupted(f: Fighter):
	f.dk_sky_rise_active = false
	f.dk_crash_timer = 0
	f.dk_flight_timer = 0
	f.state_flags.erase("no_jump_anim")
