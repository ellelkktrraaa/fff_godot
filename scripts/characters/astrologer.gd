# 占星术士 (astrologer)
class_name AstrologerCharacter

const ASTROLOGER_ANI_DIR = "res://assets/char_ani/astrologer/"
const CARD_DIR = "res://assets/char_ani/astrologer/cards/"

# ── 22 张大阿卡纳贴图 ──
# 意识期 (1牌): 愚者 ~ 战车
const CARD_FOOL            = preload(CARD_DIR + "fx_astrologer_card_fool.png")             # 0
const CARD_MAGICIAN        = preload(CARD_DIR + "fx_astrologer_card_magician.png")         # 1
const CARD_HIGH_PRIESTESS  = preload(CARD_DIR + "fx_astrologer_card_high_priestess.png")   # 2
const CARD_EMPRESS         = preload(CARD_DIR + "fx_astrologer_card_empress.png")          # 3
const CARD_EMPEROR         = preload(CARD_DIR + "fx_astrologer_card_emperor.png")          # 4
const CARD_HIEROPHANT      = preload(CARD_DIR + "fx_astrologer_card_hierophant.png")       # 5
const CARD_LOVERS          = preload(CARD_DIR + "fx_astrologer_card_lovers.png")           # 6
const CARD_CHARIOT         = preload(CARD_DIR + "fx_astrologer_card_chariot.png")          # 7
# 潜意识期 (2牌): 力量 ~ 节制
const CARD_STRENGTH        = preload(CARD_DIR + "fx_astrologer_card_strength.png")         # 8
const CARD_HERMIT          = preload(CARD_DIR + "fx_astrologer_card_hermit.png")           # 9
const CARD_WHEEL_OF_FORTUNE= preload(CARD_DIR + "fx_astrologer_card_wheel_of_fortune.png") # 10
const CARD_JUSTICE         = preload(CARD_DIR + "fx_astrologer_card_justice.png")          # 11
const CARD_HANGED_MAN      = preload(CARD_DIR + "fx_astrologer_card_hanged_man.png")       # 12
const CARD_DEATH           = preload(CARD_DIR + "fx_astrologer_card_death.png")            # 13
const CARD_TEMPERANCE      = preload(CARD_DIR + "fx_astrologer_card_temperance.png")       # 14
# 超意识期 (3牌): 恶魔 ~ 世界
const CARD_DEVIL           = preload(CARD_DIR + "fx_astrologer_card_devil.png")            # 15
const CARD_TOWER           = preload(CARD_DIR + "fx_astrologer_card_tower.png")            # 16
const CARD_STAR            = preload(CARD_DIR + "fx_astrologer_card_star.png")             # 17
const CARD_MOON            = preload(CARD_DIR + "fx_astrologer_card_moon.png")             # 18
const CARD_SUN             = preload(CARD_DIR + "fx_astrologer_card_sun.png")              # 19
const CARD_JUDGEMENT       = preload(CARD_DIR + "fx_astrologer_card_judgement.png")        # 20
const CARD_WORLD           = preload(CARD_DIR + "fx_astrologer_card_world.png")            # 21

# ── 弹射物/特效贴图 ──
const PROJ_METEOR = preload("res://assets/fx_astrologer_meteor.png")  # 普攻陨石
const PROJ_CRATER = preload("res://assets/fx_astrologer_crater.png")  # 陨石坑
const TEX_HEAVENLY_FIRE  = preload("res://assets/fx_astrologer_heavenly_fire.png")   # 权杖天火
const TEX_FLAME_ZONE     = preload("res://assets/fx_astrologer_flame_zone.png")      # 权杖火焰区域
const TEX_TIDE_F1 = preload("res://assets/fx_astrologer_tide_f1.png")  # 圣杯潮汐帧1
const TEX_TIDE_F2 = preload("res://assets/fx_astrologer_tide_f2.png")  # 圣杯潮汐帧2
const TEX_TIDE_F3 = preload("res://assets/fx_astrologer_tide_f3.png")  # 圣杯潮汐帧3
const TEX_TIDE_F4 = preload("res://assets/fx_astrologer_tide_f4.png")  # 圣杯潮汐帧4
const TEX_TORNADO_F1 = preload("res://assets/fx_astrologer_tornado_f1.png")  # 宝剑龙卷帧1
const TEX_TORNADO_F2 = preload("res://assets/fx_astrologer_tornado_f2.png")  # 宝剑龙卷帧2
const TEX_TORNADO_F3 = preload("res://assets/fx_astrologer_tornado_f3.png")  # 宝剑龙卷帧3
const TEX_EARTH_WALL   = preload("res://assets/fx_astrologer_earth_wall.png")   # 星币土墙

# ── 头顶标签贴图 ──
const LABEL_FOOL       = preload("res://assets/fx_astrologer_fool_label.png")
const LABEL_WANDS      = preload("res://assets/fx_astrologer_wands_label.png")
const LABEL_CUPS       = preload("res://assets/fx_astrologer_cups_label.png")
const LABEL_SWORDS     = preload("res://assets/fx_astrologer_swords_label.png")
const LABEL_PENTACLES  = preload("res://assets/fx_astrologer_pentacles_label.png")

# ── 角色贴图（仅待机有独立贴图，其余暂复用）──
const TEX_IDLE = preload(ASTROLOGER_ANI_DIR + "idle/astrologer_idle_f_1.png")

## 单帧 FrameAnimation 快捷包装
static func _fa(tex: Texture2D, dur: float = 999.0, loop: bool = true) -> FrameAnimation:
	var a = FrameAnimation.new(); a.add_frame(tex, dur); a.loop = loop; return a

# ── 普攻: 陨星咒 ──
const ATK_METEOR_DMG := 4.0          # 陨石直接伤害
const ATK_METEOR_COOLDOWN := 120     # 冷却 2秒
const ATK_METEOR_TARGET_RANGE := 300 # 身前自动索敌范围（像素）
const ATK_METEOR_SPEED := 6.0        # 陨石飞行速度
const ATK_ENERGY_COST := 5.0         # 能量消耗
const ATK_CRATER_LIFE := 300         # 陨石坑持续 5秒
const ATK_CRATER_DOT := 1.0          # DoT: 1/s
const ATK_CRATER_W := 80             # 陨石坑宽度
const ATK_CRATER_H := 40             # 陨石坑高度

# ── 技能一: 圣三角 ──
const SKILL1_ENERGY := 30            # 能量消耗
const SKILL1_COOLDOWN := 180         # 冷却 3秒
const SKILL1_ATK_PER_1 := 0.08       # 每张 1牌 +8% 攻击力
const SKILL1_DEF_PER_2 := 5.56       # 每张 2牌 防御 +5.56（护甲公式等效减伤 10%）
const SKILL1_CD_PER_3 := 60          # 每张 3牌 二技能冷却 -1秒

# ── 技能二: 塔罗·小阿卡纳 ──
const SKILL2_ENERGY := 20            # 能量消耗
const SKILL2_CD_WANDS := 900         # 权杖 独立冷却 15s
const SKILL2_CD_CUPS := 1080         # 圣杯 独立冷却 18s
const SKILL2_CD_SWORDS := 1200       # 宝剑 独立冷却 20s
const SKILL2_CD_PENTACLES := 720     # 星币 独立冷却 12s
const SKILL2_CDS := [SKILL2_CD_WANDS, SKILL2_CD_CUPS, SKILL2_CD_SWORDS, SKILL2_CD_PENTACLES]
# 小阿卡纳四花色: 权杖(火) 圣杯(水) 宝剑(风) 星币(土)
const MINOR_ARCANA := [
	{"suit": "Wands",     "name_cn": "权杖", "element": "火", "tex": LABEL_WANDS},
	{"suit": "Cups",      "name_cn": "圣杯", "element": "水", "tex": LABEL_CUPS},
	{"suit": "Swords",    "name_cn": "宝剑", "element": "风", "tex": LABEL_SWORDS},
	{"suit": "Pentacles", "name_cn": "星币", "element": "土", "tex": LABEL_PENTACLES},
]

