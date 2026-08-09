class_name AISystem

# ===== AI System =====
# FSM显式状态变量
static var _state: String = "IDLE"

# 闪避全局冷却（帧）
static var _dodge_cooldown: int = 0

# 物理常量（引用 TrackSystem）
const GRAVITY := 0.22
const JUMP_VY := 10.0

# ── 主入口（每帧执行） ──
static func update_ai(ai_think_delay: int) -> int:
	if GameWorld.game_mode == "pvp" or GameWorld.enemy.hp <= 0:
		return ai_think_delay
	var f = GameWorld.enemy
	
	# Frozen check
	if f.has_status("frozen"):
		_state = "IDLE"
		return ai_think_delay
	
	# Hit stun check
	if f.hit_cooldown > 0:
		_state = "IDLE"
		return ai_think_delay
	
	var diff = Constants.AI_PRESETS.get(GameWorld.difficulty, Constants.AI_PRESETS["medium"])
	
	# Phantom target selection — AI prefers nearest alive phantom
	var target = GameWorld.player
	if GameWorld.phantoms.size() > 0:
		var nearest = null
		var nd = INF
		for ph in GameWorld.phantoms:
			if not ph or ph.hp <= 0:
				continue
			var d = absf(f.pos_x - ph.x)
			if d < nd:
				nd = d
				nearest = ph
		if nearest:
			target = nearest
	
	var dx = (target["x"] if target is Dictionary else target.pos_x) - f.pos_x
	var dist = absf(dx)
	var dir_to_target = 1 if dx > 0 else -1
	
	# Think delay
	if ai_think_delay > 0:
		_state = "IDLE"
		return ai_think_delay - 1
	var new_delay = int(diff["react"] / 16) + randi() % 8
	
	var rand = randf()
	
	# ════════════════════════════════════════
	# 优先级链：IDLE → DEFEND → DODGE → ATTACK → PICKUP → CHASE/KITE
	# ════════════════════════════════════════
	
	# ── 1. DEFEND: 前方有投射物 + skill2 可用 ──
	var proj_near = false
	for p in GameWorld.projectiles:
		if p.get("owner") == GameWorld.player and absf(p.get("x", 0) - f.pos_x) < 200:
			proj_near = true
			break
	if proj_near and not f.blocking and f.grounded:
		var skill2 = f.get_skill("skill2")
		if skill2 and skill2.can_use(f):
			f.facing = dir_to_target
			skill2.try_use(f)
			_state = "DEFEND"
			return new_delay
	
	# ── 2. DODGE: 危险临近 + 闪避冷却就绪 ──
	if _should_dodge(f, target, dist, diff):
		var ddir = -dir_to_target
		f.dashing = true
		f.dash_dir = ddir
		f.dash_remaining = 15
		f.dash_speed = diff["move_speed"] * 5.0
		_dodge_cooldown = 120
		_state = "DODGE"
		return new_delay
	
	# ── 技能变量 ──
	var skill1 = f.get_skill("skill1")
	var skill2 = f.get_skill("skill2")
	var ult = f.get_skill("ult")

	var can_use_s1 = skill1 and skill1.can_use(f) and dist < 350
	var can_use_s2 = skill2 and skill2.can_use(f)
	var can_use_ult = ult and ult.can_use(f)

	# ── 3. ATTACK: 地狱战术 → Archer → Evoker → 技能 → 近战 ──

	# ---- Hell-specific tactics ----
	var is_hell = GameWorld.difficulty == "hell"
	if is_hell:
		var player = GameWorld.player
		# ① 反应闪避: 玩家攻击中+距离<150px → 后跳闪避, 70%概率
		if player and player.hp > 0 and player.attacking and dist < 150 and rand < 0.7:
			f.vx = -dir_to_target * diff["move_speed"] * 2.0
			if f.grounded: f.vy = -8
			_update_state(f, dir_to_target)
			_state = "DODGE"
			return new_delay

		# ② 对空迎击: 玩家在空中+距离<120px → AI跳起迎击, 40%概率
		if player and not player.grounded and f.grounded and dist < 120 and rand < 0.4:
			f.vy = -9
			f.vx = dir_to_target * diff["move_speed"]
			_update_state(f, dir_to_target)
			_state = "ATTACK"
			return new_delay

		# ③ 防御技能: 玩家贴脸攻击中+距离<100px → AI开技二防御, 50%概率
		if skill2 and skill2.can_use(f) and dist < 100 and player and player.attacking and rand < 0.5:
			skill2.try_use(f)
			_state = "DEFEND"
			return new_delay

		# ── 地狱角色专属战术：通过 CharacterFactory 调度到角色脚本（配置驱动，禁止 match char_id 新增分支）──
		var handled_state = CharacterFactory.call_ai_hell_tactics(f, {
			"target": target, "dist": dist, "dir": dir_to_target, "rand": rand,
			"diff": diff, "player": player,
			"skill1": skill1, "skill2": skill2, "ult": ult,
			"can_use_s1": can_use_s1, "can_use_s2": can_use_s2, "can_use_ult": can_use_ult,
		})
		if handled_state != "":
			_state = handled_state
			return new_delay

		match f.char_id:
			"assassin":
				# 刺客：玩家攻击时尝试一技能完美闪避, 60%概率
				if skill1 and skill1.can_use(f) and player and player.attacking and dist < 200 and rand < 0.6:
					f.facing = dir_to_target
					skill1.try_use(f)
					_state = "ATTACK"
					return new_delay

			"witch":
				# 魔女：能量>50%时跳跃进入飞行模式，然后空中打击
				if f.energy > f.max_energy * 0.5 and f.grounded and rand < 0.15:
					f.vy = -10  # 跳跃
					var wc = f.components.get_component("witch") if f.components else null
					if wc: wc.is_flying = true
					_state = "ATTACK"
					return new_delay
				# 飞行中：优先使用普攻和一技能
				var wc = f.components.get_component("witch") if f.components else null
				if wc and wc.is_flying and dist < 400:
					if can_use_s1 and rand < diff["skill_rate"]:
						f.facing = dir_to_target
						skill1.try_use(f)
						_state = "ATTACK"
						return new_delay
					var atk = f.get_skill("attack")
					if atk and atk.can_use(f):
						f.facing = dir_to_target
						atk.try_use(f)
						_state = "ATTACK"
						return new_delay
			
			"shadowwarrior":
				# 影武者：隐身中快速靠近破隐一击
				var sw_comp2 = f.components.get_component("shadowwarrior") if f.components else null
				if sw_comp2 and sw_comp2.stealth_active:
					if dist < 60 and f.attack_cooldown <= 0 and not f.attacking:
						f.attacking = true; f.attack_timer = 30; f.attack_delay = 8
						f.attack_hit_dealt = false; f.attack_cooldown = 60; f.state = "attack"
						sw_comp2.stealth_active = false  # 破隐
						_state = "ATTACK"
						return new_delay

			"paladin":
				# 圣骑士：距离>500时蓄力一技能，蓄满后远距离冲刺撞击
				if dist > 500 and can_use_s1 and not f.charging_skill1 and not f.dashing and rand < 0.2:
					f.facing = dir_to_target
					skill1.try_use(f)
					_state = "ATTACK"
					return new_delay

	# ── 角色特定走位修正 ──

	# ---- Skill usage ----
	# 技能一：远程距离判定
	if dist > 150 and dist < 350 and can_use_s1 and randf() < diff["skill_rate"] * 1.5:
		f.facing = dir_to_target
		skill1.try_use(f)
		if Constants.difficulty_at_least(GameWorld.difficulty, "hard"):
			skill1.cd = maxi(skill1.cd, 300)
		_state = "ATTACK"
		return new_delay

	# 大招
	if dist < 200 and can_use_ult and randf() < diff["skill_rate"] * 0.8:
		f.facing = dir_to_target
		ult.try_use(f)
		if Constants.difficulty_at_least(GameWorld.difficulty, "hard"):
			ult.cd = maxi(ult.cd, 300)
		_state = "ATTACK"
		return new_delay
	
	# ---- Hell-specific tactics (cont.) ----
	if is_hell:
		var player = GameWorld.player
		# ④ 斩杀大招: 玩家血量<40%+距离<150px → 直接丢大招, 80%概率
		if can_use_ult and dist < 150 and player and player.hp < player.max_hp * 0.4 and rand < 0.8:
			f.facing = dir_to_target
			ult.try_use(f)
			_state = "ATTACK"
			return new_delay

		# ⑤ 技能连招: 双技能可用+距离<200px → 技一→技二连发, 35%概率
		if can_use_s1 and can_use_s2 and dist < 200 and rand < 0.35:
			f.facing = dir_to_target
			skill1.try_use(f)
			if skill2.can_use(f): skill2.try_use(f)
			_state = "ATTACK"
			return new_delay

		# ⑥ 影武者：使用技能后尝试进入隐身
		var sw_comp = f.components.get_component("shadowwarrior") if f.components else null
		if sw_comp and not sw_comp.stealth_active and f.char_id == "shadowwarrior" and rand < 0.5:
			sw_comp.stealth_active = true
			sw_comp.stealth_timer = 360
			_state = "ATTACK"
			return new_delay

	# ---- Archer: buff优先 → 无条件蓄力 → 同线放箭 ----
	if f.char_id == "archer":
		f.facing = dir_to_target
		# ① 优先开强化技能（火矢/追踪）
		if skill1 and skill1.can_use(f):
			skill1.try_use(f)
			_state = "ATTACK"
			return new_delay
		if skill2 and skill2.can_use(f):
			skill2.try_use(f)
			_state = "ATTACK"
			return new_delay
		# ② 蓄力中 → 蓄满且在同一水平线时放箭
		if f.charging_attack:
			var ct = (Time.get_ticks_msec() - f.charge_start_time) / 1000.0
			var t_y = target.get("y", 0.0) if target is Dictionary else target.pos_y
			if ct >= 0.8 and absf(f.pos_y - t_y) < 30:
				ArcherCharacter.ai_fire_arrow(f, ct)
			_state = "ATTACK"
			return new_delay
		# ③ 无条件开始蓄力（有箭且能量够即可）
		var archer_comp = f.components.get_component("archer") if f.components else null
		if archer_comp and archer_comp.arrows > 0 and f.energy >= 5:
			f.charging_attack = true
			f.charge_start_time = Time.get_ticks_msec()
			f.attacking = true
			f.attack_timer = 9999
			f.state = "attack"
			_state = "ATTACK"
			return new_delay

	# ---- Evoker: summon management & ranged combat ----
	if f.char_id == "evoker":
		# HP < 30% → 优先大招
		if can_use_ult and f.hp < f.max_hp * 0.3 and dist < 350:
			f.facing = dir_to_target
			ult.try_use(f)
			_state = "ATTACK"
			return new_delay

		# HP < 50% → 防御大招
		if can_use_ult and f.hp < f.max_hp * 0.5 and dist < 250:
			f.facing = dir_to_target
			ult.try_use(f)
			_state = "ATTACK"
			return new_delay

		var has_summon = false
		var summon_state = ""
		for s in GameWorld.evoker_summons:
			if s.get("owner") == f:
				has_summon = true
				summon_state = s.get("state", "")
				break

		if not has_summon and can_use_s1:
			f.facing = dir_to_target
			skill1.try_use(f)
			_state = "ATTACK"
			return new_delay

		var atk_skill = f.get_skill("attack")

		if has_summon and can_use_s2 and randf() < diff["skill_rate"]:
			f.facing = dir_to_target
			skill2.try_use(f)
			_state = "ATTACK"
			return new_delay

		if has_summon and atk_skill and atk_skill.can_use(f):
			f.facing = dir_to_target
			atk_skill.try_use(f)
			_state = "ATTACK"
			return new_delay

		if not has_summon and atk_skill and atk_skill.can_use(f) and dist < 400 and rand < diff["aggro"]:
			f.facing = dir_to_target
			atk_skill.try_use(f)
			_state = "ATTACK"
			return new_delay

	# ---- 远程角色：在同一水平线上时普攻 ----
	if not _is_melee(f):
		f.facing = dir_to_target
		# 通过 skill 系统的角色（witch/evoker 等）
		var atk = f.get_skill("attack")
		if atk and atk.can_use(f):
			var t_y = target.get("y", 0.0) if target is Dictionary else target.pos_y
			if absf(f.pos_y - t_y) < 30 and dist < 600:
				atk.try_use(f)
				_state = "ATTACK"
				return new_delay
		# Mage 的火球普攻没有注册为 skill，需直接处理
		if f.char_id == "mage" and f.attack_cooldown <= 0 and not f.attacking and f.energy >= 10:
			var t_y = target.get("y", 0.0) if target is Dictionary else target.pos_y
			if absf(f.pos_y - t_y) < 30 and dist < 600:
				f.energy -= 10
				f.attacking = true
				f.attack_timer = 30
				f.attack_delay = 0
				f.attack_hit_dealt = true
				f.attack_cooldown = 120
				f.state = "attack"
				var d = f.facing
				var px2 = f.pos_x + (f.w if d == 1 else 0)
				var py2 = f.pos_y + 30
				GameWorld.projectiles.append({"x":px2-16,"y":py2-12,"w":32,"h":24,"vx":3*d,"vy":0,"life":120,"damage":3,"owner":f,"type":"mage_fire","color":Color(1,0.4,0),"reflected":false,"burn":true,"img":preload("res://assets/fx_fire_projectile.png")})
				_state = "ATTACK"
				return new_delay

	# ---- 近战普攻判定（远程角色跳过） ----
	if _is_melee(f) and dist < 80 and rand < diff["aggro"]:
		f.facing = dir_to_target
		if f.char_id == "assassin":
			var atk_skill = f.get_skill("attack")
			if atk_skill and atk_skill.can_use(f):
				atk_skill.try_use(f)
		else:
			if f.attack_cooldown <= 0 and not f.attacking:
				f.attacking = true
				f.attack_timer = 30
				f.attack_delay = 8
				f.attack_hit_dealt = false
				f.attack_cooldown = 60
				f.state = "attack"
		_state = "ATTACK"
		return new_delay
	
	# 残血处理（HP < 20%）：贴脸反打、保持距离、优先血球
	var max_hp = f.max_hp
	if f.hp < max_hp * 0.2:
		if dist < 80:
			# 贴脸 → 反打
			f.facing = dir_to_target
			if _is_melee(f) and f.attack_cooldown <= 0 and not f.attacking:
				f.attacking = true
				f.attack_timer = 30
				f.attack_delay = 8
				f.attack_hit_dealt = false
				f.attack_cooldown = 60
				f.state = "attack"
				_state = "ATTACK"
				return new_delay
		elif dist < 150:
			# 被追 → 先闪避，再防御，再反打
			if _should_dodge(f, target, dist, diff):
				var ddir = -dir_to_target
				f.dashing = true
				f.dash_dir = ddir
				f.dash_remaining = 15
				f.dash_speed = diff["move_speed"] * 5.0
				_dodge_cooldown = 120
				_state = "DODGE"
				return new_delay
			elif skill2 and skill2.can_use(f):
				f.facing = dir_to_target
				skill2.try_use(f)
				_state = "DEFEND"
				return new_delay
			elif _is_melee(f) and f.attack_cooldown <= 0 and not f.attacking:
				f.facing = dir_to_target
				f.attacking = true
				f.attack_timer = 30
				f.attack_delay = 8
				f.attack_hit_dealt = false
				f.attack_cooldown = 60
				f.state = "attack"
				_state = "ATTACK"
				return new_delay
		# dist >= 150: 远处拉开距离（desire_min=200），下方 CHASE/KITE 处理
	
	# ── 4. PICKUP: 能量<20% 或 HP<40% → 寻找对应球 ──
	# 识别 AI 当前所在平台
	var ai_cx = f.pos_x + f.w / 2.0
	var ai_feet_y = f.pos_y + f.h
	var ai_plat = _find_ai_platform(ai_cx, ai_feet_y)

	var need_energy = f.energy < f.max_energy * 0.2
	var need_health = f.hp < f.max_hp * 0.4
	if need_energy or need_health:
		var pickup_result = _evaluate_pickup(f, ai_plat, dist, need_energy, need_health)
		if pickup_result != null:
			var pickup_plat = pickup_result["plat"]
			var pickup_target = pickup_result["target"]
			var pdist = absf(pickup_target.x + pickup_target.w / 2.0 - f.pos_x)
			if pdist > 150:
				# 导航到拾取物平台
				TrackSystem.navigate(f, ai_plat, pickup_plat, 0, 999999, false)
				TrackSystem.follow_path(f, ai_cx)
				_state = "PICKUP"
				return new_delay
	
	# ── 5. CHASE / KITE: 走位策略 ──
	
	# 地狱·影武者隐身中：无视陷阱直接冲向玩家
	if GameWorld.difficulty == "hell" and f.char_id == "shadowwarrior":
		var sw_chase = f.components.get_component("shadowwarrior") if f.components else null
		if sw_chase and sw_chase.stealth_active:
			f.vx = dir_to_target * diff["move_speed"]
			_update_state(f, dir_to_target)
			_state = "CHASE"
			return new_delay
	
	# 识别目标所在平台
	var target_feet_x = target.get("x", 0.0) if target is Dictionary else target.pos_x
	var target_feet_y = target.get("y", 0.0) if target is Dictionary else (target.pos_y + target.h)
	var target_plat = _find_target_platform(target_feet_x, target_feet_y)
	
	# 获取走位参数
	var desire = _get_desire_range(f, dist)
	
	# 残血修正：HP<20% 且 dist>=150 时 desire_min=200
	if f.hp < max_hp * 0.2 and dist >= 150:
		desire["min"] = maxf(desire["min"], 200)
	
	if _is_melee(f):
		# 近战：CHASE
		TrackSystem.navigate(f, ai_plat, target_plat, desire["min"], desire["max"], true)
		TrackSystem.follow_path(f, ai_cx)
		_state = "CHASE"
	else:
		# 远程：KITE
		TrackSystem.navigate(f, ai_plat, target_plat, desire["min"], desire["max"], false)
		TrackSystem.follow_path(f, ai_cx)
		_state = "KITE"
	
	return new_delay


