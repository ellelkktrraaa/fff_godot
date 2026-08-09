# 狂战士 (berserker)
# ═══════════════════════════════════════════════════════════════
#  使用说明：
#  1. 贴图放置于 assets/char_ani/berserker/{state}/ 目录，
#     文件名格式 {berserker}_{state}_f_{index}.png
#  2. 替换 get_config() 中 animations 的占位动画为
#     FrameAnimation.load_from_frames(...) 调用（见注释示例）
#  3. 技能骨架已就绪，可在对应 _skill1 / _skill2 / _ult 中填充
#  4. 每帧专属逻辑在 update_systems() 中扩展
# ═══════════════════════════════════════════════════════════════
class_name BerserkerCharacter

const BERSERKER_ANI_DIR = "res://assets/char_ani/berserker/"

# ── 基础属性 ──
const BASE_HP := 100.0
const BASE_ENERGY := 80.0
const BASE_SPEED := 2.2          # 偏慢的重装战士
const BASE_ATK_RANGE := 64.0     # 双斧斩击范围（较宽）
const BASE_ATK_DMG := 5.0        # 连斩总伤害（2 + 3）
const ATK_COOLDOWN := 55
const ATK_DELAY := 8
const ATK_DURATION := 30

# ── 技能一：飞斧 ──
const SKILL1_ENERGY := 15
const SKILL1_COOLDOWN := 480     # 8秒
const AXE_SPEED := 6.0           # 斧头飞行速度
const AXE_DIST := 200.0          # 斧头飞行距离，抵达后瞬移连斩
const AXE_DMG := 1.0             # 斧头沿途撞击伤害
const AXE_HIT_CD := 8            # 每个敌人撞击冷却（帧），配合击退实现多次撞击（参考亡灵战马）
const AXE_KNOCKBACK_MULT := 1.5  # 击退速度 = 飞行速度 × 该倍率：敌人被推到斧头前方后斧头追上再撞
const AXE_ROT_SPEED := 0.8       # 斧头旋转角速度（弧度/帧）
const AXE_W := 34.0
const AXE_H := 34.0
const SLASH1_DMG := 5.0          # 连斩第一段
const SLASH2_DMG := 7.0          # 连斩第二段
const SLASH_RANGE_MULT := 1.5    # 连斩前方攻击范围放大倍率（基础 64 → 96，判定框含角色全身）

# ── 技能二 二段（狂暴专属）：地裂 ──
const GROUND_SPLIT_WINDOW := 360     # 释放断筋斩后 6s 内可释放地裂
const GROUND_SPLIT_DMG := 5.0        # 地裂冲击波伤害
const GROUND_SPLIT_DIST := 100.0     # 冲击波飞行距离
const GROUND_SPLIT_SPEED := 6.0      # 冲击波飞行速度
const GROUND_SPLIT_H := 46.0         # 冲击波高度（贴地）
const GROUND_SPLIT_CD_BONUS := 180   # 使用地裂后技能二冷却 +3s
const GROUND_SPLIT_STOMP_FRAMES := 30  # 踩碎地面动作持续 0.5s
const GROUND_SPLIT_IMG_SCALE := 2.0  # 冲击波贴图放大 2 倍
const STOMP_TEX = preload("res://assets/fx_berserker_stomp.png")   # 踩碎地面
const GROUND_SPLIT_TEX = preload("res://assets/fx_berserker_ground_split.png") # 冲击波
static var _ground_split_tex_mirrored: Texture2D = null

## 冲击波贴图水平镜像（镜像后使用）
static func _get_mirrored_ground_split_tex() -> Texture2D:
	if not _ground_split_tex_mirrored:
		var img = GROUND_SPLIT_TEX.get_image()
		img.flip_x()
		_ground_split_tex_mirrored = ImageTexture.create_from_image(img)
	return _ground_split_tex_mirrored

# ── 技能一 二段（狂暴专属）：瞬斩 ──
const FLASH_SLASH_WINDOW := 360     # 使用飞斧后 6s 内可释放瞬斩
const FLASH_SLASH_DIST := 200.0     # 冲刺距离
const FLASH_SLASH_SPEED := 10.0     # 冲刺速度
const FLASH_SLASH_DMG := 5.0        # 斩击伤害
const FLASH_SLASH_CD_BONUS := 180   # 使用瞬斩后技能一冷却 +3s
const FLASH_SLASH_TEX = preload("res://assets/fx_berserker_flash_slash.png")

# 飞斧贴图（斧头旋转绘制 / 扔出动画 / 连斩）
const AXE_TEX = preload("res://assets/fx_berserker_axe.png")
const BERSERKER_SLASH_TEX = preload("res://assets/char_ani/berserker/skill1/berserker_skill1_f_2.png")
const SLASH_TEX_SCALE := 1.2      # 连斩贴图（berserker_skill1_f_2.png）放大倍数

# ── 技能二：断筋斩 ──
const SKILL2_ENERGY := 15
const SKILL2_COOLDOWN := 900     # 15秒
const PARRY_DURATION := 60       # 举斧招架 1s
const TENDON_SLASH_DURATION := 60   # 断筋斩演出 1s（期间自己和范围内敌人不能移动）
const TENDON_SLASH_DMG := 15.0      # 断筋斩总伤害（60 帧按帧出伤）
const TENDON_SLASH_RANGE := 100.0   # 断筋斩命中范围（含自身前后）
const TENDON_SLASH_SCALE := 1.8     # 断筋斩贴图放大倍数

# 技能二贴图（招架 / 断筋斩）
const PARRY_TEX = preload("res://assets/fx_berserker_parry.png")
const TENDON_SLASH_TEX = preload("res://assets/fx_berserker_tendon_slash.png")
static var _tendon_slash_tex_mirrored: Texture2D = null  # 镜像后的断筋斩贴图（惰性生成）

