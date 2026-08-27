# 唤魔者 (evoker)
class_name EvokerCharacter

const EvokerComponent = preload("res://scripts/components/evoker_component.gd")

# Draw preloads (从 game.gd 迁移至此)
const EVOKER_SERVANT1 = preload("res://assets/fx_evoker_servant1.png")
const EVOKER_SERVANT2_IDLE = preload("res://assets/fx_evoker_servant2_idle.png")
const EVOKER_SERVANT2_HEAVY = preload("res://assets/fx_evoker_servant2_heavy.png")
const EVOKER_SERVANT2_SKILL = preload("res://assets/fx_evoker_servant2_skill.png")
const EVOKER_SERVANT3 = preload("res://assets/fx_evoker_servant3.png")
const EVOKER_FIRE_SEA = preload("res://assets/fx_evoker_fire_sea.png")
const EVOKER_PULL_BALL = preload("res://assets/fx_evoker_pull_ball.png")
const EVOKER_ULT_CRACK = preload("res://assets/fx_evoker_ult_crack.png")

const PROJ_FIREBALL = preload("res://assets/fx_fireball.png")
const EVOKER_ANI_DIR = "res://assets/char_ani/evoker/"
const EVOKER_SKILL2_SHEET = "res://assets/char_ani/evoker/idle/skill2/sheet.png"
const EVOKER_SUMMON2_SKILL_SHEET = "res://assets/sheet_skeleton.png"
const EVOKER_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/evoker_idle_foot_gaps.gd")
const EVOKER_ATTACK_FOOT_GAPS = preload("res://data/foot_gaps/evoker_attack_foot_gaps.gd")

# ── 绘制注入（每局游戏开始时重新注册）──
static func _inject_draw():
	GameWorld.register_draw_effect("evoker_all", func(font, cam_x, _cam_y = 0.0):
		var items: Array = []
		for s in GameWorld.evoker_summons:
			var sx = s["x"] - cam_x
			var tex = null
			match s["type"]:
				0: tex = EVOKER_SERVANT1
				1:
					# 骷髅 sheet 动画：待机(格1-2循环)/重击/魔令(格3-18挥镰) 都用动画当前帧
					var s2_anim: FrameAnimation = s.get("anim")
					if s2_anim:
						tex = s2_anim.get_current_texture()
					elif s.get("action_timer", 0) > 0 and s.get("action_type") == "heavy":
						tex = EVOKER_SERVANT2_HEAVY
					elif s.get("action_timer", 0) > 0 and s.get("action_type") == "skill":
						tex = EVOKER_SERVANT2_SKILL
					else:
						tex = EVOKER_SERVANT2_IDLE
				2: tex = EVOKER_SERVANT3
			if tex:
				var owner = s.get("owner")
				var face_dir = 1
				if owner:
					var enemy = GameWorld.get_opponent(owner)
					if enemy:
						face_dir = 1 if (enemy.pos_x + enemy.w/2) > (s["x"] + s["w"]/2) else -1
					else:
						face_dir = owner.facing
				items.append({"type": "set_transform", "pos": Vector2(sx + s["w"]/2, s["y"]+s["h"]/2 - _cam_y), "scale": Vector2(-face_dir, 1)})
				items.append({"type": "tex", "tex": tex, "rect": Rect2(-s["w"]/2, -s["h"]/2, s["w"], s["h"])})
				items.append({"type": "reset_transform"})
			var hp_pct = s.get("hp", 0) / maxf(s.get("max_hp", 1), 1.0)
			items.append({"type": "rect", "rect": Rect2(sx, s["y"]-10 - _cam_y, s["w"], 6), "color": Color(0.2, 0.2, 0.2)})
			var hc = Color.GREEN if hp_pct > 0.5 else (Color.ORANGE if hp_pct > 0.25 else Color.RED)
			items.append({"type": "rect", "rect": Rect2(sx, s["y"]-10 - _cam_y, s["w"]*hp_pct, 6), "color": hc})
			items.append({"type": "string", "pos": Vector2(sx+s["w"]/2, s["y"]-16 - _cam_y), "text": s.get("state",""), "size": 10, "color": Color.WHITE})
		for fs in GameWorld.evoker_fire_seas:
			var fs_anim: FrameAnimation = fs.get("anim")
			var fs_tex: Texture2D = EVOKER_FIRE_SEA if fs_anim == null else fs_anim.get_current_texture()
			if not fs_tex:
				continue
			var fs_w: float = fs["w"]
			var fs_h: float = fs["h"]
			var f_fx: float = fs["x"] - cam_x
			var f_fy: float = fs["y"] + 60 - _cam_y
			var f_dw: float = fs_w
			var f_dh: float = fs_h
			if fs_anim:
				# 动画火海：整格贴图按宽度缩放；火焰内容底边在格内约 590/768 处，
				# 将其对齐火海矩形底部（贴近地面），火焰从地面升起（整体下移 50px）
				var f_scale: float = fs_w / maxf(float(fs_tex.get_width()), 1.0)
				f_dw = fs_tex.get_width() * f_scale
				f_dh = fs_tex.get_height() * f_scale
				f_fx = fs["x"] + fs_w / 2.0 - f_dw / 2.0 - cam_x
				f_fy = fs["y"] + fs_h - f_dh * (590.0 / 768.0) - _cam_y + 50.0
			items.append({"type": "tex", "tex": fs_tex, "rect": Rect2(f_fx, f_fy, f_dw, f_dh), "color": Color(1,1,1,0.7)})
		for b in GameWorld.gravity_balls:
			items.append({"type": "tex", "tex": EVOKER_PULL_BALL, "rect": Rect2(b["x"]-cam_x, b["y"] - _cam_y, b["w"], b["h"])})
		for rift in GameWorld.void_rifts:
			var r_anim: FrameAnimation = rift.get("anim")
			var r_tex: Texture2D = EVOKER_ULT_CRACK if r_anim == null else r_anim.get_current_texture()
			if r_tex:
				if r_anim:
					# 动画裂隙：整格按 200px 宽绘制，居中于裂隙中心（动画代替原静态贴图）
					var r_scale: float = 200.0 / maxf(float(r_tex.get_width()), 1.0)
					var r_dw: float = r_tex.get_width() * r_scale
					var r_dh: float = r_tex.get_height() * r_scale
					var r_fx: float = rift["x"] + rift["w"] / 2.0 - r_dw / 2.0 - cam_x
					var r_fy: float = rift["y"] + rift["h"] / 2.0 - r_dh / 2.0 - _cam_y
					items.append({"type": "tex", "tex": r_tex, "rect": Rect2(r_fx, r_fy, r_dw, r_dh), "color": Color(1,1,1,0.8)})
				else:
					var rx = rift["x"] - cam_x
					items.append({"type": "tex", "tex": EVOKER_ULT_CRACK, "rect": Rect2(rx, rift["y"] - _cam_y, rift["w"], rift["h"]), "color": Color(1,1,1,0.7)})
			var pulse = sin(rift.get("timer",0)*0.1)*0.3+0.7
			items.append({"type": "rect", "rect": Rect2(rift["x"] - cam_x, rift["y"] - _cam_y, rift["w"], rift["h"]), "color": Color(0.784,0.392,1.0,pulse*0.8), "filled": false, "border_width": 3})
		return items
	, 10)