# ── 状态更新 ──
static func _update_state(p: Fighter, mx: int):
	if p.grounded and mx == 0 and not p.attacking and not p.dashing:
		p.state = "idle"
	elif p.grounded and mx != 0 and not p.attacking and not p.dashing:
		p.state = "walk"
	if p.attacking and p.attack_timer <= 0:
		p.attacking = false; p.state = "idle"


# ── 角色走位参数 ──

## 判断是否为近战角色
static func _is_melee(f) -> bool:
	var melee_chars = ["knight", "assassin", "rose", "paladin", "dragon_knight", "shadowwarrior", "necro_knight"]
	return f.char_id in melee_chars

## 获取角色走位参数
## 返回 {min, max}
static func _get_desire_range(f, dist) -> Dictionary:
	# ── 地狱特殊走位 ──
	if GameWorld.difficulty == "hell":
		# 角色专属走位（通过 CharacterFactory 调度，配置驱动）
		var custom_desire = CharacterFactory.call_ai_hell_desire(f)
		if not custom_desire.is_empty():
			return custom_desire
		match f.char_id:
			"evoker":
				# HP < 60% → 跟随模式（缩小距离）
				if f.hp < f.max_hp * 0.6:
					return {"min": 0, "max": 120}
			"shadowwarrior":
				# 隐身中 → 快速贴脸
				var sw_comp = f.components.get_component("shadowwarrior") if f.components else null
				if sw_comp and sw_comp.stealth_active:
					return {"min": 0, "max": 30}
			"paladin":
				# 蓄力/冲刺中保持远距离
				if f.charging_skill1 or f.dashing:
					return {"min": 500, "max": 800}
				# 平时也保持较远距离等待蓄力机会
				return {"min": 350, "max": 600}

	match f.char_id:
		"knight":
			return {"min": 0, "max": 80}
		"assassin":
			return {"min": 0, "max": 80}
		"rose":
			return {"min": 0, "max": 80}
		"paladin":
			return {"min": 0, "max": 80}
		"dragon_knight":
			return {"min": 0, "max": 140}
		"necro_knight":
			return {"min": 0, "max": 80}
		"shadowwarrior":
			return {"min": 0, "max": 80}
		"archer":
			return {"min": 150, "max": 350}
		"evoker":
			return {"min": 150, "max": 400}
		_:
			# 默认：根据距离判断
			if dist < 80:
				return {"min": 0, "max": 80}
			return {"min": 150, "max": 350}


