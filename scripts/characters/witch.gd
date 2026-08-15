# 魔女 (witch)
class_name WitchCharacter

const WitchComponent = preload("res://scripts/components/witch_component.gd")

const PROJ_GRAVITY = preload("res://assets/fx_gravity_ball.png")
const IMG_TORNADO = preload("res://assets/fx_tornado.png")
const IMG_VORTEX = preload("res://assets/fx_vortex.png")
const PROJ_METEOR = preload("res://assets/fx_meteor.png")
const WITCH_ANI_DIR = "res://assets/char_ani/witch/"
const WITCH_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/witch_idle_foot_gaps.gd")
const WITCH_SKILL2_FOOT_GAPS = preload("res://data/foot_gaps/witch_skill2_foot_gaps.gd")

static func get_config() -> Dictionary:
	_inject_draw()
	return {
		"id": "witch", "name": "魔女", "hp": 70, "max_energy": 120, "energy_regen": 0.083,
		"speed": 2.0, "attack_range": 0, "attack_damage": 0,
		"attack_cooldown": 120, "attack_delay": 0, "attack_duration": 0,
		"fields": {"is_flying":false,"fly_energy_drain":0.133,"gravity_debuff":false,"jump_reduction":1.0,"is_casting_ult":false,"cast_ult_x":0.0,"cast_ult_y":0.0},
		"world_arrays": ["tornadoes","vortexes"],
		"animations": {
			"idle": FrameAnimation.load_from_sprite_sheet(WITCH_ANI_DIR + "idle/sheet.png", 5, 4, 17, 999.0, true, _witch_idle_anchors()),
			"walk": FrameAnimation.load_from_frames(WITCH_ANI_DIR + "walk/", "witch_walk_f_", [{"index": 1, "duration": 999.0}], true),
			"jump": FrameAnimation.load_from_frames(WITCH_ANI_DIR + "jump/", "witch_jump_f_", [{"index": 1, "duration": 999.0}], true),
			"attack": FrameAnimation.load_from_frames(WITCH_ANI_DIR + "attack/", "witch_attack_f_", [{"index": 1, "duration": 0.5}], false),
			"skill2": FrameAnimation.load_from_sprite_sheet(WITCH_ANI_DIR + "skill2/sheet.png", 4, 3, 11, 0.1, false, _witch_skill2_anchors()),
			"ult": FrameAnimation.load_from_frames(WITCH_ANI_DIR + "ult/", "witch_ult_f_", [{"index": 1, "duration": 3.0}], false),
		},
		"dex": {
			"icon": "🧹",
			"intro": "风暴裹挟着紫色的裂隙，从天空的伤口中落下。她未踏足战场，风已先至——不是来战斗的，是来终结的。陨石撕裂天穹、火光填满人们的瞳孔。\n\"果然，凡人还是与地面比较适配。\"",
			"stats": [{"label": "生命", "value": "70"}, {"label": "能量上限", "value": "120"}],
			"skills": [
				{"name": "重力球（普通攻击）", "desc": "向前方发射一颗重力球，造成 4 点伤害。命中后敌人被紫色光芒包裹，最大跳跃高度减少 20%，持续 2 秒。飞行状态下会斜向下发射。", "meta": "消耗：3 能量 ｜ 冷却：2 秒"},
				{"name": "风轨·绝啸（技能一）", "desc": "在前方生成一个巨大龙卷风，持续 4 秒。龙卷风具有吸附效果，对靠近的敌人每 0.5 秒造成 5 点伤害。", "meta": "消耗：20 能量 ｜ 冷却：15 秒"},
				{"name": "黯渊·涡流（技能二）", "desc": "在脚下留下一个漩涡并快速起跳，漩涡持续 3 秒，吸附敌人并每 0.5 秒造成 3 点伤害。", "meta": "消耗：20 能量 ｜ 冷却：12 秒"},
				{"name": "陨星·寂灭（大招）", "desc": "只能在跳跃/飞行状态下释放。召唤一颗巨大陨石从天而降，撞击地面造成大范围（半径 400 像素）爆炸，造成 40 点伤害。释放后魔女进入悬停施法状态，直到陨石落地。", "meta": "消耗：100 能量（需至少 120 能量） ｜ 冷却：无"},
			]
		},
	}

