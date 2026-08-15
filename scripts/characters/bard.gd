# 吟游诗人 (bard)
class_name BardCharacter

const BARD_ANI_DIR = "res://assets/char_ani/bard/"
const NOTES_DIR = "res://assets/char_ani/bard/Notes/"
const BARD_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/bard_attack_foot_gaps.gd")
const BARD_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/bard_idle_foot_gaps.gd")
const BARD_WALK_FOOT_GAPS = preload("res://data/foot_gaps/bard_walk_foot_gaps.gd")
const BARD_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/bard_jump_foot_gaps.gd")
const BARD_ATTACK_NOTE_FOOT_GAPS = preload("res://data/foot_gaps/bard_attack_note_foot_gaps.gd")

# 技能1：我含泪而笑 — 声波贴图
const SKILL1_DIR = "res://assets/char_ani/bard/skill1/"
const SKILL1_WAVE_1 = preload(SKILL1_DIR + "bard_skill1_f_1.png")
const SKILL1_WAVE_2 = preload(SKILL1_DIR + "bard_skill1_f_2.png")
const SKILL1_WAVE_3 = preload(SKILL1_DIR + "bard_skill1_f_3.png")
const SKILL1_WAVE_IMGS := [SKILL1_WAVE_1, SKILL1_WAVE_2, SKILL1_WAVE_3]

const SKILL1_WAVE_INTERVAL := 12   # 0.2秒（60fps）
const SKILL1_WAVE_LIFE := 93       # 飞行距离280 / 速度3.0 ≈ 93帧
const SKILL1_WAVE_SPEED := 3.0
const SKILL1_WAVE_DAMAGE := 6.0
const SKILL1_WAVE_SIZE := 120.0    # 原贴图40×3倍放大
const SKILL1_ENERGY_COST := 18
const SKILL1_COOLDOWN := 600       # 10秒

# 技能2：月相盈亏 — 领域
const SKILL2_DIR = "res://assets/char_ani/bard/skill2/"
const DOMAIN_WAXING_IMG = preload(SKILL2_DIR + "bard_domain_waxing.png")
const DOMAIN_WANING_IMG = preload(SKILL2_DIR + "bard_domain_waning.png")

const SKILL2_ENERGY_COST := 25
const SKILL2_COOLDOWN := 1200      # 20秒
const DOMAIN_RADIUS := 200.0
const DOMAIN_WAXING_DURATION := 300   # 5秒
const DOMAIN_WANING_DURATION := 480   # 8秒
const DOMAIN_DEFENSE := 21.43         # 月盈领域防御 +21.43（护甲公式等效减伤 30%）
const DOMAIN_HEAL_RATE := 2.0 / 60.0  # 2点/秒
const DOMAIN_DAMAGE_RATE := 1.0 / 60.0  # 1点/秒
const DOMAIN_SLOW_FACTOR := 0.7        # 30%减速
const SKILL_CD_ADJUST := 120           # 2秒

# 大招：胜过天上的星辰
const ULT_FRAME_COUNT := 28
const ULT_DAMAGE_FRAME := 19           # 第19帧后停止出伤
const ULT_FRAME_DUR := 0.217           # 每帧基础持续秒数（来自 timetable）
const ULT_TOTAL_DAMAGE := 40.0
const ULT_ENERGY_COST := 100
const ULT_COOLDOWN := 300              # 5秒

# 彩蛋文本
const EGG_SPECIAL := "𝓮𝓽 𝓓𝓲𝓼𝓬𝓸𝓻𝓭𝓲𝓪 𝓽𝓻𝓲𝓼𝓽𝓲𝓼."
const EGG_ATTACK := "𝓞𝓻 𝓬𝓱𝓮 '𝓵 𝓬𝓲𝓮𝓵 𝓮𝓽 𝓵𝓪 𝓽𝓮𝓻𝓻𝓪 𝓮 '𝓵 𝓿𝓮𝓷𝓽𝓸 𝓽𝓪𝓬𝓮"
const EGG_SKILL1 := "𝓙𝓮 𝓻𝓲𝔃 𝓮𝓷 𝓹𝓵𝓮𝓾𝓻𝓼"
const EGG_SKILL2 := "𝓼𝓮𝓶𝓹𝓮𝓻 𝓬𝓻𝓮𝓼𝓬𝓲𝓼 𝓪𝓾𝓽 𝓭𝓮𝓬𝓻𝓮𝓼𝓬𝓲𝓼"
const EGG_ULT := "𝓒𝓱𝓲𝓪𝓻𝓸, 𝓵𝓾𝓬𝓮𝓷𝓽𝓮, 𝓹𝓲𝓾 𝓬𝓱𝓮 𝓼𝓽𝓮𝓵𝓵𝓪, 𝓲𝓷 𝓬𝓲𝓮𝓵𝓸"
const EGG_DURATION := 120  # 2秒

# 音符弹射物贴图
const NOTE_WHOLE = preload(NOTES_DIR + "note_whole.png")
const NOTE_HALF = preload(NOTES_DIR + "note_half.png")
const NOTE_QUARTER = preload(NOTES_DIR + "note_quarter.png")
const NOTE_EIGHTH = preload(NOTES_DIR + "note_eighth.png")
const NOTE_SIXTEENTH = preload(NOTES_DIR + "note_sixteenth.png")

# 命中特效贴图
const HIT_WHOLE = preload(NOTES_DIR + "hit_whole.png")
const HIT_HALF = preload(NOTES_DIR + "hit_half.png")
const HIT_QUARTER = preload(NOTES_DIR + "hit_quarter.png")
const HIT_EIGHTH = preload(NOTES_DIR + "hit_eighth.png")