# ── 权杖·星辰余烬 ──
const WANDS_FIRE_DAMAGE := 10.0      # 天火直接伤害
const WANDS_FIRE_FRAMES := 20        # 天火持续帧数
const WANDS_FIRE_TARGET_RANGE := 310 # 身前索敌范围（像素）
const WANDS_FIRE_W := 200.0          # 天火/火焰绘制宽度
const WANDS_FLAME_LIFE := 300        # 火焰区域持续 5秒
const WANDS_FLAME_DOT := 2.0         # 火焰区域每秒伤害
const WANDS_FLAME_H := 80.0          # 火焰区域高度

# 权杖天火效果列表
static var fires: Array = []
static var wands_flame_zones: Array = []

# ── 圣杯·潮汐挽歌 ──
const CUPS_TIDE_DAMAGE := 15.0       # 潮汐伤害
const CUPS_TIDE_FRAMES := 40         # 潮汐持续帧数（4帧×10帧/帧）
const CUPS_TIDE_SPAWN_DIST := 200.0   # 身前生成距离（像素，同步攻击范围）
const CUPS_TIDE_FRAME_DUR := 10      # 每帧持续帧数
const CUPS_TIDE_W := 300.0           # 潮汐绘制宽度
const CUPS_TIDE_FRAMES_LIST := [TEX_TIDE_F1, TEX_TIDE_F2, TEX_TIDE_F3, TEX_TIDE_F4]

static var tides: Array = []

# ── 宝剑·风神之叹 ──
const SWORDS_TORNADO_DAMAGE := 18.0  # 龙卷伤害
const SWORDS_TORNADO_FRAMES := 78    # 持续 1.3s
const SWORDS_TORNADO_FRAME_DUR := 4  # 每帧持续帧数
const SWORDS_TORNADO_W := 400.0      # 龙卷绘制宽度
const SWORDS_TORNADO_FRAMES_LIST := [TEX_TORNADO_F1, TEX_TORNADO_F2, TEX_TORNADO_F3]

static var tornadoes: Array = []

# ── 星币·古脉壁立 ──
const PENTACLES_WALL_DAMAGE := 10.0  # 顶飞伤害
const PENTACLES_WALL_HP := 20.0      # 土墙生命值
const PENTACLES_WALL_LIFE := 300     # 持续 5s
const PENTACLES_WALL_W := 120.0      # 土墙宽度（80×1.5）
const PENTACLES_WALL_H := 180.0      # 土墙高度（120×1.5）
const PENTACLES_WALL_SPAWN_DIST := 200.0  # 身前生成距离

static var walls: Array = []

# ── 大招: 愚者之旅 ──
const ULT_ENERGY_COST := 100
const ULT_COOLDOWN := 300              # 5秒
const ULT_FRAME_COUNT := 30
const ULT_DURATION := 18.0             # 持续 18 秒（实秒）
const ULT_BG = preload("res://assets/bg_astrologer_ult.png")

# ── 大阿卡纳数据表 ──
# period: 1=意识期  2=潜意识期  3=超意识期
static var ARCANA := [
	{"index": 0,  "name_cn": "愚者",     "name_en": "The Fool",           "period": 1, "tex": CARD_FOOL},
	{"index": 1,  "name_cn": "魔术师",   "name_en": "The Magician",       "period": 1, "tex": CARD_MAGICIAN},
	{"index": 2,  "name_cn": "女祭司",   "name_en": "The High Priestess", "period": 1, "tex": CARD_HIGH_PRIESTESS},
	{"index": 3,  "name_cn": "女皇",     "name_en": "The Empress",        "period": 1, "tex": CARD_EMPRESS},
	{"index": 4,  "name_cn": "皇帝",     "name_en": "The Emperor",        "period": 1, "tex": CARD_EMPEROR},
	{"index": 5,  "name_cn": "教皇",     "name_en": "The Hierophant",     "period": 1, "tex": CARD_HIEROPHANT},
	{"index": 6,  "name_cn": "恋人",     "name_en": "The Lovers",         "period": 1, "tex": CARD_LOVERS},
	{"index": 7,  "name_cn": "战车",     "name_en": "The Chariot",        "period": 1, "tex": CARD_CHARIOT},
	{"index": 8,  "name_cn": "力量",     "name_en": "Strength",           "period": 2, "tex": CARD_STRENGTH},
	{"index": 9,  "name_cn": "隐士",     "name_en": "The Hermit",         "period": 2, "tex": CARD_HERMIT},
	{"index": 10, "name_cn": "命运之轮", "name_en": "Wheel of Fortune",   "period": 2, "tex": CARD_WHEEL_OF_FORTUNE},
	{"index": 11, "name_cn": "正义",     "name_en": "Justice",            "period": 2, "tex": CARD_JUSTICE},
	{"index": 12, "name_cn": "倒吊人",   "name_en": "The Hanged Man",     "period": 2, "tex": CARD_HANGED_MAN},
	{"index": 13, "name_cn": "死神",     "name_en": "Death",              "period": 2, "tex": CARD_DEATH},
	{"index": 14, "name_cn": "节制",     "name_en": "Temperance",         "period": 2, "tex": CARD_TEMPERANCE},
	{"index": 15, "name_cn": "恶魔",     "name_en": "The Devil",          "period": 3, "tex": CARD_DEVIL},
	{"index": 16, "name_cn": "高塔",     "name_en": "The Tower",          "period": 3, "tex": CARD_TOWER},
	{"index": 17, "name_cn": "星星",     "name_en": "The Star",           "period": 3, "tex": CARD_STAR},
	{"index": 18, "name_cn": "月亮",     "name_en": "The Moon",           "period": 3, "tex": CARD_MOON},
	{"index": 19, "name_cn": "太阳",     "name_en": "The Sun",            "period": 3, "tex": CARD_SUN},
	{"index": 20, "name_cn": "审判",     "name_en": "Judgement",          "period": 3, "tex": CARD_JUDGEMENT},
	{"index": 21, "name_cn": "世界",     "name_en": "The World",          "period": 3, "tex": CARD_WORLD},
]

# ── 辅助方法 ──

## 按 period 筛选卡牌（1/2/3）
static func cards_by_period(period: int) -> Array:
	var result: Array = []
	for c in ARCANA:
		if c.period == period:
			result.append(c)
	return result

## 获取单张卡牌数据
static func get_card(index: int) -> Dictionary:
	if index >= 0 and index < ARCANA.size():
		return ARCANA[index]
	return {}

# ── 绘制注入: 陨石/陨石坑 + 圣三角牌面 ──

const LABEL_MAX_W := 200.0  # 头顶标签最大宽度