## 锚点辅助函数：把扫描生成的 GDScript 常量组装成 FrameAnimation 需要的字典数组
static func _witch_idle_anchors() -> Array:
	var anchors := []
	for i in range(WITCH_IDLE_FOOT_GAPS.WITCH_IDLE_FOOT.size()):
		anchors.append({
			"foot_gap": WITCH_IDLE_FOOT_GAPS.WITCH_IDLE_FOOT[i],
			"head_gap": WITCH_IDLE_FOOT_GAPS.WITCH_IDLE_HEAD[i],
			"center_dx": WITCH_IDLE_FOOT_GAPS.WITCH_IDLE_CENTER[i],
			"content_w": WITCH_IDLE_FOOT_GAPS.WITCH_IDLE_CONTENT_W[i],
			"content_h": WITCH_IDLE_FOOT_GAPS.WITCH_IDLE_CONTENT_H[i],
		})
	return anchors

static func _witch_skill2_anchors() -> Array:
	var anchors := []
	for i in range(WITCH_SKILL2_FOOT_GAPS.WITCH_SKILL2_FOOT.size()):
		anchors.append({
			"foot_gap": WITCH_SKILL2_FOOT_GAPS.WITCH_SKILL2_FOOT[i],
			"head_gap": WITCH_SKILL2_FOOT_GAPS.WITCH_SKILL2_HEAD[i],
			"center_dx": WITCH_SKILL2_FOOT_GAPS.WITCH_SKILL2_CENTER[i],
			"content_w": WITCH_SKILL2_FOOT_GAPS.WITCH_SKILL2_CONTENT_W[i],
			"content_h": WITCH_SKILL2_FOOT_GAPS.WITCH_SKILL2_CONTENT_H[i],
		})
	return anchors

static func _can_use_skill2(owner: Fighter) -> bool:
	var witch_comp: WitchComponent = owner.components.get_component("witch") if owner.components else null
	return owner.grounded and not owner.attacking and (not witch_comp or not witch_comp.is_flying)

static func _can_use_ult(owner: Fighter) -> bool:
	var witch_comp: WitchComponent = owner.components.get_component("witch") if owner.components else null
	return not owner.grounded and not owner.attacking and not owner.charging_attack and (not witch_comp or not witch_comp.is_casting_ult)

static func create_skills() -> Array:
	return [
		Skill.new("attack", "重力球", 120, 3, func(owner: Fighter): return owner.attack_cooldown <= 0 and not owner.attacking, Callable(_attack)),
		Skill.new("skill1", "风轨·绝啸", 900, 20, Callable(), Callable(_skill1)),
		Skill.new("skill2", "黯渊·涡流", 720, 20, Callable(_can_use_skill2), Callable(_skill2)),
		Skill.new("ult", "陨星·寂灭", 0, 100, Callable(_can_use_ult), Callable(_ult)),
	]

static func _attack(owner: Fighter) -> Dictionary:
	var dir = owner.facing
	var px = owner.pos_x + (owner.w if dir==1 else 0)
	var py = owner.pos_y + 30
	var p_vx = 4.0 * dir
	var p_vy = 0.0
	var witch_comp: WitchComponent = owner.components.get_component("witch") if owner.components else null
	if witch_comp and witch_comp.is_flying:
		p_vx = 3.0 * dir
		p_vy = 2.0
	GameWorld.projectiles.append({"x":px-16,"y":py-12,"w":32,"h":24,"vx":p_vx,"vy":p_vy,"life":120,"damage":4,"owner":owner,"type":"gravity","color":Color(0.67,0.53,1.0),"reflected":false,"isGravity":true,"img":PROJ_GRAVITY})
	owner.attack_cooldown = 120
	return {"success": true}

