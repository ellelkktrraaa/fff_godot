# 剑豪 (kensai)：高速连击 / 三式普攻 / 连招序列切换技能
#
# 设计（与用户确认）：
#   普攻键 = 一式·踏月逐风斩 | 技能1键 = 二式·九霄断水吟 | 技能2键 = 三式·云龙贯霄刺（都是基础攻击，各一击）
#   大招键 = 按当前连招序列触发技能：
#       [一]        → skill1 居合·一闪（突进拔刀斩）
#       [一,二]     → skill2 十字剑舞（两段斩）
#       [一,二,三]  → ult 无想一刀（全屏剑气斩）
class_name KensaiCharacter

const KENSAI_ANI_DIR = "res://assets/char_ani/kensai/"
const KENSAI_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/kensai_idle_foot_gaps.gd")
const KENSAI_WALK_FOOT_GAPS = preload("res://data/foot_gaps/kensai_walk_foot_gaps.gd")
const KENSAI_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/kensai_jump_foot_gaps.gd")
const KENSAI_STANCE_FOOT_GAPS = preload("res://data/foot_gaps/kensai_stance_foot_gaps.gd")
const KENSAI_ATTACK2_FOOT_GAPS = preload("res://data/foot_gaps/kensai_attack2_foot_gaps.gd")
const KENSAI_ATTACK1_FOOT_GAPS = preload("res://data/foot_gaps/kensai_attack1_foot_gaps.gd")
const KENSAI_ATTACK1_SLASH_FOOT_GAPS = preload("res://data/foot_gaps/kensai_attack1_slash_foot_gaps.gd")
const KENSAI_SKILL1_FOOT_GAPS = preload("res://data/foot_gaps/kensai_skill1_foot_gaps.gd")

const KENSAI_ATTACK_AIR_IMG = preload("res://assets/char_ani/kensai/attack1/kensai_attack_air_f_1.png")
const KENSAI_ATK3_SLASH1 = preload("res://assets/char_ani/kensai/attack3/kensai_atk3_slash1.png")
const KENSAI_ATK3_SLASH2 = preload("res://assets/char_ani/kensai/attack3/kensai_atk3_slash2.png")
# 千峰破云：屏幕下方最近2次普攻种类图标（1/2/3，FrameAnimation 包装）
static var KENSAI_QIFENG_1: FrameAnimation = _fa(preload("res://assets/char_ani/kensai/ui/kensai_qifeng_1.png"))
static var KENSAI_QIFENG_2: FrameAnimation = _fa(preload("res://assets/char_ani/kensai/ui/kensai_qifeng_2.png"))
static var KENSAI_QIFENG_3: FrameAnimation = _fa(preload("res://assets/char_ani/kensai/ui/kensai_qifeng_3.png"))

## 单帧静态贴图包装为 FrameAnimation（规则四：禁止裸 preload Texture2D）
static func _fa(tex: Texture2D, dur: float = 999.0) -> FrameAnimation:
	var a := FrameAnimation.new()
	a.add_frame(tex, dur)
	a.loop = true
	return a

# ── 三式普攻（各一击）──
# 一式·踏月逐风斩（普攻键）：地面三连挥刀，按帧出伤（每次 5/3 伤，三次判定总伤 5），冷却 1s；
#                       空中释放改为斜向下约 40° 快速坠击（下坠速度 18）
const ATK1_HIT1_DMG := 5.0 / 3.0   # 普攻1每次挥刀伤害（按帧出伤：帧0/1/2 三次判定，总伤 5）
const ATK1_RANGE := 150.0          # 普攻1攻击范围：对齐动画剑身挥出范围（原48px 远小于动画）
const ATK1_TS_FRAMES := 36         # 普攻1/2摧毁飞行物瞬间时停时长（帧，原12帧的3倍）
const ATK1_COOLDOWN := 90    # 1.5 秒
const ATK1_SWING_DURATION := 16   # 单刀动画时长（帧）
const ATK1_AIR_DMG := 6.0    # 空中坠击单次伤害
const ATK1_AIR_VY := 18.0    # 下坠速度（帧/帧）
const ATK1_AIR_VX := 21.5    # 水平分量：18/tan(40°)≈21.5，朝 facing 方向
const ATK2_DMG := 5.0       # 二式·九霄断水吟（技能1键）：大范围横斩
const ATK2_COOLDOWN := 120  # 2 秒
const ATK2_FRONT := 180.0   # 身前范围（像素）— 大范围横斩
const ATK2_BACK := 150.0    # 身后范围（像素）— 大范围横斩
const ATK2_SWING_DURATION := 24  # 挥刀动画时长（帧，对齐 attack2 6帧×0.06s≈22帧）
const ATK2_HIT_FRAME := 11  # 出伤/破弹帧：动画第4帧满刀（舍弃第3帧后索引3，6帧×0.06s≈0.18s）
# 三式·云龙贯霄刺（技能2键）：前突200 → 回身斜上突200（30°），伤害 4+3，冷却 3s
const ATK3_DMG_HIT1 := 4.0
const ATK3_DMG_HIT2 := 3.0
const ATK3_COOLDOWN := 180      # 3 秒
const ATK3_DASH_SPEED := 20.0   # 突进速度
const ATK3_DASH1_FRAMES := 10   # 第一段：200/20 = 10 帧
const ATK3_GAP_FRAMES := 10     # 两段突进间隔（原地停顿）
const ATK3_DASH2_FRAMES := 10   # 第二段：200/20 = 10 帧
const ATK3_BACK_VX := 17.3      # 第二段水平分量：20×cos(30°)≈17.3（朝身后）
const ATK3_BACK_VY := 10.0      # 第二段垂直分量：20×sin(30°)=10（朝上）
const ATK3_FWD_DOWN_VX := 17.3  # 空中第一段水平分量：20×cos(30°)≈17.3（朝前）
const ATK3_FWD_DOWN_VY := 10.0  # 空中第一段垂直分量：20×sin(30°)=10（朝下）
const ATK3_TOTAL_FRAMES := 30   # 10 + 10 + 10
const ATTACK_DELAY := 6     # 攻击判定延迟（帧）

# ── 普攻起手（sheet.png 前5帧）──
# 说明：sheet 每帧 duration=0.1s，游戏 60fps → 动画 1 帧 = 0.1×60 = 6 游戏帧
const WINDUP_FRAMES := 20   # 地面起手：20 帧 ≈ 3.3 动画帧（约 0.333s）
const WINDUP_FRAMES_AIR := 12  # 空中普攻1起手：只播前 2 帧（2×0.1s×60 = 12 帧）就俯冲

# ── 连招序列 → 技能（大招键触发）──
const SKILL1_ENERGY := 30   # [二,一]21 → 千枫落华斩（一技能）
const SKILL1_COOLDOWN := 720  # 冷却 12 秒（独立冷却：与二技能互不影响）
const QFLH_TOTAL_DMG := 9.0         # 千枫落华斩总伤害（按帧出伤，原 12 适当下调）
const QFLH_ANIM_COLS := 6           # skill_1/sheet.png 网格
const QFLH_ANIM_ROWS := 6
const QFLH_ANIM_FRAMES := 36
const QFLH_DMG_PER_FRAME := QFLH_TOTAL_DMG / float(QFLH_ANIM_FRAMES)  # 每帧伤害 9/36 ≈ 0.25：每帧累计、floor 取整出伤
const QFLH_FRAME_DUR := 0.1         # 每帧 0.1s（总 3.6s）— 用户反馈 0.08 仍太快
const QFLH_TOTAL_FRAMES := 220      # 技能总时长（游戏帧，36×0.1×60≈216+缓冲）
const QFLH_WINDUP_FRAMES := 36      # 一技能起手：sheet.png 前6帧 × 0.1s × 60fps = 36 游戏帧（技能体、无无敌）
const SKILL2_ENERGY := 20   # [三,一]31 → 玄鸟衔月闪（二技能）
const SKILL2_COOLDOWN := 600  # 冷却 10 秒（独立冷却：与一技能互不影响）
const SKILL1_RANGE := 200.0       # 玄鸟衔月闪追踪范围：200px 内（或任意普攻命中）可追踪瞬移
const SKILL1_GRAB_DMG := 4.0      # 抓取伤害（原 5 适当下调）
const SKILL1_SLASH_DMG := 8.0     # 斩击伤害（原 10 适当下调）
const SKILL1_GRAB_FRAME := 8      # 抓取段结束索引（帧9，抓取完成出伤）
const SKILL1_SLASH_FRAME := 9     # 斩击段起始索引（帧10）
const ULT_ENERGY := 100     # [二,三]/[三,二]  → 孤鸿踏雪（蓄力斩击贯穿屏幕）
const ULT_COOLDOWN := 900   # 冷却 15 秒
const ULT_TOTAL_DAMAGE := 40.0   # 孤鸿踏雪总伤（30 瞬间 + 10 按帧持续）
const ULT_IMPACT_DAMAGE := 30.0  # output_0027 帧（索引 26）瞬间伤害
const ULT_DOT_START_FRAME := 27  # 持续出伤起始帧：output_0028（索引 27，0 起）
const ULT_DOT_END_FRAME := 49    # 持续出伤结束帧：output_0050（索引 49，0 起）
const ULT_DOT_TOTAL := 10.0      # 持续出伤总伤害（output_0028~0050 共 23 个动画帧）
const ULT_DOT_PER_FRAME := ULT_DOT_TOTAL / float(ULT_DOT_END_FRAME - ULT_DOT_START_FRAME + 1)  # 每动画帧累计
const ULT_HIT_FRAME := 26      # 瞬间出伤帧：播放到 output_0027.png（索引 26，0 起）时出 30 伤
const ULT_HIT_STOP := 20