static func _draw_craters(_font, cam_x, _cam_y = 0.0):
	var items: Array = []
	# ── 权杖天火 ──
	for f in fires:
		var ft = f.life / float(WANDS_FIRE_FRAMES)
		var alpha = minf(ft * 3.0, 1.0)  # 初期渐入
		var draw_h = Constants.GROUND_Y - _cam_y  # 占满整个 y 轴
		var scale = draw_h / maxf(TEX_HEAVENLY_FIRE.get_height(), 1.0)
		var draw_w = TEX_HEAVENLY_FIRE.get_width() * scale
		var fx = f.x - draw_w / 2.0 - cam_x
		items.append({"type": "tex", "tex": TEX_HEAVENLY_FIRE, "rect": Rect2(fx, 50, draw_w, draw_h), "color": Color(1, 1, 1, alpha)})
	# ── 权杖火焰区域 ──
	for fz in wands_flame_zones:
		var alpha = 0.7
		var scale = fz.w / maxf(TEX_FLAME_ZONE.get_width(), 1.0)
		var draw_w = TEX_FLAME_ZONE.get_width() * scale
		var draw_h = TEX_FLAME_ZONE.get_height() * scale
		var fx = fz.x + fz.w / 2.0 - draw_w / 2.0 - cam_x
		var fy = fz.y + fz.h / 2.0 - draw_h / 2.0 - _cam_y - 30.0  # 上移30px（净效果）
		items.append({"type": "tex", "tex": TEX_FLAME_ZONE, "rect": Rect2(fx, fy, draw_w, draw_h), "color": Color(1, 1, 1, alpha)})
	# ── 圣杯潮汐（4帧动画，随朝向翻转）──
	for t in tides:
		var frame_idx = int((CUPS_TIDE_FRAMES - t.life) / CUPS_TIDE_FRAME_DUR) % 4
		var tex = CUPS_TIDE_FRAMES_LIST[frame_idx]
		var draw_h = Constants.GROUND_Y - _cam_y
		var scale = draw_h / maxf(tex.get_height(), 1.0)
		var draw_w = tex.get_width() * scale
		var fx = t.x - draw_w / 2.0 - cam_x
		if t.facing < 0:
			items.append({"type": "set_transform", "pos": Vector2(fx + draw_w, 0), "scale": Vector2(-1, 1)})
			items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, draw_w, draw_h), "color": Color(1, 1, 1, 0.85)})
			items.append({"type": "reset_transform"})
		else:
			items.append({"type": "tex", "tex": tex, "rect": Rect2(fx, 0, draw_w, draw_h), "color": Color(1, 1, 1, 0.85)})
	# ── 宝剑龙卷（3帧动画，中心与占星术士y轴一致）──
	for tn in tornadoes:
		var frame_idx = int((SWORDS_TORNADO_FRAMES - tn.life) / SWORDS_TORNADO_FRAME_DUR) % 3
		var tex = SWORDS_TORNADO_FRAMES_LIST[frame_idx]
		var scale = SWORDS_TORNADO_W / maxf(tex.get_width(), 1.0)
		var draw_w = tex.get_width() * scale
		var draw_h = tex.get_height() * scale
		var fx = tn.x - draw_w / 2.0 - cam_x
		var fy = tn.y_center - draw_h / 2.0 - _cam_y
		if tn.facing < 0:
			items.append({"type": "set_transform", "pos": Vector2(fx + draw_w, fy), "scale": Vector2(-1, 1)})
			items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, draw_w, draw_h), "color": Color(1, 1, 1, 0.85)})
			items.append({"type": "reset_transform"})
		else:
			items.append({"type": "tex", "tex": tex, "rect": Rect2(fx, fy, draw_w, draw_h), "color": Color(1, 1, 1, 0.85)})
	# ── 星币土墙 ──
	for w in walls:
		var scale = w.w / maxf(TEX_EARTH_WALL.get_width(), 1.0)
		var draw_w = TEX_EARTH_WALL.get_width() * scale
		var draw_h = TEX_EARTH_WALL.get_height() * scale
		var fx = w.x + w.w / 2.0 - draw_w / 2.0 - cam_x
		var fy = w.y + w.h / 2.0 - draw_h / 2.0 - _cam_y
		var alpha = minf(w.hp / PENTACLES_WALL_HP, 1.0)  # 受伤时变淡
		items.append({"type": "tex", "tex": TEX_EARTH_WALL, "rect": Rect2(fx, fy, draw_w, draw_h), "color": Color(1, 1, 1, alpha)})
	# ── 陨石坑 ──
	for cr in GameWorld.craters:
		var tex = cr.get("img")
		if not tex:
			continue
		var rx = cr["x"] - cam_x
		var ry = cr["y"] - _cam_y
		var rw = cr["w"]
		var rh = cr["h"]
		if cr.get("pending") and cr.get("dir", 1) < 0:
			items.append({"type": "set_transform", "pos": Vector2(rx + rw, ry), "scale": Vector2(-1, 1)})
			items.append({"type": "tex", "tex": tex, "rect": Rect2(0, 0, rw, rh)})
			items.append({"type": "reset_transform"})
		else:
			items.append({"type": "tex", "tex": tex, "rect": Rect2(rx, ry, rw, rh)})
	# 小阿卡纳 / 开场标签（角色头顶）
	for f in GameWorld.entities:
		if not is_instance_valid(f):
			continue
		var label_tex = null
		var intro = f.get_meta("intro_timer", null)
		if intro != null and intro > 0:
			label_tex = LABEL_FOOL
		else:
			var si = f.get_meta("skill2_suit", null)
			if si != null and si >= 0 and si < MINOR_ARCANA.size():
				label_tex = MINOR_ARCANA[si].tex
		if not label_tex:
			continue
		var tw = label_tex.get_width()
		var th = label_tex.get_height()
		var scale = minf(LABEL_MAX_W / tw, 1.0)  # 超大贴图缩放到合适尺寸
		var draw_w = tw * scale
		var draw_h = th * scale
		var lx = f.pos_x + f.w / 2.0 - draw_w / 2.0 - cam_x
		var ly = f.pos_y + f.h / 2.0 - draw_h / 2.0 - _cam_y - 50.0  # 角色上方50px
		items.append({"type": "tex", "tex": label_tex, "rect": Rect2(lx, ly, draw_w, draw_h)})
	return items

static func _draw_cards(_font, _cam_x, _cam_y):
	var items: Array = []
	# 圣三角牌面
	for entry in GameWorld.astrologer_cards:
		var cards: Array = entry.get("cards", [])
		if cards.is_empty():
			continue
		const CW := 48; const CH := 72; const GAP := 8; const BW := 2
		var total_w = cards.size() * CW + (cards.size() - 1) * GAP
		var sx = (800.0 - total_w) / 2.0
		var by = 8.0
		for j in cards.size():
			var card = cards[j]
			var cx = sx + j * (CW + GAP)
			var period = card.get("period", 1)
			var bc: Color
			match period:
				1: bc = Color(1.0, 0.87, 0.27)
				2: bc = Color(1.0, 0.27, 0.27)
				3: bc = Color(0.27, 0.4, 1.0)
				_: bc = Color.WHITE
			items.append({"type": "rect", "rect": Rect2(cx - BW, by - BW, CW + BW * 2, CH + BW * 2), "color": bc, "filled": false, "border_width": BW})
			var tex = card.get("tex")
			if tex:
				items.append({"type": "tex", "tex": tex, "rect": Rect2(cx, by, CW, CH)})
		var bonus = entry.get("bonus_text", "")
		if bonus != "":
			items.append({"type": "string", "pos": Vector2(400, by + CH + 8), "text": bonus, "size": 12, "color": Color(1, 1, 1, 0.8)})
	return items

