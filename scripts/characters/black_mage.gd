# 黑法师 (black_mage) —— 角色框架（待填充）
#
# 框架说明：
#   ├─ get_config()     基础属性 + 动画 + 图鉴（数值/文案均为占位，可改）
#   ├─ create_skills()  三个技能入口（skill1/skill2/ult），逻辑待填充
#   ├─ handle_input()   移动/跳跃/普攻已可用；技能键已接好 try_use 入口
#   ├─ update_systems() 每帧系统推进（动画换帧已就绪，专属机制待填充）
#   └─ body_priority()  体系统占位（默认普攻体）
#
# 素材接入（按 rule/index.md 命名规范）：
#   贴图放 assets/char_ani/black_mage/{状态}/{black_mage}_{状态}_f_{序号}.png
#   idle/walk/jump 单帧即可；attack/skill1/skill2/ult 多帧时按帧规格展开 frame_specs。
class_name BlackMageCharacter

const BLACK_MAGE_ANI_DIR = "res://assets/char_ani/black_mage/"

# ── 自定义登场动画（替代通用开场 intro_f1~f3）──
const INTRO_OUTPUT_SHEET = BLACK_MAGE_ANI_DIR + "output.png"  # 60帧动画（10列x6行，每格1890x1080 16:9）
const INTRO_OUTPUT_COLS := 10
const INTRO_OUTPUT_ROWS := 6
const INTRO_FINAL_IMG = BLACK_MAGE_ANI_DIR + "sheet.png"      # 后半段（5列x4行，前17格渐入动画，格17~19透明）
const INTRO_FINAL_COLS := 5
const INTRO_FINAL_ROWS := 4
const INTRO_FINAL_FRAMES := 17   # 格0~16（格17~19 完全透明，剔除避免露出场景）
const INTRO_FRAME_DUR := 2      # 动画帧每帧 2 游戏帧（≈30fps）

# ── 基础动画（待机/移动/跳跃共用 idle/sheet.png：4x4=16格，行0~2各4帧 + 格12，共13帧有效）──
const BLACK_MAGE_BASE_FOOT_GAPS = preload("res://data/foot_gaps/black_mage_base_foot_gaps.gd")
const BASE_SHEET_PATH = BLACK_MAGE_ANI_DIR + "idle/sheet.png"
const BASE_SHEET_COLS := 4
const BASE_SHEET_ROWS := 4
const BASE_SHEET_FRAMES := 13
const BASE_FRAME_DUR := 0.1    # 每帧 0.1s（13帧循环 ≈ 1.3s）

# ── 移动动画（walk/sheet.png：5x4=20格，行0~2各5帧 + 行3前3帧，共18帧有效）──
const BLACK_MAGE_WALK_FOOT_GAPS = preload("res://data/foot_gaps/black_mage_walk_foot_gaps.gd")
const WALK_SHEET_PATH = BLACK_MAGE_ANI_DIR + "walk/sheet.png"
const WALK_SHEET_COLS := 5
const WALK_SHEET_ROWS := 4
const WALK_SHEET_FRAMES := 18
const WALK_FRAME_DUR := 0.08   # 每帧 0.08s（18帧循环 ≈ 1.44s）

# ── 跳跃动画（jump/sheet.png：3x2=6格，前4帧有效，第4帧=空中定格；格4下落帧由落地逻辑接管）──
const BLACK_MAGE_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/black_mage_jump_foot_gaps.gd")
const JUMP_SHEET_PATH = BLACK_MAGE_ANI_DIR + "jump/sheet.png"
const JUMP_SHEET_COLS := 3
const JUMP_SHEET_ROWS := 2
const JUMP_SHEET_FRAMES := 4
const JUMP_TAKEOFF_SEC := 0.3   # 前3帧起跳合计 0.3s

# ── 普攻动画（attack/sheet.png：3x3=9格，前7帧有效；挥杖+法力波扩散）──
const BLACK_MAGE_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/black_mage_attack_foot_gaps.gd")
const ATTACK_SHEET_PATH = BLACK_MAGE_ANI_DIR + "attack/sheet.png"
const ATTACK_SHEET_COLS := 3
const ATTACK_SHEET_ROWS := 3
const ATTACK_SHEET_FRAMES := 7
const ATTACK_FRAME_DUR := 0.08

# ── 普攻·万法归尘：挥杖法力弹飞敌人（3伤命中 + 弹墙：弹到板边撞墙2伤 + 弹回指定位置，全程带击飞）──
const ATK_HIT_FRAME := 3         # 法力波出现帧（索引3，第4帧）判定命中
const ATK_COOLDOWN := 60         # 1 秒
const ATK_HIT1_DMG := 3.0        # 命中伤害
const ATK_HIT2_DMG := 2.0        # 撞墙伤害
const ATK_RANGE := 110.0         # 法力波判定范围（前方像素，对齐挥杖扩散；config 数值保持与法师一致）
const ATK_LAUNCH_SPEED := 20.0   # 弹飞水平速度（朝板边）
const ATK_REBOUND_SPEED := 12.0  # 弹回水平速度（回指定位置）
const ATK_LAUNCH_VY := -10.0     # 弹飞击飞竖直初速度（大幅弹高）
const ATK_REBOUND_VY := -8.0     # 弹回击飞竖直初速度（弹起）
const ATK_REBOUND_RATIO := 0.8   # 弹回距离 = 飞出距离（命中点→板边）× 此比例（替代固定击退，板边命中不会超界）
const ATK_DASH := 20.0           # 攻击动画期间角色向前（面向方向）前移距离
const ATK_DASH_FRAMES := 10      # 前移持续帧数
const ATK_DASH_SPEED := 2.0      # 前移速度（20px / 10帧）
const ATK_SHAKE := 8.0           # 命中震动强度
const ATK_SHAKE_DUR := 14        # 命中震动时长（帧）

# ── 基础属性（与法师 mage 数值一致）──
const BASE_HP := 70.0
const BASE_MAX_ENERGY := 120.0
const BASE_ENERGY_REGEN := 0.07
const BASE_SPEED := 1.9
const BASE_ATTACK_RANGE := 30.0
const BASE_ATTACK_DAMAGE := 0.0
const BASE_ATTACK_COOLDOWN := 120   # 2 秒
const BASE_ATTACK_DELAY := 0
const BASE_ATTACK_DURATION := 30

# ── 技能定义 ──
const SKILL1_COOLDOWN := 600   # 10 秒（妄相皆破：黄条结束后进入的冷却）
const SKILL1_ENERGY := 20
const SKILL2_COOLDOWN := 900   # 15 秒（轮回断绝）
const SKILL2_ENERGY := 20
const ULT_COOLDOWN := 900      # 15 秒
const ULT_ENERGY := 120        # 终焉灭相消耗 120 能量

# ── 大招·终焉灭相：全屏暗物质光球（10x6=60帧，第 49~59 帧按帧出伤共 40）──
const ULT_SHEET = BLACK_MAGE_ANI_DIR + "ult/output (1).png"  # 含空格文件名（已导入，原始路径可加载）
const ULT_SHEET_COLS := 10
const ULT_SHEET_ROWS := 6
const ULT_SHEET_FRAMES := 60
const ULT_FRAME_DUR := 0.08
const ULT_DOT_START_FRAME := 48  # 第 49 帧（0起索引48）开始出伤
const ULT_DOT_END_FRAME := 58    # 第 59 帧（0起索引58）结束出伤
const ULT_TOTAL_DMG := 40.0      # 大招总伤害（按帧出伤）
const ULT_DOT_PER_FRAME := ULT_TOTAL_DMG / float(ULT_DOT_END_FRAME - ULT_DOT_START_FRAME + 1)
const ULT_HIT_STOP := 20         # 大招起始时停帧
const ULT_ZONE_SIZE := 600.0     # 全屏伤害判定框（同其他全屏大招）

# ── 强化状态（技能一施法结束 → 强化 15s：技能一黄条显示剩余时间，结束进入 10s 冷却）──
const ENHANCED_DURATION := 900   # 强化状态持续 15s（900 帧）
const ENHANCED_AFTER_CD := 600   # 强化结束 → 一技能进入 10s 冷却
const SKILL1_SHOCKWAVE_FRAME := 4   # 施法动画第 5 帧（索引4）触发震飞（妄相皆破）
const SKILL1_CRYSTAL_FRAME := 9     # 施法动画第 10 帧（索引9）召唤 4 冰棱（凛冬）

# ── 大招·凛冬：召唤 4 冰棱（紧随移动 + 浮动）──
const ICE_SHEET_PATH = "res://assets/sheet_ice.png"           # 冰棱动画（5x4=20格，前18格有效，格18/19空）
const ICE_SHEET_COLS := 5
const ICE_SHEET_ROWS := 4
const ICE_SHEET_FRAMES := 18
const ICE_FRAME_DUR := 0.08
const ICEBREAK_SHEET_PATH = "res://assets/sheet_icebreak.png" # 冰棱命中/格挡破碎动画（4x4=16格）
const ICEBREAK_SHEET_COLS := 4
const ICEBREAK_SHEET_ROWS := 4
const ICEBREAK_FRAMES := 16
const ICEBREAK_FRAME_DUR := 0.06
const CRYSTAL_COUNT := 4          # 冰棱数量
const CRYSTAL_W := 44.0           # 冰棱渲染宽
const CRYSTAL_H := 36.0           # 冰棱渲染高
const CRYSTAL_SPEED := 9.0        # 冰棱飞行速度（px/帧）
const CRYSTAL_DMG := 5.0          # 冰棱命中伤害
const CRYSTAL_SLOW_PCT := 0.1     # 每次命中 10% 减速（可叠加至 4 层 40%）
const CRYSTAL_SLOW_DUR := 180     # 减速持续 3s（每层独立刷新）
const FREEZE_DURATION := 300      # 4 冰棱全部命中 → 冻结 5s
const BLOCK_DAMAGE_RATIO := 0.3   # 凛冬格挡：只受格挡伤害的 30%
# 4 冰棱相对角色中心位置：刻意凌乱（x/y 均不对称、错落有致；上方两颗下移避免过高）
const CRYSTAL_ANCHOR := [[-38.0, -30.0], [32.0, -18.0], [-24.0, 16.0], [38.0, 28.0]]
# 每颗冰棱浮动频率系数（不同 → 浮动节奏错开，不整齐同步）
const CRYSTAL_FLOAT_SPEED := [0.85, 1.1, 0.95, 1.25]
const CRYSTAL_DRAW_KEY_PREFIX := "_bm_ice_crystals"  # 绘制回调 key 前缀（+实例id）