# ── 特殊机制1：乘岚斩霞（拔刀蓄力）──
const STANCE_DMG_BONUS := 0.3    # 蓄力状态下释放普攻：伤害 +30%

# ── 普攻1动画（attack1/sheet.png：挥刀三连+剑光，3列×2行，仅前5帧有效）──
const ATK1_ANIM_FRAMES := 5      # 有效帧数（帧5 空白已剔除）
const ATK1_ANIM_HIT_FRAME := 2   # 按帧出伤最大判定帧：索引0/1/2 各判定一次，剑光帧(3/4)不出伤
const ATK1_ANIM_DURATION := 30   # 动画总时长：5帧×0.1s×60fps = 30 游戏帧
# 普攻1刀光（attack1/sheet。.png：3列×3行，仅前8帧有效，参考刺客普攻刀光特效）
const ATK1_SLASH_SHEET = KENSAI_ANI_DIR + "attack1/sheet。.png"
const ATK1_SLASH_FRAMES := 8
const ATK1_SLASH_FRAME_SEC := 0.06  # 8帧×0.06s ≈ 0.48s，对齐普攻1动画时长

# ── 特殊机制2：千峰破云（屏幕下方显示最近2次普攻种类）──
const QIFENG_ICON_SIZE := 36.0      # 图标显示尺寸（px）
const QIFENG_ICON_Y_OFFSET := 60.0  # 距屏幕底部距离（px）
const QIFENG_ICON_Z := 50           # 绘制层级（HUD 之上）

static func get_config() -> Dictionary:
	return {
		"id": "kensai", "name": "剑豪", "hp": 80, "max_energy": 100, "energy_regen": 0.03,
		"speed": 2.3, "attack_range": ATK1_RANGE, "attack_damage": ATK1_HIT1_DMG,
		"attack_cooldown": ATK1_COOLDOWN, "attack_delay": ATTACK_DELAY, "attack_duration": ATK1_SWING_DURATION,
		"image_scale": 1.0,
		"fields": {}, "world_arrays": [],
		# 乘岚斩霞蓄力架势略微缩小（相对角色碰撞体）
		"anim_scale_states": {"stance": 0.9},
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "idle/sheet.png", 5, 5, 25, 0.1, true, _kensai_idle_anchors()),
			"walk": _kensai_walk_anim(),
			"jump": _kensai_jump_anim(),
			"stance": FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "sheet.png", 3, 3, 9, 0.1, false, _kensai_stance_anchors()),
			"attack_windup": FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "sheet.png", 3, 3, 5, 0.1, false, _kensai_stance_anchors()),
			"skill1_windup": FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "sheet.png", 3, 3, 6, 0.1, false, _kensai_stance_anchors()),
			"attack1": FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "attack1/sheet.png", 3, 2, ATK1_ANIM_FRAMES, 0.1, false, _kensai_attack1_anchors(), Vector2i(2, 1)),
			"attack3": _kensai_attack3_anim(),
			"skill1": _kensai_skill1_anim(),
			"qflh": FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "skill_1/sheet.png", QFLH_ANIM_COLS, QFLH_ANIM_ROWS, QFLH_ANIM_FRAMES, QFLH_FRAME_DUR, false, [], Vector2i(2, 2)),
			"attack2": _kensai_attack2_anim(),
			"attack_air": _kensai_attack_air_anim(),
			"ult": FrameAnimation.load_from_frames(KENSAI_ANI_DIR + "ult/", "", _kensai_ult_specs(), false),
		},
		"dex": {
			"icon": "⚔️",
			"intro": "史上被称作“剑圣”的人，都是开创者——他们走到剑的尽头，然后回头，把路指给别人看。他早已不再寻找对手，只是在等，等有人能看见他留下的那一道线。\n“剑的尽头……是一片没有人走过的路。”",
			"stats": [
				{"label": "生命", "value": "80"},
				{"label": "定位", "value": "高速连击 / 脆皮"},
				{"label": "三式刀法", "value": "普攻/技能1/技能2 各一式，最近2次普攻决定 O 键触发的技能"},
				{"label": "乘岚斩霞", "value": "长按 S 蓄力架势，蓄力中释放任意普攻 +30% 且无前摇"},
				{"label": "千峰破云", "value": "屏幕下方显示最近2次普攻种类；21→千枫落华斩（一技能）、31→玄鸟衔月闪（二技能）、23/32→孤鸿踏雪"},
			],
			"skills": [
				{"name": "三式刀法", "desc": "一式·踏月逐风斩：三连挥刀，按帧出伤（共5伤），空中改为斜下坠击；二式·九霄断水吟：大范围横斩（身前180/身后150像素，伤害5，可摧毁飞行物）；三式·云龙贯霄刺：两段突进（第一段4伤、第二段3伤）。", "meta": "冷却：1.5/2/3 秒"},
				{"name": "千枫落华斩", "desc": "千峰破云显示 21 时按 O 触发（一技能）：剑豪消失，随后制造大量刀光斩击敌人，共造成 9 伤（按帧出伤），范围几乎 2/3 镜头。", "meta": "消耗：30 能 ｜ 冷却：12 秒"},
				{"name": "玄鸟衔月闪", "desc": "千峰破云显示 31 时按 O 触发（二技能）：向前瞬移200像素抓取敌人（200像素内有追踪效果，瞬移到敌人身前），随后拔剑斩击，共造成 4+8 伤害。若释放前两次普攻有任意一次命中敌人，则直接瞬移到敌人身后释放。", "meta": "消耗：20 能 ｜ 冷却：10 秒"},
				{"name": "孤鸿踏雪", "desc": "千峰破云显示 23 或 32 时按 O 触发（大招）：剑豪蓄力释放一道斩击，贯穿屏幕，共造成 40 伤（按帧出伤）。", "meta": "消耗：100 能 ｜ 冷却：15 秒"},
			],
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "千枫落华斩", SKILL1_COOLDOWN, SKILL1_ENERGY, Callable(), Callable(_skill2)),
		Skill.new("skill2", "玄鸟衔月闪", SKILL2_COOLDOWN, SKILL2_ENERGY, Callable(), Callable(_skill1)),
		Skill.new("ult", "孤鸿踏雪", ULT_COOLDOWN, ULT_ENERGY, Callable(), Callable(_ult)),
	]

## 待机动画锚点：把 foot_gaps 常量组装成 FrameAnimation 需要的字典数组
static func _kensai_idle_anchors() -> Array:
	var anchors := []
	for i in range(KENSAI_IDLE_FOOT_GAPS.KENSAI_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": KENSAI_IDLE_FOOT_GAPS.KENSAI_IDLE_FOOT[i],
			"head_gap": KENSAI_IDLE_FOOT_GAPS.KENSAI_IDLE_HEAD[i],
			"center_dx": KENSAI_IDLE_FOOT_GAPS.KENSAI_IDLE_CENTER[i],
			"content_w": KENSAI_IDLE_FOOT_GAPS.KENSAI_IDLE_CONTENT_W[i],
			"content_h": KENSAI_IDLE_FOOT_GAPS.KENSAI_IDLE_CONTENT_H[i],
		})
	return anchors

static func _kensai_walk_anchors() -> Array:
	var anchors := []
	for i in range(KENSAI_WALK_FOOT_GAPS.KENSAI_WALK_FOOT.size()):
		anchors.append({
			"foot_gap": KENSAI_WALK_FOOT_GAPS.KENSAI_WALK_FOOT[i],
			"head_gap": KENSAI_WALK_FOOT_GAPS.KENSAI_WALK_HEAD[i],
			"center_dx": KENSAI_WALK_FOOT_GAPS.KENSAI_WALK_CENTER[i],
			"content_w": KENSAI_WALK_FOOT_GAPS.KENSAI_WALK_CONTENT_W[i],
			"content_h": KENSAI_WALK_FOOT_GAPS.KENSAI_WALK_CONTENT_H[i],
		})
	return anchors

## 移动动画：12 帧舍弃前三帧（起手准备），保留格 4..12 共 9 帧
static func _kensai_walk_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "walk/sheet.png", 4, 3, 12, 0.1, true, _kensai_walk_anchors())
	anim.frames = anim.frames.slice(3, 12)
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

## 跳跃动画：8 帧舍弃 f1~f2（多余起手），保留 [f0, f3, f4, f5, f6, f7] 共 6 帧。
## f5~f6 为滞空帧（切分后索引 3~4），由 update_systems 在空中循环播放。
static func _kensai_jump_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "jump/sheet.png", 3, 3, 8, 0.08, false, _kensai_jump_anchors())
	var keep := [0, 3, 4, 5, 6, 7]
	var frames: Array[FrameAnimation.FrameData] = []
	for i in keep:
		frames.append(anim.frames[i])
	anim.frames.assign(frames)
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

## 空中普攻1动画：单帧坠击姿势（2048×2048，内容 1582×1229 → 锚点映射到 56px 与待机一致）
static func _kensai_attack_air_anim() -> FrameAnimation:
	var a = FrameAnimation.load_from_frames(KENSAI_ANI_DIR + "attack1/", "", [{"index": 1, "duration": 0.3, "filename": "kensai_attack_air_f_1.png"}], false)
	if a.frames.size() > 0:
		a.frames[0].foot_gap = 526
		a.frames[0].head_gap = 293
		a.frames[0].center_dx = -222.0
		a.frames[0].content_w = 1582
		a.frames[0].content_h = 1229
		a._calc_content_h_ref()
	return a