# ── 闪避判定 ──

## 判断 AI 是否应闪避
## 条件：
##   玩家攻击中 + dist < 100
##   或前方 150px 内有投射物
##   或 Archer 被贴脸 (dist < 80) → 100%
## 全局冷却 120 帧
## hell 概率 70%, other 20-50%
static func _should_dodge(f, target, dist, diff) -> bool:
	# 全局冷却
	if _dodge_cooldown > 0:
		_dodge_cooldown -= 1
		return false
	
	var roll = randf()
	var hell_bonus = 0.7 if GameWorld.difficulty == "hell" else (0.5 if GameWorld.difficulty == "hard" else 0.2)
	
	# Archer 被贴脸 → 100% 闪避
	if f.char_id == "archer" and dist < 80:
		return true
	
	# 玩家攻击中 + 距离 < 100（仅当目标是 Fighter 时才检查 attacking）
	if target is Fighter and target.hp > 0 and target.attacking and dist < 100 and roll < hell_bonus:
		return true
	
	# 前方 150px 内有敌方投射物（仅当 target 是 Fighter 时检查，phantom 不发射投射物）
	var target_x = target.pos_x if target is Fighter else (target.get("x", 0) if target is Dictionary else 0)
	var dir = 1 if target and (target_x > f.pos_x) else -1
	if target is Fighter:
		for p in GameWorld.projectiles:
			var owner = p.get("owner")
			if owner == target and absf(p.get("x", 0) - f.pos_x) < 150:
				return true
	
	return false