# ── 灰烬（U+S：技能一+下方向，施法召唤 3 火球快速旋转；普攻发射火球）──
const FIRE_SHEET_PATH = "res://assets/sheet_fire.png"         # 环绕火球动画（3x2=6帧）
const FIRE_SHEET_COLS := 3
const FIRE_SHEET_ROWS := 2
const FIRE_SHEET_FRAMES := 6
const FIRE_FRAME_DUR := 0.08
const FIREBALL_SHEET_PATH = "res://assets/sheet_fireball.png" # 发射火球动画（4x3=12帧）
const FIREBALL_SHEET_COLS := 4
const FIREBALL_SHEET_ROWS := 3
const FIREBALL_SHEET_FRAMES := 12
const FIREBALL_FRAME_DUR := 0.06
const FIREBALL_COUNT := 3          # 环绕火球数量
const FIREBALL_W := 40.0           # 火球渲染宽
const FIREBALL_H := 40.0           # 火球渲染高
const FIREBALL_SHOT_W := 60.0      # 发射火球渲染/碰撞尺寸（sheet_fireball 放大 1.5 倍）
const FIREBALL_SHOT_H := 60.0
const FIREBALL_ORBIT_R := 30.0     # 环绕半径（围绕黑法师中心快速旋转，缩小提高发射命中）
const FIREBALL_ROT_SPEED := 0.12   # 每帧旋转弧度（≈7°/帧，约 1s 一圈）
const FIREBALL_EXPLOSION_DMG := 10.0  # 3 个发射火球全部命中 → 爆炸伤害
const FIREBALL_EXPLOSION_VY := -8.0   # 爆炸击飞竖直初速度
const FIREBALL_EXPLOSION_VX := 2.5    # 爆炸少量击退水平速度
const FIREBALL_SHOT_DMG := 4.0     # 发射火球命中伤害
const FIREBALL_SHOT_SPEED := 8.0   # 发射火球飞行速度
const ASH_SPAWN_FRAME := 4         # 施法第 5 帧（索引4）召唤 3 火球
const FIREBALL_DRAW_KEY_PREFIX := "_bm_fireballs"  # 绘制回调 key 前缀（+实例id）

# ── 雷霆（W+U：技能一+上方向，电流覆盖身上，强化全程霸体，强化普攻召唤巨大闪电）──
const THUNDER_AURA_SHEET = "res://assets/sheet_I.png"   # 电流特效（覆盖身上，4x3=12帧，空白帧形成闪烁节律）
const THUNDER_AURA_COLS := 4
const THUNDER_AURA_ROWS := 3
const THUNDER_AURA_FRAMES := 12
const THUNDER_AURA_DUR := 0.08
const THUNDER_AURA_SCALE := 1.25  # 电流覆盖放大系数（相对角色身体）
const THUNDER_AURA_DRAW_KEY := "_bm_thunder_aura"  # 电流绘制回调 key 前缀（+实例id）
const LIGHTNING_SHEET = "res://assets/sheet_lighting.png"  # 巨大闪电动画（5x5=25格，每格1080x1890竖长；格0空，有效格1~20）
const LIGHTNING_SHEET_COLS := 5
const LIGHTNING_SHEET_ROWS := 5
const LIGHTNING_SHEET_LOAD := 21   # 加载格0~20（格0空帧）
const LIGHTNING_SHEET_FRAMES := 20 # 有效帧（剔除格0）
const LIGHTNING_ANIM_DUR := 0.06
const LIGHTNING_W := 140.0        # 巨大闪电宽
const LIGHTNING_H := 300.0        # 巨大闪电高（地面向上）
const LIGHTNING_X_OFFSET := 150.0 # 闪电出现在角色身前 150px
const LIGHTNING_DURATION := 60    # 闪电持续 60 帧（1s）
const LIGHTNING_TOTAL_DMG := 20.0 # 闪电总伤害（按帧出伤）
const LIGHTNING_LAUNCH_VY := -2.0 # 闪电每次出伤击飞高度（大幅减小，无水平击退）
const LIGHTNING_VIS_SCALE := 2.0  # 雷电动画放大倍数
const LIGHTNING_VIS_Y_OFFSET := 20.0  # 雷电动画下移像素（视觉对齐地面）
const LIGHTNING_OVERLAY_ID := "black_mage_lightning"  # 闪电视觉 overlay id
const LIGHTNING_SHAKE := 10.0     # 召唤闪电屏幕震动强度
const LIGHTNING_ACTIVE_SHAKE := 6.0  # 闪电攻击期间中度震动强度
const GRAYSCALE_FLASH := 10       # 释放瞬间/破冰/爆炸的屏幕黑白闪帧数

# ── 技能一·妄相皆破：爆发法力震飞周围敌人（5伤）+ 进入强化状态 ──
const SKILL1_RADIUS := 100.0     # 震飞半径（以黑法师为中心的圆形区域）
const SKILL1_DAMAGE := 5.0       # 震飞伤害
const SKILL1_KNOCK_SPEED := 5.0  # 径向击退水平速度
const SKILL1_FLY_VY := -6.0      # 击飞竖直初速度
const SKILL1_SHAKE := 6.0        # 命中屏幕震动强度
const SKILL1_SHAKE_DUR := 10

# ── 技能二·轮回断绝：施法（sheet.png 19帧）→ 召唤法阵（sheet2.png 舍弃前2帧 20帧 + 圆环视觉）──
const BLACK_MAGE_SKILL2_FOOT_GAPS = preload("res://data/foot_gaps/black_mage_skill2_foot_gaps.gd")
const SKILL2_CAST_SHEET = BLACK_MAGE_ANI_DIR + "skill2/sheet.png"
const SKILL2_CAST_COLS := 5
const SKILL2_CAST_ROWS := 4
const SKILL2_CAST_FRAMES := 19
const SKILL2_CAST_DUR := 0.08
const SKILL2_MATRIX_SHEET = BLACK_MAGE_ANI_DIR + "skill2/sheet2.png"
const SKILL2_MATRIX_COLS := 5
const SKILL2_MATRIX_ROWS := 5
const SKILL2_MATRIX_LOAD := 22      # 加载格0~21，再舍弃前2帧（格0/1 空）
const SKILL2_MATRIX_FRAMES := 20    # 有效法阵帧（格2~21）
const SKILL2_MATRIX_DUR := 0.08
const SKILL2_RING_IMG = BLACK_MAGE_ANI_DIR + "skill2/black_mage_skill2_ring.png"
const SKILL2_MATRIX_W := 300.0            # 法阵宽度（增益区域，宽300）
const SKILL2_MATRIX_H := 300.0            # 法阵高度（地面向上，高300）
const SKILL2_MATRIX_Y_OFFSET := 30.0      # 法阵整体偏移（净下移30：下移50→上移30→再下移10）
const SKILL2_MATRIX_DURATION := 360       # 法阵持续 6 秒（60Hz）
const SKILL2_HEAL_RATE := 1.0             # 法阵内回血 1/s
const SKILL2_ENERGY_BONUS := 0.2          # 法阵内能量恢复 +20%
const SKILL2_DEFENSE_BONUS := 33.3333     # 法阵内减伤40%等价防御（def/(def+50)=0.4 → def≈33.33）

static func get_config() -> Dictionary:
	return {
		"id": "black_mage", "name": "黑法师", "hp": BASE_HP, "max_energy": BASE_MAX_ENERGY,
		"energy_regen": BASE_ENERGY_REGEN, "speed": BASE_SPEED,
		"attack_range": BASE_ATTACK_RANGE, "attack_damage": BASE_ATTACK_DAMAGE,
		"attack_cooldown": BASE_ATTACK_COOLDOWN, "attack_delay": BASE_ATTACK_DELAY,
		"attack_duration": BASE_ATTACK_DURATION,
		"fields": {}, "world_arrays": [],
		"animations": {
			# 待机：13 帧循环动画（黑法师漂浮施法姿态）
			"idle": _bm_base_anim(),
			"walk": _bm_walk_anim(),
			# 跳跃：前3帧起跳 + 第4帧空中定格（load_jump_sheet 滞空保持，落地反向播放起跳帧）
			"jump": _bm_jump_anim(),
			# 普攻·万法归尘：挥杖+法力波扩散（7帧）
			"attack": _bm_attack_anim(),
			# 技能一/二共用施法动画：skill2/sheet.png（释放法阵 = 释放一技能的动画）
			"skill1": _bm_skill2_cast_anim(),
			"skill2": _bm_skill2_cast_anim(),
			"ult": _bm_ult_anim(),
		},
		"dex": {
			"icon": "🌑",
			"intro": "\"永别了……\"\n\n黑暗不需要蔓延，裂隙不需要闭合，法师的光亮不需要被描述——他站在那里，就已经足够让一切安静下来。黑法师从一开始就不是来战斗的，他来，是为了收割……\n\n\"永夜将至。\"",
			"stats": [
				{"label": "生命", "value": "70"},
				{"label": "能量上限", "value": "120"},
				{"label": "定位", "value": "（待定）"},
			],
			"skills": [
				{"name": "普攻·万法归尘", "desc": "弹墙：将敌人击飞至板边（3 伤），撞击墙壁（2 伤）后弹回。命中冰冻目标触发破冰：解冻 + 防御 -30% 持续 5 秒。", "meta": "冷却：1 秒"},
				{"name": "技能一·妄相皆破（U）", "desc": "震飞周围敌人（5 伤）并进入强化状态 15 秒。强化期普攻发射冰棱：5 伤 + 10% 减速叠加，4 颗全中冻结 5 秒；被命中消耗冰棱格挡，只受 30% 伤害。强化结束进 10 秒冷却。\n灰烬（U+S）：3 火球环绕旋转撞敌，普攻发射火球（4 伤 + 灼烧 5 秒），3 发全中爆炸。\n雷霆（W+U）：电流附身全程霸体，普攻召唤巨大闪电，共 20 伤持续击飞。", "meta": "消耗：20 能量"},
				{"name": "技能二·轮回断绝", "desc": "召唤增益法阵：阵内霸体、回能 +20%、回血 1/s、减伤 40%，持续 6 秒。", "meta": "消耗：20 能量 ｜ 冷却：15 秒"},
				{"name": "大招·终焉灭相", "desc": "凝聚巨大暗物质光球爆发毁灭能量（全屏演出）：按帧出伤，共 40 伤害。", "meta": "消耗：120 能量 ｜ 冷却：15 秒"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "妄相皆破", SKILL1_COOLDOWN, SKILL1_ENERGY, Callable(_skill1_can_use), Callable(_skill1)),
		Skill.new("skill2", "轮回断绝", SKILL2_COOLDOWN, SKILL2_ENERGY, Callable(), Callable(_skill2)),
		Skill.new("ult", "终焉灭相", ULT_COOLDOWN, ULT_ENERGY, Callable(), Callable(_ult)),
	]

## 大招动画：output (1).png 10x6=60 帧（单次播放，已拆分为 5x2 子图）
static func _bm_ult_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		ULT_SHEET, ULT_SHEET_COLS, ULT_SHEET_ROWS, ULT_SHEET_FRAMES,
		ULT_FRAME_DUR, false, [], Vector2i(5, 2))

## 一技能可用检查：施法中和强化状态（黄条期）均不可再次释放（强化期间 U 键转接凛冬）
static func _skill1_can_use(owner: Fighter) -> bool:
	var comp: BlackMageComponent = owner.components.get_component("black_mage") if owner.components else null
	if comp and (comp.enhanced or comp.skill1_active):
		return false
	return true

## 基础动画锚点：把 black_mage_base_foot_gaps.gd 常量组装成 FrameAnimation 需要的字典数组
static func _bm_base_anchors() -> Array:
	var anchors := []
	for i in range(BLACK_MAGE_BASE_FOOT_GAPS.BLACK_MAGE_BASE_FOOT.size()):
		anchors.append({
			"foot_gap": BLACK_MAGE_BASE_FOOT_GAPS.BLACK_MAGE_BASE_FOOT[i],
			"head_gap": BLACK_MAGE_BASE_FOOT_GAPS.BLACK_MAGE_BASE_HEAD[i],
			"center_dx": BLACK_MAGE_BASE_FOOT_GAPS.BLACK_MAGE_BASE_CENTER[i],
			"content_w": BLACK_MAGE_BASE_FOOT_GAPS.BLACK_MAGE_BASE_CONTENT_W[i],
			"content_h": BLACK_MAGE_BASE_FOOT_GAPS.BLACK_MAGE_BASE_CONTENT_H[i],
		})
	return anchors

## 待机动画：idle/sheet.png 前 13 帧循环
static func _bm_base_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		BASE_SHEET_PATH, BASE_SHEET_COLS, BASE_SHEET_ROWS, BASE_SHEET_FRAMES,
		BASE_FRAME_DUR, true, _bm_base_anchors())