# 音符类型定义
const NOTE_TYPES := [
	{"id": "whole", "name": "全音符", "damage": 8, "note_img": NOTE_WHOLE, "hit_img": HIT_WHOLE, "color": Color(1.0, 0.84, 0.0), "particles": 40, "size": 30},
	{"id": "half", "name": "二分音符", "damage": 6, "note_img": NOTE_HALF, "hit_img": HIT_HALF, "color": Color(1.0, 0.6, 0.2), "particles": 30, "size": 26},
	{"id": "quarter", "name": "四分音符", "damage": 5, "note_img": NOTE_QUARTER, "hit_img": HIT_QUARTER, "color": Color(0.7, 0.3, 1.0), "particles": 25, "size": 22},
	{"id": "eighth", "name": "八分音符", "damage": 4, "note_img": NOTE_EIGHTH, "hit_img": HIT_EIGHTH, "color": Color(0.3, 0.6, 1.0), "particles": 20, "size": 18},
	{"id": "sixteenth", "name": "十六分音符", "damage": 2, "note_img": NOTE_SIXTEENTH, "hit_img": null, "color": Color(0.9, 0.9, 0.9), "particles": 10, "size": 14},
]

const NOTE_HIT_DURATION := 15
const CONFUSION_DURATION := 300  # 5秒
const COLLECTED_ICON_SIZE := 28.0
const COLLECTED_ICON_Y := 400.0  # 屏幕底部上方

static var _note_hits: Array = []  # 音符命中特效 [{img, x, y, timer}]

static func get_config() -> Dictionary:
	return {
		"id": "bard", "name": "吟游诗人", "hp": 80, "max_energy": 100, "energy_regen": 0.05,
		"speed": 2.25, "attack_range": 0, "attack_damage": 5,
		"attack_cooldown": 120, "attack_delay": 8, "attack_duration": 30,
		"image_scale": 1.2,
		"fields": {}, "world_arrays": [],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(BARD_ANI_DIR + "idle/sheet.png", 4, 4, 14, 0.1, true, _bard_idle_anchors()),
			"walk": FrameAnimation.load_from_sprite_sheet(BARD_ANI_DIR + "walk/sheet.png", 3, 3, 9, 0.1, true, _bard_walk_anchors()),
			"jump": FrameAnimation.load_jump_sheet(BARD_ANI_DIR + "jump/sheet.png", 3, 2, 5, 0.2, _bard_jump_anchors()),
			"attack": FrameAnimation.load_from_sprite_sheet(BARD_ANI_DIR + "attack/sheet.png", 3, 3, 8, 0.05, false, _bard_attack_anchors()),
			"attack_note": FrameAnimation.load_from_sprite_sheet(BARD_ANI_DIR + "attack_note/sheet.png", 3, 2, 6, 0.1, false, _bard_attack_note_anchors()),
			"skill1": FrameAnimation.load_from_frames(BARD_ANI_DIR + "attack/", "bard_attack_f_", [
				{"index": 1, "duration": 0.5},
				{"index": 2, "duration": 0.5},
				{"index": 3, "duration": 0.5},
			], false),
			"skill_perform": FrameAnimation.load_from_frames(BARD_ANI_DIR + "Whisper/", "bard_perform_f_", [
				{"index": 1, "duration": 0.8},
				{"index": 2, "duration": 0.4},
				{"index": 3, "duration": 0.4},
				{"index": 4, "duration": 0.4},
			], true),
			"ult": FrameAnimation.load_from_frames(BARD_ANI_DIR + "ult/", "bard_ult_f_", [{"index": 1, "duration": 3.0}], false),
		},
		"dex": {
			"icon": "\U0001F3B5",
			"intro": "琴弦轻颤，诗篇流淌。她不持利刃，却以旋律抚慰战友、震慑敌心。战场是她的舞台，每一次拨弦都是命运的变奏。\n\"听，这是为你谱写的挽歌。\"\n特殊机制「叶之低语」：地面双击 ↓ 进入演奏状态，能量恢复速度翻倍，任意操作/受击退出。\n特殊机制「忧伤的纷争」：五种音符各命中一次后，敌人进入紊乱状态（方向颠倒）持续5秒。",
			"easter_egg": "𝓮𝓽 𝓓𝓲𝓼𝓬𝓸𝓻𝓭𝓲𝓪 𝓽𝓻𝓲𝓼𝓽𝓲𝓼.",
			"stats": [
				{"label": "生命", "value": "80"}, {"label": "能量上限", "value": "100"},
				{"label": "叶之低语", "value": "地面双击↓演奏"},
				{"label": "忧伤的纷争", "value": "集齐5音符→紊乱5s"},
			],
			"skills": [
				{"name": "此刻万籁俱寂（普通攻击）", "desc": "消耗5能量，拨动琴弦随机发射一枚音符弹射物（240px射程）。全8伤 / 二分6伤 / 四分5伤 / 八分4伤 / 十六分2伤。每种命中后收集，未收集音符出现率×5，集齐五种触发紊乱。", "meta": "消耗：5 能 ｜ 冷却：2 秒", "easter_egg": "𝓞𝓻 𝓬𝓱𝓮 '𝓵 𝓬𝓲𝓮𝓵 𝓮𝓽 𝓵𝓪 𝓽𝓮𝓻𝓻𝓪 𝓮 '𝓵 𝓿𝓮𝓷𝓽𝓸 𝓽𝓪𝓬𝓮"},
				{"name": "我含泪而笑（技能一）", "desc": "连续发射3道声波，每道间隔0.2秒，飞行距离300，每道伤害6。三段声波全部命中敌人直接触发紊乱效果（方向颠倒）持续5秒。", "meta": "消耗：18 能 ｜ 冷却：10 秒", "easter_egg": "𝓙𝓮 𝓻𝓲𝔃 𝓮𝓷 𝓹𝓵𝓮𝓾𝓻𝓼"},
				{"name": "月相盈亏（技能二）", "desc": "周围200内无敌人时展开高音领域（金色）持续5秒：诗人在领域内防御力+21.4，回复2HP/秒，技能冷却-2秒（不可叠加）。有敌人时展开低音领域（暗紫色）持续8秒：敌人在领域内受1伤害/秒，移速跳跃-30%，技能冷却+2秒（不可叠加）。", "meta": "消耗：25 能 ｜ 冷却：20 秒", "easter_egg": "𝓼𝓮𝓶𝓹𝓮𝓻 𝓬𝓻𝓮𝓼𝓬𝓲𝓼 𝓪𝓾𝓽 𝓭𝓮𝓬𝓻𝓮𝓼𝓬𝓲𝓼"},
				{"name": "胜过天上的星辰（大招）", "desc": "在星空下演奏，净化敌人。释放后生成28帧星空动画，第19帧前持续出伤，总计40点伤害。", "meta": "消耗：100 能 ｜ 冷却：5 秒", "easter_egg": "𝓒𝓱𝓲𝓪𝓻𝓸, 𝓵𝓾𝓬𝓮𝓷𝓽𝓮, 𝓹𝓲𝓾 𝓬𝓱𝓮 𝓼𝓽𝓮𝓵𝓵𝓪, 𝓲𝓷 𝓬𝓲𝓮𝓵𝓸"},
			]
		},
	}