## 断筋斩贴图水平镜像（贴图提供方向与角色朝向不匹配时使用）
static func _get_mirrored_tendon_tex() -> Texture2D:
	if not _tendon_slash_tex_mirrored:
		var img = TENDON_SLASH_TEX.get_image()
		img.flip_x()
		_tendon_slash_tex_mirrored = ImageTexture.create_from_image(img)
	return _tendon_slash_tex_mirrored

# ── 大招：诸神黄昏（巨大龙卷风） ──
const ULT_ENERGY := 80
const ULT_COOLDOWN := 600        # 10秒
const ULT_FRAME_COUNT := 30      # 动画帧数（ult/berserker_ult_f_1 ~ 30）
const ULT_FRAME_DUR := 0.238     # 每帧基础时长（秒，来自 output_timetable）
const ULT_TOTAL_DMG := 40.0      # 龙卷风总伤害
const ULT_DAMAGE_START := 8      # 第 8 帧开始出伤（龙卷风成型）
const ULT_DAMAGE_END := 19       # 出伤持续到第 19 帧

# ── 子技能：战吼（7键） ──
const SUB_ENERGY := 0
const SUB_COOLDOWN := 1200       # 20秒
const WAR_CRY_DURATION := 90     # 战吼持续 1.5s（霸体 + 减伤50%）
const WAR_CRY_DEFENSE := 50.0    # 减伤50%（护甲公式 defense/(defense+50) 等效）
const WAR_CRY_RAGE_HP := 0.4     # 血量低于上限 40% 时使用 → 狂暴模式
const WAR_CRY_TEX = preload("res://assets/fx_berserker_warcry.png")

# 狂暴模式红色斗气（透明 png 叠加在角色身上，20帧切换循环）
const RAGE_AURA_TEX1 = preload("res://assets/fx_berserker_rage_aura_1.png")
const RAGE_AURA_TEX2 = preload("res://assets/fx_berserker_rage_aura_2.png")
const RAGE_AURA_SWITCH := 20    # 20 帧切换一帧
const RAGE_AURA_SCALE := 1.15   # 斗气略大于角色身体

## 创建占位动画（纯色块，贴图就绪后替换为 load_from_frames）
static func _placeholder_anim(color: Color) -> FrameAnimation:
	var img := Image.create(64, 96, false, Image.FORMAT_RGBA8)
	img.fill(color)
	var tex := ImageTexture.create_from_image(img)
	var a := FrameAnimation.new()
	a.add_frame(tex, 999.0)
	a.loop = true
	return a

## 大招动画帧规格（来自 output_timetable (4).txt：前 29 帧 0.238s，末帧 1s）
static func _ult_frame_specs() -> Array:
	var specs := []
	for i in range(1, ULT_FRAME_COUNT + 1):
		var dur: float = ULT_FRAME_DUR
		if i == ULT_FRAME_COUNT:
			dur = 1.0
		specs.append({"index": i, "duration": dur})
	return specs