## 三式刀光：stage=1 前突横斩（200×27）/ stage=2 回身斜上斩（150×113）/ 0 清除
static func _kensai_atk3_slash(f: Fighter, stage: int) -> void:
	var key = str(f.get_instance_id()) + "_kensai_atk3s"
	if stage == 0:
		GameWorld.unregister_draw_effect(key)
		return
	var tex = KENSAI_ATK3_SLASH1 if stage == 1 else KENSAI_ATK3_SLASH2
	var w: float = 200.0 if stage == 1 else 150.0
	var h: float = 27.0 if stage == 1 else 113.0
	GameWorld.register_draw_effect(key, func(font, cam_x, cam_y = 0.0):
		var cx = f.pos_x + f.w / 2.0 - cam_x
		var cy = f.pos_y + f.h / 2.0 - cam_y
		var fl = f.facing > 0   # 刀光镜像（相对默认朝向翻转）
		return [
			{"type": "set_transform", "pos": Vector2(cx, cy), "scale": Vector2(-1.0 if fl else 1.0, 1.0)},
			{"type": "tex", "tex": tex, "rect": Rect2(-w / 2.0, -h / 2.0, w, h), "color": Color(1, 1, 1, 0.9)},
			{"type": "reset_transform"},
		]
	, 0)

## 二式动画：7 帧舍弃第3帧（f2），保留 [f0, f1, f3, f4, f5, f6] 共 6 帧
static func _kensai_attack2_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(KENSAI_ANI_DIR + "attack2/sheet.png", 3, 3, 7, 0.06, false, _kensai_attack2_anchors())
	var keep := [0, 1, 3, 4, 5, 6]
	var frames: Array[FrameAnimation.FrameData] = []
	for i in keep:
		frames.append(anim.frames[i])
	anim.frames.assign(frames)
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

static func _kensai_stance_anchors() -> Array:
	var anchors := []
	for i in range(KENSAI_STANCE_FOOT_GAPS.KENSAI_STANCE_FOOT.size()):
		anchors.append({
			"foot_gap": KENSAI_STANCE_FOOT_GAPS.KENSAI_STANCE_FOOT[i],
			"head_gap": KENSAI_STANCE_FOOT_GAPS.KENSAI_STANCE_HEAD[i],
			"center_dx": KENSAI_STANCE_FOOT_GAPS.KENSAI_STANCE_CENTER[i],
			"content_w": KENSAI_STANCE_FOOT_GAPS.KENSAI_STANCE_CONTENT_W[i],
			"content_h": KENSAI_STANCE_FOOT_GAPS.KENSAI_STANCE_CONTENT_H[i],
		})
	return anchors

## 普攻1动画锚点（attack1/sheet.png 前5帧）
static func _kensai_attack1_anchors() -> Array:
	var anchors := []
	for i in range(KENSAI_ATTACK1_FOOT_GAPS.KENSAI_ATTACK1_FOOT.size()):
		anchors.append({
			"foot_gap": KENSAI_ATTACK1_FOOT_GAPS.KENSAI_ATTACK1_FOOT[i],
			"head_gap": KENSAI_ATTACK1_FOOT_GAPS.KENSAI_ATTACK1_HEAD[i],
			"center_dx": KENSAI_ATTACK1_FOOT_GAPS.KENSAI_ATTACK1_CENTER[i],
			"content_w": KENSAI_ATTACK1_FOOT_GAPS.KENSAI_ATTACK1_CONTENT_W[i],
			"content_h": KENSAI_ATTACK1_FOOT_GAPS.KENSAI_ATTACK1_CONTENT_H[i],
		})
	return anchors

## 普攻1刀光锚点（attack1/sheet。.png 前8帧）
static func _kensai_attack1_slash_anchors() -> Array:
	var anchors := []
	for i in range(KENSAI_ATTACK1_SLASH_FOOT_GAPS.KENSAI_ATTACK1_SLASH_FOOT.size()):
		anchors.append({
			"foot_gap": KENSAI_ATTACK1_SLASH_FOOT_GAPS.KENSAI_ATTACK1_SLASH_FOOT[i],
			"head_gap": KENSAI_ATTACK1_SLASH_FOOT_GAPS.KENSAI_ATTACK1_SLASH_HEAD[i],
			"center_dx": KENSAI_ATTACK1_SLASH_FOOT_GAPS.KENSAI_ATTACK1_SLASH_CENTER[i],
			"content_w": KENSAI_ATTACK1_SLASH_FOOT_GAPS.KENSAI_ATTACK1_SLASH_CONTENT_W[i],
			"content_h": KENSAI_ATTACK1_SLASH_FOOT_GAPS.KENSAI_ATTACK1_SLASH_CONTENT_H[i],
		})
	return anchors

## 普攻3单帧动画：attack1/sheet.png 第4帧（横贯大斩），供云龙贯霄刺突进期间显示
static func _kensai_attack3_anim() -> FrameAnimation:
	var anim := FrameAnimation.new()
	var atlas: Texture2D = load(KENSAI_ANI_DIR + "attack1/sheet.png")
	var at := AtlasTexture.new()
	at.atlas = atlas
	at.region = Rect2(0 * 1440, 1 * 1080, 1440, 1080)  # 帧3：第2行第1列（col0, row1）
	# 帧3 锚点：foot_gap=68 head_gap=81 center_dx=30 content 966×931
	anim.add_frame(at, 0.1, 68, 81, 30.0, 966, 931)
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

## 玄鸟衔月闪锚点（skill_2/sheet.png 帧1~18，索引0~17；帧19/20 空白已剔除）
static func _kensai_skill1_anchors() -> Array:
	var anchors := []
	for i in range(18):
		anchors.append({
			"foot_gap": KENSAI_SKILL1_FOOT_GAPS.KENSAI_SKILL1_FOOT[i],
			"head_gap": KENSAI_SKILL1_FOOT_GAPS.KENSAI_SKILL1_HEAD[i],
			"center_dx": KENSAI_SKILL1_FOOT_GAPS.KENSAI_SKILL1_CENTER[i],
			"content_w": KENSAI_SKILL1_FOOT_GAPS.KENSAI_SKILL1_CONTENT_W[i],
			"content_h": KENSAI_SKILL1_FOOT_GAPS.KENSAI_SKILL1_CONTENT_H[i],
		})
	return anchors

## 玄鸟衔月闪动画：skill_2/sheet.png 5列×4行取帧1~18（含原舍弃帧；帧19/20 空白剔除）
static func _kensai_skill1_anim() -> FrameAnimation:
	var anim := FrameAnimation.load_from_sprite_sheet(
		KENSAI_ANI_DIR + "skill_2/sheet.png", 5, 4, 20, 0.06, false, _kensai_skill1_anchors(), Vector2i(2, 1))
	if anim.frames.size() >= 18:
		anim.frames.assign(anim.frames.slice(0, 18))
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

static func _kensai_attack2_anchors() -> Array:
	var anchors := []
	for i in range(KENSAI_ATTACK2_FOOT_GAPS.KENSAI_ATTACK2_FOOT.size()):
		anchors.append({
			"foot_gap": KENSAI_ATTACK2_FOOT_GAPS.KENSAI_ATTACK2_FOOT[i],
			"head_gap": KENSAI_ATTACK2_FOOT_GAPS.KENSAI_ATTACK2_HEAD[i],
			"center_dx": KENSAI_ATTACK2_FOOT_GAPS.KENSAI_ATTACK2_CENTER[i],
			"content_w": KENSAI_ATTACK2_FOOT_GAPS.KENSAI_ATTACK2_CONTENT_W[i],
			"content_h": KENSAI_ATTACK2_FOOT_GAPS.KENSAI_ATTACK2_CONTENT_H[i],
		})
	return anchors

static func _kensai_jump_anchors() -> Array:
	var anchors := []
	for i in range(KENSAI_JUMP_FOOT_GAPS.KENSAI_JUMP_FOOT.size()):
		anchors.append({
			"foot_gap": KENSAI_JUMP_FOOT_GAPS.KENSAI_JUMP_FOOT[i],
			"head_gap": KENSAI_JUMP_FOOT_GAPS.KENSAI_JUMP_HEAD[i],
			"center_dx": KENSAI_JUMP_FOOT_GAPS.KENSAI_JUMP_CENTER[i],
			"content_w": KENSAI_JUMP_FOOT_GAPS.KENSAI_JUMP_CONTENT_W[i],
			"content_h": KENSAI_JUMP_FOOT_GAPS.KENSAI_JUMP_CONTENT_H[i],
		})
	return anchors

## 大招 60 帧动画规格（ult/output_timetable.txt：前 59 帧各 0.08s，末帧保持 1s）
static func _kensai_ult_specs() -> Array:
	var specs := []
	for i in range(59):
		specs.append({"index": i + 1, "duration": 0.08, "filename": "output_%04d.png" % (i + 1)})
	specs.append({"index": 60, "duration": 1.0, "filename": "output_0060.png"})
	return specs