static func _inject_draw():
	GameWorld.register_draw_effect("astrologer_craters", func(font, cam_x, _cam_y = 0.0):
		return _draw_craters(font, cam_x, _cam_y)
	, 0)
	GameWorld.register_draw_effect("astrologer_cards_ui", func(_font, _cam_x, _cam_y):
		return _draw_cards(_font, _cam_x, _cam_y)
	, 10)

# ── 技能常量 (TODO) ──

static func get_config() -> Dictionary:
	_inject_draw()
	return {
		"id": "astrologer", "name": "占星术士", "hp": 80, "max_energy": 120, "energy_regen": 0.067,  # 4/s
		"speed": 2.0, "attack_range": 35, "attack_damage": 4,
		"attack_cooldown": ATK_METEOR_COOLDOWN, "attack_delay": 10, "attack_duration": 30,
		"fields": {
			"drawn_cards": [],          # 圣三角已抽卡牌 [{index, period, tex, name_cn}]
			"skill1_active": false,     # 圣三角是否激活
			"skill1_atk_boost": 0.0,    # 已应用攻击加成（用于移除）
			"skill1_def_boost": 0.0,    # 已应用防御（用于移除）
			"skill1_cd_reduce": 0,      # 二技能冷却减少（帧）
			"skill2_suit": -1,          # 当前小阿卡纳花色索引 (-1=未抽取)
			"skill2_name": "The Fool",  # 头顶显示文字（初始为愚者）
			"skill2_element": "",       # 当前花色元素
			"skill2_label_timer": 0,    # 二技能标签显示计时器（帧）
			"skill2_cds": [0, 0, 0, 0], # 四花色独立冷却帧数 [权杖, 圣杯, 宝剑, 星币]
			"skill2_predicted": -1,     # 预掷骰子结果（花色索引），-1=需重掷
			"intro_timer": 120,         # 开场显示倒计时（2秒）
		}, "world_arrays": ["craters"],  # craters: 陨石坑列表
		"animations": {
			"idle":   FrameAnimation.load_from_frames(ASTROLOGER_ANI_DIR + "idle/", "astrologer_idle_f_", [{"index": 1, "duration": 999.0}], true),
			"walk":   _fa(TEX_IDLE, 999.0, true),
			"jump":   _fa(TEX_IDLE, 999.0, true),
			"attack": _fa(TEX_IDLE, 0.5, false),
			"ult":    FrameAnimation.load_from_frames(ASTROLOGER_ANI_DIR + "ult/", "astrologer_ult_f_", _ult_frame_specs(), false),
		},
		"dex": {
			"icon": "✨",
			"intro": "“我看见了。”\n\n星辰在他的眼瞳中低语，命运如丝线般在他指尖缠绕。他不预言吉凶，只陈述必然——每一张塔罗牌的翻转，都是时间长河中一个早已落定的涟漪。陨星从虚空坠下，带着远古的咒语，为宿命刻下最后的注脚。他站在现世与星界的交界，既是观者，也是书写者。\n\n“宇宙的意志……不可违逆。”",
			"stats": [{"label": "生命", "value": "80"}, {"label": "能量上限", "value": "120"}],
			"skills": [
				{"name": "陨星咒（普通攻击）", "desc": "从屏幕外召唤陨石以45°斜向下坠落。身前300像素内有敌人时自动瞄准落点。陨石造成4点伤害，对碰触到的敌人直接伤害（不生成坑）。陨石落地后留下陨石坑持续5秒，敌人站在上面每秒流失1点生命。", "meta": "消耗：5 能量 ｜ 冷却：2 秒"},
				{"name": "圣三角（技能一）", "desc": "从22张大阿卡纳中随机抽取三张牌显示在屏幕上方，效果持续到下次使用。每张1牌（意识期）+8%攻击力，每张2牌（潜意识期）防御力+5.6，每张3牌（超意识期）二技能冷却减少1秒。释放后获得1秒无敌。", "meta": "消耗：30 能量 ｜ 冷却：3 秒"},
				{"name": "塔罗·小阿卡纳（技能二）", "desc": "随机抽取小阿卡纳四花色之一释放对应技能：\n• 权杖·星辰余烬：前方向敌人降下天火（10伤害，多帧判定），留下火焰区域持续灼烧（5秒，2伤/秒）[CD 15s]\n• 圣杯·潮汐挽歌：身前召唤潮汐拍打敌人（15伤害，多帧判定）[CD 18s]\n• 宝剑·风神之叹：释放横向龙卷撕裂敌人（18伤害，持续1.3秒，期间不可操作）[CD 20s]\n• 星币·古脉壁立：生成土墙顶飞敌人（10伤害），土墙可阻挡敌人与飞行物（20HP/5秒）[CD 12s]\n\n特殊机制——圣三角主导牌型：1牌最多→权杖概率40%；2牌最多→圣杯概率40%，潮汐附加40%减速3秒；3牌最多→宝剑概率40%，自身移速跳跃+20%持续5秒；三种牌等量→星币概率40%，土墙+5伤害+2秒+10HP。未使用一技能时随机抽取。增强效果不可叠加。", "meta": "消耗：20 能量 ｜ 四花色独立冷却"},
				{"name": "大招（愚者之旅）", "desc": "发动愚者之旅，从大阿卡纳中抽取「愚者」改变战场。全屏播放塔罗动画，切换战斗背景。所有敌方单位及其飞行物移动/跳跃速度下降50%，防御力+12.5，持续18秒。同时自身技能一二冷却减少2秒。", "meta": "消耗：100 能量 ｜ 冷却：5 秒"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("ult", "愚者之旅", ULT_COOLDOWN, ULT_ENERGY_COST, Callable(), Callable(_ult)),
		Skill.new("skill1", "圣三角", SKILL1_COOLDOWN, SKILL1_ENERGY, Callable(), Callable(_skill1)),
		Skill.new("skill2", "小阿卡纳", 0, SKILL2_ENERGY, Callable(), Callable(_skill2)),  # 独立冷却由花色管理
	]

# ── 技能一: 圣三角 ──

## 随机抽取 3 张不重复的大阿卡纳，显示在屏幕上方，效果持续到下次使用
static func _skill1(owner: Fighter) -> Dictionary:
	# 如果已有激活的圣三角，先移除旧效果
	if owner.get_meta("skill1_active"):
		owner.attack_boost -= owner.get_meta("skill1_atk_boost")
		owner.defense -= owner.get_meta("skill1_def_boost")
		GameWorld.astrologer_cards.clear()

	# 随机抽 3 张不重复
	var pool = range(22)
	pool.shuffle()
	var cards: Array = []
	var count_1 = 0
	var count_2 = 0
	var count_3 = 0
	for i in 3:
		var idx = pool[i]
		var card = ARCANA[idx]
		cards.append({"index": idx, "period": card.period, "tex": card.tex, "name_cn": card.name_cn})
		match card.period:
			1: count_1 += 1
			2: count_2 += 1
			3: count_3 += 1

	# 计算效果
	var atk_boost = count_1 * SKILL1_ATK_PER_1
	var def_boost = count_2 * SKILL1_DEF_PER_2
	var cd_reduce = count_3 * SKILL1_CD_PER_3

	# 应用 buff
	if atk_boost > 0:
		owner.attack_boost += atk_boost
	if def_boost > 0:
		owner.defense += def_boost

	# 存储状态
	owner.set_meta("drawn_cards", cards)
	owner.set_meta("skill1_active", true)
	owner.set_meta("skill2_predicted", -1)  # 一技能后立刻重新预掷二技能
	owner.set_meta("skill1_atk_boost", atk_boost)
	owner.set_meta("skill1_def_boost", def_boost)
	owner.set_meta("skill1_cd_reduce", cd_reduce)

	# 释放后获得 1s 无敌（通用接口，由 apply_physics 自动计时）
	Fighter.set_invincible(owner, 60)

	# 构建加成描述
	var bonus_parts: Array = []
	if atk_boost > 0:
		bonus_parts.append("攻击+%d%%" % int(atk_boost * 100))
	if def_boost > 0:
		bonus_parts.append("防御+%.1f" % def_boost)
	if cd_reduce > 0:
		bonus_parts.append("二技能CD-%ds" % (cd_reduce / 60))
	var bonus_text = "  ".join(bonus_parts) if bonus_parts.size() > 0 else ""

	# 注册牌面显示（无计时，持续到下次使用）
	GameWorld.astrologer_cards.append({
		"owner": owner,
		"cards": cards,
		"bonus_text": bonus_text,
	})

	return {"success": true}

# ── 技能二: 塔罗·小阿卡纳 ──

## 随机抽取一种小阿卡纳花色，显示在角色头上。四花色独立冷却，圣三角主导牌型影响抽取概率。
static func _skill2(owner: Fighter) -> Dictionary:
	# ── 清除旧增强效果 ──
	owner.set_meta("swords_buff_timer", 0)

	# ── 检查独立冷却：筛除不可用的花色 ──
	var cds = owner.get_meta("skill2_cds")
	var available_indices: Array = []
	for i in 4:
		var cd = cds[i] if cds and i < cds.size() else 0
		if cd <= 0:
			available_indices.append(i)
	if available_indices.is_empty():
		return {"success": false}  # 全部在冷却中

	# ── 判定主导花色 ──
	var skill1_active = owner.get_meta("skill1_active")
	var dominant = _get_dominant_period(owner) if skill1_active else -1
	owner.set_meta("dominant_period", dominant)

	# ── 使用预掷骰子结果（按键显示即释放结果）──
	var predicted = owner.get_meta("skill2_predicted")
	if predicted == null or predicted < 0 or not available_indices.has(predicted):
		return {"success": false}
	var idx: int = predicted
	owner.set_meta("skill2_predicted", -1)  # 消耗，下帧重掷

	# ── 设置独立冷却 ──
	cds[idx] = SKILL2_CDS[idx]
	owner.set_meta("skill2_cds", cds)

	# ── 应用圣三角冷却减少 ──
	var cd_reduce = owner.get_meta("skill1_cd_reduce")
	if cd_reduce != null and cd_reduce > 0:
		cds[idx] = maxi(0, cds[idx] - cd_reduce)
		owner.set_meta("skill2_cds", cds)

	var suit = MINOR_ARCANA[idx]
	owner.set_meta("skill2_suit", idx)
	owner.set_meta("skill2_name", suit.name_cn)
	owner.set_meta("skill2_element", suit.element)
	owner.set_meta("skill2_label_timer", 30)  # 0.5秒

	# ── 权杖·星辰余烬 ──
	if idx == 0:  # 权杖
		# 身前 310px 索敌（参考普攻陨石索敌逻辑）
		var fire_x = owner.pos_x + owner.w / 2.0 + WANDS_FIRE_TARGET_RANGE * owner.facing
		var best_target: Fighter = null
		var best_dist = WANDS_FIRE_TARGET_RANGE
		for e in GameWorld.entities:
			if e == owner or e.hp <= 0:
				continue
			var dx = (e.pos_x + e.w / 2.0) - (owner.pos_x + owner.w / 2.0)
			if dx * owner.facing <= 0:
				continue
			if dx * owner.facing < best_dist:
				best_dist = dx * owner.facing
				best_target = e
		if best_target:
			fire_x = best_target.pos_x + best_target.w / 2.0
		fires.append({
			"x": fire_x,
			"life": WANDS_FIRE_FRAMES,
			"damage": WANDS_FIRE_DAMAGE,
			"owner": owner,
		})
		Fighter.emit_particles(fire_x, Constants.GROUND_Y - 100, 20, Color(1.0, 0.4, 0.1), 8, 14, "circle")

	# ── 圣杯·潮汐挽歌 ──
	if idx == 1:  # 圣杯
		var tide_x = owner.pos_x + owner.w / 2.0 + CUPS_TIDE_SPAWN_DIST * owner.facing
		var tide = {
			"x": tide_x,
			"life": CUPS_TIDE_FRAMES,
			"damage": CUPS_TIDE_DAMAGE,
			"owner": owner,
			"facing": owner.facing,
		}
		if dominant == 2:
			tide["enhanced"] = true
		tides.append(tide)
		Fighter.emit_particles(tide_x, Constants.GROUND_Y - 60, 15, Color(0.3, 0.5, 1.0), 6, 10, "circle")

	# ── 宝剑·风神之叹 ──
	if idx == 2:  # 宝剑
		var tn_x = owner.pos_x + owner.w / 2.0 + 200.0 * owner.facing
		var tn_y = owner.pos_y + owner.h / 2.0  # 中心与占星术士y轴一致
		tornadoes.append({
			"x": tn_x,
			"y_center": tn_y,
			"life": SWORDS_TORNADO_FRAMES,
			"damage": SWORDS_TORNADO_DAMAGE,
			"owner": owner,
			"facing": owner.facing,
		})
		# 期间不可操作
		owner.set_meta("swords_lock_timer", SWORDS_TORNADO_FRAMES)
		if dominant == 3:
			owner.set_meta("swords_buff_timer", 300)  # 5s 加速
		Fighter.emit_particles(tn_x, Constants.GROUND_Y - 60, 20, Color(0.7, 0.8, 1.0), 6, 10, "circle")

	# ── 星币·古脉壁立 ──
	if idx == 3:  # 星币
		var wx = owner.pos_x + owner.w / 2.0 + PENTACLES_WALL_SPAWN_DIST * owner.facing
		var wy = Constants.GROUND_Y - PENTACLES_WALL_H
		var wall_hp = PENTACLES_WALL_HP
		var wall_life = PENTACLES_WALL_LIFE
		var wall_dmg = PENTACLES_WALL_DAMAGE
		if dominant == 0:
			wall_dmg += 5.0
			wall_life += 120
			wall_hp += 10.0
		var wall = {
			"x": wx - PENTACLES_WALL_W / 2.0,
			"y": wy,
			"w": PENTACLES_WALL_W,
			"h": PENTACLES_WALL_H,
			"hp": wall_hp,
			"life": wall_life,
			"owner": owner,
			"dmg_dealt": false,
			"dmg": wall_dmg,
		}
		walls.append(wall)
		# 作为平台实体加入（阻挡敌人移动）
		GameWorld.platforms.append({
			"x": wall.x, "y": wall.y, "w": wall.w, "h": wall.h,
			"terrain_type": 4,  # 自定义类型：土墙
			"wall_ref": wall,   # 引用回 wall dict
		})
		Fighter.emit_particles(wx, Constants.GROUND_Y - 60, 15, Color(0.6, 0.4, 0.2), 6, 8, "circle")

	return {"success": true}

# ── 普攻: 陨星咒 ──

## 从屏幕外以 37° 斜向下召唤陨石，身前 250px 内有敌人则自动瞄准
static func _normal_attack(owner: Fighter):
	var dir = owner.facing
	const ANGLE_COS := 0.79863551   # cos(37°)
	const ANGLE_SIN := 0.60181502   # sin(37°)
	var speed = ATK_METEOR_SPEED
	var vx = speed * ANGLE_COS * dir
	var vy = speed * ANGLE_SIN
	var sy = -80.0  # 屏幕外上方起点

	# 计算飞行时间（从 sy 到地面）
	var t = (Constants.GROUND_Y - sy) / vy
	var life_frames = int(t)

	# 默认起点 X：从角色中心出发
	var sx = owner.pos_x + owner.w / 2.0

	# 身前 300px 索敌：自动瞄准最近敌人
	var best_target: Fighter = null
	var best_dist = ATK_METEOR_TARGET_RANGE
	for e in GameWorld.entities:
		if e == owner or e.hp <= 0:
			continue
		var dx2 = (e.pos_x + e.w / 2.0) - (owner.pos_x + owner.w / 2.0)
		if dx2 * dir <= 0:  # 不在面朝方向
			continue
		if dx2 * dir < best_dist:
			best_dist = dx2 * dir
			best_target = e

	if best_target:
		# 反算起点 X，使陨石精准落在敌人中心
		var target_x = best_target.pos_x + best_target.w / 2.0
		sx = target_x - vx * t

	GameWorld.craters.append({
		"pending": true,
		"x": sx - 24, "y": sy - 24,
		"w": 48, "h": 48,
		"vx": vx, "vy": vy,
		"life": life_frames,
		"damage": ATK_METEOR_DMG,
		"hit_enemy": false,
		"dir": dir,  # 飞行朝向（用于绘制翻转）
		"owner": owner,
		"img": PROJ_METEOR,
		"crater_img": PROJ_CRATER,
		"crater_w": ATK_CRATER_W, "crater_h": ATK_CRATER_H,
		"crater_life": ATK_CRATER_LIFE,
		"dmg_timer": 0.0,
	})

	# 发射粒子
	Fighter.emit_particles(sx, sy, 10, Color(1.0, 0.53, 0.27), 4, 6, "star")

# ── 每帧更新: 陨石飞行 + 陨石坑生命周期 + DoT ──

static func update_systems(owner: Fighter):
	# ── 四花色独立冷却递减 ──
	var cds = owner.get_meta("skill2_cds")
	if cds != null:
		for i in 4:
			if cds[i] > 0:
				cds[i] -= 1
		owner.set_meta("skill2_cds", cds)

	# ── 更新二技能按键标签 + 预掷骰子（按键名与释放效果一致）──
	var skill1_active = owner.get_meta("skill1_active")
	var skill = owner.get_skill("skill2")
	var predicted = owner.get_meta("skill2_predicted")
	
	# 构建可用花色列表 + 判断主导
	var avail: Array = []
	for i in 4:
		if cds != null and i < cds.size() and cds[i] <= 0:
			avail.append(i)
	
	var dominant = _get_dominant_period(owner) if skill1_active else -1
	var need_reroll = (predicted == null or predicted < 0 or not avail.has(predicted))
	
	if need_reroll and not avail.is_empty():
		# 预掷骰子：40% 加权随机（与 _skill2 抽取逻辑一致）
		var target: int = -1
		match dominant:
			1: target = 0
			2: target = 1
			3: target = 2
			0: target = 3
		if not skill1_active or dominant < 0:
			target = -1  # 无主导，均等随机
		var weights = [0.0, 0.0, 0.0, 0.0]
		for i in avail:
			if target >= 0 and i == target:
				weights[i] = 0.4
			else:
				weights[i] = 1.0  # 均分
		var total = 0.0
		for w in weights: total += w
		if total > 0:
			var r = randf() * total
			var acc = 0.0
			for i in 4:
				acc += weights[i]
				if r < acc:
					predicted = i
					break
		owner.set_meta("skill2_predicted", predicted)

	# 更新按键标签
	var suit_names = ["星辰余烬", "潮汐挽歌", "风神之叹", "古脉壁立"]
	if predicted != null and predicted >= 0 and predicted < 4:
		owner.hud_skill_labels["skill2"] = "I " + suit_names[predicted]
		if skill and cds != null and predicted < cds.size():
			skill.cooldown = SKILL2_CDS[predicted]
			skill.cd = cds[predicted]
	elif avail.is_empty():
		owner.hud_skill_labels["skill2"] = "I 冷却中"
		if skill:
			skill.cd = 0
	else:
		owner.hud_skill_labels["skill2"] = "I 小阿卡纳"
		if skill:
			skill.cd = 0

	# ── 愚者之旅大招倒计时（实秒）──
	if GameWorld.astrologer_ult_end_frame > 0 and GameWorld.astrologer_ult_owner == owner:
		if GameWorld.frame >= GameWorld.astrologer_ult_end_frame:
			GameWorld.astrologer_ult_bg = null
			GameWorld.astrologer_ult_owner = null
			GameWorld.astrologer_ult_end_frame = 0

	# ── 圣三角 1s 无敌由 apply_physics 通用计时管理 ──

	# ── 风神之叹加速 buff 倒计时 ──
	var swords_buff = owner.get_meta("swords_buff_timer", null)
	if swords_buff != null and swords_buff > 0:
		owner.set_meta("swords_buff_timer", swords_buff - 1)

	# ── 开场蓝色 "The Fool" 显示 2s ──
	var intro = owner.get_meta("intro_timer", null)
	if intro != null and intro > 0:
		var t = intro - 1
		owner.set_meta("intro_timer", t)
		if t <= 0:
			owner.set_meta("skill2_name", "")

	# ── 二技能标签 0.5s 计时 ──
	var label_timer = owner.get_meta("skill2_label_timer", null)
	if label_timer != null and label_timer > 0:
		var t = label_timer - 1
		owner.set_meta("skill2_label_timer", t)
		if t <= 0:
			owner.set_meta("skill2_suit", -1)

	# ── 权杖天火 ──
	var fi = fires.size() - 1
	while fi >= 0:
		var f = fires[fi]
		f.life -= 1
		# 粒子
		Fighter.emit_particles(f.x, Constants.GROUND_Y - 40, 3, Color(1.0, 0.4, 0.1, 0.6), 4, 8, "star")
		# 每帧检测范围内敌人造成伤害（类似陨石坑 DoT）
		for e in GameWorld.entities:
			if e == f.owner or e.hp <= 0:
				continue
			if _rect_overlap(f.x - WANDS_FIRE_W / 2.0, 0, WANDS_FIRE_W, Constants.GROUND_Y, e.pos_x, e.pos_y, e.w, e.h):
				if is_instance_valid(f.owner):
					Fighter.apply_damage(e, f.damage / WANDS_FIRE_FRAMES, f.owner, false, Color(1.0, 0.4, 0.1), "hit_enemy", "astrologer_wands_fire")
		# 生命结束 → 生成火焰区域
		if f.life <= 0:
			wands_flame_zones.append({
				"x": f.x - WANDS_FIRE_W / 2.0,
				"y": Constants.GROUND_Y - WANDS_FLAME_H,
				"w": WANDS_FIRE_W, "h": WANDS_FLAME_H,
				"life": WANDS_FLAME_LIFE,
				"dmg_timer": 0.0,
				"owner": f.owner,
			})
			Fighter.emit_particles(f.x, Constants.GROUND_Y, 20, Color(1.0, 0.4, 0.1), 8, 14, "circle")
			fires.remove_at(fi)
		fi -= 1

	# ── 权杖火焰区域（参考陨石坑 DoT）──
	var fzi = wands_flame_zones.size() - 1
	while fzi >= 0:
		var fz = wands_flame_zones[fzi]
		fz.life -= 1
		if fz.life <= 0:
			wands_flame_zones.remove_at(fzi)
			fzi -= 1
			continue
		fz.dmg_timer += 1.0
		while fz.dmg_timer >= 60.0:
			fz.dmg_timer -= 60.0
			for e in GameWorld.entities:
				if e == fz.owner or e.hp <= 0:
					continue
				if _rect_overlap(fz.x, fz.y, fz.w, fz.h, e.pos_x, e.pos_y, e.w, e.h):
					if is_instance_valid(fz.owner):
						Fighter.apply_damage(e, WANDS_FLAME_DOT, fz.owner, false, Color(0.8, 0.3, 0.0), "hit_enemy", "astrologer_wands_flame")
		fzi -= 1

	# ── 圣杯潮汐 ──
	var ti = tides.size() - 1
	while ti >= 0:
		var t = tides[ti]
		t.life -= 1
		if t.life <= 0:
			tides.remove_at(ti)
			ti -= 1
			continue
		# 粒子 + 每帧伤害（参考天火逐帧出伤）
		Fighter.emit_particles(t.x, Constants.GROUND_Y - 40, 2, Color(0.3, 0.5, 1.0, 0.5), 3, 6, "circle")
		for e in GameWorld.entities:
			if e == t.owner or e.hp <= 0:
				continue
			if _rect_overlap(t.x - CUPS_TIDE_W / 2.0, 0, CUPS_TIDE_W, Constants.GROUND_Y, e.pos_x, e.pos_y, e.w, e.h):
				if is_instance_valid(t.owner):
					Fighter.apply_damage(e, t.damage / CUPS_TIDE_FRAMES, t.owner, false, Color(0.3, 0.5, 1.0), "hit_enemy", "astrologer_cups_tide")
				if t.get("enhanced") and is_instance_valid(t.owner):
					e.slow_timer = 180
					e.slow_percent = 0.4
		ti -= 1

	# ── 宝剑龙卷 ──
	var tni = tornadoes.size() - 1
	while tni >= 0:
		var tn = tornadoes[tni]
		tn.life -= 1
		if tn.life <= 0:
			tornadoes.remove_at(tni)
			tni -= 1
			continue
		# 粒子 + 每帧伤害（碰撞框跟随占星术士y轴）
		Fighter.emit_particles(tn.x, tn.y_center, 2, Color(0.7, 0.8, 1.0, 0.5), 3, 6, "circle")
		# 计算龙卷贴图高度用于碰撞
		var tn_tex = SWORDS_TORNADO_FRAMES_LIST[0]
		var tn_scale = SWORDS_TORNADO_W / maxf(tn_tex.get_width(), 1.0)
		var tn_h = tn_tex.get_height() * tn_scale
		for e in GameWorld.entities:
			if e == tn.owner or e.hp <= 0:
				continue
			if _rect_overlap(tn.x - SWORDS_TORNADO_W / 2.0, tn.y_center - tn_h / 2.0, SWORDS_TORNADO_W, tn_h, e.pos_x, e.pos_y, e.w, e.h):
				if is_instance_valid(tn.owner):
					Fighter.apply_damage(e, tn.damage / SWORDS_TORNADO_FRAMES, tn.owner, false, Color(0.7, 0.8, 1.0), "hit_enemy", "astrologer_swords_tornado")
		tni -= 1

	# ── 星币土墙 ──
	var wi = walls.size() - 1
	while wi >= 0:
		var w = walls[wi]
		w.life -= 1
		if w.life <= 0 or w.hp <= 0:
			_remove_wall(w, wi)
			wi -= 1
			continue
		# 敌人碰撞 → 顶飞 + 伤害（仅前60帧，一次性）
		if not w.dmg_dealt and w.life >= PENTACLES_WALL_LIFE - 60:
			for e in GameWorld.entities:
				if e == w.owner or e.hp <= 0:
					continue
				if _rect_overlap(w.x, w.y, w.w, w.h, e.pos_x, e.pos_y, e.w, e.h):
					if is_instance_valid(w.owner):
						Fighter.apply_damage(e, w.dmg, w.owner, false, Color(0.6, 0.4, 0.2), "hit_enemy", "astrologer_pentacles_wall")
					e.vy = -10  # 顶飞
					e.vx = (w.owner.facing if is_instance_valid(w.owner) else 1) * 8  # 击退
					e.grounded = false
					w.dmg_dealt = true
					break
		# 投射物阻挡
		var pj = GameWorld.projectiles.size() - 1
		while pj >= 0:
			var p = GameWorld.projectiles[pj]
			if _rect_overlap(w.x, w.y, w.w, w.h, p.x, p.y, p.w, p.h):
				w.hp -= p.get("damage", 1.0)
				Fighter.emit_particles(p.x + p.w / 2.0, p.y + p.h / 2.0, 6, Color(0.6, 0.4, 0.2), 3, 5, "circle")
				GameWorld.projectiles.remove_at(pj)
			pj -= 1
		wi -= 1

	# ── 陨石坑 ──
	var i = GameWorld.craters.size() - 1
	while i >= 0:
		var cr = GameWorld.craters[i]

		if cr.get("pending"):
			_update_meteor(cr, owner, i)
			i -= 1
			continue

		# 已落地 → 陨石坑计时 + DoT
		cr.life -= 1
		if cr.life <= 0:
			GameWorld.craters.remove_at(i)
			i -= 1
			continue

		cr.dmg_timer += 1.0
		while cr.dmg_timer >= 60.0:
			cr.dmg_timer -= 60.0
			for e in GameWorld.entities:
				if e == owner or e.hp <= 0:
					continue
				if _rect_overlap(cr.x, cr.y, cr.w, cr.h, e.pos_x, e.pos_y, e.w, e.h):
					Fighter.apply_damage(e, ATK_CRATER_DOT, owner, false, Color(0.8, 0.4, 0.0), "hit_enemy", "astrologer_crater")
		i -= 1

## 更新飞行中的陨石：移动、碰撞敌人、检测落地
static func _update_meteor(cr: Dictionary, owner: Fighter, _idx: int):
	cr.x += cr.vx
	cr.y += cr.vy
	cr.life -= 1

	# 蓝色粒子拖尾
	Fighter.emit_particles(cr.x + cr.w / 2.0, cr.y + cr.h / 2.0, 2, Color(0.3, 0.5, 1.0, 0.6), 2, 4, "star")

	# 检查是否命中敌人（命中 → 造成伤害，移除陨石，不出坑）
	if not cr.hit_enemy:
		for e in GameWorld.entities:
			if e == owner or e.hp <= 0:
				continue
			if _rect_overlap(cr.x, cr.y, cr.w, cr.h, e.pos_x, e.pos_y, e.w, e.h):
				Fighter.apply_damage(e, cr.damage, owner, true, Color(1.0, 0.53, 0.27), "hit_enemy", "astrologer_meteor")
				cr.hit_enemy = true
				# 移除（不生成陨石坑）
				GameWorld.craters.erase(cr)
				return

	# 检查是否到达地面（落地 → 生成陨石坑）
	if cr.y + cr.h >= Constants.GROUND_Y or cr.life <= 0:
		# 转为陨石坑
		cr.erase("pending")
		cr.erase("vx"); cr.erase("vy")
		cr.erase("hit_enemy")
		cr.x = cr.x + cr.w / 2.0 - ATK_CRATER_W / 2.0
		cr.y = Constants.GROUND_Y - ATK_CRATER_H
		cr.w = ATK_CRATER_W
		cr.h = ATK_CRATER_H
		cr.img = PROJ_CRATER
		cr.life = ATK_CRATER_LIFE
		cr.dmg_timer = 0.0
		# 落地粒子
		Fighter.emit_particles(cr.x + ATK_CRATER_W / 2.0, Constants.GROUND_Y, 20, Color(1.0, 0.53, 0.27), 5, 8, "circle")
		Fighter.emit_particles(cr.x + ATK_CRATER_W / 2.0, Constants.GROUND_Y, 15, Color(0.6, 0.3, 0.0), 8, 12, "star")

## AABB 矩形重叠检测
static func _rect_overlap(x1: float, y1: float, w1: float, h1: float,
		x2: float, y2: float, w2: float, h2: float) -> bool:
	return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2

## 移除土墙（从 walls 和 platforms 中清理）
static func _remove_wall(w: Dictionary, idx: int):
	for pi in range(GameWorld.platforms.size() - 1, -1, -1):
		if GameWorld.platforms[pi].get("wall_ref") == w:
			GameWorld.platforms.remove_at(pi)
	walls.remove_at(idx)
	Fighter.emit_particles(w.x + w.w / 2.0, w.y + w.h / 2.0, 12, Color(0.6, 0.4, 0.2), 4, 6, "circle")

# ── 大招: 愚者之旅 ──

## 大招帧规格（30帧，含时长数据）—— 播片速度 x2（原 f1~f29 0.121s / f30 1.0s）
static func _ult_frame_specs() -> Array:
	var specs := []
	# timetable: f1~f29 0.121s, f30 1.0s → 时长减半，播放速度 x2
	for i in range(1, ULT_FRAME_COUNT + 1):
		var dur: float = 0.0605
		if i == 30: dur = 0.5
		specs.append({"index": i, "duration": dur})
	return specs

## 大招: 愚者之旅 — 全屏动画 + 背景切换 + 敌方减速/防御debuff + 技能冷却缩减
static func _ult(owner: Fighter) -> Dictionary:
	var ult_anim = FrameAnimation.load_from_frames(ASTROLOGER_ANI_DIR + "ult/", "astrologer_ult_f_", _ult_frame_specs(), false)
	if ult_anim.frames.is_empty():
		return {"success": false}
	ult_anim.play()
	owner.config["animations"]["ult"] = ult_anim
	owner.state = "ult"
	GameWorld.hit_stop = 20

	GameWorld.active_overlays.append({
		"anim": ult_anim,
		"position": {"type": "fullscreen"},
		"overlay_id": "astrologer_ult",
		"on_finish": func():
			owner.state = "idle"
	})

	# ── 愚者之旅效果（持续 10 秒实秒）──
	GameWorld.astrologer_ult_end_frame = GameWorld.frame + int(ULT_DURATION * 60)
	GameWorld.astrologer_ult_bg = ULT_BG
	GameWorld.astrologer_ult_owner = owner

	# 对所有敌方单位施加 debuff（减速50%、防御+12.5、跳跃减半）
	for e in GameWorld.entities:
		if e == owner or e.hp <= 0:
			continue
		e.add_status("astrologer_ult")

	# 自身技能冷却缩减 2 秒（120帧）
	var s1 = owner.get_skill("skill1")
	if s1: s1.cd = maxi(0, s1.cd - 120)
	var s2 = owner.get_skill("skill2")
	if s2: s2.cd = maxi(0, s2.cd - 120)

	# 星辰粒子特效
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 60, Color(0.8, 0.7, 1.0, 0.4), 10, 12, "star", 2.0)
	return {"success": true}

## 判定圣三角主导花色：1=1牌最多 2=2牌最多 3=3牌最多 0=一样多
static func _get_dominant_period(owner: Fighter) -> int:
	var cards = owner.get_meta("drawn_cards")
	if cards == null or cards.is_empty():
		return 0
	var counts = [0, 0, 0]
	for c in cards:
		var p = c.get("period", 0)
		if p >= 1 and p <= 3:
			counts[p - 1] += 1
	if counts[0] > counts[1] and counts[0] > counts[2]:
		return 1
	if counts[1] > counts[0] and counts[1] > counts[2]:
		return 2
	if counts[2] > counts[0] and counts[2] > counts[1]:
		return 3
	return 0  # 一样多

## 输入处理
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	# 风神之叹期间不可操作
	var lock = owner.get_meta("swords_lock_timer", null)
	if lock != null and lock > 0:
		owner.set_meta("swords_lock_timer", lock - 1)
		Fighter.apply_movement(owner, 0, 2.25)
		Fighter.update_state(owner, 0)
		return 0
	var mx = 0
	# 风神之叹加速 buff
	var speed_mult = 2.25
	var jump_vy = -9.0
	var buff = owner.get_meta("swords_buff_timer", null)
	if buff != null and buff > 0:
		speed_mult *= 1.2
		jump_vy *= 1.2
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and owner.grounded:
		owner.vy = jump_vy
		owner.grounded = false
	# 普攻: 陨星咒
	if keys.attack and owner.attack_cooldown <= 0 and not owner.attacking and owner.energy >= ATK_ENERGY_COST:
		owner.attacking = true
		owner.attack_timer = 30
		owner.attack_delay = 10
		owner.attack_hit_dealt = true  # 陨石坑由 update_systems 处理 DoT
		owner.attack_cooldown = ATK_METEOR_COOLDOWN
		owner.state = "attack"
		owner.energy -= ATK_ENERGY_COST
		_normal_attack(owner)
		keys.attack = false
	# 技能一: 圣三角
	if keys.skill1:
		var s = owner.get_skill("skill1")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill1 = false
	# 技能二: 小阿卡纳
	if keys.skill2:
		var s = owner.get_skill("skill2")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill2 = false
	# 大招: 愚者之旅
	if keys.ult:
		var s = owner.get_skill("ult")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.ult = false
	Fighter.apply_movement(owner, mx, speed_mult)
	Fighter.update_state(owner, mx)
	return mx

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

	# 风神之叹锁定期间不可操作
	var lock = f.get_meta("swords_lock_timer", null)
	if lock != null and lock > 0:
		f.vx = 0
		return "ATTACK"

	# ① 无增益 → 优先圣三角（随机三卡，含攻/防/减CD）
	if can_use_s1 and not f.get_meta("skill1_active"):
		f.facing = dir
		skill1.try_use(f)
		return "ATTACK"

	# ② 玩家残血或贴脸 → 大招愚者之旅
	if can_use_ult and player and player.hp > 0 and (player.hp < player.max_hp * 0.4 or dist < 200) and rand < 0.5:
		f.facing = dir
		ult.try_use(f)
		return "ATTACK"

	# ③ 中距离 → 小阿卡纳四花色（攻击/土墙阻挡随机出）
	if can_use_s2 and dist < 420 and rand < 0.45:
		f.facing = dir
		skill2.try_use(f)
		return "ATTACK"

	# ④ 同水平线 + 中距离 → 普攻陨石风筝
	if dist < 420 and f.energy >= ATK_ENERGY_COST and f.attack_cooldown <= 0 and not f.attacking:
		f.facing = dir
		f.energy -= ATK_ENERGY_COST
		_normal_attack(f)
		f.attacking = true; f.attack_timer = 30; f.attack_delay = 10
		f.attack_hit_dealt = true  # 陨石坑 DoT 由 update_systems 处理
		f.attack_cooldown = ATK_METEOR_COOLDOWN
		f.state = "attack"
		return "ATTACK"

	return ""

## 地狱模式专属走位参数（空字典表示不覆盖）
static func ai_hell_desire(f: Fighter) -> Dictionary:
	return {"min": 180, "max": 420}