## 移动动画锚点（walk/sheet.png 前 18 帧）
static func _bm_walk_anchors() -> Array:
	var anchors := []
	for i in range(BLACK_MAGE_WALK_FOOT_GAPS.BLACK_MAGE_WALK_FOOT.size()):
		anchors.append({
			"foot_gap": BLACK_MAGE_WALK_FOOT_GAPS.BLACK_MAGE_WALK_FOOT[i],
			"head_gap": BLACK_MAGE_WALK_FOOT_GAPS.BLACK_MAGE_WALK_HEAD[i],
			"center_dx": BLACK_MAGE_WALK_FOOT_GAPS.BLACK_MAGE_WALK_CENTER[i],
			"content_w": BLACK_MAGE_WALK_FOOT_GAPS.BLACK_MAGE_WALK_CONTENT_W[i],
			"content_h": BLACK_MAGE_WALK_FOOT_GAPS.BLACK_MAGE_WALK_CONTENT_H[i],
		})
	return anchors

## 移动动画：walk/sheet.png 前 18 帧循环
static func _bm_walk_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		WALK_SHEET_PATH, WALK_SHEET_COLS, WALK_SHEET_ROWS, WALK_SHEET_FRAMES,
		WALK_FRAME_DUR, true, _bm_walk_anchors())

## 跳跃动画锚点（jump/sheet.png 前 4 帧）
static func _bm_jump_anchors() -> Array:
	var anchors := []
	for i in range(BLACK_MAGE_JUMP_FOOT_GAPS.BLACK_MAGE_JUMP_FOOT.size()):
		anchors.append({
			"foot_gap": BLACK_MAGE_JUMP_FOOT_GAPS.BLACK_MAGE_JUMP_FOOT[i],
			"head_gap": BLACK_MAGE_JUMP_FOOT_GAPS.BLACK_MAGE_JUMP_HEAD[i],
			"center_dx": BLACK_MAGE_JUMP_FOOT_GAPS.BLACK_MAGE_JUMP_CENTER[i],
			"content_w": BLACK_MAGE_JUMP_FOOT_GAPS.BLACK_MAGE_JUMP_CONTENT_W[i],
			"content_h": BLACK_MAGE_JUMP_FOOT_GAPS.BLACK_MAGE_JUMP_CONTENT_H[i],
		})
	return anchors

## 跳跃动画：前 3 帧起跳 + 第 4 帧空中定格（load_jump_sheet：最后一帧滞空保持，落地反向播放起跳帧）
static func _bm_jump_anim() -> FrameAnimation:
	return FrameAnimation.load_jump_sheet(
		JUMP_SHEET_PATH, JUMP_SHEET_COLS, JUMP_SHEET_ROWS, JUMP_SHEET_FRAMES,
		JUMP_TAKEOFF_SEC, _bm_jump_anchors())

## 普攻动画锚点（attack/sheet.png 前 7 帧）
static func _bm_attack_anchors() -> Array:
	var anchors := []
	for i in range(BLACK_MAGE_ATTACK_FOOT_GAPS.BLACK_MAGE_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": BLACK_MAGE_ATTACK_FOOT_GAPS.BLACK_MAGE_ATTACK_FOOT[i],
			"head_gap": BLACK_MAGE_ATTACK_FOOT_GAPS.BLACK_MAGE_ATTACK_HEAD[i],
			"center_dx": BLACK_MAGE_ATTACK_FOOT_GAPS.BLACK_MAGE_ATTACK_CENTER[i],
			"content_w": BLACK_MAGE_ATTACK_FOOT_GAPS.BLACK_MAGE_ATTACK_CONTENT_W[i],
			"content_h": BLACK_MAGE_ATTACK_FOOT_GAPS.BLACK_MAGE_ATTACK_CONTENT_H[i],
		})
	return anchors

## 普攻动画：attack/sheet.png 前 7 帧（挥杖+法力波扩散，单次播放）
static func _bm_attack_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		ATTACK_SHEET_PATH, ATTACK_SHEET_COLS, ATTACK_SHEET_ROWS, ATTACK_SHEET_FRAMES,
		ATTACK_FRAME_DUR, false, _bm_attack_anchors())

# ════════════ 普攻·万法归尘（挥杖法力弹飞敌人）════════════

## 命中：3 伤 + 时缓 + 震动，然后开始"弹墙"（高速弹到板边撞墙 → 弹回指定位置）
static func _atk_hit(f: Fighter, comp: BlackMageComponent) -> void:
	var enemy = GameWorld.get_opponent(f)
	if not enemy or enemy.hp <= 0:
		return
	# 自定义法力波判定框（config 的 attack_range 与法师一致保持 30，此处按挥杖扩散范围判定）
	var box: Rect2
	if f.facing > 0:
		box = Rect2(f.pos_x + f.w, f.pos_y + 6, ATK_RANGE, f.h - 16.0)
	else:
		box = Rect2(f.pos_x - ATK_RANGE, f.pos_y + 6, ATK_RANGE, f.h - 16.0)
	if not box.intersects(enemy.get_hit_box()):
		return
	# 破冰：冻结目标被普攻命中 → 立即解冻 + 防御-30%（5s）+ 蓝色粒子
	break_ice(enemy)
	Fighter.apply_damage(enemy, ATK_HIT1_DMG, f, false, Color(0.6, 0.4, 1.0), "hit_enemy", "attack", 0)
	Fighter.emit_particles(enemy.pos_x + enemy.w / 2.0, enemy.pos_y + enemy.h / 2.0, 18, Color(0.65, 0.45, 1.0), 6, 6, "star", 1.0)
	# 命中反馈：震动
	GameWorld.trigger_shake(ATK_SHAKE, ATK_SHAKE_DUR)
	# 初始化弹墙：朝敌人身后板边方向弹飞（带击飞 y 速度），frozen 锁敌人操作
	comp.launch_dir = 1 if enemy.pos_x >= f.pos_x else -1
	comp.hit_x = enemy.pos_x
	comp.launch_vy = ATK_LAUNCH_VY
	enemy.grounded = false
	enemy.add_status("frozen")
	comp.launch_stage = 1

## 弹墙：阶段1 弹飞到板边（击飞抛物线，撞墙出 2 伤 + 震动），阶段2 弹回命中点前方 250 像素
static func _atk_bounce_wall(f: Fighter, comp: BlackMageComponent) -> void:
	var enemy = GameWorld.get_opponent(f)
	if not enemy or enemy.hp <= 0:
		_end_bounce(enemy, comp)
		return
	# ── 兜底限制：弹墙全程把敌人位置钳制在地图内，防止被弹到地图外（掉出地图）──
	enemy.pos_x = clampf(enemy.pos_x, 10.0, Constants.MAP_W - 10.0 - enemy.w)
	if enemy.pos_y > Constants.GROUND_Y - enemy.h:
		enemy.pos_y = Constants.GROUND_Y - enemy.h
		enemy.grounded = true
		comp.launch_vy = 0.0
	# 击飞抛物线（frozen 锁 vy，手动模拟竖直；落地后保持地面滑行）
	if not enemy.grounded:
		comp.launch_vy += 0.22
		enemy.pos_y += comp.launch_vy
		if enemy.pos_y >= Constants.GROUND_Y - enemy.h:
			enemy.pos_y = Constants.GROUND_Y - enemy.h
			enemy.grounded = true
			comp.launch_vy = 0.0
	if comp.launch_stage == 1:
		# 弹飞：水平 20 朝板边
		enemy.pos_x += comp.launch_dir * ATK_LAUNCH_SPEED
		enemy.vx = 0
		var edge: float = 10.0 if comp.launch_dir < 0 else Constants.MAP_W - 10.0 - enemy.w
		if (comp.launch_dir > 0 and enemy.pos_x >= edge - 0.5) or (comp.launch_dir < 0 and enemy.pos_x <= edge + 0.5):
			enemy.pos_x = edge
			# 撞墙：2 伤 + 震动 + 粒子，进入弹回阶段（再次击飞弹起）
			Fighter.apply_damage(enemy, ATK_HIT2_DMG, f, false, Color(0.6, 0.4, 1.0), "hit_enemy", "attack", 0)
			Fighter.emit_particles(enemy.pos_x + enemy.w / 2.0, enemy.pos_y + enemy.h / 2.0, 30, Color(0.7, 0.5, 1.0), 7, 7, "star", 1.2)
			GameWorld.trigger_shake(6.0, 10)
			comp.launch_stage = 2
			comp.launch_vy = ATK_REBOUND_VY
			enemy.grounded = false
			comp.launch_dist = absf(edge - comp.hit_x)  # 飞出距离（命中点→板边）
	elif comp.launch_stage == 2:
		# 弹回：水平 12 弹回，弹回距离 = 飞出距离 × 比例（板边命中时目标点不会超界）
		enemy.pos_x += -comp.launch_dir * ATK_REBOUND_SPEED
		enemy.vx = 0
		var edge2: float = 10.0 if comp.launch_dir < 0 else Constants.MAP_W - 10.0 - enemy.w
		var stop_x: float = edge2 - comp.launch_dir * (comp.launch_dist * ATK_REBOUND_RATIO)
		stop_x = clampf(stop_x, 10.0, Constants.MAP_W - 10.0 - enemy.w)
		if (comp.launch_dir > 0 and enemy.pos_x <= stop_x) or (comp.launch_dir < 0 and enemy.pos_x >= stop_x):
			enemy.pos_x = stop_x
			_end_bounce(enemy, comp)