static func get_config() -> Dictionary:
	return {
		"id": "berserker", "name": "狂战士",
		"hp": BASE_HP, "max_energy": BASE_ENERGY, "energy_regen": 0.05,
		"speed": BASE_SPEED, "attack_range": BASE_ATK_RANGE, "attack_damage": BASE_ATK_DMG,
		"attack_cooldown": ATK_COOLDOWN, "attack_delay": ATK_DELAY, "attack_duration": ATK_DURATION,
		"image_scale": 1.2,
		"attack_image_scale": 1.5,  # 普攻贴图独立缩放（放大 1.5 倍）
		"fields": {},
		"world_arrays": [],
		"animations": {
			"idle":   FrameAnimation.load_from_frames(BERSERKER_ANI_DIR + "idle/", "berserker_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk":   FrameAnimation.load_from_frames(BERSERKER_ANI_DIR + "walk/", "berserker_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump":   FrameAnimation.load_from_frames(BERSERKER_ANI_DIR + "jump/", "berserker_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(BERSERKER_ANI_DIR + "attack/", "berserker_attack_f_", [{"index": 1, "duration": 0.5}], false),
			"skill1": FrameAnimation.load_from_frames(BERSERKER_ANI_DIR + "skill1/", "berserker_skill1_f_", [{"index": 1, "duration": 999.0}], false),
			"skill2": _placeholder_anim(Color(0.5, 0.1, 0.0)),
			"ult":    FrameAnimation.load_from_frames(BERSERKER_ANI_DIR + "ult/", "berserker_ult_f_", _ult_frame_specs(), false),
		},
		"dex": {
			"icon": "🪓",
			"intro": "“不够！”\n\n他站住了。血顺着指缝滴下去，分不清是谁的——无所谓，反正很快就会干。地上已经躺了几个，下一个正在犹豫要不要上。他等了一会儿，不耐烦了，干脆自己走过去。两柄斧头拖在地上，划出两道浅浅的沟。\n\n“起来！”",
			"stats": [
				{"label": "生命", "value": "100"},
				{"label": "能量上限", "value": "80"},
				{"label": "浴血", "value": "失血增伤：每损失 10 血 +4%（最多 +24%）；不可治疗"},
			],
			"skills": [
				{"name": "连斩（普通攻击）", "desc": "挥动双斧斩击身前敌人，造成 2 段伤害（共 5 点）。", "meta": "消耗：无 ｜ 冷却：0.9 秒"},
				{"name": "飞斧/瞬斩（技能一）", "desc": "【飞斧】掷出高速旋转的飞斧，沿途持续击飞敌人（每次造成 1 点伤害），飞行 200 像素后狂战士瞬移至斧头处发动连斩（共造成 12 点伤害）。\n【瞬斩】狂暴状态下使用飞斧后 6 秒内可释放：向前冲刺约 200 像素斩击敌人（5 点伤害），释放后技能一冷却 +3 秒。", "meta": "消耗：15 能量 ｜ 冷却：8 秒"},
				{"name": "断筋斩/地裂（技能二）", "desc": "【断筋斩】举斧招架 1 秒，期间受到攻击会瞬移到敌人身后重击；若未受击，可在招架期间按 J 原地出招。断筋斩将敌人按住 1 秒持续出伤（共 15 点伤害），命中后敌人移动速度 -10%、跳跃高度 -60%，持续 5 秒。\n【地裂】狂暴状态下释放断筋斩后 6 秒内可释放：踩碎地面生成穿透性冲击波，飞行 100 像素击飞敌人（5 点伤害），释放后技能二冷却 +3 秒。", "meta": "消耗：15 能量 ｜ 冷却：15 秒"},
				{"name": "诸神黄昏（大招）", "desc": "狂战士挥动双斧制造巨大龙卷风撕碎敌人。动画期间自身无敌，总计造成 40 点伤害。", "meta": "消耗：80 能量 ｜ 冷却：10 秒"},
				{"name": "战吼（子技能）", "desc": "发出战吼震慑敌人：1.5 秒内获得霸体并提升防御力 +50；全屏敌人随机受到一种震慑效果（移动失灵 1 秒 / 能量 -10 / 技能冷却 +1 秒）。血量低于上限 40% 时使用会进入狂暴模式：全程霸体、免疫所有负面效果、防御力 +12.5、能量回复速度 +20%，代价是每秒受到 1 点真实伤害（血量低于 5 时真伤停止，不会致死；携带「破釜沉舟」天赋时狂暴免真伤），持续到战斗结束。", "meta": "消耗：无 ｜ 冷却：20 秒"},
			],
		},
		"ai_profile": {"ideal_range": [0, 60], "kite": false},
	}

static func create_skills() -> Array:
	# 技能一多段：飞斧（一段）→ 瞬斩（二段，狂暴专属，使用飞斧后 2s 内）
	var s1 = Skill.make_staged("skill1", "飞斧/瞬斩", SKILL1_COOLDOWN, SKILL1_ENERGY,
		func(owner: Fighter): return owner.grounded,
		[Callable(_skill1), Callable(_skill1_flash_slash)],
		FLASH_SLASH_WINDOW,
		func(owner: Fighter): return owner.state_flags.get("berserker_rage", false))
	# 技能二多段：断筋斩（一段）→ 地裂（二段，狂暴专属，释放断筋斩后 6s 内）
	var s2 = Skill.make_staged("skill2", "断筋斩/地裂", SKILL2_COOLDOWN, SKILL2_ENERGY,
		func(owner: Fighter): return owner.grounded,
		[Callable(_skill2), Callable(_skill2_ground_split)],
		GROUND_SPLIT_WINDOW,
		func(owner: Fighter): return owner.state_flags.get("berserker_rage", false))
	return [
		s1,
		s2,
		Skill.new("sub", "战吼", SUB_COOLDOWN, SUB_ENERGY, func(owner: Fighter): return owner.grounded, Callable(_sub_warcry)),
		Skill.new("ult", "诸神黄昏", ULT_COOLDOWN, ULT_ENERGY, func(owner: Fighter): return owner.grounded, Callable(_ult)),
	]

# ===== 技能一：飞斧 =====
## 掷出旋转飞斧（飞行 200 像素，沿途击飞敌人 1 伤害/次），抵达后狂战士瞬移发动连斩（5 + 7）
static func _skill1(owner: Fighter) -> Dictionary:
	var dir = owner.facing
	var cx = owner.pos_x + owner.w / 2.0
	owner.set_animation_state("skill1")
	# 生成飞行斧头
	owner.state_flags["berserker_axe"] = {
		"x": cx + dir * 8.0, "y": owner.pos_y + 8.0,
		"w": AXE_W, "h": AXE_H,
		"vx": AXE_SPEED * dir, "vy": 0.0,
		"dist": 0.0, "rot": 0.0,
		"hit_cd": {},  # 每个敌人命中冷却
	}
	# 注册旋转斧头绘制
	GameWorld.register_draw_effect("berserker_axe", func(font, cam_x, cam_y):
		if not is_instance_valid(owner):
			return []
		var axe = owner.state_flags.get("berserker_axe")
		if not axe is Dictionary:
			return []
		return [
			{"type": "set_transform", "pos": Vector2(axe["x"] + axe["w"] / 2.0 - cam_x, axe["y"] + axe["h"] / 2.0 - cam_y), "rot": axe["rot"], "scale": Vector2(1, 1)},
			{"type": "tex", "tex": AXE_TEX, "rect": Rect2(-axe["w"] / 2.0, -axe["h"] / 2.0, axe["w"], axe["h"])},
			{"type": "reset_transform"},
		]
	, 5)
	Fighter.emit_particles(cx, owner.pos_y + owner.h / 2.0, 12, Color(0.85, 0.5, 0.15), 4, 6, "star")
	return {"success": true}

## 技能一 二段（狂暴专属）：瞬斩 — 向前冲刺斩击（约200px，速度10）
static func _skill1_flash_slash(owner: Fighter) -> Dictionary:
	if not owner.state_flags.get("berserker_rage", false):
		return {"success": false}
	owner.state_flags["berserker_flash_slash"] = {"dist": FLASH_SLASH_DIST, "dir": owner.facing, "dealt": false}
	# 瞬斩贴图叠加绘制（随冲刺移动/翻转）
	var key = str(owner.get_instance_id()) + "_flash_slash"
	GameWorld.register_draw_effect(key, func(font, cam_x, cam_y):
		if not is_instance_valid(owner) or not owner.state_flags.has("berserker_flash_slash"):
			return []
		var sc = maxf(owner.w, owner.h) / maxf(FLASH_SLASH_TEX.get_width(), FLASH_SLASH_TEX.get_height()) * 1.3
		var tw = FLASH_SLASH_TEX.get_width() * sc
		var th = FLASH_SLASH_TEX.get_height() * sc
		var cx = owner.pos_x + owner.w / 2.0 - cam_x
		var cy = owner.pos_y + owner.h / 2.0 - cam_y
		return [
			{"type": "set_transform", "pos": Vector2(cx, cy), "rot": 0.0, "scale": Vector2(-1 if owner.facing < 0 else 1, 1)},
			{"type": "tex", "tex": FLASH_SLASH_TEX, "rect": Rect2(-tw / 2.0, -th / 2.0, tw, th)},
			{"type": "reset_transform"},
		]
	, 5)
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 20, Color(1.0, 0.5, 0.1), 6, 8, "star")
	# 使用二段后：技能一冷却 +3s
	var s1 = owner.get_skill("skill1")
	if s1:
		s1.cd += FLASH_SLASH_CD_BONUS
	return {"success": true}

## 技能二 二段（狂暴专属）：地裂 — 踩碎地面，释放巨大冲击波振飞敌人（穿透飞行物）
static func _skill2_ground_split(owner: Fighter) -> Dictionary:
	if not owner.state_flags.get("berserker_rage", false):
		return {"success": false}
	var dir = owner.facing
	# 冲击波碰撞/贴图放大 2 倍（飞行距离不变，仍为 GROUND_SPLIT_DIST）
	var gw = GROUND_SPLIT_DIST * GROUND_SPLIT_IMG_SCALE
	var gh = GROUND_SPLIT_H * GROUND_SPLIT_IMG_SCALE
	var px = owner.pos_x + (owner.w if dir == 1 else 0)
	var py = Constants.GROUND_Y - gh  # 贴地冲击波（放大后贴图）
	GameWorld.projectiles.append({
		"x": px, "y": py,
		"w": gw, "h": gh,
		"vx": GROUND_SPLIT_SPEED * dir, "vy": 0.0,
		"life": int(GROUND_SPLIT_DIST / GROUND_SPLIT_SPEED),
		"damage": GROUND_SPLIT_DMG,
		"owner": owner, "type": "berserker_ground_split",
		"color": Color(1.0, 0.55, 0.1),
		"img": _get_mirrored_ground_split_tex(),  # 冲击波（镜像后使用）
		"piercing": true,
		"reflected": false,
		"launch_vy": -14.0, "launch_vx": dir * 6.0,  # 振飞敌人
	})
	# 踩碎地面动作（0.5s）
	owner.state_flags["berserker_stomp"] = GROUND_SPLIT_STOMP_FRAMES
	owner.state_flags["draw_texture_override"] = STOMP_TEX
	Fighter.emit_particles(px + gw / 2.0, py + gh / 2.0, 30, Color(1.0, 0.55, 0.1), 8, 12, "circle", 1.2)
	# 使用二段后：技能二进入冷却且冷却时间 +3s
	var s2 = owner.get_skill("skill2")
	if s2:
		s2.cd = s2.cooldown + GROUND_SPLIT_CD_BONUS
	return {"success": true}

# ===== 技能二：断筋斩 =====
## 举斧招架 1s：期间受击 → 瞬移敌人身后断筋斩；未受击按 U → 原地断筋斩
static func _skill2(owner: Fighter) -> Dictionary:
	owner.set_animation_state("skill2")
	owner.state_flags["berserker_parry"] = {"timer": PARRY_DURATION, "triggered": false}
	owner.state_flags["draw_texture_override"] = PARRY_TEX  # 招架贴图
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 25, Color(0.85, 0.5, 0.15), 5, 7, "star")
	return {"success": true}

## 招架结束（时间到/已出招）→ 还原待机与贴图
static func _end_parry(owner: Fighter):
	owner.state_flags.erase("berserker_parry")
	owner.state_flags.erase("draw_texture_override")
	owner.state_flags.erase("draw_texture_override_scale")
	if owner.image_state == "skill2":
		owner.set_animation_state("idle")

## 发动断筋斩：target 为受击反击目标（瞬移敌人身后），null 为原地出招
static func _start_tendon_slash(owner: Fighter, target: Fighter):
	# 招架已被触发/提前出招 → 清除招架状态与招架贴图
	owner.state_flags.erase("berserker_parry")
	owner.state_flags.erase("draw_texture_override")
	owner.state_flags.erase("draw_texture_override_scale")
	if target and target != owner and target.hp > 0:
		# 瞬移到敌人身后（绕到敌人另一侧，保持贴地）
		var dir = 1 if owner.pos_x < target.pos_x else -1
		var behind_x = target.pos_x + target.w + 6.0 if dir == 1 else target.pos_x - owner.w - 6.0
		owner.pos_x = clampf(behind_x, 10, Constants.MAP_W - 10 - owner.w)
		owner.pos_y = Constants.GROUND_Y - owner.h
		owner.vx = 0
		owner.vy = 0
		owner.grounded = true
		owner.facing = -dir  # 面向敌人
	owner.state_flags["berserker_tendon"] = {"timer": TENDON_SLASH_DURATION}
	owner.state_flags["draw_texture_override"] = _get_mirrored_tendon_tex()
	owner.state_flags["draw_texture_override_scale"] = TENDON_SLASH_SCALE
	owner.set_animation_state("skill2")
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 30, Color(0.75, 0.9, 0.3), 8, 12, "star")