static func _skill1(owner: Fighter) -> Dictionary:
	var tx = owner.pos_x + (owner.w if owner.facing>0 else -120)
	var ty = 260.0 # GROUND_Y - 120
	GameWorld.tornadoes.append({"x":tx,"y":ty,"w":120,"h":160,"life":240,"timer":0,"damage":5,"tick_interval":60,"owner":owner,"type":"tornado","pull_strength":0.3,"img":IMG_TORNADO})
	return {"success": true}

static func _skill2(owner: Fighter) -> Dictionary:
	var vx = owner.pos_x - 40
	var vy = 350.0 # GROUND_Y - 30
	GameWorld.vortexes.append({"x":vx,"y":vy,"w":80,"h":30,"life":180,"timer":0,"damage":3,"tick_interval":30,"owner":owner,"type":"vortex","pull_strength":0.4,"img":IMG_VORTEX})
	owner.vy = -10
	owner.grounded = false
	return {"success": true}

static func _ult(owner: Fighter) -> Dictionary:
	if owner.grounded:
		return {"success": false}
	var witch_comp: WitchComponent = owner.components.get_component("witch") if owner.components else null
	if not witch_comp:
		return {"success": false}
	var target_x = owner.pos_x + owner.w / 2
	var dir = owner.facing if owner.facing != 0 else 1
	GameWorld.projectiles.append({"x":target_x-200,"y":-500,"w":600,"h":600,"vx":1.0*dir,"vy":1.0,"life":300,"damage":40,"owner":owner,"type":"meteor","exploded":false,"img":PROJ_METEOR})
	witch_comp.is_casting_ult = true
	witch_comp.ult_lock_timer = 30  # 0.5s 前摇冻结
	witch_comp.cast_ult_x = target_x
	witch_comp.cast_ult_y = -500
	owner.state = "ult"
	owner.vx = 0
	owner.vy = 0
	return {"success": true}

# ===== 全局实体更新（龙卷风 + 漩涡，从 tornado_system.gd 迁移至此）=====
static func update_global():
	for i in range(GameWorld.tornadoes.size() - 1, -1, -1):
		var t = GameWorld.tornadoes[i]
		t["life"] -= 1
		if t["life"] <= 0: GameWorld.tornadoes.remove_at(i); continue
		var target = GameWorld.get_opponent(t["owner"])
		if target and target.hp > 0:
			var dx2 = (t["x"]+t["w"]/2)-(target.pos_x+target.w/2)
			var dy2 = (t["y"]+t["h"]/2)-(target.pos_y+target.h/2)
			var d2 = sqrt(dx2*dx2+dy2*dy2)
			if d2 < 150:
				var pull = t.get("pull_strength", 0.3)
				var ang = atan2(dy2, dx2)
				target.vx += cos(ang)*pull; target.vy += sin(ang)*pull*0.5
			if target.get_hit_box().intersects(Rect2(t["x"], t["y"], t["w"], t["h"])):
				t["timer"] = t.get("timer", 0) + 1
				var ti = t.get("tick_interval", 60)
				if t["timer"] >= ti:
					t["timer"] = 0
					Fighter.apply_damage(target, t["damage"], t["owner"], false)
	for i in range(GameWorld.vortexes.size()-1,-1,-1):
		var v = GameWorld.vortexes[i]
		v["life"] -= 1
		if v["life"] <= 0: GameWorld.vortexes.remove_at(i); continue
		var target = GameWorld.get_opponent(v["owner"])
		if target and target.hp > 0:
			var dx2 = (v["x"]+v["w"]/2)-(target.pos_x+target.w/2)
			var dy2 = (v["y"]+v["h"]/2)-(target.pos_y+target.h/2)
			var d2 = sqrt(dx2*dx2+dy2*dy2)
			if d2 < 130:
				var pull = v.get("pull_strength", 0.4)
				var ang = atan2(dy2, dx2)
				target.vx += cos(ang)*pull; target.vy += sin(ang)*pull*0.4
			if target.get_hit_box().intersects(Rect2(v["x"], v["y"], v["w"], v["h"])):
				v["timer"] = v.get("timer", 0) + 1
				var ti = v.get("tick_interval", 30)
				if v["timer"] >= ti:
					v["timer"] = 0
					Fighter.apply_damage(target, v["damage"], v["owner"], false)