## 弹墙结束：解除敌人冻结并复位状态机，同时兜底把敌人放回地图内（防解冻后坠落/卡界外）
static func _end_bounce(enemy: Fighter, comp: BlackMageComponent) -> void:
	_unfreeze_enemy(enemy)
	comp.launch_stage = 0
	if enemy and enemy.hp > 0:
		enemy.pos_x = clampf(enemy.pos_x, 10.0, Constants.MAP_W - 10.0 - enemy.w)
		if enemy.pos_y > Constants.GROUND_Y - enemy.h:
			enemy.pos_y = Constants.GROUND_Y - enemy.h
			enemy.grounded = true
		enemy.vy = 0.0

## 解除敌人冻结（frozen 移除，弹墙结束必须清理，否则残留冻结）
static func _unfreeze_enemy(e: Fighter):
	if e == null or e.statuses.is_empty():
		return
	e.statuses = e.statuses.filter(func(s): return s.id != "frozen")

## 破冰：冻结目标被普攻命中 → 立即解除冰冻 + 防御 -30%（持续 5s）+ 蓝色粒子爆发
static func break_ice(target: Fighter) -> void:
	if target == null or target.hp <= 0:
		return
	if not target.has_status("frozen"):
		return
	_unfreeze_enemy(target)
	target.add_status("bm_ice_break")
	GameWorld.trigger_grayscale(GRAYSCALE_FLASH)  # 破冰瞬间屏幕黑白
	Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 40, Color(0.53, 0.87, 1.0), 8, 8, "star", 1.6)

## 自定义登场动画（代替通用开场 intro_f1~f3）
## 先播 output.png 的 60 帧动画，再播 sheet.png 的 17 帧渐入（5列x4行，剔除透明结尾）。
## 返回 {"frames": Array[Texture2D], "durs": Array[int]}；由 game.gd _start_intro() 消费。
static func get_intro() -> Dictionary:
	var frames: Array = []
	var durs: Array[int] = []
	# output.png：10列x6行 → 拆分网格 (5,2)，子图 sub_cols=2 / sub_rows=3
	_collect_split_sheet_frames(INTRO_OUTPUT_SHEET, INTRO_OUTPUT_COLS, INTRO_OUTPUT_ROWS,
		INTRO_OUTPUT_COLS * INTRO_OUTPUT_ROWS, Vector2i(5, 2), frames, durs)
	# sheet.png：5列x4行 → 拆分网格 (2,1)，sub_cols=3 / sub_rows=4
	_collect_split_sheet_frames(INTRO_FINAL_IMG, INTRO_FINAL_COLS, INTRO_FINAL_ROWS,
		INTRO_FINAL_FRAMES, Vector2i(2, 1), frames, durs)
	return {"frames": frames, "durs": durs}

## 从拆分图集（{basename}_split_{r}_{c}.png）按格收集 AtlasTexture 帧，供登场动画使用
static func _collect_split_sheet_frames(
	sheet_path: String, columns: int, rows: int, frame_count: int,
	split_grid: Vector2i, frames: Array, durs: Array[int]) -> void:
	var sub_cols: int = ceili(float(columns) / float(split_grid.x))
	var sub_rows: int = ceili(float(rows) / float(split_grid.y))
	var base: String = sheet_path.get_basename()
	var ext: String = sheet_path.get_extension()
	var sub00: Texture2D = load("%s_split_0_0.%s" % [base, ext])
	if not sub00:
		printerr("[BlackMage] 登场动画拆分图加载失败: ", "%s_split_0_0.%s" % [base, ext])
		return
	var cell_w: int = sub00.get_width() / sub_cols
	var cell_h: int = sub00.get_height() / sub_rows
	var atlases: Dictionary = {}
	for i in range(frame_count):
		var col: int = i % columns
		var row: int = floori(float(i) / float(columns))
		var gc: int = col / sub_cols
		var gr: int = row / sub_rows
		var key := Vector2i(gc, gr)
		var atlas: Texture2D = atlases.get(key)
		if atlas == null:
			var p := "%s_split_%d_%d.%s" % [base, gr, gc, ext]
			atlas = load(p)
			if atlas == null:
				printerr("[BlackMage] 登场动画拆分图加载失败: ", p)
				continue
			atlases[key] = atlas
		var at := AtlasTexture.new()
		at.atlas = atlas
		at.region = Rect2((col % sub_cols) * cell_w, (row % sub_rows) * cell_h, cell_w, cell_h)
		frames.append(at)
		durs.append(INTRO_FRAME_DUR)

## 技能二锚点（sheet.png 前 19 帧）
static func _bm_skill2_anchors() -> Array:
	var anchors := []
	for i in range(BLACK_MAGE_SKILL2_FOOT_GAPS.BLACK_MAGE_SKILL2_FOOT.size()):
		anchors.append({
			"foot_gap": BLACK_MAGE_SKILL2_FOOT_GAPS.BLACK_MAGE_SKILL2_FOOT[i],
			"head_gap": BLACK_MAGE_SKILL2_FOOT_GAPS.BLACK_MAGE_SKILL2_HEAD[i],
			"center_dx": BLACK_MAGE_SKILL2_FOOT_GAPS.BLACK_MAGE_SKILL2_CENTER[i],
			"content_w": BLACK_MAGE_SKILL2_FOOT_GAPS.BLACK_MAGE_SKILL2_CONTENT_W[i],
			"content_h": BLACK_MAGE_SKILL2_FOOT_GAPS.BLACK_MAGE_SKILL2_CONTENT_H[i],
		})
	return anchors

## 技能二施法动画：skill2/sheet.png 前 19 帧（单次播放）
static func _bm_skill2_cast_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		SKILL2_CAST_SHEET, SKILL2_CAST_COLS, SKILL2_CAST_ROWS, SKILL2_CAST_FRAMES,
		SKILL2_CAST_DUR, false, _bm_skill2_anchors())

## 法阵动画：sheet2.png 舍弃前 2 帧（格0/1 空），取格2~21 共 20 帧
static func _bm_skill2_matrix_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(
		SKILL2_MATRIX_SHEET, SKILL2_MATRIX_COLS, SKILL2_MATRIX_ROWS, SKILL2_MATRIX_LOAD,
		SKILL2_MATRIX_DUR, false)
	if anim.frames.size() > 2:
		anim.frames.assign(anim.frames.slice(2, SKILL2_MATRIX_LOAD))
		anim._calc_total_duration()
		anim._calc_content_h_ref()
	return anim

## 技能一·妄相皆破/凛冬：黑法师施法（skill2/sheet.png），
## 第 5 帧爆发法力震飞周围敌人（5伤），第 10 帧召唤 4 冰棱，施法结束进入强化状态（15s）
static func _skill1(owner: Fighter) -> Dictionary:
	var comp: BlackMageComponent = owner.components.get_component("black_mage") if owner.components else null
	if not comp:
		return {"success": false}
	if comp.skill1_active:
		return {"success": false}
	comp.skill1_active = true
	comp.ash_active = false        # 普通 U：凛冬形态（U+S 走灰烬）
	comp.shockwave_dealt = false   # 第 5 帧震飞（妄相皆破）
	comp.crystals_spawned = false  # 第 10 帧召唤冰棱（凛冬）
	owner.state = "skill1"
	owner.set_animation_state("skill1")  # 与二技能共用施法动画（skill2/sheet.png）
	owner.attacking = true
	owner.attack_timer = int(SKILL2_CAST_FRAMES * SKILL2_CAST_DUR * 60.0) + 2  # 施法动画完整播完
	owner.attack_hit_dealt = true
	owner.vx = 0
	owner.vy = 0
	# 施法全程霸体（施法结束由 _skill1_update 清除）
	Fighter.set_super_armor(owner, 0)
	comp.skill1_cast_armor = true
	return {"success": true}

## 妄相皆破·震飞：黑法师周围半径 100px 圆形区域内的敌人受 5 伤 + 径向击退击飞
static func _skill1_shockwave(f: Fighter) -> void:
	var enemy = GameWorld.get_opponent(f)
	if not enemy or enemy.hp <= 0:
		return
	var cx: float = f.pos_x + f.w / 2.0
	var cy: float = f.pos_y + f.h / 2.0
	var ex: float = enemy.pos_x + enemy.w / 2.0
	var ey: float = enemy.pos_y + enemy.h / 2.0
	var dx: float = ex - cx
	var dy: float = ey - cy
	if dx * dx + dy * dy > SKILL1_RADIUS * SKILL1_RADIUS:
		return
	Fighter.apply_damage(enemy, SKILL1_DAMAGE, f, false, Color(0.6, 0.4, 1.0), "hit_enemy", "skill1")
	# 径向震飞（从黑法师指向敌人的方向击退 + 击飞弹起）
	var dir: int = 1 if dx >= 0 else -1
	enemy.vy = SKILL1_FLY_VY
	enemy.vx = dir * SKILL1_KNOCK_SPEED
	enemy.grounded = false
	GameWorld.trigger_shake(SKILL1_SHAKE, SKILL1_SHAKE_DUR)
	Fighter.emit_particles(ex, ey, 20, Color(0.65, 0.45, 1.0), 6, 6, "star", 1.0)

## 技能一每帧推进：灰烬/凛冬分流触发，施法播完 → 进入强化状态（15s 黄条）
static func _skill1_update(f: Fighter, comp: BlackMageComponent) -> void:
	if not comp.skill1_active:
		return
	if comp.ash_active:
		# 灰烬：施法第 5 帧（索引4）召唤 3 火球
		if not comp.fireballs_spawned and f.current_anim and f.current_anim.get_current_index() >= ASH_SPAWN_FRAME:
			_spawn_fireballs(f, comp)
	elif comp.thunder_active:
		# 雷霆：无额外召唤物（电流已覆盖身上），施法结束进强化
		pass
	else:
		# 凛冬：施法第 5 帧（索引4）震飞、第 10 帧（索引9）召唤冰棱
		if not comp.shockwave_dealt and f.current_anim and f.current_anim.get_current_index() >= SKILL1_SHOCKWAVE_FRAME:
			comp.shockwave_dealt = true
			_skill1_shockwave(f)
		if not comp.crystals_spawned and f.current_anim and f.current_anim.get_current_index() >= SKILL1_CRYSTAL_FRAME:
			_spawn_crystals(f, comp)
	# 施法动画播完 → 结束施法并进入强化状态
	if not f.attacking:
		comp.skill1_active = false
		comp.ash_active = false
		comp.skill1_cast_armor = false
		Fighter.clear_super_armor(f)
		f.attacking = false
		f.set_animation_state("idle")
		# 进入强化状态：持续 15s（技能一黄条显示剩余时间，结束后进入 10s 冷却）
		comp.enhanced = true
		comp.enhanced_timer = ENHANCED_DURATION
		var s1 = f.get_skill("skill1")
		if s1:
			s1.buff_timer = ENHANCED_DURATION
		# 雷霆强化：全程霸体
		if comp.thunder_active:
			Fighter.set_super_armor(f, 0)
			comp.thunder_armor = true