## 断筋斩范围判定：以角色中心为圆心的方形范围（含自身前后）
static func _in_tendon_range(owner: Fighter, f: Fighter) -> bool:
	var cx = owner.pos_x + owner.w / 2.0
	var cy = owner.pos_y + owner.h / 2.0
	var fx = f.pos_x + f.w / 2.0
	var fy = f.pos_y + f.h / 2.0
	return absf(cx - fx) < (TENDON_SLASH_RANGE + f.w) / 2.0 and absf(cy - fy) < (TENDON_SLASH_RANGE + f.h) / 2.0

# ===== 子技能：战吼（7键） =====
## 发出战吼震慑敌人：1.5s 霸体+减伤50%；全屏敌人随机 debuff；残血触发狂暴模式
static func _sub_warcry(owner: Fighter) -> Dictionary:
	owner.state_flags["berserker_warcry"] = {"timer": WAR_CRY_DURATION}
	owner.state_flags["draw_texture_override"] = WAR_CRY_TEX  # 战吼贴图（1.5s）
	# 霸体 + 减伤 50%（防御 +50，护甲公式等效）
	Fighter.set_super_armor(owner, WAR_CRY_DURATION)
	owner.defense += WAR_CRY_DEFENSE
	# 全屏敌人随机震慑
	for f in GameWorld.entities:
		if f == owner or f.hp <= 0:
			continue
		_apply_warcry_debuff(owner, f)
	# 残血使用战吼 → 狂暴模式
	if owner.hp < owner.max_hp * WAR_CRY_RAGE_HP:
		_enter_rage_mode(owner)
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 40, Color(1.0, 0.84, 0.4), 10, 14, "star", 1.5)
	return {"success": true}