static func get_config() -> Dictionary:
	_inject_draw()
	return {
		"id": "evoker", "name": "唤魔者", "hp": 60, "max_energy": 140, "energy_regen": 0.083,
		"speed": 2.25, "attack_range": 44, "attack_damage": 4,
		"attack_cooldown": 0, "attack_delay": 8, "attack_duration": 30,
		"fields": {"last_summon_type":-1,"summon_dead1":false,"summon_dead2":false,"summon_dead3":false},
		"world_arrays": ["evoker_summons","void_rifts","evoker_fire_seas","gravity_balls","phantoms"],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(EVOKER_ANI_DIR + "idle/sheet.png", 4, 4, 15, 0.1, true, _evoker_idle_anchors()),
			"walk": FrameAnimation.load_from_sprite_sheet(EVOKER_ANI_DIR + "idle/sheet.png", 4, 4, 15, 0.08, true, _evoker_idle_anchors()),
			"jump": FrameAnimation.load_jump_sheet(EVOKER_ANI_DIR + "idle/sheet.png", 4, 4, 15, 0.3, _evoker_idle_anchors()),
			"attack": FrameAnimation.load_from_sprite_sheet(EVOKER_ANI_DIR + "attack/sheet.png", 3, 3, 8, 0.05, false, _evoker_attack_anchors()),
			"ult": FrameAnimation.load_from_frames(EVOKER_ANI_DIR + "ult/", "evoker_ult_f_", [{"index": 1, "duration": 3.0}], false),
		},
		"dex": {
			"icon": "🧙",
			"intro": "幽蓝的火焰自虚空燃起，焚尽凡俗，只留灰烬。他立于现世与深渊的交界，指尖跃动着来自异界的冷焰——每一簇蓝火都是魔物苏醒的指引，每一次召唤都是地狱的回响。魔物从阴影中爬出，服从他的意志，撕碎他的敌人。在他的领域里，你面对的不只是一个施法者，而是一支来自深渊的军团。\n\"死亡太廉价了——来见见我的收藏品吧。\"",
			"stats": [
				{"label": "生命", "value": "60"},
				{"label": "能量上限", "value": "140"},
				{"label": "能量恢复", "value": "5/秒"},
			],
			"skills": [
				{
					"name": "契约（特殊机制）",
					"desc": "与深渊签订契约，可操纵三种召唤物，场上最多同时存在 1 个。\n· 寂语之喉（1 号）：血量 60。\n· 哀恸枷锁（2 号）：血量 40。\n· 诅咒之眼（3 号）：血量 80。\n召唤物上场时以 3 点/秒缓慢恢复血量；除「随行」状态外可被敌人直接攻击，血量耗尽后死亡且无法再次召唤。\n唤魔者的普攻与技能2 会随当前召唤物而改变。\n\n召唤物被动：\n· 噤声（1 号）：当敌人与唤魔者处于 1 号的同一侧时，敌人造成的伤害减少 20%。\n· 摄魂（2 号）：处于 2 号附近的敌人能量以 5 点/秒的速度流失。\n· 凝视（3 号）：处于 3 号附近的敌人，技能1、技能2 的冷却时间增加 1 秒。",
					"meta": "被动 ｜ 召唤物上场回血 3/秒"
				},
				{
					"name": "冥炎弹 / 役使·随行 / 役使·猎杀（普攻）",
					"desc": "无召唤物 → 冥炎弹：抛出以抛物线飞行的冥炎弹，命中造成 4 伤害，附加减速 20%（持续 6 秒）与灼烧（每 2 秒 1 点，持续 6 秒）。消耗 10，冷却 2 秒。\n\n召唤物处于猎杀状态 → 役使·随行：召回召唤物回到身边并一同移动（移动速度与玩家一致），回归途中对沿途敌人造成 5 撞击伤害；随行期间唤魔者受到伤害的 60% 由召唤物承受。消耗 20，冷却 2 秒。\n\n召唤物处于随行状态 → 役使·猎杀：召唤物释放一次重击后进入猎杀状态（缓慢靠近敌人但不主动攻击）。消耗 20，冷却 3 秒。\n\n召唤物重击：\n· 1 号：以自身为中心释放蓝紫色空心圆冲击波，强力击飞周围敌人，伤害 10。\n· 2 号：向前突进用镰刀斩击敌人，伤害 10。\n· 3 号：发射一枚缓慢飞行的引力球，持续吸附敌人并造成 3 点/秒伤害。",
					"meta": "消耗 10~20 ｜ 冷却 2~3 秒"
				},
				{
					"name": "深渊召令（技能一）",
					"desc": "随机召唤一个召唤物生成在身前，默认为「随行」状态；若场上已有召唤物则将其替换。\n连续两次召唤的召唤物不会重复，已死亡的召唤物不能被召唤。",
					"meta": "消耗 20 ｜ 冷却 5 秒"
				},
				{
					"name": "幽蓝之境 / 魔令（技能二）",
					"desc": "无召唤物 → 幽蓝之境：在脚下生成大范围火海（持续 4 秒），持续灼烧范围内敌人（5 点/秒）并造成 40% 减速。消耗 20，冷却 13 秒。\n\n有召唤物 → 魔令：命令召唤物释放技能。消耗 20，冷却 13 秒。\n· 1 号：释放大范围水平冲击波，命中眩晕敌人 2 秒（无法进行任何操作），伤害 15。\n· 2 号：大范围挥镰斩击，命中造成流血（释放时受到 3 伤害）并持续 5 秒，伤害 15。\n· 3 号：向前突进撞击，命中剥夺敌人视力，失明 3 秒，伤害 20。",
					"meta": "消耗 20 ｜ 冷却 13 秒"
				},
				{
					"name": "虚空裂隙（大招）",
					"desc": "献祭场上的召唤物，召唤物立刻死亡，其剩余血量转移到唤魔者身上。\n召唤物死亡处出现虚空裂隙，持续 4 秒，吸附并对范围内敌人造成 10 点/秒的大量伤害。",
					"meta": "消耗 100 ｜ 冷却 60 秒"
				},
			]
		},
	}