static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var comp: KensaiComponent = owner.components.get_component("kensai") if owner.components else null
	if not comp:
		return 0
	if owner.hud_skill_labels.is_empty():
		owner.hud_skill_labels = {"attack": "踏月逐风斩", "skill1": "九霄断水吟", "skill2": "云龙贯霄刺", "ult": "连招·大招"}

	# 普攻起手（sheet.png 前5帧）期间锁定：不响应移动/技能输入
	if comp.windup_active:
		return 0

	# ── 特殊机制1：乘岚斩霞（拔刀蓄力）──
	# 地面长按 S：进入蓄力架势（播放拔刀动画）；蓄力状态下释放任意普攻 → +30% 且跳过前摇
	var down_just_pressed = keys.down and not comp.was_down_pressed
	comp.was_down_pressed = keys.down
	if down_just_pressed and owner.grounded and not owner.attacking and not owner.dashing and not comp.stance_active:
		comp.stance_active = true
		comp.stance_hits_taken = 0      # 每次蓄力重新获得霸体（可承受 2 次伤害）
		comp.stance_armor_broken = false
		owner.state = "stance"  # 标记 state，apply_physics 不再把拔刀架势覆盖回 idle/walk
		owner.set_animation_state("stance")  # 拔刀蓄力动画：播放一次后保持末尾架势
	if comp.stance_active:
		owner.vx = 0  # 乘岚斩霞期间完全锁死移动（清除行走惯性，apply_movement 是累积式）
		if not keys.down:
			comp.stance_active = false  # 松键结束蓄力（无强化）
		else:
			var stance_atk := 0
			if keys.attack: stance_atk = 1
			elif keys.skill1: stance_atk = 2
			elif keys.skill2: stance_atk = 3
			if stance_atk > 0:
				# 蓄力状态下释放普攻：+30% 且不播放前摇，直接出招
				comp.stance_active = false
				if _stance_attack(owner, comp, stance_atk):
					keys.attack = false
					keys.skill1 = false
					keys.skill2 = false
					return 0
			elif keys.ult:
				comp.stance_active = false  # 大招键退出蓄力（无强化），交给连招处理
			else:
				return 0  # 蓄力期间不可移动、不处理其他输入

	# 释放一/二技能期间剑豪不可移动（千枫落华斩 / 玄鸟衔月闪演出中锁定）
	if comp.skill1_active or comp.qflh_active or comp.qflh_windup_active:
		owner.vx = 0
		owner.vy = 0
		return 0

	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and owner.grounded:
		owner.vy = -10
		owner.grounded = false

	# 大招键：按连招序列触发对应技能（消耗成功后清空连招）
	if keys.ult:
		_try_combo_skill(owner, comp, keys)
		keys.ult = false

	# 三式普攻：技能1/技能2 键在剑豪身上是普攻 2/3
	if keys.skill2:
		if _try_attack(owner, comp, 3):
			keys.skill2 = false
	elif keys.skill1:
		if _try_attack(owner, comp, 2):
			keys.skill1 = false
	elif keys.attack:
		if _try_attack(owner, comp, 1):
			keys.attack = false

	# 三式·云龙贯霄刺：突进/间隔期间接管移动（速度固定，防移速钳制）
	if comp.atk3_stage > 0:
		match comp.atk3_stage:
			1:
				if comp.atk3_air:
					# 空中：向前下 30° 倾斜突进
					owner.vx = owner.facing * ATK3_FWD_DOWN_VX
					owner.vy = ATK3_FWD_DOWN_VY
				else:
					owner.vx = owner.facing * ATK3_DASH_SPEED
					owner.vy = 0.0
			2:
				# 间隔：原地停顿 10 帧
				owner.vx = 0.0
				owner.vy = 0.0
			3:
				if comp.atk3_air:
					# 空中：向身后水平突进
					owner.vx = owner.facing * ATK3_DASH_SPEED
					owner.vy = 0.0
				else:
					# 地面：回身斜上 30°（facing 已在进入间隔时翻转）
					owner.vx = owner.facing * ATK3_BACK_VX
					owner.vy = -ATK3_BACK_VY
		return mx

	Fighter.apply_movement(owner, mx, owner.attack_speed)
	# 大招演出中 state 保持 "ult"（_advance_time_stop_casters 靠它识别出招者推进出伤；
	# update_state 会把 "ult" 无条件覆盖成 idle/walk，导致时停期间出伤被跳过）
	if owner.state != "ult":
		Fighter.update_state(owner, mx)
	# 空中坠击：整个坠击过程锁定 40° 轨迹（vx≈21.5 / vy=18），
	# 避免被 apply_movement 的移速上限（attack_speed）钳成垂直下坠
	if comp.atk1_plunge_active:
		owner.vx = owner.facing * ATK1_AIR_VX
		owner.vy = ATK1_AIR_VY
	return mx

## 千峰破云：按最近2次普攻组合触发 O 键技能（完全替换旧连招）
static func _try_combo_skill(owner: Fighter, comp: KensaiComponent, _keys: Dictionary):
	var skill_key := ""
	match comp.combo_key():
		"21": skill_key = "skill1"    # 一技能：玄鸟衔月闪
		"31": skill_key = "skill2"    # 二技能：玄鸟衔月闪
		"23", "32": skill_key = "ult" # 孤鸿踏雪（大招）
	if skill_key == "":
		return
	var s = owner.get_skill(skill_key)
	if not s or not s.can_use(owner):
		return
	var r = s.try_use(owner)
	if r is Dictionary and not r.get("success", false):
		return
	# 千峰破云：技能释放成功后清空组合（每个拼出的技能只能释放一次），
	# 回到开局状态（无显示），需重新通过普攻搭配获得技能
	comp.combo_seq.clear()
	comp.atk_hit_flags.clear()
	comp.combo_expire_timer = -1  # 技能已释放：关闭释放窗口（黄条）

## 乘岚斩霞强化倍率：attack_buff 生效期间 1.3，否则 1.0
static func _bm(comp: KensaiComponent) -> float:
	return 1.0 + STANCE_DMG_BONUS if comp.attack_buff else 1.0

## 触发三式中的某一式普攻（复用 Fighter 内置近战判定）
static func _try_attack(owner: Fighter, comp: KensaiComponent, atk_id: int) -> bool:
	if owner.attacking or owner.dashing:
		return false
	if comp.attack_cd.get(atk_id, 0) > 0:
		return false  # 各招式独立冷却
	# 一式·踏月逐风斩：地面三连挥刀按帧出伤 / 空中坠击（单独处理）
	if atk_id == 1:
		return _start_atk1(owner, comp)
	# 二式·九霄断水吟：大范围横斩（自定义判定框，身前50/身后80）
	if atk_id == 2:
		return _start_atk2(owner, comp)
	# 三式·云龙贯霄刺：两段突进连击
	return _start_atk3(owner, comp)

## 普攻起手：播放 sheet.png 前几帧（拔刀架势），播完由 update_systems 执行对应招式
static func _begin_windup(owner: Fighter, comp: KensaiComponent, atk_id: int, air: bool = false) -> void:
	comp.windup_active = true
	comp.windup_timer = 0
	comp.windup_attack = atk_id
	comp.windup_air = air  # 空中普攻1起手：只播前2帧（12帧）就俯冲
	owner.state = "windup"  # 标记 state，apply_physics 不把起手动画覆盖回 idle/walk
	owner.set_animation_state("attack_windup")

## 一式·踏月逐风斩：起手后地面三连挥刀（按帧出伤 3×3=9）；空中改为 40° 斜下坠击
static func _exec_atk1(owner: Fighter, comp: KensaiComponent) -> void:
	owner.attack_range = ATK1_RANGE
	owner.attack_delay = ATTACK_DELAY
	if not owner.grounded:
		# 空中：斜向下约 40° 快速坠击（下坠 18），单次高伤
		owner.attack_damage = ATK1_AIR_DMG * _bm(comp)
		owner.attack_timer = 18
		owner.attacking = true
		owner.attack_hit_dealt = false
		owner.vx = owner.facing * ATK1_AIR_VX
		owner.vy = ATK1_AIR_VY
		comp.atk1_swing = 0
		comp.atk1_plunge_active = true
		owner.state = "attack"
		owner.set_animation_state("attack_air")
		Fighter.emit_slash(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, float(owner.facing), Color(0.9, 0.95, 1.0, 0.5))
		return
	# 地面：播放普攻1动画（attack1/sheet.png 前5帧：三连挥刀+剑光收尾），
	# 按帧出伤：动画每推进到新挥刀帧（索引0/1/2）各判定一次（每帧 3 伤），剑光帧不出伤
	owner.attack_timer = ATK1_ANIM_DURATION
	owner.attack_delay = 0
	owner.attack_hit_dealt = true   # 禁用内置单次判定，改由 update_systems 按帧结算
	owner.attacking = true
	comp.atk1_swing = 0          # 不再使用两段衔接
	comp.atk1_plunge_active = false
	comp.atk1_last_hit_frame = -1
	comp.atk1_frame_active = true   # 开启按帧出伤（三连挥刀每帧判定）
	owner.state = "attack"
	owner.set_animation_state("attack1")
	_start_atk1_slash(owner, comp)   # 普攻1刀光特效（参考刺客普攻）
	Fighter.emit_slash(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, float(owner.facing), Color(0.9, 0.95, 1.0, 0.5))

## 普攻1按帧出伤：动画当前帧推进到新挥刀帧（0/1/2）时判定一次（5/3 伤）
static func _atk1_frame_hit(f: Fighter, comp: KensaiComponent) -> void:
	if not f.attacking:
		return  # 攻击结束（动画已切回 idle）不得误判
	var idx: int = f.current_anim.get_current_index() if f.current_anim else -1
	if idx < 0 or idx > ATK1_ANIM_HIT_FRAME or idx == comp.atk1_last_hit_frame:
		return
	comp.atk1_last_hit_frame = idx
	var target = GameWorld.get_opponent(f)
	if target and target.hp > 0 and f.get_attack_box().intersects(target.get_hit_box()):
		comp.mark_attack_hit()   # 玄鸟衔月闪：记录本次普攻命中
		Fighter.apply_damage(target, ATK1_HIT1_DMG * _bm(comp), f, false, Color(0.9, 0.95, 1.0), "hit_enemy", "attack1", 0)
	# 普攻1机制：摧毁攻击框内的飞行物 → 瞬间时停 + 时停结束后紧跟屏幕震动（手感反馈）
	var box: Rect2 = f.get_attack_box()
	var doomed: Array = []
	for proj in GameWorld.projectiles:
		if proj is Dictionary and box.intersects(Rect2(proj["x"], proj["y"], proj["w"], proj["h"])):
			doomed.append(proj)
	if not doomed.is_empty():
		for proj in doomed:
			GameWorld.projectiles.erase(proj)
			Fighter.emit_particles(proj["x"] + proj["w"] / 2.0, proj["y"] + proj["h"] / 2.0, 12, Color(0.95, 0.95, 1.0, 0.8), 4, 5, "star", 0.7)
		_time_stop_caster(f, ATK1_TS_FRAMES)
		GameWorld.queue_after_time_stop(func():
			if is_instance_valid(f):
				GameWorld.trigger_shake(14.0, 16)
		)