## 随机施加一种震慑 debuff
static func _apply_warcry_debuff(owner: Fighter, f: Fighter):
	match randi() % 4:
		0:  # 移动键失灵 1s
			f.add_status("warcry_lock")
		1:  # 能量减少 10
			f.energy = maxf(0.0, f.energy - 10.0)
		2:  # 一技能冷却 +1s（一次性）
			var s1 = f.get_skill("skill1")
			if s1:
				s1.cd += 60
		3:  # 二技能冷却 +1s（一次性）
			var s2 = f.get_skill("skill2")
			if s2:
				s2.cd += 60

## 进入狂暴模式：全程霸体、免疫负面、减伤20%、能量回复+20%；代价每秒1真实伤害
static func _enter_rage_mode(owner: Fighter):
	owner.state_flags["berserker_rage"] = true
	owner.state_flags["immune_negative_status"] = true  # 免疫所有负面效果
	owner.statuses.clear()  # 清除已存在的负面状态
	owner.defense += 12.5  # 减伤 20%（护甲公式 defense/(defense+50) 等效）
	owner.config["energy_regen"] = owner.config.get("energy_regen", 0.083) * 1.2  # 能量回复 +20%
	owner.set_meta("berserker_rage_tick", 0)
	# 注册斗气绘制：随角色移动/翻转，20帧切换两帧循环
	var key = str(owner.get_instance_id()) + "_rage"
	GameWorld.register_draw_effect(key, func(font, cam_x, cam_y):
		if not is_instance_valid(owner) or owner.hp <= 0 or not owner.state_flags.get("berserker_rage", false):
			return []
		var tex = RAGE_AURA_TEX1 if (int(GameWorld.frame / RAGE_AURA_SWITCH) % 2 == 0) else RAGE_AURA_TEX2
		# 按角色身体尺寸等比缩放（避免贴图原始像素过大）
		var sc = maxf(owner.w, owner.h) / maxf(tex.get_width(), tex.get_height()) * RAGE_AURA_SCALE
		var tw = tex.get_width() * sc
		var th = tex.get_height() * sc
		var cx = owner.pos_x + owner.w / 2.0 - cam_x
		var cy = owner.pos_y + owner.h / 2.0 - cam_y
		return [
			{"type": "set_transform", "pos": Vector2(cx, cy), "rot": 0.0, "scale": Vector2(-1 if owner.facing < 0 else 1, 1)},
			{"type": "tex", "tex": tex, "rect": Rect2(-tw / 2.0, -th / 2.0, tw, th)},
			{"type": "reset_transform"},
		]
	, 5)
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 50, Color(1.0, 0.2, 0.0), 12, 16, "star", 2.0)

# ===== 大招：诸神黄昏（巨大龙卷风） =====
static func _ult(owner: Fighter) -> Dictionary:
	# 防重复
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "berserker_ult":
			return {"success": false}

	# 运行时加载 30 帧全屏动画（ult/berserker_ult_f_1 ~ 30）
	var ult_anim = FrameAnimation.load_from_frames(BERSERKER_ANI_DIR + "ult/", "berserker_ult_f_", _ult_frame_specs(), false)
	if ult_anim.frames.is_empty():
		return {"success": false}
	ult_anim.play()

	# 注入 config 供角色自身动画播放；全屏 overlay 使用同一 anim 对象，播放状态同步
	owner.config["animations"]["ult"] = ult_anim
	owner.set_animation_state("ult")

	# 大招演出状态：出伤计时（动画结束后由 on_finish 清理）
	owner.state_flags["berserker_ult"] = {"timer": 0, "dmg_acc": 0.0}
	owner.state = "ult"
	GameWorld.hit_stop = 20
	Fighter.set_invincible(owner)  # 大招期间持续无敌

	GameWorld.active_overlays.append({
		"anim": ult_anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "berserker_ult",
		"border_color": Color(0.9, 0.95, 1.0),
		"on_finish": func():
			owner.state_flags.erase("berserker_ult")
			Fighter.clear_invincible(owner)
			owner.state = "idle"
			owner.set_animation_state("idle")
	})

	# 大招释放特效
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(0.85, 0.9, 1.0), 14, 18, "star", 2.0)
	return {"success": true}