# ===== 多帧 sheet 动画锚点（由 scan_feet_offsets.py 数据组装）=====
static func _evoker_idle_anchors() -> Array:
	var anchors: Array = []
	for i in range(EVOKER_IDLE_FOOT_GAPS.EVOKER_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": EVOKER_IDLE_FOOT_GAPS.EVOKER_IDLE_FOOT[i],
			"head_gap": EVOKER_IDLE_FOOT_GAPS.EVOKER_IDLE_HEAD[i],
			"center_dx": EVOKER_IDLE_FOOT_GAPS.EVOKER_IDLE_CENTER[i],
			"content_w": EVOKER_IDLE_FOOT_GAPS.EVOKER_IDLE_CONTENT_W[i],
			"content_h": EVOKER_IDLE_FOOT_GAPS.EVOKER_IDLE_CONTENT_H[i],
		})
	return anchors

static func _evoker_attack_anchors() -> Array:
	var anchors: Array = []
	for i in range(EVOKER_ATTACK_FOOT_GAPS.EVOKER_ATTACK_FOOT.size()):
		anchors.append({
			"foot_gap": EVOKER_ATTACK_FOOT_GAPS.EVOKER_ATTACK_FOOT[i],
			"head_gap": EVOKER_ATTACK_FOOT_GAPS.EVOKER_ATTACK_HEAD[i],
			"center_dx": EVOKER_ATTACK_FOOT_GAPS.EVOKER_ATTACK_CENTER[i],
			"content_w": EVOKER_ATTACK_FOOT_GAPS.EVOKER_ATTACK_CONTENT_W[i],
			"content_h": EVOKER_ATTACK_FOOT_GAPS.EVOKER_ATTACK_CONTENT_H[i],
		})
	return anchors

# Helper: find the owner's summon in GameWorld.evoker_summons
static func _get_summon(owner: Fighter) -> Dictionary:
	for s in GameWorld.evoker_summons:
		if s.get("owner") == owner:
			return s
	return {}

# canUse helpers (separate functions for clarity)
static func _can_attack(owner: Fighter) -> bool:
	if owner.attack_cooldown > 0 or owner.attacking:
		return false
	var s = _get_summon(owner)
	var cost: int = 20 if not s.is_empty() else 10
	return owner.energy >= cost

static func _can_skill1(owner: Fighter) -> bool:
	if owner.energy < 20:
		return false
	var comp: EvokerComponent = owner.components.get_component("evoker") if owner.components else null
	if not comp:
		return true
	if not comp.summon_dead1 or not comp.summon_dead2 or not comp.summon_dead3:
		return true
	return false

static func _can_ult(owner: Fighter) -> bool:
	if owner.energy < 100:
		return false
	var s = _get_summon(owner)
	return not s.is_empty() and s.get("hp", 0) > 0

static func create_skills() -> Array:
	return [
		Skill.new("attack", "冥炎弹/役使", 0, 0, Callable(_can_attack), Callable(_attack)),
		Skill.new("skill1", "深渊召令", 300, 20, Callable(_can_skill1), Callable(_skill1)),
		Skill.new("skill2", "幽蓝之境/魔令", 780, 20, func(owner: Fighter): return owner.energy >= 20, Callable(_skill2)),
		Skill.new("ult", "虚空裂隙", 3600, 100, Callable(_can_ult), Callable(_ult)),
	]

# ===== 普攻：冥炎弹 / 役使·随行 / 役使·猎杀 =====
static func _attack(owner: Fighter) -> Dictionary:
	var summon = _get_summon(owner)

	if summon.is_empty():
		# ---- 冥炎弹 ----
		owner.energy -= 10
		owner.attack_cooldown = 120
		owner.attacking = true
		owner.attack_timer = 30
		owner.set_animation_state("attack")
		# 火球不在起手瞬间生成：等普攻动画播到投掷帧（第 5 帧）再由 update_systems 出手
		owner.set_meta("evoker_fire_pending", true)
		return {"success": true}

	# ---- 有召唤物 ----
	if summon["state"] == "猎杀":
		# 役使·随行
		owner.energy -= 20
		owner.attack_cooldown = 120
		summon["state"] = "回归"
		summon["hit_enemies"] = []
		Fighter.emit_particles(summon["x"], summon["y"], 8, Color(0.4, 0.8, 1.0), 2, 10)
		return {"success": true}

	if summon["state"] == "随行":
		# 役使·猎杀
		owner.energy -= 20
		owner.attack_cooldown = 180
		_perform_heavy_attack(summon)
		if summon["state"] == "随行":
			summon["state"] = "猎杀"
		return {"success": true}

	return {"success": false}

## 生成冥炎弹（普攻动画第 5 帧投掷出手时调用，与画面同步）
static func _fire_fireball(owner: Fighter):
	var fire_x = owner.pos_x + (30.0 if owner.facing > 0 else -30.0)
	var fire_y = owner.pos_y + 20.0
	GameWorld.projectiles.append({
		"x": fire_x, "y": fire_y,
		"w": 24.0, "h": 24.0,
		"vx": 5.0 * owner.facing, "vy": -2.5,
		"life": 90,
		"damage": 4.0,
		"owner": owner,
		"type": "evoker_fireball",
		"color": Color(1.0, 0.533, 0.0),
		"reflected": false,
		"gravity": 0.15,
		"img": PROJ_FIREBALL,
		"slowDuration": 360,
		"burnDuration": 360,
	})
	Fighter.emit_particles(fire_x, fire_y, 10, Color(1.0, 0.533, 0.0), 3, 6)