# ── 拾取评估 ──

## 评估拾取物
## 遍历所有活跃拾取物，找到所在平台
## 玩家在拾取物同平台 → 评分 -80（危险）
## 路径第一跳平台是玩家所在平台 → 评分 -60
## 评分 > 50 且 dist > 150 → 执行 PICKUP 状态
## 返回 {target, plat} 或 null
static func _evaluate_pickup(f, ai_plat, dist_to_enemy: float, need_energy: bool, need_health: bool):
	# 检查是否已被玩家接近（dist < 150 时不应拾取）
	if dist_to_enemy < 150:
		return null

	var best_score = 0.0
	var best_target = null
	var best_plat = null

	for item in GameWorld.pickups:
		if not item or not item.active:
			continue

		# 找到拾取物所在平台
		var item_cx = item.x + item.w / 2.0
		var item_feet_y = item.y + item.h / 2.0
		var item_plat = null
		for p in GameWorld.platforms:
			if p.get("terrain_type", -1) == 3: continue
			if _is_on_platform(item_cx, item_feet_y, p):
				item_plat = p
				break

		if item_plat == null:
			continue

		# 基础评分
		var score = 50.0

		# 角色特定权重
		if f.char_id == "assassin" and item.type == "energy":
			score += 20.0
		elif f.char_id == "paladin" and item.type == "health":
			score += 30.0
		elif f.char_id == "evoker" and item.type == "cooldown":
			score += 40.0

		# 通用需求权重：需能量时能量球+20，需血量时血球+20
		if need_energy and item.type == "energy":
			score += 20.0
		if need_health and item.type == "health":
			score += 20.0
		
		# 玩家在拾取物同平台 → 危险，评分 -80
		var player_on_plat = false
		if GameWorld.player:
			var pcx = GameWorld.player.pos_x + GameWorld.player.w / 2.0
			var pfy = GameWorld.player.pos_y + GameWorld.player.h
			for p in GameWorld.platforms:
				if p.get("terrain_type", -1) == 3: continue
				if _is_on_platform(pcx, pfy, p) and p == item_plat:
					player_on_plat = true
					break
		if player_on_plat:
			score -= 80.0
		elif ai_plat != null and item_plat != ai_plat:
			# 不同平台：检查路径第一跳是否是玩家平台
			var path = TrackSystem._find_path(ai_plat, item_plat)
			if path.size() >= 2:
				var first_jump = path[1]
				if GameWorld.player:
					var pcx2 = GameWorld.player.pos_x + GameWorld.player.w / 2.0
					var pfy2 = GameWorld.player.pos_y + GameWorld.player.h
					for p in GameWorld.platforms:
						if p.get("terrain_type", -1) == 3: continue
						if _is_on_platform(pcx2, pfy2, p) and p == first_jump:
							score -= 60.0
							break
		
		if score > best_score:
			best_score = score
			best_target = item
			best_plat = item_plat
	
	if best_score > 50 and best_target != null:
		return {"target": best_target, "plat": best_plat}
	
	return null


# ── 平台辅助 ──

## 查找 AI 所在平台
static func _find_ai_platform(cx: float, feet_y: float):
	for p in GameWorld.platforms:
		if p.get("terrain_type", -1) == 3: continue
		if _is_on_platform(cx, feet_y, p):
			return p
	return null

## 查找目标所在平台
static func _find_target_platform(feet_x: float, feet_y: float):
	for p in GameWorld.platforms:
		if p.get("terrain_type", -1) == 3: continue
		if _is_on_platform(feet_x, feet_y, p):
			return p
	return null

## 判断点 (x, y) 是否站在平台 p 上
static func _is_on_platform(x: float, y: float, p: Dictionary) -> bool:
	if p.get("terrain_type", -1) == 3:
		return false
	return x >= p["x"] and x <= p["x"] + p["w"] and absf(y - p["y"]) < 20

## 在 GameWorld.platforms 中查找平台下标
static func _plat_index(plat: Dictionary) -> int:
	for i in range(GameWorld.platforms.size()):
		if GameWorld.platforms[i] == plat:
			return i
	return -1