## 技能二·轮回断绝：黑法师施法（sheet.png 19帧），播完在敌人脚下召唤法阵 + 圆环视觉效果
## TODO: 法阵效果（伤害/控制等）待用户补充
static func _skill2(owner: Fighter) -> Dictionary:
	var comp: BlackMageComponent = owner.components.get_component("black_mage") if owner.components else null
	if not comp:
		return {"success": false}
	if comp.skill2_active:
		return {"success": false}
	# 施法阶段：播放施法动画（attacking 锁定输入；apply_physics 已保留 skill 动画不被覆盖）
	comp.skill2_active = true
	comp.skill2_stage = 1
	comp.matrix_spawned = false
	owner.state = "skill2"
	owner.set_animation_state("skill2")
	owner.attacking = true
	owner.attack_timer = int(SKILL2_CAST_FRAMES * SKILL2_CAST_DUR * 60.0) + 2  # +2 帧确保施法动画完整播完
	owner.attack_hit_dealt = true  # 禁用内置攻击判定
	owner.vx = 0
	owner.vy = 0
	# 施法全程霸体（施法结束由 _skill2_update 清除；法阵增益接管后保留）
	Fighter.set_super_armor(owner, 0)
	comp.cast_armor = true
	return {"success": true}

## 技能二每帧推进：施法动画第5帧召唤法阵；动画播完结束施法（法阵进入 6s 增益期）
static func _skill2_update(f: Fighter, comp: BlackMageComponent) -> void:
	if comp.skill2_stage == 1:
		# 第 5 帧（动画索引4）时法阵出现（施法动画继续播放）
		if not comp.matrix_spawned and f.current_anim and f.current_anim.get_current_index() >= 4:
			comp.matrix_spawned = true
			_spawn_matrix(f, comp)
		# 施法动画播完 → 施法结束：清施法霸体（已在法阵内则由法阵增益接管），恢复自由控制
		if not f.attacking:
			comp.skill2_stage = 2
			comp.cast_armor = false
			if not comp.in_matrix:
				Fighter.clear_super_armor(f)
			f.set_animation_state("idle")
	elif comp.skill2_stage == 2:
		comp.matrix_timer -= 1
		if comp.matrix_timer <= 0:
			_skill2_end(f, comp)
			return
		_matrix_buff(f, comp)

## 召唤法阵 + 圆环（固定增益区域，宽300 高300；第5帧施法中出现）
static func _spawn_matrix(f: Fighter, comp: BlackMageComponent) -> void:
	var fx: float = f.pos_x + f.w / 2.0 - SKILL2_MATRIX_W / 2.0   # 法阵左缘（居中于角色）
	var fy: float = Constants.GROUND_Y - SKILL2_MATRIX_H + SKILL2_MATRIX_Y_OFFSET  # 法阵顶缘（地面向上300 再下移30）
	comp.matrix_rect = Rect2(fx, fy, SKILL2_MATRIX_W, SKILL2_MATRIX_H)
	comp.matrix_timer = SKILL2_MATRIX_DURATION
	# 法阵动画（loop，与圆环同步显示）
	var matrix_anim = _bm_skill2_matrix_anim()
	matrix_anim.loop = true
	matrix_anim.play()
	GameWorld.active_overlays.append({
		"anim": matrix_anim,
		"position": {"type": "world", "x": fx, "y": fy, "scale": Vector2(SKILL2_MATRIX_W / 768.0, SKILL2_MATRIX_H / 768.0)},
		"owner": f,
		"overlay_id": "black_mage_skill2",
	})
	# 圆环视觉效果（单帧常驻，与法阵重合同步显示）
	var ring_tex: Texture2D = load(SKILL2_RING_IMG)
	if ring_tex:
		var ring_anim := FrameAnimation.new()
		ring_anim.add_frame(ring_tex, 0.2)
		ring_anim.loop = true
		ring_anim.play()
		GameWorld.active_overlays.append({
			"anim": ring_anim,
			"position": {"type": "world", "x": fx, "y": fy, "scale": Vector2(SKILL2_MATRIX_W / 2048.0, SKILL2_MATRIX_H / 2048.0)},
			"owner": f,
			"overlay_id": "black_mage_skill2_ring",
		})

## 法阵增益：黑法师在阵内获得 霸体 + 能量恢复+20% + 回血1/s + 减伤40%（防御33.33）
static func _matrix_buff(f: Fighter, comp: BlackMageComponent) -> void:
	var in_rect: bool = comp.matrix_rect.intersects(f.get_hit_box())
	if in_rect and not comp.in_matrix:
		comp.in_matrix = true
		Fighter.set_super_armor(f, 0)          # 持续霸体（法阵结束清除）
		f.defense += SKILL2_DEFENSE_BONUS      # 减伤40%等价防御
	elif not in_rect and comp.in_matrix:
		comp.in_matrix = false
		Fighter.clear_super_armor(f)
		f.defense -= SKILL2_DEFENSE_BONUS
	if in_rect:
		var regen: float = f.config.get("energy_regen", 0.083)
		f.energy = minf(f.max_energy, f.energy + regen * SKILL2_ENERGY_BONUS)
		comp.heal_acc += SKILL2_HEAL_RATE / 60.0
		if comp.heal_acc >= 1.0:
			var h: int = int(comp.heal_acc)
			comp.heal_acc -= h
			f.hp = minf(f.max_hp, f.hp + h)

## 技能二结束：清理法阵/圆环 overlay 与增益
static func _skill2_end(f: Fighter, comp: BlackMageComponent) -> void:
	if comp.cast_armor:
		comp.cast_armor = false
		Fighter.clear_super_armor(f)
	if comp.in_matrix:
		comp.in_matrix = false
		Fighter.clear_super_armor(f)
		f.defense -= SKILL2_DEFENSE_BONUS
	for i in range(GameWorld.active_overlays.size() - 1, -1, -1):
		var oid: String = GameWorld.active_overlays[i].get("overlay_id", "")
		if oid == "black_mage_skill2" or oid == "black_mage_skill2_ring":
			GameWorld.active_overlays.remove_at(i)
	comp.skill2_active = false
	comp.skill2_stage = 0
	comp.matrix_timer = 0
	comp.matrix_spawned = false
	f.attacking = false
	f.set_animation_state("idle")

## ════════════ 大招·凛冬（强化状态期间按 U 召唤 4 冰棱）════════════

## 冰棱动画：sheet_ice.png 前 15 帧循环
static func _bm_ice_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		ICE_SHEET_PATH, ICE_SHEET_COLS, ICE_SHEET_ROWS, ICE_SHEET_FRAMES,
		ICE_FRAME_DUR, true)

## 冰棱破碎动画：sheet_icebreak.png 16 帧单次，舍弃第 2/4/5 帧（索引1/3/4）
static func _bm_icebreak_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(
		ICEBREAK_SHEET_PATH, ICEBREAK_SHEET_COLS, ICEBREAK_SHEET_ROWS, ICEBREAK_FRAMES,
		ICEBREAK_FRAME_DUR, false)
	if anim.frames.size() > 5:
		var kept: Array = []
		for i in range(anim.frames.size()):
			if i == 1 or i == 3 or i == 4:  # 舍弃第 2/4/5 帧（1-based）
				continue
			kept.append(anim.frames[i])
		anim.frames.assign(kept)
		anim._calc_total_duration()
		anim._calc_content_h_ref()
	return anim

## 召唤 4 冰棱：登记凌乱环绕锚点 + 注册世界空间绘制回调（跟随黑法师，含浮动）
static func _spawn_crystals(f: Fighter, comp: BlackMageComponent) -> void:
	comp.crystals = []
	for i in range(CRYSTAL_COUNT):
		var a: Array = CRYSTAL_ANCHOR[i]
		comp.crystals.append({
			"state": "idle",
			"x": f.pos_x + f.w / 2.0 + a[0],
			"y": f.pos_y + f.h / 2.0 + a[1],
			"offset_x": a[0],
			"offset_y": a[1],
			"phase": i * 1.7 + randf() * 0.8,   # 浮动相位（每颗不同步，略微随机更凌乱）
			"speed": CRYSTAL_FLOAT_SPEED[i],    # 浮动频率系数（每颗节奏不同）
		})
	comp.crystals_spawned = true
	comp.ult_active = true
	comp.crystal_hits = 0
	if comp.crystal_anim == null or not comp.crystal_anim.is_playing():
		comp.crystal_anim = _bm_ice_anim()
		comp.crystal_anim.play()
	if comp.crystal_break_anim == null:
		comp.crystal_break_anim = _bm_icebreak_anim()
	# 冰棱世界空间绘制回调（每帧按当前位置+波动绘制）
	GameWorld.register_draw_effect(str(f.get_instance_id()) + CRYSTAL_DRAW_KEY_PREFIX,
		func(font, cam_x, cam_y = 0.0):
			return _bm_crystal_draw(comp, cam_x, cam_y),
		5, false)
	# 召唤冰爆粒子
	var cx: float = f.pos_x + f.w / 2.0
	var cy: float = f.pos_y + f.h / 2.0
	Fighter.emit_particles(cx, cy, 30, Color(0.53, 0.87, 1.0), 6, 7, "star", 1.2)

## 冰棱紧随黑法师移动：相对角色中心固定偏移（offset_x 随 facing 镜像转向）+ 多频正弦叠加浮动
## （水平摆动 + 上下漂移，每颗频率/相位不同 → 错落浮动感，而非严格绑定）
static func _bm_crystal_follow(f: Fighter, comp: BlackMageComponent) -> void:
	var cx: float = f.pos_x + f.w / 2.0
	var cy: float = f.pos_y + f.h / 2.0
	var t := float(GameWorld.frame)
	for c in comp.crystals:
		if c["state"] != "idle":
			continue
		var spd: float = c["speed"]
		var ph: float = c["phase"]
		var wob_x: float = sin(t * 0.045 * spd + ph) * 8.0 + sin(t * 0.11 * spd + ph * 1.7) * 3.0
		var wob_y: float = cos(t * 0.06 * spd + ph * 0.8) * 6.0 + sin(t * 0.09 * spd + ph * 2.3) * 2.5
		c["x"] = cx + c["offset_x"] * f.facing + wob_x
		c["y"] = cy + c["offset_y"] + wob_y

## 冰棱绘制回调（世界空间）：绘制仍环绕的冰棱当前动画帧
static func _bm_crystal_draw(comp: BlackMageComponent, cam_x: float, cam_y: float) -> Array:
	var items: Array = []
	if comp == null or not comp.crystals_spawned or comp.crystal_anim == null:
		return items
	for c in comp.crystals:
		if c["state"] != "idle":
			continue
		var sx: float = c["x"] - cam_x - CRYSTAL_W / 2.0
		var sy: float = c["y"] - cam_y - CRYSTAL_H / 2.0
		items.append({"type": "tex", "tex": comp.crystal_anim.get_current_texture(),
			"rect": Rect2(sx, sy, CRYSTAL_W, CRYSTAL_H), "color": Color(1, 1, 1, 0.92)})
	return items

## 是否有空闲冰棱可发射/格挡
static func _bm_has_idle_crystal(comp: BlackMageComponent) -> bool:
	for c in comp.crystals:
		if c["state"] == "idle":
			return true
	return false