# ---- Heavy attack by summon type (triggered by 役使·猎杀) ----
static func _perform_heavy_attack(summon: Dictionary):
	var owner: Fighter = summon["owner"]
	var enemy: Fighter = GameWorld.get_opponent(owner)
	if not enemy:
		return

	summon["action_type"] = "heavy"
	GameWorld.trigger_shake(10.0, 12)  # 召唤物重击释放：屏幕中等震动
	var st: int = summon["type"]
	var cx: float = summon["x"] + summon["w"] / 2.0
	var cy: float = summon["y"] + summon["h"] / 2.0

	match st:
		0:
			# 1号：蓝紫色空心圆形冲击波
			var dx = enemy.pos_x + enemy.w / 2.0 - cx
			var dy = enemy.pos_y + enemy.h / 2.0 - cy
			var dist = sqrt(dx * dx + dy * dy)
			if dist < 100.0:
				var angle = atan2(dy, dx)
				Fighter.apply_damage(enemy, 10, owner, false)
				enemy.vx = cos(angle) * 12.0
				enemy.vy = -6.0
				Fighter.emit_particles(cx, cy, 30, Color(0.667, 0.533, 1.0), 6, 20, "star")
			summon["action_timer"] = 20
			summon["state"] = "猎杀"

		1:
			# 2号：向前突进斩（16 帧挥镰动画，0.05s/帧 ≈ 0.8s）
			summon["state"] = "突进"
			var dir_to_enemy: float = signf(enemy.pos_x - summon["x"])
			summon["dash_dir"] = int(dir_to_enemy) if dir_to_enemy != 0 else owner.facing
			summon["dash_timer"] = 16
			summon["dash_hit"] = false
			summon["vx"] = 0.0
			summon["vy"] = 0.0
			summon["action_timer"] = 48
			var h_anim: FrameAnimation = _servant2_skill_anim()
			h_anim.play()  # 必须 play，否则 update() 不推进帧
			summon["anim"] = h_anim

		2:
			# 3号：发射引力球
			var dir: float = signf(enemy.pos_x - summon["x"])
			if dir == 0:
				dir = float(owner.facing)
			GameWorld.gravity_balls.append({
				"x": summon["x"] + (summon["w"] if dir > 0 else -20.0),
				"y": summon["y"] + 10.0,
				"w": 30.0, "h": 30.0,
				"vx": 1.5 * dir,
				"vy": 0.0,
				"life": 180,
				"owner": owner,
				"attract_radius": 120.0,
				"damage_timer": 0,
			})
			summon["action_timer"] = 20
			summon["state"] = "猎杀"

# ===== 技能1：深渊召令 =====
static func _skill1(owner: Fighter) -> Dictionary:
	var comp: EvokerComponent = owner.components.get_component("evoker") if owner.components else null
	
	# Find available types (not dead)
	var available = []
	if comp:
		if not comp.summon_dead1: available.append(0)
		if not comp.summon_dead2: available.append(1)
		if not comp.summon_dead3: available.append(2)
	else:
		available = [0, 1, 2]
	if available.is_empty():
		return {"success": false}

	# Exclude last summoned type if possible
	var exclude = comp.last_summon_type if comp else -1
	var filtered = []
	for t in available:
		if t != exclude:
			filtered.append(t)
	if filtered.is_empty():
		filtered = available  # only the last type is available, allow re-summon

	var type_id: int = filtered[randi() % filtered.size()]

	# Remove existing summon (not marking dead) — iterate backwards
	for i in range(GameWorld.evoker_summons.size() - 1, -1, -1):
		if GameWorld.evoker_summons[i].get("owner") == owner:
			GameWorld.evoker_summons.remove_at(i)

	# Spawn new summon in front of owner
	var spawn_x: float = owner.pos_x + (60.0 if owner.facing > 0 else -60.0)
	var spawn_y: float = owner.pos_y + 10.0
	var max_hps = [60.0, 40.0, 80.0]
	GameWorld.evoker_summons.append({
		"type": type_id,
		"owner": owner,
		"hp": float(max_hps[type_id]),
		"max_hp": float(max_hps[type_id]),
		"state": "随行",
		"x": spawn_x, "y": spawn_y,
		"w": 40.0, "h": 40.0,
		"vx": 0.0, "vy": 0.0,
		"hit_enemies": [],
		"action_timer": 0,
		"action_type": "",
		"anim": null,
		"flash_timer": 0,
		"hit_cd": 0,
		"dash_dir": 1,
		"dash_timer": 0,
		"dash_hit": false,
	})

	# 召唤物2：挂载骷髅 sheet 待机动画（格 1..2 循环），重击/魔令时临时切换到挥镰动画
	if type_id == 1:
		var s2_idle: FrameAnimation = _servant2_idle_anim()
		s2_idle.play()
		var s2_ref: Dictionary = GameWorld.evoker_summons[GameWorld.evoker_summons.size() - 1]
		s2_ref["anim"] = s2_idle
		s2_ref["idle_anim"] = s2_idle

	if comp:
		comp.last_summon_type = type_id

	var summon_colors = [
		Color(0.541, 0.169, 0.886),
		Color(1.0, 0.271, 0.0),
		Color(0.196, 0.804, 0.196),
	]
	Fighter.emit_particles(spawn_x, spawn_y, 20, summon_colors[type_id], 4, 15)
	return {"success": true}

# ===== 技能2：幽蓝之境 / 魔令 =====
static func _skill2(owner: Fighter) -> Dictionary:
	var summon = _get_summon(owner)

	if summon.is_empty():
		# ---- 幽蓝之境：在脚下生成大范围火海（16 帧火焰动画循环，火海持续期间持续燃烧）----
		var sea_anim = FrameAnimation.load_from_sprite_sheet(EVOKER_SKILL2_SHEET, 4, 4, 16, 0.1, true)
		sea_anim.play()  # 必须 play，否则 update() 不推进帧
		GameWorld.evoker_fire_seas.append({
			"x": owner.pos_x - 100.0,
			"y": owner.pos_y - 40.0,
			"w": 200.0, "h": 80.0,
			"timer": 0,
			"duration": 240,
			"owner": owner,
			"anim": sea_anim,
		})
		Fighter.emit_particles(owner.pos_x, owner.pos_y, 30, Color(0.267, 0.533, 1.0), 5, 20)
		return {"success": true}
	else:
		# ---- 魔令：命令召唤物释放技能 ----
		_perform_summon_skill(summon)
		return {"success": true}

# ---- Summon skill by type (triggered by 魔令) ----
## 加载召唤物2（哀恸枷锁）待机动画：sheet 格 1..2 共 2 帧循环（站姿）
static func _servant2_idle_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(EVOKER_SUMMON2_SKILL_SHEET, 5, 4, 2, 0.5, true)
	return anim

## 加载召唤物2（哀恸枷锁）挥镰技能动画：sheet 5x4 网格，格 3..18 共 16 帧（前 2 格为待机不入动画）
static func _servant2_skill_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(EVOKER_SUMMON2_SKILL_SHEET, 5, 4, 18, 0.05, false)
	if anim.frames.size() >= 3:
		anim.frames = anim.frames.slice(2, 18)  # 保留格 3..18 共 16 帧
		anim._calc_total_duration()
	return anim