static func create_skills() -> Array:
	return [
		Skill.new("skill1", "我含泪而笑", SKILL1_COOLDOWN, SKILL1_ENERGY_COST, Callable(), Callable(_skill1)),
		Skill.new("skill2", "月相盈亏", SKILL2_COOLDOWN, SKILL2_ENERGY_COST, Callable(), Callable(_skill2)),
		Skill.new("ult", "胜过天上的星辰", ULT_COOLDOWN, ULT_ENERGY_COST, Callable(), Callable(_ult)),
	]

## 攻击动画锚点：把扫描生成的 GDScript 常量组装成 FrameAnimation 需要的字典数组
static func _bard_attack_anchors() -> Array:
	var anchors := []
	for i in range(BARD_ATTACK_FOOT_GAPS.BARD_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": BARD_ATTACK_FOOT_GAPS.BARD_ATTACK_FOOT[i],
			"head_gap": BARD_ATTACK_FOOT_GAPS.BARD_ATTACK_HEAD[i],
			"center_dx": BARD_ATTACK_FOOT_GAPS.BARD_ATTACK_CENTER[i],
			"content_w": BARD_ATTACK_FOOT_GAPS.BARD_ATTACK_CONTENT_W[i],
			"content_h": BARD_ATTACK_FOOT_GAPS.BARD_ATTACK_CONTENT_H[i],
		})
	return anchors

## idle 动画锚点：同 _bard_attack_anchors 写法
static func _bard_idle_anchors() -> Array:
	var anchors := []
	for i in range(BARD_IDLE_FOOT_GAPS.BARD_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": BARD_IDLE_FOOT_GAPS.BARD_IDLE_FOOT[i],
			"head_gap": BARD_IDLE_FOOT_GAPS.BARD_IDLE_HEAD[i],
			"center_dx": BARD_IDLE_FOOT_GAPS.BARD_IDLE_CENTER[i],
			"content_w": BARD_IDLE_FOOT_GAPS.BARD_IDLE_CONTENT_W[i],
			"content_h": BARD_IDLE_FOOT_GAPS.BARD_IDLE_CONTENT_H[i],
		})
	return anchors

## walk 动画锚点：同 _bard_attack_anchors 写法
static func _bard_walk_anchors() -> Array:
	var anchors := []
	for i in range(BARD_WALK_FOOT_GAPS.BARD_WALK_FOOT.size()):
		anchors.append({
			"foot_gap": BARD_WALK_FOOT_GAPS.BARD_WALK_FOOT[i],
			"head_gap": BARD_WALK_FOOT_GAPS.BARD_WALK_HEAD[i],
			"center_dx": BARD_WALK_FOOT_GAPS.BARD_WALK_CENTER[i],
			"content_w": BARD_WALK_FOOT_GAPS.BARD_WALK_CONTENT_W[i],
			"content_h": BARD_WALK_FOOT_GAPS.BARD_WALK_CONTENT_H[i],
		})
	return anchors

## jump 动画锚点：同 _bard_attack_anchors 写法
static func _bard_jump_anchors() -> Array:
	var anchors := []
	for i in range(BARD_JUMP_FOOT_GAPS.BARD_JUMP_FOOT.size()):
		anchors.append({
			"foot_gap": BARD_JUMP_FOOT_GAPS.BARD_JUMP_FOOT[i],
			"head_gap": BARD_JUMP_FOOT_GAPS.BARD_JUMP_HEAD[i],
			"center_dx": BARD_JUMP_FOOT_GAPS.BARD_JUMP_CENTER[i],
			"content_w": BARD_JUMP_FOOT_GAPS.BARD_JUMP_CONTENT_W[i],
			"content_h": BARD_JUMP_FOOT_GAPS.BARD_JUMP_CONTENT_H[i],
		})
	return anchors