# ===== 输入处理（移动/跳跃/普攻） =====
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	# 大招（诸神黄昏）演出期间：锁定所有输入
	if owner.state_flags.has("berserker_ult"):
		keys.attack = false
		keys.skill1 = false
		keys.skill2 = false
		keys.ult = false
		keys["sub"] = false
		return 0
	# 瞬斩冲刺期间：锁定所有输入
	if owner.state_flags.has("berserker_flash_slash"):
		keys.attack = false
		keys.skill1 = false
		keys.skill2 = false
		keys.ult = false
		keys["sub"] = false
		return 0
	# 招架期间：不可移动/放技能，按 J 直接释放原地断筋斩
	var parry = owner.state_flags.get("berserker_parry")
	if parry:
		if keys.attack and not parry.get("triggered", false):
			parry["triggered"] = true
			_start_tendon_slash(owner, null)
			keys.attack = false
		keys.skill1 = false
		keys.skill2 = false
		keys.ult = false
		keys["sub"] = false
		return 0
	# 战吼期间：不可移动/操作（演出 1.5s）
	if owner.state_flags.has("berserker_warcry"):
		keys.attack = false
		keys.skill1 = false
		keys.skill2 = false
		keys.ult = false
		keys["sub"] = false
		return 0
	var slashing: bool = owner.state_flags.has("berserker_axe_slash") or owner.state_flags.has("berserker_tendon")  # 连斩/断筋斩演出期间禁用攻击/技能
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and owner.grounded:
		owner.vy = -10
		owner.grounded = false
	# 普攻：连斩（双斧两段，2 + 3 伤害）
	if keys.attack and not slashing and owner.attack_cooldown <= 0 and not owner.attacking and not owner.dashing:
		owner.attacking = true
		owner.attack_timer = ATK_DURATION
		owner.attack_delay = 999  # 阻止 fighter.gd 标准单段判定，由 update_systems 接管两段
		owner.attack_hit_dealt = true
		owner.attack_cooldown = ATK_COOLDOWN
		owner.state = "attack"
		owner.state_flags["berserker_slash1"] = false
		owner.state_flags["berserker_slash2"] = false
		keys.attack = false
	# 技能
	if keys.skill1 and not slashing:
		var s = owner.get_skill("skill1")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill1 = false
	if keys.skill2 and not slashing:
		var s2 = owner.get_skill("skill2")
		if s2:
			var r2 = s2.try_use(owner)
			if r2.get("success"):
				keys.skill2 = false
	if keys.ult:
		var s3 = owner.get_skill("ult")
		if s3:
			var r3 = s3.try_use(owner)
			if r3.get("success"):
				keys.ult = false
	# 子技能（7键）：战吼
	if keys.get("sub", false) and not slashing:
		var ss = owner.get_skill("sub")
		if ss:
			var rs = ss.try_use(owner)
			if rs.get("success"):
				keys["sub"] = false
	Fighter.apply_movement(owner, mx, BASE_SPEED)
	Fighter.update_state(owner, mx)
	return mx