static func _perform_summon_skill(summon: Dictionary):
	var owner: Fighter = summon["owner"]
	var enemy: Fighter = GameWorld.get_opponent(owner)
	if not enemy:
		return

	summon["action_type"] = "skill"
	var st: int = summon["type"]
	var cx: float = summon["x"] + summon["w"] / 2.0
	var cy: float = summon["y"] + summon["h"] / 2.0

	match st:
		0:
			# 1号：水平冲击波，伤害15，眩晕2秒（frozen 120帧）
			var dx = enemy.pos_x + enemy.w / 2.0 - cx
			var dy = enemy.pos_y + enemy.h / 2.0 - cy
			if abs(dy) < 40.0 and abs(dx) < 120.0:
				Fighter.apply_damage(enemy, 15, owner, true)
				enemy.add_status("frozen")
				for s in enemy.statuses:
					if s.id == "frozen":
						s.timer = 120
				Fighter.emit_particles(cx, cy, 25, Color(0.4, 0.267, 1.0), 5, 20)
			summon["action_timer"] = 20

		1:
			# 2号：大范围斩击，伤害15+3，流血5秒（16 帧挥镰动画，0.05s/帧 ≈ 0.8s）
			var dx2 = enemy.pos_x + enemy.w / 2.0 - cx
			var dy2 = enemy.pos_y + enemy.h / 2.0 - cy
			var dist2 = sqrt(dx2 * dx2 + dy2 * dy2)
			if dist2 < 90.0:
				Fighter.apply_damage(enemy, 15, owner, true)
				Fighter.apply_damage(enemy, 3, owner, false)
				enemy.bleed_timer = 300
				Fighter.emit_particles(cx, cy, 30, Color(1.0, 0.2, 0.2), 6, 20)
			summon["action_timer"] = 48
			var s2_anim: FrameAnimation = _servant2_skill_anim()
			s2_anim.play()  # 必须 play，否则 update() 不推进帧
			summon["anim"] = s2_anim

		2:
			# 3号：突进撞击（瞬移），伤害20，失明3秒
			var dx3 = enemy.pos_x + enemy.w / 2.0 - cx
			var dy3 = enemy.pos_y + enemy.h / 2.0 - cy
			var dist3 = sqrt(dx3 * dx3 + dy3 * dy3)
			if dist3 < 120.0:
				var target_x = enemy.pos_x + enemy.w / 2.0 - summon["w"] / 2.0
				var target_y = enemy.pos_y + enemy.h / 2.0 - summon["h"] / 2.0
				summon["x"] = target_x
				summon["y"] = target_y
				Fighter.apply_damage(enemy, 20, owner, true)
				enemy.blind_timer = 180
				Fighter.emit_particles(target_x + summon["w"] / 2.0, target_y + summon["h"] / 2.0, 30, Color(0.533, 1.0, 0.533), 5, 20)
			summon["action_timer"] = 20

# ===== 大招：虚空裂隙 =====
static func _ult(owner: Fighter) -> Dictionary:
	# 防重复（裂隙存在期间不可重复释放）
	for rift in GameWorld.void_rifts:
		if rift.get("owner") == owner:
			return {"success": false}
	var summon = _get_summon(owner)
	if summon.is_empty() or summon.get("hp", 0) <= 0:
		return {"success": false}

	# 献祭召唤物：剩余血量转移给唤魔者
	var transferred: int = int(summon["hp"])
	var heal: float = minf(float(transferred), owner.max_hp - owner.hp)
	Fighter.try_heal(owner, heal)

	# 标记召唤物类型死亡
	var comp: EvokerComponent = owner.components.get_component("evoker") if owner.components else null
	if comp:
		match summon["type"]:
			0: comp.summon_dead1 = true
			1: comp.summon_dead2 = true
			2: comp.summon_dead3 = true

	# 记录召唤物位置（裂隙/法阵生成在死亡处）
	var fx: float = summon["x"] + summon["w"] / 2.0
	var fy: float = summon["y"] + summon["h"] / 2.0

	# 移除召唤物
	for i in range(GameWorld.evoker_summons.size() - 1, -1, -1):
		if GameWorld.evoker_summons[i].get("owner") == owner:
			GameWorld.evoker_summons.remove_at(i)

	# 虚空裂隙：动画即裂隙视觉（代替原静态贴图），无时停，
	# 裂隙存在期间由 _update_void_rifts 持续「抓取 + 吸附 + 伤害」
	var ult_anim = _load_ult_anim()
	if ult_anim.frames.is_empty():
		ult_anim = null  # 动画资源异常时退回静态裂隙贴图
	_spawn_rift(owner, fx, fy, ult_anim)
	if ult_anim:
		ult_anim.play()  # 必须 play，否则 update() 不推进帧
	GameWorld.trigger_shake(10.0, 12)  # 大招释放：屏幕中等震动

	# 抓取：裂隙范围内敌人被拉到裂隙中心并定身（参考 Fighter.grab_fighter_in_rect）
	var enemy: Fighter = GameWorld.get_opponent(owner)
	if enemy and enemy.hp > 0:
		var grab_rect := Rect2(fx - 220.0, enemy.pos_y - 100.0, 440.0, 200.0)
		if Fighter.grab_fighter_in_rect(owner, grab_rect, fx):
			Fighter.emit_particles(enemy.pos_x + enemy.w / 2.0, enemy.pos_y + enemy.h / 2.0, 20, Color(0.667, 0.267, 1.0), 5, 8, "star")
	Fighter.emit_particles(fx, fy, 50, Color(0.667, 0.267, 1.0), 8, 10, "star")
	return {"success": true}

## 在指定位置生成虚空裂隙（动画作为裂隙视觉；无动画时用静态贴图；持续抓取+吸附+伤害）
static func _spawn_rift(owner: Fighter, fx: float, fy: float, anim: FrameAnimation = null):
	GameWorld.void_rifts.append({
		"x": fx - 80.0,
		"y": fy - 60.0,
		"w": 160.0, "h": 120.0,
		"duration": int(anim.total_duration * 60) if anim else 240,
		"timer": 0,
		"owner": owner,
		"anim": anim,
	})

## 加载大招法阵动画（sheet.png 为 7x7 网格，前4格/后5格为空白帧，运行时剔除格 4..43 共 40 帧）
static func _load_ult_anim() -> FrameAnimation:
	var anim = FrameAnimation.load_from_sprite_sheet(EVOKER_ANI_DIR + "ult/sheet.png", 7, 7, 44, 0.1, false, [])
	if anim.frames.size() > 4:
		anim.frames = anim.frames.slice(4, 44)  # 保留格 4..43 共 40 帧
		if anim.frames.size() > 1:
			anim.frames[anim.frames.size() - 1].duration_seconds = 1.0
		anim._calc_total_duration()
	return anim