## attack_note 动画锚点：同 _bard_attack_anchors 写法
static func _bard_attack_note_anchors() -> Array:
	var anchors := []
	for i in range(BARD_ATTACK_NOTE_FOOT_GAPS.BARD_ATTACK_NOTE_FOOT.size()):
		anchors.append({
			"foot_gap": BARD_ATTACK_NOTE_FOOT_GAPS.BARD_ATTACK_NOTE_FOOT[i],
			"head_gap": BARD_ATTACK_NOTE_FOOT_GAPS.BARD_ATTACK_NOTE_HEAD[i],
			"center_dx": BARD_ATTACK_NOTE_FOOT_GAPS.BARD_ATTACK_NOTE_CENTER[i],
			"content_w": BARD_ATTACK_NOTE_FOOT_GAPS.BARD_ATTACK_NOTE_CONTENT_W[i],
			"content_h": BARD_ATTACK_NOTE_FOOT_GAPS.BARD_ATTACK_NOTE_CONTENT_H[i],
		})
	return anchors

static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var comp: BardComponent = owner.components.get_component("bard") if owner.components else null
	if not comp:
		return 0

	var down_just_pressed = keys.down and not comp.was_down_pressed
	comp.was_down_pressed = keys.down

	if comp.perform_active:
		if keys.left or keys.right or keys.up or keys.attack or keys.skill1 or keys.skill2 or keys.ult or down_just_pressed:
			comp.perform_active = false
			owner.image_state = ""
			owner.set_animation_state("idle")
		return 0

	if down_just_pressed and owner.grounded and owner.pos_y + owner.h >= 375.0:
		var current_frame = GameWorld.frame
		if current_frame - comp.last_down_press_frame < 25:
			comp.perform_active = true
			_show_easter_egg(comp, EGG_SPECIAL)
			owner.set_animation_state("skill_perform")
			owner.vx = 0
			comp.last_down_press_frame = -999
			return 0
		comp.last_down_press_frame = current_frame

	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and owner.grounded:
		owner.vy = -10
		owner.grounded = false
	if keys.attack and owner.attack_cooldown <= 0 and not owner.attacking and not comp.skill1_active and owner.energy >= 5:
		owner.energy -= 5
		_fire_note(owner, comp)
		owner.attacking = true
		owner.attack_timer = 30
		owner.attack_delay = 8
		owner.attack_hit_dealt = false
		owner.attack_cooldown = 120
		owner.state = "attack"
		keys.attack = false

	# 技能1：我含泪而笑
	if keys.skill1 and not comp.skill1_active and not owner.attacking and not owner.dashing:
		var s = owner.get_skill("skill1")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill1 = false

	# 技能2：月相盈亏
	if keys.skill2 and not comp.skill2_active and not owner.attacking and not owner.dashing:
		var s = owner.get_skill("skill2")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill2 = false

	# 大招
	if keys.ult and not comp.ult_active and not owner.attacking and not owner.dashing:
		var s = owner.get_skill("ult")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.ult = false

	Fighter.apply_movement(owner, mx, 2.25)
	Fighter.update_state(owner, mx)
	return mx

static func _fire_note(owner: Fighter, comp: BardComponent):
	_show_easter_egg(comp, EGG_ATTACK)
	var note = _pick_note(comp)
	var dir = owner.facing
	var px = owner.pos_x + (owner.w if dir == 1 else 0)
	var py = owner.pos_y + 28
	var sz = note["size"]

	var proj = {
		"x": px - sz / 2.0, "y": py - sz / 2.0,
		"w": float(sz), "h": float(sz),
		"vx": 4.0 * dir, "vy": 0.0,
		"life": 60, "damage": float(note["damage"]),
		"owner": owner, "type": "bard_note",
		"color": note["color"],
		"reflected": false,
		"img": note["note_img"],
	}
	GameWorld.projectiles.append(proj)
	Fighter.emit_particles(px, py, note["particles"] / 2, Color(note["color"].r, note["color"].g, note["color"].b, 0.3), 3, 5, "circle")

	comp._tracked_note = proj
	comp._tracked_hit_img = note["hit_img"]
	comp._tracked_note_damage = note["damage"]
	comp._tracked_note_id = note["id"]

## 技能1：我含泪而笑 — 执行函数
static func _skill1(owner: Fighter) -> Dictionary:
	var comp: BardComponent = owner.components.get_component("bard") if owner.components else null
	if not comp:
		return {"success": false}
	_show_easter_egg(comp, EGG_SKILL1)
	comp.skill1_active = true
	comp.skill1_wave_index = 0
	comp.skill1_wave_timer = 0
	comp.skill1_hits = 0
	comp._skill1_tracked_waves.clear()
	owner.set_animation_state("skill1")
	# 第一波立即发射
	_fire_skill1_wave(owner, comp)
	comp.skill1_wave_timer = SKILL1_WAVE_INTERVAL
	return {"success": true}

## 发射一道声波弹射物
static func _fire_skill1_wave(owner: Fighter, comp: BardComponent):
	var dir = owner.facing
	var px = owner.pos_x + (owner.w if dir == 1 else 0)
	var py = owner.pos_y + 20
	var sz = SKILL1_WAVE_SIZE
	var wave_img = SKILL1_WAVE_IMGS[comp.skill1_wave_index]

	var proj = {
		"x": px - sz / 2.0, "y": py - sz / 2.0,
		"w": sz, "h": sz,
		"vx": SKILL1_WAVE_SPEED * dir, "vy": 0.0,
		"life": SKILL1_WAVE_LIFE,
		"damage": SKILL1_WAVE_DAMAGE,
		"owner": owner, "type": "bard_skill1_wave",
		"color": Color(0.7, 0.5, 1.0, 0.8),
		"reflected": false,
		"piercing": true,
		"stun": true,
		"img": wave_img,
	}
	GameWorld.projectiles.append(proj)
	comp._skill1_tracked_waves.append(proj)
	Fighter.emit_particles(px, py, 15, Color(0.7, 0.5, 1.0, 0.3), 3, 5, "circle")