# ===== 每帧专属逻辑 =====
static func update_systems(owner: Fighter):
	# 连斩普攻：双斧两段伤害（2 + 3，随攻击力缩放）
	if owner.attacking and not owner.state_flags.get("berserker_slash1", true):
		if owner.attack_timer <= 20:
			owner.state_flags["berserker_slash1"] = true
			_do_slash(owner, owner.attack_damage * (2.0 / 5.0), Color(0.9, 0.45, 0.1))
	elif owner.attacking and owner.state_flags.get("berserker_slash1", false) and not owner.state_flags.get("berserker_slash2", false):
		if owner.attack_timer <= 10:
			owner.state_flags["berserker_slash2"] = true
			_do_slash(owner, owner.attack_damage * (3.0 / 5.0), Color(1.0, 0.35, 0.0))
	# 攻击结束后清理标记
	if not owner.attacking:
		owner.state_flags.erase("berserker_slash1")
		owner.state_flags.erase("berserker_slash2")
	# ── 飞斧（技能一）：斧头飞行 → 抵达后瞬移连斩 ──
	var axe = owner.state_flags.get("berserker_axe")
	if axe:
		if owner.hp <= 0:
			_clean_axe(owner)
		else:
			axe["x"] += axe["vx"]
			axe["dist"] += absf(axe["vx"])
			axe["rot"] += AXE_ROT_SPEED
			_axe_hit(owner, axe)
			# 抵达飞行距离或飞出地图 → 瞬移连斩
			if axe["dist"] >= AXE_DIST or axe["x"] < -30 or axe["x"] > Constants.MAP_W + 30:
				_axe_arrive(owner)
	# ── 瞬斩（技能一 二段）：向前冲刺斩击 ──
	var fs = owner.state_flags.get("berserker_flash_slash")
	if fs:
		owner.vx = 0
		owner.vy = 0
		var step = minf(FLASH_SLASH_SPEED, fs["dist"])
		owner.pos_x = clampf(owner.pos_x + fs["dir"] * step, 10, Constants.MAP_W - 10 - owner.w)
		fs["dist"] -= step
		# 斩击判定（命中一次）
		if not fs["dealt"]:
			var target = GameWorld.get_opponent(owner)
			if target and target.hp > 0 and owner.get_attack_box().intersects(target.get_hit_box()):
				fs["dealt"] = true
				Fighter.apply_damage(target, FLASH_SLASH_DMG, owner)
				Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 14, Color(1.0, 0.45, 0.1), 6, 8, "star", 0.9)
		# 冲刺结束 → 清理
		if fs["dist"] <= 0:
			owner.state_flags.erase("berserker_flash_slash")
			GameWorld.unregister_draw_effect(str(owner.get_instance_id()) + "_flash_slash")
	# ── 连斩（技能一）：瞬移后两段斩击（5 + 7），贴图总持续 6 + 39 = 45 帧 = 0.75s ──
	var slash = owner.state_flags.get("berserker_axe_slash")
	if slash:
		slash["timer"] -= 1
		if slash["timer"] <= 0:
			if slash["stage"] == 0:
				slash["stage"] = 1
				slash["timer"] = 39
				_skill_slash(owner, SLASH1_DMG)
			else:
				_skill_slash(owner, SLASH2_DMG)
				owner.state_flags.erase("berserker_axe_slash")
				owner.state_flags.erase("draw_texture_override")
				owner.state_flags.erase("draw_texture_override_scale")
				owner.set_animation_state("idle")
				owner.facing = -owner.facing  # 连斩结束自动转身（例：飞斧→瞬移连斩→转身待机）
	# ── 断筋斩（技能二）演出：期间自己和范围内敌人不能移动，按帧出伤 ──
	var tendon = owner.state_flags.get("berserker_tendon")
	if tendon:
		tendon["timer"] -= 1
		owner.state_flags["tendon_locked"] = true  # 自己不能移动
		var tick_dmg = TENDON_SLASH_DMG / TENDON_SLASH_DURATION
		for f in GameWorld.entities:
			if f == owner or f.hp <= 0:
				continue
			if _in_tendon_range(owner, f):
				f.state_flags["tendon_locked"] = true
				Fighter.apply_damage(f, tick_dmg, owner, false, Color(0.75, 0.9, 0.3), "hit_enemy", "domain")
				if not f.has_status("tendon_cut"):
					f.add_status("tendon_cut")  # 移速-10% / 跳跃高度-60%，持续5s
		if tendon["timer"] <= 0:
			# 结束：解除自身与范围内敌人的移动锁定
			owner.state_flags.erase("tendon_locked")
			for f in GameWorld.entities:
				if is_instance_valid(f):
					f.state_flags.erase("tendon_locked")
			owner.state_flags.erase("berserker_tendon")
			owner.state_flags.erase("draw_texture_override")
			owner.state_flags.erase("draw_texture_override_scale")
			owner.set_animation_state("idle")
	# ── 招架（技能二）：受击 → 瞬移身后断筋斩；时间到 → 结束招架 ──
	var parry = owner.state_flags.get("berserker_parry")
	if parry:
		parry["timer"] -= 1
		owner.vx = 0  # 招架中不可移动
		# 受到攻击（damage_flash 标记）→ 反击（触发时缓，参考骑士招架成功）
		if not parry.get("triggered", false) and owner.damage_flash > 0:
			parry["triggered"] = true
			GameWorld.trigger_slow_motion(90)
			var target = GameWorld.get_opponent(owner)
			if target and target.hp > 0:
				_start_tendon_slash(owner, target)
			else:
				_end_parry(owner)
		elif parry["timer"] <= 0 and not parry.get("triggered", false):
			_end_parry(owner)
	# ── 战吼（子技能）：1.5s 霸体+减伤，到时还原防御并清理贴图 ──
	var warcry = owner.state_flags.get("berserker_warcry")
	if warcry:
		warcry["timer"] -= 1
		if warcry["timer"] <= 0:
			owner.state_flags.erase("berserker_warcry")
			owner.state_flags.erase("draw_texture_override")
			owner.state_flags.erase("draw_texture_override_scale")
			owner.defense = maxf(0.0, owner.defense - WAR_CRY_DEFENSE)
	# ── 地裂（技能二二段）：踩碎地面动作计时，到时还原贴图 ──
	var stomp: int = owner.state_flags.get("berserker_stomp", 0)
	if stomp > 0:
		stomp -= 1
		owner.state_flags["berserker_stomp"] = stomp
		if stomp <= 0:
			owner.state_flags.erase("berserker_stomp")
			owner.state_flags.erase("draw_texture_override")
			owner.state_flags.erase("draw_texture_override_scale")
	# ── 狂暴模式：全程霸体（无计时常驻），代价每秒 1 真实伤害（血量≤5 时停止，不会致死）──
	if owner.state_flags.get("berserker_rage", false):
		Fighter.set_super_armor(owner, 0)  # 持续到游戏结束
		var rage_tick: int = owner.get_meta("berserker_rage_tick", 0) + 1
		owner.set_meta("berserker_rage_tick", rage_tick)
		if rage_tick >= 60 and owner.hp > 5 and not owner.ad.get("broken_boat", false):  # 血量低于 5 时真伤结束；携带破釜沉舟则免真伤
			owner.set_meta("berserker_rage_tick", 0)
			owner.hp = maxf(0.0, owner.hp - 1.0)  # 真实伤害：无视防御/减伤
	# ── 大招：诸神黄昏 — 第 8~19 帧持续撕碎敌人（总计 40 伤，附带卷起击飞）──
	var ult_state = owner.state_flags.get("berserker_ult")
	if ult_state:
		ult_state["timer"] += 1
		# 出伤起点：第 8 帧开始（前 7 帧约 0.238s/帧）
		const ULT_DAMAGE_START_FRAMES := int((ULT_DAMAGE_START - 1) * ULT_FRAME_DUR * 60)
		const ULT_DAMAGE_FRAMES := int((ULT_DAMAGE_END - ULT_DAMAGE_START + 1) * ULT_FRAME_DUR * 60)  # ≈171
		if ult_state["timer"] >= ULT_DAMAGE_START_FRAMES and ult_state["timer"] < ULT_DAMAGE_START_FRAMES + ULT_DAMAGE_FRAMES:
			ult_state["dmg_acc"] += ULT_TOTAL_DMG / float(ULT_DAMAGE_FRAMES)
			var dmg = floor(ult_state["dmg_acc"])
			if dmg > 0:
				ult_state["dmg_acc"] -= dmg
				var enemy = GameWorld.get_opponent(owner)
				if enemy and enemy.hp > 0:
					Fighter.apply_damage(enemy, float(dmg), owner, false, Color(0.85, 0.9, 1.0), "hit_enemy", "ult", 0)
					enemy.vy = -6                    # 被龙卷风卷起
					enemy.vx = owner.facing * 4      # 向龙卷风方向撕扯
		# 动画播放完毕由 overlay on_finish 回调清理 berserker_ult