# ===== Per-fighter 状态更新（从 evoker_system.gd 迁移至此）=====
static func update_systems(f: Fighter):
	if f.char_id != "evoker" or f.hp <= 0.0:
		return
	# 多帧 sprite-sheet 动画每帧推进（与玫瑰等角色一致，否则只显示第一帧）
	if f.current_anim and f.current_anim.is_playing():
		f.current_anim.update(1.0)
	# 普攻冥炎弹：动画播到第 5 帧（投掷出手）时生成，与画面同步
	if f.attacking and f.get_meta("evoker_fire_pending", false):
		if f.current_anim and f.current_anim.get_current_index() >= 4:
			f.set_meta("evoker_fire_pending", false)
			_fire_fireball(f)
	# Slow timer
	if f.slow_timer > 0:
		f.slow_timer -= 1
		if f.slow_percent > 0.0:
			var max_spd: float = 2.25 * (1.0 - f.slow_percent)
			if absf(f.vx) > max_spd:
				f.vx = max_spd * signf(f.vx)
	# Burn timer — damage every 120 frames (2 seconds)
	# 龙鳞：龙骑士免疫一切灼烧效果
	if f.burn_timer > 0:
		f.burn_timer -= 1
		if f.char_id != "dragon_knight" and f.burn_timer % 120 == 0:
			f.hp -= 1.0
			if f.hp < 0.0:
				f.hp = 0.0
	# Bleed timer
	if f.bleed_timer > 0:
		f.bleed_timer -= 1
	# Blind timer — disable attacking, slow to 50%
	if f.blind_timer > 0:
		f.blind_timer -= 1
		f.attacking = false
		var blind_max_spd: float = 2.25 * 0.5
		if absf(f.vx) > blind_max_spd:
			f.vx = blind_max_spd * signf(f.vx)

# ===== 全局实体更新（fire seas, gravity balls, void rifts, summons）=====
static func update_global() -> void:
	_update_fire_seas()
	_update_gravity_balls()
	_update_void_rifts()
	_update_summons()

# ===== Fire sea updates =====
static func _update_fire_seas() -> void:
	for i in range(GameWorld.evoker_fire_seas.size() - 1, -1, -1):
		var fs: Dictionary = GameWorld.evoker_fire_seas[i]
		var fs_anim: FrameAnimation = fs.get("anim")
		if fs_anim:
			fs_anim.update(1.0)  # 推进火海动画帧
		fs["timer"] = fs.get("timer", 0) + 1
		if fs["timer"] >= fs.get("duration", 240):
			GameWorld.evoker_fire_seas.remove_at(i)
			continue
		# Damage every 12 frames
		if fs["timer"] % 12 == 0:
			var owner: Fighter = fs.get("owner") as Fighter
			if owner:
				var enemy: Fighter = GameWorld.get_opponent(owner)
				if enemy and enemy.hp > 0.0:
					var fs_x: float = fs.get("x", 0.0)
					var fs_y: float = fs.get("y", 0.0)
					var fs_w: float = fs.get("w", 0.0)
					var fs_h: float = fs.get("h", 0.0)
					if _rect_collision(enemy.pos_x, enemy.pos_y, enemy.w, enemy.h, fs_x, fs_y, fs_w, fs_h):
						Fighter.apply_damage(enemy, 1.0, owner, false, Color(0.4, 0.6, 1.0), "hit_enemy", "", 0, 1)  # 幽蓝之径火海 = 技能体攻击
						enemy.slow_timer = 12
						enemy.slow_percent = 0.4

# ===== Gravity ball updates =====
static func _update_gravity_balls() -> void:
	for i in range(GameWorld.gravity_balls.size() - 1, -1, -1):
		var b: Dictionary = GameWorld.gravity_balls[i]
		b["x"] = b.get("x", 0.0) + b.get("vx", 0.0)
		b["y"] = b.get("y", 0.0) + b.get("vy", 0.0)
		b["life"] = b.get("life", 0) - 1
		if b["life"] <= 0:
			GameWorld.gravity_balls.remove_at(i)
			continue
		var owner: Fighter = b.get("owner") as Fighter
		if not owner:
			continue
		var enemy: Fighter = GameWorld.get_opponent(owner)
		if not enemy or enemy.hp <= 0.0:
			continue
		var b_x: float = b.get("x", 0.0)
		var b_y: float = b.get("y", 0.0)
		var b_w: float = b.get("w", 30.0)
		var b_h: float = b.get("h", 30.0)
		var att_rad: float = b.get("attract_radius", 120.0)
		# Attract: pull enemy toward ball center
		var cx: float = b_x + b_w / 2.0
		var cy: float = b_y + b_h / 2.0
		var ex_cx: float = enemy.pos_x + enemy.w / 2.0
		var ex_cy: float = enemy.pos_y + enemy.h / 2.0
		var dx: float = cx - ex_cx
		var dy: float = cy - ex_cy
		var dist: float = sqrt(dx * dx + dy * dy)
		if dist < att_rad and dist > 0.1:
			enemy.vx += (dx / dist) * 0.5
			enemy.vy += (dy / dist) * 0.5
		# Damage every 20 frames
		var dmg_timer: int = b.get("damage_timer", 0) + 1
		b["damage_timer"] = dmg_timer
		if dmg_timer % 20 == 0:
			var ball_rect := Rect2(b_x, b_y, b_w, b_h)
			if enemy.get_hit_box().intersects(ball_rect):
				Fighter.apply_damage(enemy, 1.0, owner, false)