## 大招生成帧规格（来自 output_timetable.txt）
static func _ult_frame_specs() -> Array:
	var specs := []
	for i in range(1, ULT_FRAME_COUNT + 1):
		var dur: float = ULT_FRAME_DUR
		if i == 24: dur = 0.434
		elif i == 28: dur = 1.0
		specs.append({"index": i, "duration": dur})
	return specs

## 大招：胜过天上的星辰 — 执行函数
static func _ult(owner: Fighter) -> Dictionary:
	var comp: BardComponent = owner.components.get_component("bard") if owner.components else null
	if not comp:
		return {"success": false}

	_show_easter_egg(comp, EGG_ULT)

	# 运行时加载28帧大动画（仿 Rose 模式）
	var ult_anim = FrameAnimation.load_from_frames(BARD_ANI_DIR + "ult/", "bard_ult_f_", _ult_frame_specs(), false)
	if ult_anim.frames.is_empty():
		printerr("[Bard] ult animation failed to load frames")
		return {"success": false}
	ult_anim.play()

	# 全屏 overlay 播放（仿 Rose/DK 模式），inject 到 config 中供 update_state 使用
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
		"overlay_id": "bard_ult",
		"on_finish": func():
			comp.ult_active = false
			comp.ult_anim_obj = null
			owner.state = "idle"
	})
	# 大招释放特效
	Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 80, Color(0.3, 0.6, 1.0, 0.3), 10, 12, "star", 2.0)
	return {"success": true}

## 技能2：月相盈亏 — 执行函数
static func _skill2(owner: Fighter) -> Dictionary:
	var comp: BardComponent = owner.components.get_component("bard") if owner.components else null
	if not comp:
		return {"success": false}

	_show_easter_egg(comp, EGG_SKILL2)

	# 判断周围200px内是否有敌人
	var enemy = GameWorld.get_opponent(owner)
	var has_enemy_nearby = enemy and enemy.hp > 0 and absf(owner.pos_x - enemy.pos_x) < DOMAIN_RADIUS
	
	if has_enemy_nearby:
		# 月亏：低音领域
		comp.domain_type = "waning"
		comp.domain_img = DOMAIN_WANING_IMG
		comp.domain_color = Color(0.5, 0.0, 0.5, 0.3)  # 暗紫色半透明
		comp.domain_timer = DOMAIN_WANING_DURATION
		comp.domain_radius = DOMAIN_RADIUS
	else:
		# 月盈：高音领域
		comp.domain_type = "waxing"
		comp.domain_img = DOMAIN_WAXING_IMG
		comp.domain_color = Color(1.0, 0.84, 0.0, 0.3)  # 金色半透明
		comp.domain_timer = DOMAIN_WAXING_DURATION
		comp.domain_radius = DOMAIN_RADIUS

	# 领域以诗人当前位置为中心
	comp.domain_center_x = owner.pos_x + owner.w / 2.0
	comp.domain_center_y = owner.pos_y + owner.h / 2.0
	comp.domain_x = comp.domain_center_x - DOMAIN_RADIUS
	comp.domain_y = comp.domain_center_y - DOMAIN_RADIUS
	comp.skill2_active = true
	comp.domain_cd_applied = false
	comp.domain_enemy_debuffed = false

	# 创建领域贴图弹射物（纯视觉，固定在释放位置，无伤害无碰撞）
	var img_size = 80.0
	var domain_proj = {
		"x": comp.domain_center_x - img_size / 2.0,
		"y": comp.domain_center_y - img_size / 2.0,
		"w": img_size, "h": img_size,
		"vx": 0.0, "vy": 0.0,
		"life": comp.domain_timer + 1,
		"damage": 0.0,
		"owner": owner, "type": "bard_domain",
		"color": comp.domain_color,
		"reflected": false,
		"piercing": true,
		"img": comp.domain_img,
	}
	GameWorld.projectiles.append(domain_proj)
	comp._domain_projectile = domain_proj

	# 领域范围光圈（固定在释放位置，用 camera 做偏移）
	GameWorld.register_draw_effect("bard_domain", func(_font, cam_x, cam_y = 0.0):
		return [{"type": "circle",
			"pos": Vector2(comp.domain_center_x - cam_x, comp.domain_center_y - cam_y),
			"radius": DOMAIN_RADIUS, "color": comp.domain_color}]
	, 0)

	# 复位敌人的减速状态（防止旧领域残留）
	owner.speed_multiplier = 1.0
	owner.jump_reduction = 1.0
	if enemy and enemy.hp > 0:
		enemy.speed_multiplier = 1.0
		enemy.jump_reduction = 1.0

	owner.set_animation_state("skill1")
	return {"success": true}