# ── 绘制注入（龙卷风 + 漩涡渲染，从 game.gd 迁移至此）──
static func _inject_draw():
	GameWorld.register_draw_effect("witch_tornadoes", func(font, cam_x, _cam_y = 0.0):
		var items: Array = []
		for t in GameWorld.tornadoes:
			var px = t["x"] - cam_x
			if px > -t["w"] and px < Constants.W + t["w"]:
				if t.has("img") and t["img"] is Texture2D:
					items.append({"type": "tex", "tex": t["img"], "rect": Rect2(px, t["y"] - _cam_y, t["w"], t["h"]), "color": Color(1,1,1,0.8)})
				else:
					items.append({"type": "rect", "rect": Rect2(px, t["y"] - _cam_y, t["w"], t["h"]), "color": Color(0.533, 0.867, 1.0, 0.8)})
		for v in GameWorld.vortexes:
			var px = v["x"] - cam_x
			if px > -v["w"] and px < Constants.W + v["w"]:
				if v.has("img") and v["img"] is Texture2D:
					items.append({"type": "tex", "tex": v["img"], "rect": Rect2(px, v["y"] - _cam_y, v["w"], v["h"]), "color": Color(1,1,1,0.8)})
				else:
					items.append({"type": "rect", "rect": Rect2(px, v["y"] - _cam_y, v["w"], v["h"]), "color": Color(0.467, 0.267, 0.667, 0.8)})
		return items
	, 0)

## 输入处理（替代 input_handler.gd 中的 _input_witch）
static func handle_input(owner: Fighter, keys: Dictionary) -> int:
	var mx = 0
	var witch_comp: WitchComponent = owner.components.get_component("witch") if owner.components else null
	if keys.up and witch_comp:
		if owner.grounded and not witch_comp.is_flying:
			owner.vy = owner.jump_reduction * -10
			owner.grounded = false
			keys.up = false
		elif not owner.grounded and not witch_comp.is_flying and not owner.attacking:
			if owner.energy > 0:
				witch_comp.is_flying = true
				owner.vy = 0
			keys.up = false
		elif witch_comp.is_flying:
			witch_comp.is_flying = false
			keys.up = false
	if witch_comp and witch_comp.is_flying:
		owner.energy -= witch_comp.fly_energy_drain
		if owner.energy <= 0:
			owner.energy = 0
			witch_comp.is_flying = false
	if keys.left: mx = -1
	if keys.right: mx = 1
	if mx != 0:
		owner.facing = 1 if mx > 0 else -1
	if not owner.has_status("frozen") and not owner.dashing:
		var sp = 1.8 if (witch_comp and witch_comp.is_flying) else 2.0
		owner.vx += mx * 0.25
		if absf(owner.vx) > sp:
			owner.vx = sp * signf(owner.vx)
	if keys.attack and not owner.attacking and owner.attack_cooldown <= 0:
		var s = owner.get_skill("attack")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.attack = false
	if keys.skill1 and not owner.attacking:
		var s = owner.get_skill("skill1")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill1 = false
	if keys.skill2 and not owner.attacking and owner.grounded:
		var s = owner.get_skill("skill2")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.skill2 = false
	if keys.ult and not owner.attacking:
		var s = owner.get_skill("ult")
		if s:
			var r = s.try_use(owner)
			if r.get("success"):
				keys.ult = false
	Fighter.update_state(owner, mx)
	return mx