# ===== Void rift updates =====
static func _update_void_rifts() -> void:
	for i in range(GameWorld.void_rifts.size() - 1, -1, -1):
		var rift: Dictionary = GameWorld.void_rifts[i]
		# 推进裂隙动画帧（动画即裂隙视觉）
		var rift_anim: FrameAnimation = rift.get("anim")
		if rift_anim:
			rift_anim.update(1.0)
		rift["timer"] = rift.get("timer", 0) + 1
		if rift["timer"] >= rift.get("duration", 240):
			GameWorld.void_rifts.remove_at(i)
			continue
		# 抓取 + 吸附 + 伤害（无时停，实时生效）
		var rift_owner: Fighter = rift.get("owner") as Fighter
		if rift_owner:
			var rift_enemy: Fighter = GameWorld.get_opponent(rift_owner)
			if rift_enemy and rift_enemy.hp > 0.0:
				var r_cx: float = rift.get("x", 0.0) + rift.get("w", 160.0) / 2.0
				var r_cy: float = rift.get("y", 0.0) + rift.get("h", 120.0) / 2.0
				var a_dx: float = r_cx - (rift_enemy.pos_x + rift_enemy.w / 2.0)
				var a_dy: float = r_cy - (rift_enemy.pos_y + rift_enemy.h / 2.0)
				var a_dist: float = sqrt(a_dx * a_dx + a_dy * a_dy)
				if a_dist < 220.0 and not rift_enemy.is_invincible:
					# 抓取：裂隙范围内敌人被定身在裂隙中心（参考 Fighter.hold_fighter_in_place）
					rift_enemy.pos_x = clampf(r_cx - rift_enemy.w / 2.0, 10.0, 2390.0 - rift_enemy.w)
					rift_enemy.pos_y = clampf(r_cy - rift_enemy.h / 2.0, 40.0, 380.0 - rift_enemy.h)
					rift_enemy.vx = 0.0
					rift_enemy.vy = 0.0
				elif a_dist < 320.0 and a_dist > 0.1:
					# 吸附：裂隙范围外敌人被持续拉向裂隙中心
					rift_enemy.vx += (a_dx / a_dist) * 0.8
					rift_enemy.vy += (a_dy / a_dist) * 0.8
				# 伤害：裂隙矩形范围内每 6 帧 1 点（10/秒）
				if rift["timer"] % 6 == 0:
					var r_x: float = rift.get("x", 0.0)
					var r_y: float = rift.get("y", 0.0)
					var r_w: float = rift.get("w", 0.0)
					var r_h: float = rift.get("h", 0.0)
					if _rect_collision(rift_enemy.pos_x, rift_enemy.pos_y, rift_enemy.w, rift_enemy.h, r_x, r_y, r_w, r_h):
						# 裂隙伤害按抓取结算：打断除金刚体外一切技能
						Fighter.apply_damage(rift_enemy, 1.0, rift_owner, false, Color(0.53, 0.27, 0.8), "hit_enemy", "grab")

# ===== Summon state machine =====
static func _update_summons() -> void:
	for i in range(GameWorld.evoker_summons.size() - 1, -1, -1):
		var summon: Dictionary = GameWorld.evoker_summons[i]
		var owner: Fighter = summon.get("owner") as Fighter
		# Owner null or dead — remove summon
		if not owner or owner.hp <= 0.0:
			GameWorld.evoker_summons.remove_at(i)
			continue
		# Summon hp <= 0 — mark type as dead, remove
		if summon.get("hp", 0.0) <= 0.0:
			var st: int = summon.get("type", -1)
			if st >= 0:
				var evoker_comp: EvokerComponent = owner.components.get_component("evoker") if owner.components else null
				if evoker_comp:
					match st:
						0: evoker_comp.summon_dead1 = true
						1: evoker_comp.summon_dead2 = true
						2: evoker_comp.summon_dead3 = true
			GameWorld.evoker_summons.remove_at(i)
			continue
		# HP regen
		var mhp: float = summon.get("max_hp", 0.0)
		if summon["hp"] < mhp:
			summon["hp"] = minf(mhp, summon["hp"] + 0.05)
		# Action timer
		if summon.get("action_timer", 0) > 0:
			summon["action_timer"] = summon["action_timer"] - 1
		# 动作动画推进（挥镰技能等）；动作结束回到待机动画（若有）
		var sum_anim: FrameAnimation = summon.get("anim")
		if sum_anim:
			sum_anim.update(1.0)
			if summon.get("action_timer", 0) <= 0:
				var sum_idle: FrameAnimation = summon.get("idle_anim")
				summon["anim"] = sum_idle
				if sum_idle and not sum_idle.is_playing():
					sum_idle.play()
		# Flash timer
		if summon.get("flash_timer", 0) > 0:
			summon["flash_timer"] = summon["flash_timer"] - 1
		var enemy: Fighter = GameWorld.get_opponent(owner)
		# === State machine ===
		var state: String = summon.get("state", "随行")
		var sx: float = summon.get("x", 0.0)
		var sy: float = summon.get("y", 0.0)
		var sw: float = summon.get("w", 40.0)
		var sh: float = summon.get("h", 40.0)
		match state:
			"随行":
				var target_x: float = owner.pos_x - 50.0
				var target_y: float = owner.pos_y + 10.0
				summon["vx"] = summon.get("vx", 0.0) + (target_x - sx) * 0.08
				summon["vy"] = summon.get("vy", 0.0) + (target_y - sy) * 0.08
				var speed: float = sqrt(summon["vx"] * summon["vx"] + summon["vy"] * summon["vy"])
				if speed > 3.5:
					summon["vx"] = (summon["vx"] / speed) * 3.5
					summon["vy"] = (summon["vy"] / speed) * 3.5
			"猎杀":
				if enemy and enemy.hp > 0.0:
					var edx: float = enemy.pos_x - sx
					var edy: float = enemy.pos_y - sy
					var edist: float = sqrt(edx * edx + edy * edy)
					if edist > 0.1:
						summon["vx"] = (edx / edist) * 1.5
						summon["vy"] = (edy / edist) * 1.5
					var spd2: float = sqrt(summon["vx"] * summon["vx"] + summon["vy"] * summon["vy"])
					if spd2 > 2.0:
						summon["vx"] = (summon["vx"] / spd2) * 2.0
						summon["vy"] = (summon["vy"] / spd2) * 2.0
			"回归":
				var ret_tx: float = owner.pos_x - 50.0
				var ret_ty: float = owner.pos_y + 10.0
				var ret_dx: float = ret_tx - sx
				var ret_dy: float = ret_ty - sy
				var ret_dist: float = sqrt(ret_dx * ret_dx + ret_dy * ret_dy)
				if ret_dist > 0.1:
					summon["vx"] = (ret_dx / ret_dist) * 6.0
					summon["vy"] = (ret_dy / ret_dist) * 6.0
				else:
					summon["vx"] = 0.0
					summon["vy"] = 0.0
				if ret_dist < 10.0:
					summon["state"] = "随行"
				if enemy and enemy.hp > 0.0:
					var hit_ens: Array = summon.get("hit_enemies", [])
					if not hit_ens.has(enemy):
						if _rect_collision(sx, sy, sw, sh, enemy.pos_x, enemy.pos_y, enemy.w, enemy.h):
							Fighter.apply_damage(enemy, 5.0, owner, false)
							hit_ens.append(enemy)
							summon["hit_enemies"] = hit_ens
			"突进":
				var dash_d: int = summon.get("dash_dir", 1)
				summon["vx"] = dash_d * 8.0
				summon["vy"] = 0.0
				var dash_t: int = summon.get("dash_timer", 0) - 1
				summon["dash_timer"] = dash_t
				if enemy and enemy.hp > 0.0:
					var dash_h: bool = summon.get("dash_hit", false)
					if not dash_h:
						if _rect_collision(sx, sy, sw, sh, enemy.pos_x, enemy.pos_y, enemy.w, enemy.h):
							Fighter.apply_damage(enemy, 10.0, owner, false)
							summon["dash_hit"] = true
				if dash_t <= 0:
					summon["state"] = "猎杀"
		# Apply velocity
		summon["x"] = summon.get("x", 0.0) + summon.get("vx", 0.0)
		summon["y"] = summon.get("y", 0.0) + summon.get("vy", 0.0)
		sx = summon["x"]
		sy = summon["y"]
		# === Passive auras ===
		var s_type: int = summon.get("type", -1)
		if enemy and enemy.hp > 0.0:
			var ecx: float = enemy.pos_x + enemy.w / 2.0
			var ecy: float = enemy.pos_y + enemy.h / 2.0
			var scx: float = sx + sw / 2.0
			var scy: float = sy + sh / 2.0
			var aura_dx: float = ecx - scx
			var aura_dy: float = ecy - scy
			var aura_dist: float = sqrt(aura_dx * aura_dx + aura_dy * aura_dy)
			match s_type:
				1:
					if aura_dist < 150.0 and GameWorld.frame % 60 == 0:
						enemy.energy = maxf(0.0, enemy.energy - 5.0)
				2:
					if aura_dist < 150.0:
						if not enemy.has_status("evoker_gazed"):
							var es1 = enemy.get_skill("skill1")
							if es1: es1.cd += 60
							var es2 = enemy.get_skill("skill2")
							if es2: es2.cd += 60
						enemy.add_status("evoker_gazed")
					elif enemy.has_status("evoker_gazed"):
						var es1 = enemy.get_skill("skill1")
						if es1: es1.cd = maxi(0, es1.cd - 60)
						var es2 = enemy.get_skill("skill2")
						if es2: es2.cd = maxi(0, es2.cd - 60)
						for s in enemy.statuses:
							if s.id == "evoker_gazed":
								s.timer = 0
		# === Hit detection (non-随行 state only) ===
		if state != "随行":
			var hit_cd: int = summon.get("hit_cd", 0)
			if hit_cd > 0:
				summon["hit_cd"] = hit_cd - 1
			if enemy and enemy.hp > 0.0 and hit_cd <= 0:
				if enemy.attacking and enemy.attack_hit_dealt:
					if _rect_collision(sx, sy, sw, sh, enemy.pos_x, enemy.pos_y, enemy.w, enemy.h):
						summon["hp"] = summon.get("hp", 0.0) - enemy.attack_damage
						summon["hit_cd"] = 30
						var fsx: float = sx + sw / 2.0
						var fsy: float = sy + sh / 2.0
						Fighter.emit_particles(fsx, fsy, 8, Color(1.0, 0.0, 0.0), 2, 10)
			if enemy:
				for pi in range(GameWorld.projectiles.size() - 1, -1, -1):
					var proj: Dictionary = GameWorld.projectiles[pi]
					var p_owner: Fighter = proj.get("owner") as Fighter
					if p_owner != enemy:
						continue
					var pr_x: float = proj.get("x", 0.0)
					var pr_y: float = proj.get("y", 0.0)
					var pr_w: float = proj.get("w", 32.0)
					var pr_h: float = proj.get("h", 20.0)
					if _rect_collision(sx, sy, sw, sh, pr_x, pr_y, pr_w, pr_h):
						summon["hp"] = summon.get("hp", 0.0) - proj.get("damage", 0.0)
						if not proj.get("piercing", false):
							GameWorld.projectiles.remove_at(pi)