## 每帧更新领域效果
static func _update_domain(comp: BardComponent, f: Fighter):
	if not comp.skill2_active or comp.domain_timer <= 0:
		if comp.skill2_active:
			# 领域结束 → 清除效果
			comp.skill2_active = false
			comp.domain_type = ""
			GameWorld.unregister_draw_effect("bard_domain")
			_remove_domain_projectile(comp)
			if comp.domain_def_applied:
				f.defense = maxf(0.0, f.defense - DOMAIN_DEFENSE)
				comp.domain_def_applied = false
			f.speed_multiplier = 1.0
			f.jump_reduction = 1.0
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0:
				enemy.speed_multiplier = 1.0
				enemy.jump_reduction = 1.0
		return

	comp.domain_timer -= 1
	var enemy = GameWorld.get_opponent(f)

	if comp.domain_type == "waxing":
		# 月盈：高音领域 — 诗人需在领域内
		var fx = f.pos_x + f.w / 2.0
		var fy = f.pos_y + f.h / 2.0
		var dist = sqrt(pow(fx - comp.domain_center_x, 2) + pow(fy - comp.domain_center_y, 2))
		if dist <= comp.domain_radius:
			# 月盈领域：诗人站在领域内获得防御加成（一次性累加）
			if not comp.domain_def_applied:
				f.defense += DOMAIN_DEFENSE
				comp.domain_def_applied = true
			# 生命恢复（2点/秒）
			Fighter.try_heal(f, DOMAIN_HEAL_RATE)
			# 技能冷却减少2秒（一次性，不可叠加）
			if not comp.domain_cd_applied:
				for s in f.skills:
					s.cd = maxi(0, s.cd - SKILL_CD_ADJUST)
				comp.domain_cd_applied = true
		else:
			# 诗人离开领域 → 移除防御加成
			if comp.domain_def_applied:
				f.defense = maxf(0.0, f.defense - DOMAIN_DEFENSE)
				comp.domain_def_applied = false

	elif comp.domain_type == "waning" and enemy and enemy.hp > 0:
		# 月亏：低音领域 — 敌人在领域内
		var ex = enemy.pos_x + enemy.w / 2.0
		var ey = enemy.pos_y + enemy.h / 2.0
		var dist = sqrt(pow(ex - comp.domain_center_x, 2) + pow(ey - comp.domain_center_y, 2))
		if dist <= comp.domain_radius:
			# 持续伤害（1点/秒）
			Fighter.apply_damage(enemy, DOMAIN_DAMAGE_RATE, f, false, Color(0.5, 0.0, 0.5), "hit_enemy", "domain", 0)
			# 减速30%
			enemy.speed_multiplier = DOMAIN_SLOW_FACTOR
			enemy.jump_reduction = DOMAIN_SLOW_FACTOR
			# 技能冷却增加2秒（一次性，不可叠加）
			if not comp.domain_enemy_debuffed:
				for s in enemy.skills:
					s.cd += SKILL_CD_ADJUST
				comp.domain_enemy_debuffed = true
		else:
			# 敌人离开领域 → 恢复速度
			enemy.speed_multiplier = 1.0
			enemy.jump_reduction = 1.0

## 移除领域弹射物
static func _remove_domain_projectile(comp: BardComponent):
	if comp._domain_projectile and not comp._domain_projectile.is_empty():
		GameWorld.projectiles.erase(comp._domain_projectile)
		comp._domain_projectile = {}

## 加权随机选音符：未收集的音符权重 ×5，促进补全
static func _pick_note(comp: BardComponent) -> Dictionary:
	if comp._confusion_active or comp._collected_notes.size() == 0:
		return NOTE_TYPES[randi() % NOTE_TYPES.size()]

	var weights = []
	var total_weight = 0.0
	for nt in NOTE_TYPES:
		var w = 5.0 if not nt["id"] in comp._collected_notes else 1.0
		weights.append(w)
		total_weight += w

	var r = randf() * total_weight
	var accum = 0.0
	for i in range(NOTE_TYPES.size()):
		accum += weights[i]
		if r < accum:
			return NOTE_TYPES[i]
	return NOTE_TYPES[-1]

## 每帧更新：演奏 + 音符命中 + 收集 + 紊乱
static func update_systems(f: Fighter):
	if f.hp <= 0:
		_handle_perform_audio(f, false)
		return
	var comp: BardComponent = f.components.get_component("bard") if f.components else null
	if not comp:
		return

	if comp.perform_active:
		# 受击时退出演奏状态，恢复待机贴图
		if f.damage_flash > 0:
			comp.perform_active = false
			f.image_state = ""
			f.set_animation_state("idle")
		else:
			f.energy = minf(f.max_energy, f.energy + f.energy_regen)

	# 技能1：我含泪而笑 — 波次定时发射
	if comp.skill1_active:
		comp.skill1_wave_timer -= 1
		if comp.skill1_wave_timer <= 0:
			comp.skill1_wave_index += 1
			if comp.skill1_wave_index >= 3:
				comp.skill1_active = false
				if f.image_state == "skill1":
					f.image_state = ""
			else:
				_fire_skill1_wave(f, comp)
				comp.skill1_wave_timer = SKILL1_WAVE_INTERVAL

	# 动画帧推进（多帧动画需要每帧 update）
	if f.current_anim:
		f.current_anim.update(1.0)

	_handle_perform_audio(f, comp.perform_active if comp else false)
	_update_note_hits(comp)
	_update_skill1_hits(comp)
	_update_domain(comp, f)
	_update_ult(comp, f)
	_update_confusion_display(comp)
	_update_easter_egg(comp)

## 彩蛋：显示指定文本（屏幕正上方，金色，2秒消失）
static func _show_easter_egg(comp: BardComponent, text: String):
	comp.easter_egg_text = text
	comp.easter_egg_timer = EGG_DURATION