## 普攻1刀光特效：懒加载刀光动画并从头播放（attack1/sheet。.png 8帧）
static func _start_atk1_slash(owner: Fighter, comp: KensaiComponent) -> void:
	if comp.atk1_slash_anim == null:
		comp.atk1_slash_anim = FrameAnimation.load_from_sprite_sheet(
			ATK1_SLASH_SHEET, 3, 3, ATK1_SLASH_FRAMES, ATK1_SLASH_FRAME_SEC, false,
			_kensai_attack1_slash_anchors())
	comp.atk1_slash_anim.play()
	comp.atk1_slash_active = true

## 二式·九霄断水吟：起手后播放 attack2 横斩动画，满刀帧出伤并摧毁范围内飞行物
static func _exec_atk2(owner: Fighter, comp: KensaiComponent) -> void:
	owner.attack_damage = ATK2_DMG * _bm(comp)
	owner.attacking = true
	owner.attack_timer = ATK2_SWING_DURATION
	owner.attack_delay = ATTACK_DELAY
	owner.attack_hit_dealt = true   # 禁用内置正向判定，改用自定义大范围判定
	owner.state = "attack"
	owner.set_animation_state("attack2")
	comp.slash_active = true
	comp.slash_hit_timer = ATK2_HIT_FRAME
	comp.slash_damage_dealt = false
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 12, Color(0.85, 0.95, 1.0, 0.5), 4, 5, "star", 0.8)

## 三式·云龙贯霄刺：起手后向前突进150 → 回身斜上突进200（30°），伤害 3+3，冷却 3s
static func _exec_atk3(owner: Fighter, comp: KensaiComponent) -> void:
	owner.attack_damage = ATK3_DMG_HIT1 * _bm(comp)
	owner.attacking = true
	owner.attack_timer = ATK3_TOTAL_FRAMES + 4
	owner.attack_delay = 0
	owner.attack_hit_dealt = true   # 禁用内置判定，两段命中由组件状态机控制
	owner.state = "attack"
	owner.set_animation_state("attack3")   # 突进期间显示 sheet 第4帧（横贯大斩）
	comp.atk3_stage = 1
	comp.atk3_timer = ATK3_DASH1_FRAMES
	comp.atk3_air = not owner.grounded   # 空中释放 → 交换两段方向
	comp.atk3_dmg1_dealt = false
	comp.atk3_dmg2_dealt = false
	owner.vx = owner.facing * ATK3_DASH_SPEED
	owner.vy = 0.0
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 14, Color(0.9, 0.95, 1.0, 0.5), 5, 6, "star", 1.0)

## 蓄力状态下释放普攻：直接出招（跳过前摇），本次攻击 +30%
static func _stance_attack(owner: Fighter, comp: KensaiComponent, atk_id: int) -> bool:
	if owner.attacking or owner.dashing:
		return false
	if comp.attack_cd.get(atk_id, 0) > 0:
		return false
	match atk_id:
		1: comp.attack_cd[1] = ATK1_COOLDOWN
		2: comp.attack_cd[2] = ATK2_COOLDOWN
		3: comp.attack_cd[3] = ATK3_COOLDOWN
	comp.record_attack(atk_id)
	comp.attack_buff = true  # 乘岚斩霞：本次攻击 +30%
	match atk_id:
		1: _exec_atk1(owner, comp)
		2: _exec_atk2(owner, comp)
		3: _exec_atk3(owner, comp)
	return true

## 一式·踏月逐风斩（入口）：空中先播 2 帧起手再俯冲；地面播 5 帧起手
static func _start_atk1(owner: Fighter, comp: KensaiComponent) -> bool:
	comp.attack_cd[1] = ATK1_COOLDOWN
	comp.record_attack(1)
	_begin_windup(owner, comp, 1, not owner.grounded)
	return true

## 二式·九霄断水吟（入口）：先播起手
static func _start_atk2(owner: Fighter, comp: KensaiComponent) -> bool:
	comp.attack_cd[2] = ATK2_COOLDOWN
	comp.record_attack(2)
	_begin_windup(owner, comp, 2)
	return true

## 三式·云龙贯霄刺（入口）：先播起手
static func _start_atk3(owner: Fighter, comp: KensaiComponent) -> bool:
	comp.attack_cd[3] = ATK3_COOLDOWN
	comp.record_attack(3)
	_begin_windup(owner, comp, 3)
	return true

## 云龙贯霄刺：身前近战判定框（跟随 facing），命中返回 true
static func _atk3_check_hit(f: Fighter) -> bool:
	var enemy = GameWorld.get_opponent(f)
	if not enemy or enemy.hp <= 0:
		return false
	var box: Rect2
	if f.facing > 0:
		box = Rect2(f.pos_x + f.w, f.pos_y + 6.0, 46.0, f.h - 16.0)
	else:
		box = Rect2(f.pos_x - 46.0, f.pos_y + 6.0, 46.0, f.h - 16.0)
	return box.intersects(enemy.get_hit_box())

## 触发瞬间时停（短暂全冻结：敌人/环境/动画短暂暂停，时停计时归零后自动恢复，不会卡死）。
## 不用 state_flags["time_stop"] 标记：标记会使 is_time_stopped() 恒真，且 check_time_stop_end
## 依赖 not is_time_stopped() 触发清除队列 → 形成死锁（永久时停卡住）
static func _time_stop_caster(_owner: Fighter, duration: int):
	GameWorld.trigger_time_stop(duration)

## 解除抓取冻结：移除敌人的 frozen 状态（抓取期间敌人不可操作，结束后解除）
static func _unfreeze_enemy(e: Fighter):
	if e == null or e.statuses.is_empty():
		return
	e.statuses = e.statuses.filter(func(s): return s.id != "frozen")

## 玄鸟衔月闪（O·31 二技能触发）：向前瞬移抓取敌人，随后拔剑斩击（5+10伤）。
## 只要千峰破云显示 31 即可释放；200px 内（或前两次普攻任意命中）有追踪效果：
## 命中 → 准确瞬移到敌人身后；200px 内未命中 → 瞬移到敌人身前；200px 外未命中 → 向前瞬移固定距离
static func _skill1(owner: Fighter) -> Dictionary:
	var comp: KensaiComponent = owner.components.get_component("kensai") if owner.components else null
	if not comp:
		return {"success": false}
	var enemy = GameWorld.get_opponent(owner)
	if not enemy or enemy.hp <= 0:
		return {"success": false}
	var dist: float = absf(enemy.pos_x - owner.pos_x)
	# 前两次普攻任意命中 → 追踪身后；200px 内未命中 → 追踪身前
	var behind := false
	for b in comp.atk_hit_flags:
		if b:
			behind = true
			break
	var side: float = 1.0 if enemy.pos_x >= owner.pos_x else -1.0
	var gap: float = enemy.w / 2.0 + owner.w / 2.0 + 6.0
	if behind:
		# 准确瞬移到敌人身后（敌人 facing 反方向），剑豪转身面向敌人再攻击；y 轴对齐敌人
		owner.pos_x = enemy.pos_x - enemy.facing * gap
		owner.pos_y = enemy.pos_y
		owner.facing = -enemy.facing
	elif dist <= SKILL1_RANGE:
		owner.pos_x = enemy.pos_x - side * gap   # 200px 内追踪到敌人身前
		owner.pos_y = enemy.pos_y                # y 轴对齐敌人
		owner.facing = int(side)                 # 面向敌人
	else:
		# 200px 外且未命中：无追踪，向前瞬移固定距离
		owner.pos_x += owner.facing * SKILL1_RANGE
	# 播放抓取→斩击动画（帧3~14）：复用 config 动画对象，随 current_anim 统一推进
	comp.skill1_anim = owner.config.get("animations", {}).get("skill1")
	if comp.skill1_anim == null:
		comp.skill1_anim = _kensai_skill1_anim()
	comp.skill1_anim.play()
	comp.skill1_stage = 1
	comp.skill1_dmg_dealt = false
	comp.skill1_slash_dmg_dealt = false
	comp.skill1_grabbed = false
	comp.skill1_grab_pos_x = enemy.pos_x + enemy.w / 2.0  # 抓取定身基准：敌人被抓取时中心 x
	enemy.add_status("frozen")  # 抓取期间敌人不可操作（frozen 锁移动/AI/输入），斩击段开始时解除
	# 不设 attacking：让 fighter.apply_physics 的 image_state.begins_with("skill") 分支保留玄鸟衔月闪动画。
	# 设 attacking 会被覆盖成 attack 动画 → 技能动画不播放且 skill1_anim 永不结束（技能结束后仍锁移动）
	owner.state = "attack"
	owner.set_animation_state("skill1")
	comp.skill1_active = true
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 12, Color(0.95, 0.9, 1.0, 0.5), 4, 5, "star", 0.8)
	return {"success": true}