## 普攻（凛冬状态）：发射一颗冰棱投射物（5 伤 + 10% 减速可叠加），命中逻辑在 projectile_system
static func _fire_crystal(f: Fighter, comp: BlackMageComponent) -> void:
	var idx := -1
	for i in range(comp.crystals.size()):
		if comp.crystals[i]["state"] == "idle":
			idx = i
			break
	if idx < 0:
		return
	var c: Dictionary = comp.crystals[idx]
	c["state"] = "fired"
	var dir: int = f.facing if f.facing != 0 else 1
	# 法阵内发射 → 冰棱带一定追踪效果
	var enemy = GameWorld.get_opponent(f)
	var tracking: bool = comp.in_matrix and enemy != null and enemy.hp > 0
	# 冰棱动画投射物（独立实例，随投射物系统每帧推进）
	var anim := _bm_ice_anim()
	anim.play()
	GameWorld.projectiles.append({
		"x": c["x"] - CRYSTAL_W / 2.0, "y": c["y"] - CRYSTAL_H / 2.0,
		"w": CRYSTAL_W, "h": CRYSTAL_H,
		"vx": dir * CRYSTAL_SPEED, "vy": 0.0, "life": 120,
		"damage": CRYSTAL_DMG, "owner": f, "type": "bm_ice_crystal",
		"img": anim, "priority": 1,
		"tracking": tracking, "trackingTarget": enemy if tracking else null,
	})
	Fighter.emit_particles(c["x"], c["y"], 12, Color(0.53, 0.87, 1.0), 4, 5, "star", 0.8)

## 冰棱命中/格挡破碎动画（世界坐标一次性 overlay，播完自动移除）
static func play_crystal_break(x: float, y: float) -> void:
	var anim := _bm_icebreak_anim()
	anim.play()
	GameWorld.active_overlays.append({
		"anim": anim,
		"position": {"type": "world", "x": x - CRYSTAL_W / 2.0, "y": y - CRYSTAL_H / 2.0,
			"scale": Vector2(CRYSTAL_W / 576.0, CRYSTAL_H / 384.0)},
	})

## 冰棱命中减速：10% 减速（可叠加至 4 层 40%），每层独立计时刷新
static func apply_ice_slow(target: Fighter) -> void:
	if target == null or target.hp <= 0:
		return
	for s in target.statuses:
		if s.id == "bm_ice_slow":
			s.stacks = mini(CRYSTAL_COUNT, s.stacks + 1)
			s.slow_factor = 1.0 - CRYSTAL_SLOW_PCT * s.stacks
			s.timer = CRYSTAL_SLOW_DUR
			return
	var se := StatusEffect.new("bm_ice_slow", CRYSTAL_SLOW_DUR)
	se.stacks = 1
	se.slow_factor = 1.0 - CRYSTAL_SLOW_PCT
	target.statuses.append(se)

## 强化状态每帧推进：召唤物全部消耗完（凛冬冰棱 / 灰烬火球）→ 提前结束强化；
## 计时到 0 → 结束强化；均进入 10s 冷却
static func _enhanced_update(f: Fighter, comp: BlackMageComponent) -> void:
	if not comp.enhanced:
		return
	comp.enhanced_timer -= 1
	# 召唤物消耗完：环绕冰棱全部发射/格挡、或环绕火球全部发射，且场上无飞行中投射物 → 提前结束强化
	var ice_done: bool = comp.crystals_spawned and not _bm_has_idle_crystal(comp) and not _bm_has_flying_crystal(f)
	var ash_done: bool = comp.fireballs_spawned and not _bm_has_unfired_fireball(comp) and not _bm_has_flying_fireball(f)
	if ice_done or ash_done:
		_end_enhanced(f, comp)
		return
	if comp.enhanced_timer <= 0:
		_end_enhanced(f, comp)

## 结束强化状态：清黄条、技能一进入 10s 冷却、雷霆霸体/电流消失、剩余召唤物消失
## （已召唤的巨大闪电独立推进，不受影响）
static func _end_enhanced(f: Fighter, comp: BlackMageComponent) -> void:
	comp.enhanced = false
	comp.enhanced_timer = 0
	var s1 = f.get_skill("skill1")
	if s1:
		s1.buff_timer = 0
		s1.cd = ENHANCED_AFTER_CD
	# 雷霆清理：解除全程霸体 + 电流特效消失
	if comp.thunder_armor:
		comp.thunder_armor = false
		Fighter.clear_super_armor(f)
	if comp.thunder_active:
		comp.thunder_active = false
	GameWorld.unregister_draw_effect(str(f.get_instance_id()) + THUNDER_AURA_DRAW_KEY)
	_clear_crystals(f, comp)

## 是否有仍飞行中的冰棱投射物
static func _bm_has_flying_crystal(f: Fighter) -> bool:
	for p in GameWorld.projectiles:
		if p.get("type") == "bm_ice_crystal" and p.get("owner") == f:
			return true
	return false

## 是否有仍飞行中的火球投射物
static func _bm_has_flying_fireball(f: Fighter) -> bool:
	for p in GameWorld.projectiles:
		if p.get("type") == "bm_fireball" and p.get("owner") == f:
			return true
	return false

## 强化结束清理：剩余冰棱/火球消失（含飞行中投射物），凛冬/灰烬状态关闭
static func _clear_crystals(f: Fighter, comp: BlackMageComponent) -> void:
	# 凛冬冰棱
	GameWorld.unregister_draw_effect(str(f.get_instance_id()) + CRYSTAL_DRAW_KEY_PREFIX)
	comp.crystals.clear()
	comp.crystals_spawned = false
	comp.ult_active = false
	comp.crystal_hits = 0
	# 灰烬火球
	GameWorld.unregister_draw_effect(str(f.get_instance_id()) + FIREBALL_DRAW_KEY_PREFIX)
	comp.fireballs.clear()
	comp.fireballs_spawned = false
	comp.ash_active = false
	# 移除仍飞行中的冰棱/火球投射物（强化结束召唤物消失）
	for i in range(GameWorld.projectiles.size() - 1, -1, -1):
		var p = GameWorld.projectiles[i]
		var t = p.get("type")
		if (t == "bm_ice_crystal" or t == "bm_fireball") and p.get("owner") == f:
			GameWorld.projectiles.remove_at(i)

## ════════════ 灰烬（U+S：技能一+下方向）════════════

## 环绕火球动画：sheet_fire.png 6 帧循环
static func _bm_fire_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		FIRE_SHEET_PATH, FIRE_SHEET_COLS, FIRE_SHEET_ROWS, FIRE_SHEET_FRAMES,
		FIRE_FRAME_DUR, true)

## 发射火球动画：sheet_fireball.png 12 帧循环
static func _bm_fireball_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		FIREBALL_SHEET_PATH, FIREBALL_SHEET_COLS, FIREBALL_SHEET_ROWS, FIREBALL_SHEET_FRAMES,
		FIREBALL_FRAME_DUR, true)

## U+S（技能一+下方向）：释放灰烬——施法动画，第 5 帧召唤 3 火球，结束进入强化状态
static func _bm_try_ash(owner: Fighter, comp: BlackMageComponent, s1) -> bool:
	if comp.enhanced or comp.skill1_active or owner.attacking or owner.charging_attack:
		return false
	if s1.cd > 0 or owner.energy < s1.energy_cost:
		return false
	owner.energy -= s1.energy_cost
	s1.cd = s1.cooldown
	_bm_ash(owner, comp)
	return true

## 灰烬施法开始（复用技能一施法动画/霸体框架，跳过凛冬震飞）
static func _bm_ash(owner: Fighter, comp: BlackMageComponent) -> void:
	comp.skill1_active = true
	comp.ash_active = true
	comp.shockwave_dealt = true   # 灰烬不触发凛冬第 5 帧震飞
	comp.fireballs_spawned = false
	owner.state = "skill1"
	owner.set_animation_state("skill1")
	owner.attacking = true
	owner.attack_timer = int(SKILL2_CAST_FRAMES * SKILL2_CAST_DUR * 60.0) + 2
	owner.attack_hit_dealt = true
	owner.vx = 0
	owner.vy = 0
	Fighter.set_super_armor(owner, 0)
	comp.skill1_cast_armor = true

## 召唤 3 火球：登记旋转角度 + 注册世界空间绘制回调
static func _spawn_fireballs(f: Fighter, comp: BlackMageComponent) -> void:
	comp.fireballs = []
	for i in range(FIREBALL_COUNT):
		comp.fireballs.append({
			"angle": i * TAU / FIREBALL_COUNT,
			"x": 0.0, "y": 0.0, "fired": false, "prev_hit": false,
		})
	comp.fireballs_spawned = true
	comp.fireball_hits = 0
	if comp.fireball_anim == null or not comp.fireball_anim.is_playing():
		comp.fireball_anim = _bm_fire_anim()
		comp.fireball_anim.play()
	if comp.fireball_shot_anim == null:
		comp.fireball_shot_anim = _bm_fireball_anim()
	GameWorld.register_draw_effect(str(f.get_instance_id()) + FIREBALL_DRAW_KEY_PREFIX,
		func(font, cam_x, cam_y = 0.0):
			return _bm_fireball_draw(comp, cam_x, cam_y),
		5, false)
	Fighter.emit_particles(f.pos_x + f.w / 2.0, f.pos_y + f.h / 2.0, 30, Color(1.0, 0.53, 0.27), 6, 7, "star", 1.2)

## 火球快速旋转：围绕黑法师中心公转
static func _bm_fireball_follow(f: Fighter, comp: BlackMageComponent) -> void:
	var cx: float = f.pos_x + f.w / 2.0
	var cy: float = f.pos_y + f.h / 2.0
	for fb in comp.fireballs:
		if fb.get("fired", false):
			continue
		fb["angle"] += FIREBALL_ROT_SPEED
		fb["x"] = cx + cos(fb["angle"]) * FIREBALL_ORBIT_R
		fb["y"] = cy + sin(fb["angle"]) * FIREBALL_ORBIT_R

## 旋转火球伤害：1/次（次 = 撞击次数）。火球从未接触变为接触敌人（一次撞击）→ 1 伤 + 轻微击退，火球不消耗
static func _bm_fireball_tick(f: Fighter, comp: BlackMageComponent) -> void:
	var enemy = GameWorld.get_opponent(f)
	if not enemy or enemy.hp <= 0:
		return
	for fb in comp.fireballs:
		if fb.get("fired", false):
			continue
		var fb_rect := Rect2(fb["x"] - FIREBALL_W / 2.0, fb["y"] - FIREBALL_H / 2.0, FIREBALL_W, FIREBALL_H)
		var hitting: bool = fb_rect.intersects(enemy.get_hit_box())
		# 撞击事件：从"未接触"变"接触"的瞬间触发一次（持续贴着不重复结算）
		if hitting and not fb.get("prev_hit", false):
			Fighter.apply_damage(enemy, 1.0, f, false, Color(1.0, 0.53, 0.27), "hit_enemy", "ash", 0)
			# 一定击退：从黑法师方向轻微推开
			var dir: int = 1 if enemy.pos_x >= f.pos_x else -1
			enemy.vx = dir * 1.5
			enemy.vy = -1.5
		fb["prev_hit"] = hitting