static func _update_easter_egg(comp: BardComponent):
	if comp.easter_egg_timer <= 0:
		GameWorld.unregister_draw_effect("bard_easter_egg")
		return
	comp.easter_egg_timer -= 1
	var alpha = 1.0 if comp.easter_egg_timer > 30 else comp.easter_egg_timer / 30.0
	var txt = comp.easter_egg_text
	GameWorld.register_draw_effect("bard_easter_egg", func(font, _cam_x, _cam_y = 0.0):
		return [{"type": "string", "text": txt,
			"pos": Vector2(400, 30),
			"size": 16, "color": Color(1.0, 0.84, 0.0, alpha)}]
	, 0)

## 大招：胜过天上的星辰 — 逐帧出伤
static func _update_ult(comp: BardComponent, f: Fighter):
	if not comp.ult_active:
		return
	# 前19帧每帧 0.217s，出伤窗口 = 19 × 0.217s × 60fps
	const DAMAGE_FRAMES := int(ULT_DAMAGE_FRAME * ULT_FRAME_DUR * 60)  # ≈247
	const DAMAGE_PER_TICK := ULT_TOTAL_DAMAGE / float(DAMAGE_FRAMES)

	comp.ult_timer += 1
	# 出伤窗口：前19帧动画期间
	if comp.ult_timer <= DAMAGE_FRAMES:
		comp.ult_damage_acc += DAMAGE_PER_TICK
		var dmg = floor(comp.ult_damage_acc)
		if dmg > 0:
			var enemy = GameWorld.get_opponent(f)
			if enemy and enemy.hp > 0:
				Fighter.apply_damage(enemy, float(dmg), f, false, Color(0.3, 0.6, 1.0), "hit_enemy", "ult", 0)
			comp.ult_damage_acc -= dmg

	# overlay 动画结束后由 on_finish 回调清理 ult_active

## 检测音符命中 → 收集 + 触发紊乱
static func _update_note_hits(comp: BardComponent):
	# 检测追踪的弹射物是否已消失（命中）
	if comp._tracked_note and not comp._tracked_note.is_empty():
		var found = false
		for p in GameWorld.projectiles:
			if p == comp._tracked_note:
				found = true
				break
		if not found:
			# 弹射物消失 → 判断是否命中敌人（距离 < 80px 判定为命中）
			var pos_x = comp._tracked_note.get("x", 0.0) + comp._tracked_note.get("w", 24.0) / 2.0
			var pos_y = comp._tracked_note.get("y", 0.0) + comp._tracked_note.get("h", 24.0) / 2.0
			var enemy = GameWorld.get_opponent(comp.owner)
			var did_hit = enemy and enemy.hp > 0 and absf(pos_x - enemy.pos_x - enemy.w / 2.0) < 80.0
			
			if did_hit:
				# 命中特效
				if comp._tracked_hit_img:
					_note_hits.append({
						"img": comp._tracked_hit_img, "x": pos_x, "y": pos_y,
						"timer": NOTE_HIT_DURATION,
					})
				# 收集音符（每种只收集一次）
				var note_id = comp._tracked_note_id
				if note_id != "" and not note_id in comp._collected_notes and not comp._confusion_active:
					comp._collected_notes.append(note_id)
					if comp._collected_notes.size() >= 5:
						comp._confusion_active = true
						comp._confusion_timer = CONFUSION_DURATION
						comp._confused_enemy = enemy
						Fighter.emit_particles(enemy.pos_x + enemy.w / 2.0, enemy.pos_y + enemy.h / 2.0, 60, Color(1.0, 0.3, 0.6, 0.3), 8, 10, "star", 1.5)
			comp._tracked_note = {}
			comp._tracked_hit_img = null

	# 更新命中特效计时器
	var to_remove := []
	for fx in _note_hits:
		fx["timer"] -= 1
		if fx["timer"] <= 0:
			to_remove.append(fx)
	for fx in to_remove:
		_note_hits.erase(fx)

## 检测技能1声波命中 → 3段全中触发紊乱
static func _update_skill1_hits(comp: BardComponent):
	if comp.skill1_hits >= 3:
		return
	var to_remove := []
	for tracked_wave in comp._skill1_tracked_waves:
		var found = false
		for p in GameWorld.projectiles:
			if p == tracked_wave:
				found = true
				break
		if not found:
			# 弹射物消失 → 判断是否命中敌人（距离 < 100px 判定为命中）
			var pos_x = tracked_wave.get("x", 0.0) + tracked_wave.get("w", 120.0) / 2.0
			var pos_y = tracked_wave.get("y", 0.0) + tracked_wave.get("h", 120.0) / 2.0
			var enemy = GameWorld.get_opponent(comp.owner)
			var did_hit = enemy and enemy.hp > 0 and absf(pos_x - enemy.pos_x - enemy.w / 2.0) < 100.0
			if did_hit:
				comp.skill1_hits += 1
				if comp.skill1_hits >= 3 and not comp._confusion_active:
					# 三段全中 → 直接触发紊乱
					comp._confusion_active = true
					comp._confusion_timer = CONFUSION_DURATION
					comp._confused_enemy = enemy
					Fighter.emit_particles(enemy.pos_x + enemy.w / 2.0, enemy.pos_y + enemy.h / 2.0, 60, Color(1.0, 0.3, 0.6, 0.3), 8, 10, "star", 1.5)
			to_remove.append(tracked_wave)
	for tw in to_remove:
		comp._skill1_tracked_waves.erase(tw)