## 斧头抵达：狂战士瞬移至斧头位置发动连斩
static func _axe_arrive(owner: Fighter):
	var axe = owner.state_flags.get("berserker_axe")
	if not axe:
		return
	# 若此时处于瞬斩冲刺中 → 取消冲刺（改为瞬移连斩）
	if owner.state_flags.has("berserker_flash_slash"):
		owner.state_flags.erase("berserker_flash_slash")
		GameWorld.unregister_draw_effect(str(owner.get_instance_id()) + "_flash_slash")
	# 瞬移至斧头位置（保持地面高度）
	owner.pos_x = clampf(axe["x"] - owner.w / 2.0, 10, Constants.MAP_W - 10 - owner.w)
	owner.pos_y = maxf(axe["y"] + axe["h"] / 2.0 - owner.h, Constants.GROUND_Y - owner.h)
	owner.facing = 1 if axe["vx"] > 0 else -1
	_clean_axe(owner)
	# 发动连斩（两段：5 + 7）
	owner.state_flags["berserker_axe_slash"] = {"stage": 0, "timer": 6}
	owner.state_flags["draw_texture_override"] = BERSERKER_SLASH_TEX
	owner.state_flags["draw_texture_override_scale"] = SLASH_TEX_SCALE
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 20, Color(0.9, 0.4, 0.1), 6, 8, "star")

## 斧头沿途撞击：持续击飞敌人（参考亡灵战马冲刺），伤害 1/次
static func _axe_hit(owner: Fighter, axe: Dictionary):
	var ax = axe["x"] + axe["w"] / 2.0
	var ay = axe["y"] + axe["h"] / 2.0
	var frame = GameWorld.frame
	var hit_cd: Dictionary = axe["hit_cd"]
	for f in GameWorld.entities:
		if f == owner or f.hp <= 0:
			continue
		var fid = f.get_instance_id()
		var last_hit: int = hit_cd.get(fid, -9999)
		if frame - last_hit < AXE_HIT_CD:
			continue
		var fx = f.pos_x + f.w / 2.0
		var fy = f.pos_y + f.h / 2.0
		if absf(ax - fx) < (axe["w"] + f.w) / 2.0 and absf(ay - fy) < (axe["h"] + f.h) / 2.0:
			hit_cd[fid] = frame
			f.vy = 0
			f.vx = axe["vx"] * AXE_KNOCKBACK_MULT
			f.damage_flash = 8
			Fighter.apply_damage(f, AXE_DMG, owner, false)
			Fighter.emit_particles(fx, fy, 8, Color(0.85, 0.5, 0.15), 4, 6, "circle")

## 清理飞行斧头
static func _clean_axe(owner: Fighter):
	owner.state_flags.erase("berserker_axe")
	GameWorld.unregister_draw_effect("berserker_axe")

## 连斩单段判定：攻击框含角色全身（可扫到身后敌人），命中后向自己身后击退
static func _skill_slash(owner: Fighter, dmg: float):
	var target = GameWorld.get_opponent(owner)
	if not target or target.hp <= 0:
		return
	# 攻击框覆盖整个角色身体（含身后），并朝前方放大 SLASH_RANGE_MULT 倍
	var reach = owner.attack_range * SLASH_RANGE_MULT
	var atk_box = Rect2(owner.pos_x - (reach if owner.facing < 0 else 0.0),
		owner.pos_y + 6, owner.w + reach, owner.h - 16)
	if atk_box.intersects(target.get_hit_box()):
		Fighter.apply_damage(target, dmg, owner, false)  # 关闭默认前向击退
		target.vy = -4
		target.vx = -owner.facing * 5.0  # 向狂战士身后击退
		Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 12, Color(1.0, 0.35, 0.0), 5, 7, "star", 0.9)

## 连斩单段判定：斩击身前敌人
static func _do_slash(owner: Fighter, dmg: float, color: Color):
	var target = GameWorld.get_opponent(owner)
	if not target or target.hp <= 0:
		return
	var atk_box = owner.get_attack_box()
	if atk_box.intersects(target.get_hit_box()):
		Fighter.apply_damage(target, dmg, owner)
		Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 12, color, 5, 7, "star", 0.9)

# ===== 地狱模式 AI（可选，默认走通用 AI） =====
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

	# 残血玩家 → 大招斩杀
	if can_use_ult and player and player.hp > 0 and player.hp < player.max_hp * 0.4 and dist < 250 and rand < 0.5:
		f.facing = dir
		ult.try_use(f)
		return "ATTACK"
	# 中距离 → 飞斧（掷斧后瞬移连斩）
	if can_use_s1 and dist < 140 and dist > 40 and rand < 0.4:
		f.facing = dir
		skill1.try_use(f)
		return "ATTACK"
	# 贴脸 → 普攻（连斩）
	if dist < 70:
		f.facing = dir
		if f.attack_cooldown <= 0 and not f.attacking:
			f.attacking = true
			f.attack_timer = ATK_DURATION
			f.attack_delay = 999  # 由 update_systems 接管两段判定
			f.attack_hit_dealt = true
			f.attack_cooldown = ATK_COOLDOWN
			f.state_flags["berserker_slash1"] = false
			f.state_flags["berserker_slash2"] = false
		return "ATTACK"
	return ""

static func ai_hell_desire(f: Fighter) -> Dictionary:
	return {"min": 0, "max": 60}