## 火球绘制回调（世界空间）：绘制仍环绕的火球当前动画帧
static func _bm_fireball_draw(comp: BlackMageComponent, cam_x: float, cam_y: float) -> Array:
	var items: Array = []
	if comp == null or not comp.fireballs_spawned or comp.fireball_anim == null:
		return items
	for fb in comp.fireballs:
		if fb.get("fired", false):
			continue
		var sx: float = fb["x"] - cam_x - FIREBALL_W / 2.0
		var sy: float = fb["y"] - cam_y - FIREBALL_H / 2.0
		items.append({"type": "tex", "tex": comp.fireball_anim.get_current_texture(),
			"rect": Rect2(sx, sy, FIREBALL_W, FIREBALL_H), "color": Color(1, 1, 1, 0.92)})
	return items

## 是否有未发射的环绕火球（灰烬普攻可用）
static func _bm_has_unfired_fireball(comp: BlackMageComponent) -> bool:
	for fb in comp.fireballs:
		if not fb.get("fired", false):
			return true
	return false

## 普攻（灰烬状态）：发射 1 个环绕火球（消耗该火球），命中 4 伤 + 1/s 灼烧 5s
static func _fire_fireball(f: Fighter, comp: BlackMageComponent) -> void:
	for i in range(comp.fireballs.size()):
		var fb: Dictionary = comp.fireballs[i]
		if fb.get("fired", false):
			continue
		fb["fired"] = true
		var dir: int = f.facing if f.facing != 0 else 1
		# 法阵内发射 → 火球带一定追踪效果
		var enemy = GameWorld.get_opponent(f)
		var tracking: bool = comp.in_matrix and enemy != null and enemy.hp > 0
		var anim := _bm_fireball_anim()
		anim.play()
		GameWorld.projectiles.append({
			"x": fb["x"] - FIREBALL_SHOT_W / 2.0, "y": fb["y"] - FIREBALL_SHOT_H / 2.0,
			"w": FIREBALL_SHOT_W, "h": FIREBALL_SHOT_H,
			"vx": dir * FIREBALL_SHOT_SPEED, "vy": 0.0, "life": 120,
			"damage": FIREBALL_SHOT_DMG, "owner": f, "type": "bm_fireball",
			"img": anim, "priority": 1,
			"tracking": tracking, "trackingTarget": enemy if tracking else null,
		})
		# 发射红色粒子特效
		Fighter.emit_particles(fb["x"], fb["y"], 14, Color(1.0, 0.2, 0.1), 5, 6, "star", 0.9)
		return

## 3 个发射火球全部命中 → 爆炸：10 伤 + 击飞 + 少量击退（projectile_system 调用）
static func fireball_explosion(target: Fighter, f: Fighter) -> void:
	if target == null or target.hp <= 0:
		return
	Fighter.apply_damage(target, FIREBALL_EXPLOSION_DMG, f, false, Color(1.0, 0.4, 0.1), "hit_enemy", "ash", 0)
	var dir: int = 1 if target.pos_x >= f.pos_x else -1
	target.vy = FIREBALL_EXPLOSION_VY    # 击飞
	target.vx = dir * FIREBALL_EXPLOSION_VX  # 少量击退
	target.grounded = false
	GameWorld.trigger_shake(8.0, 12)
	GameWorld.trigger_grayscale(GRAYSCALE_FLASH)  # 爆炸瞬间屏幕黑白
	Fighter.emit_particles(target.pos_x + target.w / 2.0, target.pos_y + target.h / 2.0, 40, Color(1.0, 0.5, 0.1), 7, 8, "star", 1.5)

## ════════════ 雷霆（W+U：技能一+上方向）════════════

## 电流特效动画：sheet_I.png 12 帧循环（空白帧形成闪烁节律）
static func _bm_thunder_aura_anim() -> FrameAnimation:
	return FrameAnimation.load_from_sprite_sheet(
		THUNDER_AURA_SHEET, THUNDER_AURA_COLS, THUNDER_AURA_ROWS, THUNDER_AURA_FRAMES,
		THUNDER_AURA_DUR, true)

## 巨大闪电动画：sheet_lighting.png 5x5，剔除空帧格0 → 20 帧循环
static func _bm_lightning_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(
		LIGHTNING_SHEET, LIGHTNING_SHEET_COLS, LIGHTNING_SHEET_ROWS, LIGHTNING_SHEET_LOAD,
		LIGHTNING_ANIM_DUR, true, [], Vector2i(2, 3))
	if anim.frames.size() > 1:
		anim.frames.remove_at(0)  # 剔除格 0（空帧）
		anim._calc_total_duration()
		anim._calc_content_h_ref()
	return anim

## W+U（技能一+上方向）：释放雷霆——施法动画，电流覆盖身上，施法结束进入强化（全程霸体）
static func _bm_try_thunder(owner: Fighter, comp: BlackMageComponent, s1) -> bool:
	if comp.enhanced or comp.skill1_active or owner.attacking or owner.charging_attack:
		return false
	if s1.cd > 0 or owner.energy < s1.energy_cost:
		return false
	owner.energy -= s1.energy_cost
	s1.cd = s1.cooldown
	_bm_thunder(owner, comp)
	return true

## 雷霆施法开始（复用技能一施法动画/霸体框架，跳过凛冬震飞；电流即刻覆盖）
static func _bm_thunder(owner: Fighter, comp: BlackMageComponent) -> void:
	comp.skill1_active = true
	comp.ash_active = false
	comp.thunder_active = true
	comp.shockwave_dealt = true   # 雷霆不触发凛冬第 5 帧震飞
	owner.state = "skill1"
	owner.set_animation_state("skill1")
	owner.attacking = true
	owner.attack_timer = int(SKILL2_CAST_FRAMES * SKILL2_CAST_DUR * 60.0) + 2
	owner.attack_hit_dealt = true
	owner.vx = 0
	owner.vy = 0
	Fighter.set_super_armor(owner, 0)
	comp.skill1_cast_armor = true
	# 电流特效动画 + 覆盖身上的绘制回调
	if comp.thunder_aura_anim == null or not comp.thunder_aura_anim.is_playing():
		comp.thunder_aura_anim = _bm_thunder_aura_anim()
		comp.thunder_aura_anim.play()
	GameWorld.register_draw_effect(str(owner.get_instance_id()) + THUNDER_AURA_DRAW_KEY,
		func(font, cam_x, cam_y = 0.0):
			return _bm_thunder_aura_draw(owner, comp, cam_x, cam_y),
		5, false)

## 电流绘制回调（世界空间）：电流闪烁覆盖在黑法师身上（参考狂战士狂暴怒气特效）
static func _bm_thunder_aura_draw(owner: Fighter, comp: BlackMageComponent, cam_x: float, cam_y: float) -> Array:
	var items: Array = []
	if owner == null or not is_instance_valid(owner) or owner.hp <= 0 or not comp.thunder_active:
		return items
	if comp.thunder_aura_anim == null:
		return items
	var tex = comp.thunder_aura_anim.get_current_texture()
	if tex == null:
		return items
	# 按角色身体尺寸等比缩放（覆盖全身）
	var sc: float = maxf(owner.w, owner.h) / maxf(tex.get_width(), tex.get_height()) * THUNDER_AURA_SCALE
	var tw: float = tex.get_width() * sc
	var th: float = tex.get_height() * sc
	var cx2: float = owner.pos_x + owner.w / 2.0 - cam_x
	var cy2: float = owner.pos_y + owner.h / 2.0 - cam_y
	items.append({"type": "set_transform", "pos": Vector2(cx2, cy2), "rot": 0.0, "scale": Vector2(-1 if owner.facing < 0 else 1, 1)})
	items.append({"type": "tex", "tex": tex, "rect": Rect2(-tw / 2.0, -th / 2.0, tw, th), "color": Color(1, 1, 1, 0.85)})
	items.append({"type": "reset_transform"})
	return items

## 雷霆强化普攻：在身前 150px 召唤巨大闪电（视觉 sheet_I 放大 + 持续击飞 + 按帧出伤共 20）
static func _summon_lightning(f: Fighter, comp: BlackMageComponent) -> void:
	var fx: float = f.pos_x + f.w / 2.0 + f.facing * LIGHTNING_X_OFFSET
	comp.lightning = {
		"x": fx - LIGHTNING_W / 2.0,
		"y": Constants.GROUND_Y - LIGHTNING_H,
		"w": LIGHTNING_W, "h": LIGHTNING_H,
		"timer": LIGHTNING_DURATION,
		"dmg_acc": 0.0,
	}
	# 闪电视觉：sheet_lighting.png 动画放大 2 倍、下移 20px（以判定区域为中心，世界 overlay 持续到闪电结束）
	var vis_w: float = LIGHTNING_W * LIGHTNING_VIS_SCALE
	var vis_h: float = LIGHTNING_H * LIGHTNING_VIS_SCALE
	var vis_x: float = comp.lightning["x"] + LIGHTNING_W / 2.0 - vis_w / 2.0
	var vis_y: float = comp.lightning["y"] + LIGHTNING_H / 2.0 - vis_h / 2.0 + LIGHTNING_VIS_Y_OFFSET
	var lanim := _bm_lightning_anim()
	lanim.play()
	GameWorld.active_overlays.append({
		"anim": lanim,
		"overlay_id": LIGHTNING_OVERLAY_ID,
		"position": {"type": "world", "x": vis_x, "y": vis_y,
			"scale": Vector2(vis_w / 1080.0, vis_h / 1890.0)},
	})
	GameWorld.trigger_shake(LIGHTNING_SHAKE, 14)
	GameWorld.trigger_grayscale(GRAYSCALE_FLASH)  # 雷电释放瞬间屏幕瞬间黑白
	Fighter.emit_particles(fx, Constants.GROUND_Y - 60, 40, Color(0.7, 0.8, 1.0), 8, 9, "star", 1.5)