## 屏幕底部：收集音符显示 + 紊乱状态
static func _update_confusion_display(comp: BardComponent):
	if comp._confusion_active:
		var remaining = comp._confusion_timer
		GameWorld.register_draw_effect("bard_confusion", func(_font, cam_x, _cam_y = 0.0):
			var items := []
			var start_x = 400.0 - (comp._collected_notes.size() * COLLECTED_ICON_SIZE) / 2.0
			for i in range(comp._collected_notes.size()):
				var nid = comp._collected_notes[i]
				var img = _get_note_img_by_id(nid)
				if img:
					var alpha = 0.5 + 0.5 * sin(GameWorld.frame * 0.1 + i)
					items.append({"type": "tex", "tex": img,
						"rect": Rect2(start_x + i * COLLECTED_ICON_SIZE, COLLECTED_ICON_Y, COLLECTED_ICON_SIZE, COLLECTED_ICON_SIZE),
						"color": Color(1, 1, 1, alpha)})
			# 紊乱状态文字
			if remaining > 0:
				var secs = ceil(remaining / 60.0)
				items.append({"type": "string", "text": "紊乱 " + str(secs) + "s",
					"pos": Vector2(400, COLLECTED_ICON_Y + 30),
					"size": 12, "color": Color(1.0, 0.3, 0.6, 0.9 + 0.1 * sin(GameWorld.frame * 0.05))})
			return items
		, 0)
	elif comp._collected_notes.size() > 0:
		GameWorld.register_draw_effect("bard_confusion", func(_font, cam_x, _cam_y = 0.0):
			var items := []
			var start_x = 400.0 - (comp._collected_notes.size() * COLLECTED_ICON_SIZE) / 2.0
			for i in range(comp._collected_notes.size()):
				var nid = comp._collected_notes[i]
				var img = _get_note_img_by_id(nid)
				if img:
					items.append({"type": "tex", "tex": img,
						"rect": Rect2(start_x + i * COLLECTED_ICON_SIZE, COLLECTED_ICON_Y, COLLECTED_ICON_SIZE, COLLECTED_ICON_SIZE),
						"color": Color(1, 1, 1, 0.7)})
			return items
		, 0)
	else:
		GameWorld.unregister_draw_effect("bard_confusion")

## 紊乱全局更新（在 game.gd 帧末调用，AI/物理之后执行方向反转）
static func update_global():
	var player = GameWorld.player
	if not player or player.hp <= 0:
		return
	var comp: BardComponent = player.components.get_component("bard") if player.components else null
	if not comp:
		return

	# 紊乱计时 + 方向反转
	if comp._confusion_active and comp._confusion_timer > 0:
		comp._confusion_timer -= 1
		var enemy = comp._confused_enemy
		if enemy and enemy.hp > 0:
			enemy.vx = -enemy.vx
			enemy.facing = -enemy.facing
		if comp._confusion_timer <= 0:
			comp._confusion_active = false
			comp._collected_notes.clear()
			comp._confused_enemy = null
			GameWorld.unregister_draw_effect("bard_confusion")

static func _get_note_img_by_id(nid: String) -> Texture2D:
	for nt in NOTE_TYPES:
		if nt["id"] == nid:
			return nt["note_img"]
	return null

static func _handle_perform_audio(f: Fighter, active: bool):
	var comp: BardComponent = f.components.get_component("bard") if f.components else null
	if not comp: return
	if active and not comp._was_perform_active:
		AudioManager.play_loop("bard_perform")
	elif not active and comp._was_perform_active:
		AudioManager.stop_loop("bard_perform")
	comp._was_perform_active = active

# ===== 地狱模式 AI（由 AISystem 通过 CharacterFactory 调度，配置驱动） =====

## 地狱模式 AI 战术钩子
## ctx 字段: target / dist / dir / rand / diff / player / skill1 / skill2 / ult / can_use_s1 / can_use_s2 / can_use_ult
## 返回已处理的状态（"ATTACK"/"DODGE"/"DEFEND"），返回 "" 表示未处理走默认 AI
static func ai_hell_tactics(f: Fighter, ctx: Dictionary) -> String:
	var comp: BardComponent = f.components.get_component("bard") if f.components else null
	if not comp:
		return ""
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

	# ① 玩家贴脸逼近 + 低音领域冷却好 → 开领域减速压制
	if can_use_s2 and not comp.skill2_active and player and player.hp > 0 and dist < 180 and rand < 0.6:
		f.facing = dir
		skill2.try_use(f)
		return "ATTACK"

	# ② 玩家残血 → 大招斩杀（全屏 40 伤）
	if can_use_ult and player and player.hp > 0 and player.hp < player.max_hp * 0.45 and dist < 500:
		f.facing = dir
		ult.try_use(f)
		return "ATTACK"

	# ③ 同水平线 + 中距离 → 普攻音符风筝（需能量 5）
	if dist < 350 and f.energy >= 5 and f.attack_cooldown <= 0 and not f.attacking:
		f.facing = dir
		f.energy -= 5
		_fire_note(f, comp)
		f.attacking = true; f.attack_timer = 30; f.attack_delay = 8
		f.attack_hit_dealt = false; f.attack_cooldown = 120
		f.state = "attack"
		return "ATTACK"

	# ④ 中距离 → 三段声波连招（三中触发紊乱）
	if can_use_s1 and not comp.skill1_active and dist < 260 and rand < 0.35:
		f.facing = dir
		skill1.try_use(f)
		return "ATTACK"

	return ""

## 地狱模式专属走位参数（空字典表示不覆盖）
static func ai_hell_desire(f: Fighter) -> Dictionary:
	return {"min": 200, "max": 380}