## 千枫落华斩（O·21 一技能触发）：先播 sheet.png 前6帧起手（技能体、无无敌，可被打断），
## 起手播完进入全屏斩击阶段（剑豪消失 + 大量刀光斩击，无敌）。
## 伤害 9 按帧出伤，范围几乎 2/3 镜头
static func _skill2(owner: Fighter) -> Dictionary:
	var comp: KensaiComponent = owner.components.get_component("kensai") if owner.components else null
	if not comp:
		return {"success": false}
	# 防止重复叠加（起手阶段或全屏斩击进行中均不可再触发）
	if comp.qflh_active or comp.qflh_windup_active:
		return {"success": false}
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "kensai_qflh":
			return {"success": false}
	# 起手阶段：播 sheet.png 前6帧（技能体、无无敌，被打断则取消技能）；播完由 update_systems 进入全屏斩击
	comp.qflh_windup_active = true
	comp.qflh_windup_timer = 0
	owner.attacking = true
	owner.attack_timer = QFLH_TOTAL_FRAMES + QFLH_WINDUP_FRAMES
	owner.state = "attack"
	owner.set_animation_state("skill1_windup")
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 20, Color(0.95, 0.9, 1.0, 0.5), 5, 6, "star", 1.0)
	return {"success": true}

## 千枫落华斩全屏斩击阶段（起手播完后调用）：剑豪消失 + 全屏刀光 + 无敌
static func _start_qflh(owner: Fighter, comp: KensaiComponent) -> void:
	var qflh_anim: FrameAnimation = owner.config.get("animations", {}).get("qflh")
	if qflh_anim == null:
		comp.qflh_active = false
		owner.attacking = false
		owner.state = "idle"
		return
	qflh_anim.play()
	comp.qflh_anim = qflh_anim
	comp.qflh_active = true
	comp.qflh_damage_acc = 0.0
	comp.qflh_last_frame = -1
	comp.qflh_origin_x = owner.pos_x
	comp.qflh_origin_y = owner.pos_y
	# 剑豪消失：隐藏本体渲染，由全屏刀光 overlay 接管（与大招同款全屏动画）
	owner.state_flags["skip_fighter_draw"] = true
	Fighter.set_invincible(owner)  # 斩击阶段无敌（起手阶段无无敌，可被打断）
	owner.attacking = true
	owner.attack_timer = QFLH_TOTAL_FRAMES
	owner.state = "attack"
	GameWorld.active_overlays.append({
		"anim": qflh_anim,
		"position": {"type": "fullscreen"},
		"overlay_id": "kensai_qflh",
		"on_finish": func():
			comp.qflh_active = false
			comp.qflh_damage_acc = 0.0
			comp.qflh_last_frame = -1
			owner.attacking = false
			owner.state = "idle"
			owner.state_flags.erase("skip_fighter_draw")
			Fighter.clear_invincible(owner)
	})

## 孤鸿踏雪（O·23/32 触发）：剑豪蓄力释放一道斩击贯穿屏幕（全屏动画承载演出）
static func _ult(owner: Fighter) -> Dictionary:
	var comp: KensaiComponent = owner.components.get_component("kensai") if owner.components else null
	if not comp:
		return {"success": false}
	# 照搬刺客：大招演出中不可重复释放（防重复扣能量/重复开 overlay）
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "kensai_ult":
			return {"success": false}
	# 每次释放新建动画对象：全屏 overlay 独立推进，不与剑豪 current_anim 共用（共用会 2 倍速）
	var ult_anim = FrameAnimation.load_from_frames(KENSAI_ANI_DIR + "ult/", "", _kensai_ult_specs(), false)
	if ult_anim.frames.is_empty():
		printerr("[Kensai] ult 动画帧加载失败（assets/char_ani/kensai/ult/ 缺贴图?）")
		return {"success": false}
	ult_anim.play()
	comp.ult_active = true
	comp.ult_damage_dealt = false
	comp.ult_dot_last_frame = -1
	comp.ult_dot_acc = 0.0
	comp.ult_anim_obj = ult_anim
	owner.state = "ult"
	# 剑豪消失：全屏斩击动画为 100% 不透明整屏演出，本体隐藏（不参与 current_anim 播放）
	owner.state_flags["skip_fighter_draw"] = true
	Fighter.set_invincible(owner)  # 大招演出期间无敌，防止被打死导致出伤中断（打不到人）
	GameWorld.hit_stop = ULT_HIT_STOP
	GameWorld.active_overlays.append({
		"anim": ult_anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "kensai_ult",
		"on_finish": func():
			comp.ult_active = false
			comp.ult_anim_obj = null
			owner.state = "idle"
			owner.state_flags.erase("skip_fighter_draw")
			Fighter.clear_invincible(owner)
	})
	return {"success": true}

## 孤鸿踏雪出伤：判定照搬刺客大招——以"释放者当前位置"为中心的全屏 600×600 矩形框，
## 不传自定义中心（与刺客完全一致），只要敌人与释放者同框即命中，杜绝高度/范围偏差打空
static func _ult_damage_zone(f: Fighter, dmg: float) -> void:
	Fighter.apply_ult_damage_zone(f, dmg, Color(0.9, 0.95, 1.0), 600.0)