## 闪电每帧推进：按帧出伤（共 20），每次造成伤害击飞一次（无视霸体及以下 → 打断+击飞），结束移除视觉与区域
static func _bm_lightning_update(f: Fighter, comp: BlackMageComponent) -> void:
	if comp.lightning.is_empty():
		return
	var lt: Dictionary = comp.lightning
	lt["timer"] -= 1
	# 雷电攻击期间：屏幕中度持续震动
	GameWorld.trigger_shake(LIGHTNING_ACTIVE_SHAKE, 2)
	var lt_rect := Rect2(lt["x"], lt["y"], lt["w"], lt["h"])
	for e in GameWorld.entities:
		if e == f or e.hp <= 0:
			continue
		if lt_rect.intersects(e.get_hit_box()):
			# 按帧出伤（总 20 伤）；每结算 1 伤 → 击飞一次（大幅减小高度，无水平击退）
			lt["dmg_acc"] += LIGHTNING_TOTAL_DMG / float(LIGHTNING_DURATION)
			while lt["dmg_acc"] >= 1.0:
				lt["dmg_acc"] -= 1.0
				e.vy = LIGHTNING_LAUNCH_VY
				e.grounded = false
				# 无视霸体及以下（hit_priority=霸体体）：目标体 < 闪电体 → 打断且不击退（金刚体豁免）
				Fighter.apply_damage(e, 1.0, f, false, Color(0.6, 0.7, 1.0), "hit_enemy", "thunder", 0, Fighter.BODY_ARMOR)
	# 电流粒子（节流）
	if lt["timer"] % 4 == 0:
		Fighter.emit_particles(lt["x"] + randf() * lt["w"], lt["y"] + randf() * lt["h"], 3, Color(0.7, 0.8, 1.0), 4, 6, "star")
	if lt["timer"] <= 0:
		for i in range(GameWorld.active_overlays.size() - 1, -1, -1):
			if GameWorld.active_overlays[i].get("overlay_id") == LIGHTNING_OVERLAY_ID:
				GameWorld.active_overlays.remove_at(i)
		comp.lightning = {}

## ── 大招·终焉灭相：黑法师凝聚巨大暗物质光球，爆发毁天灭地能量（全屏动画承载演出）──
## 全屏 overlay（overlay_id 以 _ult 结尾 → 自动时停；state=ult → 时停中出招者持续出伤）
static func _ult(owner: Fighter) -> Dictionary:
	var comp: BlackMageComponent = owner.components.get_component("black_mage") if owner.components else null
	if not comp:
		return {"success": false}
	# 大招演出中不可重复释放（防重复扣能量/重复开 overlay）
	for entry in GameWorld.active_overlays:
		if entry.get("overlay_id") == "black_mage_ult":
			return {"success": false}
	# 每次释放新建动画对象：全屏 overlay 独立推进，不与 current_anim 共用（共用会 2 倍速）
	var ult_anim := _bm_ult_anim()
	if ult_anim.frames.is_empty():
		printerr("[BlackMage] 终焉灭相动画加载失败: ", ULT_SHEET)
		return {"success": false}
	ult_anim.play()
	comp.ult_play_active = true
	comp.ult_dot_dealt = 0
	comp.ult_anim_obj = ult_anim
	owner.state = "ult"
	# 本体隐藏：全屏动画为 100% 不透明整屏演出
	owner.state_flags["skip_fighter_draw"] = true
	Fighter.set_invincible(owner)  # 大招演出期间无敌，防止被打死导致出伤中断
	GameWorld.hit_stop = ULT_HIT_STOP
	GameWorld.active_overlays.append({
		"anim": ult_anim,
		"position": {"type": "fullscreen"},
		"owner": owner,
		"overlay_id": "black_mage_ult",
		"on_finish": func():
			comp.ult_play_active = false
			comp.ult_anim_obj = null
			owner.state = "idle"
			owner.state_flags.erase("skip_fighter_draw")
			Fighter.clear_invincible(owner)
	})
	return {"success": true}

## 终焉灭相出伤：全屏范围判定（以释放者为中心 600×600，同其他全屏大招）
static func _ult_damage_zone(f: Fighter, dmg: float) -> void:
	Fighter.apply_ult_damage_zone(f, dmg, Color(0.35, 0.15, 0.6), ULT_ZONE_SIZE)

## 大招每帧推进：第 49~59 帧按帧出伤（共 40，累计期望取整补满，无浮点误差）
static func _ult_update(f: Fighter, comp: BlackMageComponent) -> void:
	if not comp.ult_play_active:
		return
	var ua: FrameAnimation = comp.ult_anim_obj
	if ua == null or not ua.is_playing():
		return
	var uidx: int = ua.get_current_index()
	if uidx >= ULT_DOT_START_FRAME and uidx <= ULT_DOT_END_FRAME:
		# 累计期望伤害 = round(已播帧数 × 每帧期望)，只结算增量 → 窗口播完精确补满总伤
		var frames_in: int = uidx - ULT_DOT_START_FRAME + 1
		var expected: int = roundi(frames_in * ULT_DOT_PER_FRAME)
		while comp.ult_dot_dealt < expected:
			comp.ult_dot_dealt += 1
			_ult_damage_zone(f, 1.0)

## 输入处理：标准移动/跳跃/普攻 + 技能键接入
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	# W+U（上方向+技能一）= 雷霆：此时不触发跳跃
	if keys.up and owner.grounded and not keys.skill1:
		owner.vy = -10
		owner.grounded = false
	# 普攻：雷霆召唤闪电 / 灰烬发射火球 / 凛冬发射冰棱 / 常态万法归尘
	if keys.attack and owner.attack_cooldown <= 0 and not owner.attacking and not owner.dashing:
		var bm: BlackMageComponent = owner.components.get_component("black_mage") if owner.components else null
		if bm and bm.thunder_active and bm.enhanced and bm.lightning.is_empty():
			# 雷霆强化普攻：身前 150px 召唤巨大闪电（持续击飞 + 共 20 伤按帧出伤），释放一次强化结束
			_summon_lightning(owner, bm)
			owner.attack_cooldown = ATK_COOLDOWN
			_end_enhanced(owner, bm)
			keys.attack = false
		elif bm and bm.fireballs_spawned and _bm_has_unfired_fireball(bm):
			# 灰烬状态：普攻发射 1 个火球（4伤 + 1/s 灼烧 5s）
			# 强化普攻动画与待机一致：不进入攻击硬直/不切换动画，仅限制发射频率
			_fire_fireball(owner, bm)
			owner.attack_cooldown = ATK_COOLDOWN
			keys.attack = false
		elif bm and bm.crystals_spawned and bm.ult_active and _bm_has_idle_crystal(bm):
			# 凛冬状态：普攻发射 1 颗冰棱（5伤+10%减速，4 颗全中冻结 5s）
			# 强化普攻动画与待机一致：不进入攻击硬直/不切换动画，仅限制发射频率
			_fire_crystal(owner, bm)
			owner.attack_cooldown = ATK_COOLDOWN
			keys.attack = false
		else:
			owner.attacking = true
			owner.attack_timer = int(ATTACK_SHEET_FRAMES * ATTACK_FRAME_DUR * 60.0)  # 动画总时长（游戏帧）
			owner.attack_delay = 0
			owner.attack_hit_dealt = true   # 禁用内置单次判定，由 update_systems 按动画帧出伤
			owner.attack_cooldown = ATK_COOLDOWN
			owner.state = "attack"
			owner.set_animation_state("attack")
			# 攻击动画期间向前（面向方向）前移 20 像素（复用冲刺机制）
			owner.dashing = true
			owner.dash_remaining = ATK_DASH_FRAMES
			owner.dash_dir = owner.facing
			owner.dash_speed = ATK_DASH_SPEED
			if bm:
				bm.atk_active = true
				bm.atk_hit_dealt = false
			keys.attack = false
	# 技能键：统一走 try_use（冷却/能量检查由 Skill 处理）
	# 技能一 = 妄相皆破/凛冬（U）/灰烬（U+S）/雷霆（W+U）四形态，共用冷却与强化
	if keys.skill1:
		var s1 = owner.get_skill("skill1")
		if s1:
			var bm2: BlackMageComponent = owner.components.get_component("black_mage") if owner.components else null
			if bm2 and keys.down:
				# U+S（下方向）：灰烬形态
				if _bm_try_ash(owner, bm2, s1):
					keys.skill1 = false
			elif bm2 and keys.up:
				# W+U（上方向）：雷霆形态
				if _bm_try_thunder(owner, bm2, s1):
					keys.skill1 = false
			else:
				var r1 = s1.try_use(owner)
				if r1.get("success"):
					keys.skill1 = false
	if keys.skill2:
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
	Fighter.apply_movement(owner, mx, BASE_SPEED)
	Fighter.update_state(owner, mx)
	return mx

## 每帧系统推进：动画换帧已就绪，专属机制待填充
static func update_systems(f: Fighter):
	if f.hp <= 0:
		return
	# 帧动画推进（循环动画 walk/idle 每帧换帧；单次动画播完由状态机切回 idle）
	if f.current_anim and f.current_anim.is_playing():
		f.current_anim.update(1.0)
	var comp: BlackMageComponent = f.components.get_component("black_mage") if f.components else null
	if not comp:
		return
	# 清除上帧的冰棱格挡标志（本帧被命中格挡时由 on_pre_damage 重新置位）
	f.state_flags.erase("bm_ice_block")
	# 普攻·万法归尘：动画播到法力波帧判定命中（3伤 + 击退），随后击退/反弹状态机推进
	if comp.atk_active:
		if not f.attacking:
			comp.atk_active = false
			comp.atk_hit_dealt = false
		elif f.current_anim:
			var atk_idx: int = f.current_anim.get_current_index()
			if atk_idx >= ATK_HIT_FRAME and not comp.atk_hit_dealt:
				comp.atk_hit_dealt = true
				_atk_hit(f, comp)
	if comp.launch_stage > 0:
		_atk_bounce_wall(f, comp)
	# 技能一·妄相皆破：施法播完 → 结束施法并进入强化状态
	if comp.skill1_active:
		_skill1_update(f, comp)
	# 技能二·轮回断绝：施法播完 → 召唤法阵
	if comp.skill2_active:
		_skill2_update(f, comp)
	# 强化状态计时：结束 → 一技能进入 10s 冷却、剩余冰棱/火球消失
	_enhanced_update(f, comp)
	# 凛冬冰棱：紧随黑法师移动 + 位置波动 + 动画推进
	if comp.crystals_spawned and comp.ult_active:
		_bm_crystal_follow(f, comp)
		if comp.crystal_anim and comp.crystal_anim.is_playing():
			comp.crystal_anim.update(1.0)
	# 灰烬火球：快速旋转 + 碰撞帧伤 + 动画推进
	if comp.fireballs_spawned:
		_bm_fireball_follow(f, comp)
		_bm_fireball_tick(f, comp)
		if comp.fireball_anim and comp.fireball_anim.is_playing():
			comp.fireball_anim.update(1.0)
	# 雷霆电流特效动画推进（覆盖身上闪烁）
	if comp.thunder_active and comp.thunder_aura_anim and comp.thunder_aura_anim.is_playing():
		comp.thunder_aura_anim.update(1.0)
	# 雷霆巨大闪电：持续击飞 + 按帧出伤（独立推进，不随强化结束消失）
	_bm_lightning_update(f, comp)
	# 大招·终焉灭相：全屏动画第 49~59 帧按帧出伤（时停中由 _advance_time_stop_casters 照常调用）
	_ult_update(f, comp)

## 体系统：黑法师状态分类（技能打断优先级）
## 强化状态为普攻体（BODY_NORMAL）：强化不提供霸体/技能体保护，可被普攻正常打断
static func body_priority(f: Fighter) -> int:
	var comp: BlackMageComponent = f.components.get_component("black_mage") if f.components else null
	if comp and comp.enhanced:
		return Fighter.BODY_NORMAL
	return -1