# ===== Utility: rectangle collision =====
static func _rect_collision(a_x: float, a_y: float, a_w: float, a_h: float, b_x: float, b_y: float, b_w: float, b_h: float) -> bool:
	return a_x + a_w > b_x and a_x < b_x + b_w and a_y + a_h > b_y and a_y < b_y + b_h

## 输入处理（替代 input_handler.gd 中的 _input_evoker）
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var mx = 0
	if keys.left: mx = -1
	if keys.right: mx = 1
	if keys.up and owner.grounded:
		owner.vy = -10
		owner.grounded = false
	
	# Bypass Skill.can_use's "attacking" check — evoker's attack cooldown is managed by attack_cooldown, not attacking
	if keys.attack:
		var s = owner.get_skill("attack")
		if s and owner.attack_cooldown <= 0:
			# Determine energy cost based on summon presence
			var has_summon = false
			for sm in GameWorld.evoker_summons:
				if sm.get("owner") == owner:
					has_summon = true
					break
			var cost = 20.0 if has_summon else 10.0
			if owner.energy >= cost:
				if s.execute_func.is_valid():
					s.execute_func.call(owner)
				keys.attack = false
	
	if keys.skill1:
		var s = owner.get_skill("skill1")
		if s and s.cd <= 0 and owner.energy >= s.energy_cost:
			if s.can_use_func.is_valid() and s.can_use_func.call(owner):
				owner.energy -= s.energy_cost
				s.cd = s.cooldown
				if s.execute_func.is_valid():
					s.execute_func.call(owner)
				keys.skill1 = false
	
	if keys.skill2:
		var s = owner.get_skill("skill2")
		if s and s.cd <= 0 and owner.energy >= s.energy_cost:
			if s.can_use_func.is_valid() and s.can_use_func.call(owner):
				owner.energy -= s.energy_cost
				s.cd = s.cooldown
				if s.execute_func.is_valid():
					s.execute_func.call(owner)
				keys.skill2 = false
	
	if keys.ult:
		var s = owner.get_skill("ult")
		if s and s.cd <= 0 and owner.energy >= s.energy_cost:
			if s.can_use_func.is_valid() and s.can_use_func.call(owner):
				owner.energy -= s.energy_cost
				s.cd = s.cooldown
				if s.execute_func.is_valid():
					s.execute_func.call(owner)
				keys.ult = false
	
	Fighter.apply_movement(owner, mx, 2.25)
	Fighter.update_state(owner, mx)
	return mx