## 每帧更新：连招窗口 + 大招逐帧出伤
static func update_systems(f: Fighter):
	if f.hp <= 0:
		return
	var comp: KensaiComponent = f.components.get_component("kensai") if f.components else null
	if not comp:
		return
	# 多帧 sheet 动画需要每帧 update 才能换帧（待机呼吸 / 移动 / 跳跃 / 大招）
	if f.current_anim and f.current_anim.is_playing():
		f.current_anim.update(1.0)
	# 一技能（千枫落华斩）起手：sheet.png 前6帧播完 → 进入全屏斩击阶段
	if comp.qflh_windup_active:
		comp.qflh_windup_timer += 1
		f.vx = 0  # 起手锁定移动
		f.vy = 0
		if comp.qflh_windup_timer >= QFLH_WINDUP_FRAMES:
			comp.qflh_windup_active = false
			comp.qflh_windup_timer = 0
			_start_qflh(f, comp)
	# 普攻起手：sheet.png 前5帧播完执行对应招式
	if comp.windup_active:
		comp.windup_timer += 1
		f.vx = 0  # 起手锁定移动
		if not f.grounded:
			f.vy = 0  # 空中起手悬停，保证空中坠击完整
		if comp.windup_timer >= (WINDUP_FRAMES_AIR if comp.windup_air else WINDUP_FRAMES):
			comp.windup_active = false
			comp.windup_air = false
			match comp.windup_attack:
				1: _exec_atk1(f, comp)
				2: _exec_atk2(f, comp)
				3: _exec_atk3(f, comp)
			comp.windup_attack = 0
	# 跳跃滞空：空中只保持峰值帧（原第6帧 f5，切分后索引3），落地由 update_state 切回 idle
	if f.image_state == "jump" and not f.grounded:
		var ja: FrameAnimation = f.current_anim
		if ja and ja.frames.size() > 3 and ja.get_current_index() >= 3:
			ja.set_frame_index(3)
	# 乘岚斩霞强化：本次攻击结束后清除（起手期间不算结束）
	if comp.attack_buff and not f.attacking and not comp.windup_active:
		comp.attack_buff = false
	# 一式·踏月逐风斩：按帧出伤（三连挥刀），清理残留衔接状态
	if comp.atk1_swing != 0 and not f.attacking:
		comp.atk1_swing = 0
	# 空中坠击落地后清理状态
	if comp.atk1_plunge_active and f.grounded:
		comp.atk1_plunge_active = false
	# 普攻1按帧出伤：动画推进到新挥刀帧（索引0/1/2）各判定一次；攻击结束立即关闭
	if comp.atk1_frame_active:
		if f.attacking:
			_atk1_frame_hit(f, comp)
		else:
			comp.atk1_frame_active = false
			comp.atk1_last_hit_frame = -1
	# 普攻1刀光特效：推进动画并注册绘制（参考刺客普攻 slash）
	if comp.atk1_slash_active:
		var slash_anim: FrameAnimation = comp.atk1_slash_anim
		if slash_anim and slash_anim.is_playing():
			slash_anim.update(1.0)
		else:
			comp.atk1_slash_active = false
		if comp.atk1_slash_active:
			GameWorld.register_draw_effect(str(f.get_instance_id()) + "_atk1_slash", func(font, cam_x, _cam_y = 0.0):
				var items: Array = []
				var sa: FrameAnimation = comp.atk1_slash_anim
				if sa:
					var tex = sa.get_current_texture()
					if tex:
						# 参考刺客普攻：斩击画在身前（显示高度 ≈80px，放大2倍），并上移 120px（50+70）
						var s = 80.0 / float(KENSAI_ATTACK1_SLASH_FOOT_GAPS.KENSAI_ATTACK1_SLASH_HEIGHT_MEDIAN)
						var tw = tex.get_width() * s
						var th = tex.get_height() * s
						var sx = f.pos_x + (f.w if f.facing > 0 else -tw) + 10.0 - cam_x
						var sy = f.pos_y + 10.0 - 120.0 - _cam_y
						if f.facing < 0:
							items.append({"type": "set_transform", "pos": Vector2(sx + tw, sy), "scale": Vector2(-1, 1)})
							items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, tw, th), "color": Color(1, 1, 1, 0.9)})
							items.append({"type": "reset_transform"})
						else:
							items.append({"type": "tex", "tex": tex, "rect": Rect2(sx, sy, tw, th), "color": Color(1, 1, 1, 0.9)})
				return items
			, 0)
	else:
		GameWorld.unregister_draw_effect(str(f.get_instance_id()) + "_atk1_slash")
	# 二式·九霄断水吟：大范围横斩判定（身前/身后 对齐动画刀身）+ 摧毁范围内飞行物
	if comp.slash_active:
		comp.slash_hit_timer -= 1
		if comp.slash_hit_timer <= 0 and not comp.slash_damage_dealt:
			comp.slash_damage_dealt = true
			var cx = f.pos_x + f.w / 2.0
			var box: Rect2
			if f.facing > 0:
				box = Rect2(cx - ATK2_BACK, f.pos_y + 6.0, ATK2_BACK + ATK2_FRONT, f.h - 16.0)
			else:
				box = Rect2(cx - ATK2_FRONT, f.pos_y + 6.0, ATK2_BACK + ATK2_FRONT, f.h - 16.0)
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0 and box.intersects(enemy.get_hit_box()):
				comp.mark_attack_hit()   # 玄鸟衔月闪：记录本次普攻2命中
				Fighter.apply_damage(enemy, ATK2_DMG * _bm(comp), f, false, Color(0.85, 0.95, 1.0), "hit_enemy", "skill1", 0)
			# 二式机制：摧毁攻击范围内的飞行物 → 时缓（3倍慢速）+ 微微震动（普攻1为时停，普攻2改为时缓）
			var doomed: Array = []
			for proj in GameWorld.projectiles:
				if proj is Dictionary and box.intersects(Rect2(proj["x"], proj["y"], proj["w"], proj["h"])):
					doomed.append(proj)
			if not doomed.is_empty():
				for proj in doomed:
					GameWorld.projectiles.erase(proj)
					Fighter.emit_particles(proj["x"] + proj["w"] / 2.0, proj["y"] + proj["h"] / 2.0, 12, Color(0.95, 0.95, 1.0, 0.8), 4, 5, "star", 0.7)
				GameWorld.trigger_slow_motion(90)  # 时缓：逻辑 3 倍慢速（90 帧 ≈ 0.5s 正常时间）
				GameWorld.trigger_shake(7.0, 12)   # 微微震动（时缓开始同时触发）
		if not f.attacking:
			comp.slash_active = false
	# 三式·云龙贯霄刺：两段突进状态机（命中判定跟随当前位置）
	if comp.atk3_stage == 1:
		_kensai_atk3_slash(f, 1)   # 刀光1：前突横斩
		if not comp.atk3_dmg1_dealt and _atk3_check_hit(f):
			comp.atk3_dmg1_dealt = true
			comp.mark_attack_hit()   # 玄鸟衔月闪：记录普攻3第一段命中
			var e1 = GameWorld.get_opponent(f)
			if e1 and e1.hp > 0:
				Fighter.apply_damage(e1, ATK3_DMG_HIT1 * _bm(comp), f, false, Color(0.9, 0.95, 1.0), "hit_enemy", "skill2", 0)
		comp.atk3_timer -= 1
		if comp.atk3_timer <= 0:
			# 进入间隔：翻转 facing（回身），原地停顿 ATK3_GAP_FRAMES 帧
			comp.atk3_stage = 2
			comp.atk3_timer = ATK3_GAP_FRAMES
			f.facing = -f.facing
	elif comp.atk3_stage == 2:
		# 间隔 10 帧：不移动、不命中、无刀光
		_kensai_atk3_slash(f, 0)
		comp.atk3_timer -= 1
		if comp.atk3_timer <= 0:
			comp.atk3_stage = 3
			comp.atk3_timer = ATK3_DASH2_FRAMES
	elif comp.atk3_stage == 3:
		_kensai_atk3_slash(f, 2)   # 刀光2：回身斜上斩
		if not comp.atk3_dmg2_dealt and _atk3_check_hit(f):
			comp.atk3_dmg2_dealt = true
			comp.mark_attack_hit()   # 玄鸟衔月闪：记录普攻3第二段命中
			var e2 = GameWorld.get_opponent(f)
			if e2 and e2.hp > 0:
				# knockback=true：内置击退方向 = attacker.facing（已翻转）→ 敌人被推向身后
				Fighter.apply_damage(e2, ATK3_DMG_HIT2 * _bm(comp), f, true, Color(0.9, 0.95, 1.0), "hit_enemy", "skill2", 0)
		comp.atk3_timer -= 1
		if comp.atk3_timer <= 0:
			comp.atk3_stage = 0
			f.attacking = false
			_kensai_atk3_slash(f, 0)   # 清除刀光
	# 玄鸟衔月闪：抓取→斩击状态机（抓取段出 5 伤，斩击段出 10 伤）
	if comp.skill1_stage > 0:
		var s1a: FrameAnimation = comp.skill1_anim
		if s1a and s1a.is_playing():
			var s1idx: int = s1a.get_current_index()
			var s1e: Fighter = GameWorld.get_opponent(f)
			if comp.skill1_stage == 1:
				# 抓取段（动画索引0~6 = sheet帧3~9）：每帧定住敌人（通用抓取接口，不击退/击飞）
				var held := false
				if s1e and s1e.hp > 0:
					held = Fighter.hold_fighter_in_place(s1e, comp.skill1_grab_pos_x)
				if held:
					comp.skill1_grabbed = true
				# 抓取完成出 5 伤（sheet 帧9）
				if s1idx >= SKILL1_GRAB_FRAME and not comp.skill1_dmg_dealt:
					comp.skill1_dmg_dealt = true
					if comp.skill1_grabbed and s1e and s1e.hp > 0:
						Fighter.apply_damage(s1e, SKILL1_GRAB_DMG * _bm(comp), f, false, Color(0.9, 0.9, 1.0), "hit_enemy", "skill1", 0, Fighter.BODY_SKILL)
				if s1idx >= SKILL1_SLASH_FRAME:
					if comp.skill1_grabbed:
						_unfreeze_enemy(s1e)  # 抓取结束进入斩击段：解除敌人不可操作
						comp.skill1_stage = 2  # 抓取成功 → 进入斩击段（sheet帧10~14）
					else:
						# 抓取未命中：不播放斩击，直接结束技能
						_unfreeze_enemy(s1e)
						s1a.stop()
						comp.skill1_stage = 0
						comp.skill1_active = false
						f.attacking = false
						f.set_animation_state("idle")
			else:
				# 斩击段：拔剑斩击出 10 伤，斩击瞬间屏幕抖动 + 黑白（手感反馈）
				if not comp.skill1_slash_dmg_dealt:
					comp.skill1_slash_dmg_dealt = true
					if s1e and s1e.hp > 0:
						Fighter.apply_damage(s1e, SKILL1_SLASH_DMG * _bm(comp), f, true, Color(0.95, 0.95, 1.0), "hit_enemy", "skill1", 0, Fighter.BODY_SKILL)
					GameWorld.trigger_shake(16.0, 18)
					GameWorld.trigger_grayscale(12)
		if s1a and s1a.is_finished():
			# 动画播放完：结束技能状态并恢复待机动画（防止 image_state 残留 skill1 导致动画不恢复）
			_unfreeze_enemy(GameWorld.get_opponent(f))  # 解除敌人抓取冻结
			comp.skill1_stage = 0
			comp.skill1_active = false
			f.attacking = false
			f.set_animation_state("idle")
	# 千枫落华斩：全屏 overlay 动画由 overlay 系统推进，这里只负责按帧出伤
	if comp.qflh_active:
		GameWorld.trigger_shake(1.5, 3)   # 一技能释放期间持续轻震（已再减弱）
		var qa: FrameAnimation = comp.qflh_anim
		if qa and qa.is_playing():
			# 按帧出伤：动画推进到新动画帧时累计 9/36 ≈ 0.25 伤（floor 取整出伤）
			# 注意按动画帧而非游戏帧累计，否则 36 帧动画实际播放约 173 游戏帧 → 总伤膨胀
			var qidx: int = qa.get_current_index()
			if qidx != comp.qflh_last_frame:
				comp.qflh_last_frame = qidx
				comp.qflh_damage_acc += QFLH_DMG_PER_FRAME * _bm(comp)
				var qdmg: int = floori(comp.qflh_damage_acc)
				if qdmg > 0:
					comp.qflh_damage_acc -= float(qdmg)
					Fighter.apply_ult_damage_zone(f, float(qdmg), Color(0.95, 0.95, 1.0), 600.0, Fighter.BODY_SKILL, Vector2(comp.qflh_origin_x + f.w / 2.0, comp.qflh_origin_y + f.h / 2.0))
		elif qa == null:
			# 动画缺失：兜底结束
			comp.qflh_active = false
			f.attacking = false
			f.state_flags.erase("skip_fighter_draw")
	if comp.ult_active:
		var ua: FrameAnimation = comp.ult_anim_obj
		if ua and ua.is_playing():
			var uidx: int = ua.get_current_index()
			# 瞬间 30 伤：播放到 output_0027.png（索引 26）时一次性出 30
			if not comp.ult_damage_dealt and uidx >= ULT_HIT_FRAME:
				comp.ult_damage_dealt = true
				_ult_damage_zone(f, ULT_IMPACT_DAMAGE)
			# 后续 10 伤：output_0028（索引 27）~ output_0050（索引 49）按动画帧累计出伤
			# （期望值法：按动画帧索引累计，避免浮点误差，播完正好补满 10 伤）
			if uidx >= ULT_DOT_START_FRAME and uidx <= ULT_DOT_END_FRAME:
				if uidx != comp.ult_dot_last_frame:
					comp.ult_dot_last_frame = uidx
					comp.ult_dot_acc += ULT_DOT_PER_FRAME
					var d: int = floori(comp.ult_dot_acc)
					if d > 0:
						comp.ult_dot_acc -= float(d)
						_ult_damage_zone(f, float(d))
	# 千峰破云：屏幕正下方常驻显示最近2次普攻种类图标（1/2/3），左旧右新，新的替换旧的
	# top_layer=true：绘制在全屏技能动画（千枫落华斩/孤鸿踏雪）之上，释放技能不被遮挡
	# 仅玩家操控的剑豪显示（敌方 AI 拼连招时不该把操作提示画到玩家屏幕）
	if not comp.combo_seq.is_empty() and f.is_player:
		# 解锁技能（21/31）释放窗口黄条倒计时：5 秒内未按 O 释放 → 组合刷新，需重新搭配解锁
		if comp.combo_expire_timer > 0:
			comp.combo_expire_timer -= 1
			if comp.combo_expire_timer <= 0:
				comp.combo_expire_timer = -1
				comp.combo_seq.clear()
				comp.atk_hit_flags.clear()
		GameWorld.register_draw_effect(str(f.get_instance_id()) + "_qifeng", func(font, _cam_x, _cam_y = 0.0):
			var items: Array = []
			var n: int = comp.combo_seq.size()
			var total_w: float = n * QIFENG_ICON_SIZE
			var start_x: float = Constants.W / 2.0 - total_w / 2.0
			var y: float = Constants.H - QIFENG_ICON_Y_OFFSET
			for i in range(n):
				var atk_id: int = comp.combo_seq[i]  # 左=较早，右=最新
				var icon: Texture2D
				match atk_id:
					1: icon = KENSAI_QIFENG_1.get_current_texture()
					2: icon = KENSAI_QIFENG_2.get_current_texture()
					3: icon = KENSAI_QIFENG_3.get_current_texture()
				if icon:
					items.append({"type": "tex", "tex": icon, "rect": Rect2(start_x + i * QIFENG_ICON_SIZE, y, QIFENG_ICON_SIZE, QIFENG_ICON_SIZE), "color": Color(1, 1, 1, 0.92)})
			# O 键搭配出的技能黄标（参考龙骑士/狂战士多段技能黄条样式）：
			# 21→千枫落华斩(skill1)、31→玄鸟衔月闪(skill2)、23/32→孤鸿踏雪(ult)
			# 冷却中：黄底 + "冷却 Xs"；就绪且 21/31 窗口内：黄底 + "就绪 X.Xs"(窗口倒计时)；就绪：绿底 + "就绪"
			var ck2: String = comp.combo_key()
			var sk_cd := -1
			var skill_label := ""
			if ck2 == "21":
				var sk1 = f.get_skill("skill1")
				sk_cd = sk1.cd if sk1 else -1
				skill_label = "千枫落华斩"
			elif ck2 == "31":
				var sk2 = f.get_skill("skill2")
				sk_cd = sk2.cd if sk2 else -1
				skill_label = "玄鸟衔月闪"
			elif ck2 == "23" or ck2 == "32":
				var sk3 = f.get_skill("ult")
				sk_cd = sk3.cd if sk3 else -1
				skill_label = "孤鸿踏雪"
			if sk_cd >= 0:
				var hb_x: float = Constants.W / 2.0 - 34.0
				var hb_y: float = y - 26.0
				if sk_cd > 0:
					# 冷却中：黄底 + 剩余秒数 + 边框
					items.append({"type": "rect", "rect": Rect2(hb_x, hb_y, 68, 22), "color": Color(1.0, 0.84, 0.1, 0.9)})
					items.append({"type": "string", "pos": Vector2(hb_x + 4, hb_y + 14), "text": "冷却 %.1fs" % (float(sk_cd) / 60.0), "size": 9, "color": Color(0.15, 0.1, 0.0)})
					items.append({"type": "rect", "rect": Rect2(hb_x, hb_y, 68, 22), "color": Color(1.0, 0.7, 0.0), "filled": false, "border_width": 2})
				elif comp.combo_expire_timer > 0:
					# 就绪 + 释放窗口倒计时（仅 21/31）
					var wfrac: float = float(comp.combo_expire_timer) / 60.0
					items.append({"type": "rect", "rect": Rect2(hb_x, hb_y, 68, 22), "color": Color(1.0, 0.84, 0.1, 0.9)})
					items.append({"type": "string", "pos": Vector2(hb_x + 4, hb_y + 14), "text": "就绪 %.1fs" % wfrac, "size": 9, "color": Color(0.15, 0.1, 0.0)})
					items.append({"type": "rect", "rect": Rect2(hb_x, hb_y, 68, 22), "color": Color(1.0, 0.7, 0.0), "filled": false, "border_width": 2})
				else:
					# 就绪（combo_expire_timer 归零后的兜底显示；正常窗口过期会清空 combo）
					items.append({"type": "rect", "rect": Rect2(hb_x, hb_y, 68, 22), "color": Color(0.4, 1.0, 0.5, 0.9)})
					items.append({"type": "string", "pos": Vector2(hb_x + 4, hb_y + 14), "text": skill_label + " 就绪", "size": 8, "color": Color(0.05, 0.15, 0.05)})
					items.append({"type": "rect", "rect": Rect2(hb_x, hb_y, 68, 22), "color": Color(0.2, 0.7, 0.3), "filled": false, "border_width": 2})
			return items
		, QIFENG_ICON_Z, true, true)
	else:
		GameWorld.unregister_draw_effect(str(f.get_instance_id()) + "_qifeng")

## 常规 AI：剑豪像玩家一样"搭配"——普攻积攒千峰破云连招，按组合触发技能
## （21 千枫落华斩 / 31 玄鸟衔月闪 / 23·32 孤鸿踏雪）。所有难度生效，替代通用随机放技能。
static func ai_tactics(f: Fighter, ctx: Dictionary) -> String:
	var comp: KensaiComponent = f.components.get_component("kensai") if f.components else null
	if not comp:
		return ""
	# 演出/起手/攻击中：本帧不干预（交给 update_systems 推进）
	if comp.windup_active or comp.skill1_active or comp.qflh_active or comp.qflh_windup_active or comp.ult_active:
		return "ATTACK"
	if f.attacking or f.dashing or f.hit_cooldown > 0:
		return "ATTACK"
	var target = ctx.get("target")
	var dist = ctx.get("dist", 99999.0)
	if not target or target.hp <= 0:
		return ""
	var tx = target.pos_x if target is Fighter else target.get("x", 0)
	f.facing = 1 if tx >= f.pos_x else -1

	# ① 连招已拼好 → 直接 O 触发对应技能
	var key: String = comp.combo_key()
	if key in ["21", "31", "23", "32"]:
		var skill_key := ""
		match key:
			"21": skill_key = "skill1"    # 千枫落华斩（全屏）
			"31": skill_key = "skill2"    # 玄鸟衔月闪（抓取）
			"23", "32": skill_key = "ult" # 孤鸿踏雪
		var sk = f.get_skill(skill_key)
		if sk and sk.can_use(f):
			var keys := {"ult": true, "attack": false, "skill1": false, "skill2": false}
			_try_combo_skill(f, comp, keys)
			return "ATTACK"
		# 技能暂不可用（能量/冷却不足）：继续出招滚动窗口

	# ② 距离太远 → 交给 CHASE 靠近（普攻是近战，需贴身攒连招）
	if dist > 100:
		return ""

	# ③ 目标组合：按能量/冷却选择，凑不出就只普攻
	var target_combo := ""
	if f.energy >= ULT_ENERGY:
		var ult_skill = f.get_skill("ult")
		if ult_skill and ult_skill.can_use(f):
			target_combo = "23"   # 孤鸿踏雪（大招）
	if target_combo == "" and f.energy >= SKILL1_ENERGY:
		target_combo = "21"   # 千枫落华斩（全屏，30 能）
	if target_combo == "" and f.energy >= SKILL2_ENERGY:
		target_combo = "31"   # 玄鸟衔月闪（抓取，20 能）

	# ④ 决定下一次出招，把滚动窗口逐步推向目标组合
	var next_atk := 1
	if target_combo != "":
		if key == "":
			next_atk = int(target_combo[0])
		elif key == target_combo.left(1):
			next_atk = int(target_combo[1])
		elif key.length() == 1:
			# 已有 1 式且与目标首式不符：用目标首式滚动窗口
			next_atk = int(target_combo[0])
		else:
			# 已有 2 式但窗口无效：让新窗口以目标首式结尾
			next_atk = int(target_combo[1]) if key[1] == target_combo[0] else int(target_combo[0])
	_try_attack(f, comp, next_atk)
	return "ATTACK"

## 地狱模式 AI：已由 ai_tactics 统一接管（所有难度生效），此处不再单独处理
static func ai_hell_tactics(f: Fighter, ctx: Dictionary) -> String:
	return ""

static func ai_hell_desire(f: Fighter) -> Dictionary:
	return {"min": 0, "max": 90}

## 体系统：剑豪状态分类（技能打断优先级）
## 键位：J/U/I = 三式普攻（普攻体）；O = 千峰破云组合触发技能（技能体/金刚体）
static func body_priority(f: Fighter) -> int:
	var comp: KensaiComponent = f.components.get_component("kensai") if f.components else null
	if comp and comp.ult_active:
		return Fighter.BODY_VAJRA  # 孤鸿踏雪（大招）
	if comp and comp.skill1_active:
		return Fighter.BODY_SKILL  # 玄鸟衔月闪（O·31 二技能）
	if comp and (comp.qflh_active or comp.qflh_windup_active):
		return Fighter.BODY_SKILL  # 千枫落华斩（O·21 一技能，起手+全屏斩击）
	if comp and comp.stance_active and not comp.stance_armor_broken:
		return Fighter.BODY_ARMOR  # 乘岚斩霞蓄力：霸体（受 2 次伤害后破，变普攻体）
	return -1  # 三式普攻（J/U/I）= 普攻体
