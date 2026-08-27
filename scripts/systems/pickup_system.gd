class_name PickupSystem

# ===== Pickup & End System =====
static func update_pickups_and_end():
	# Pickup collection
	for i in range(GameWorld.pickups.size()-1,-1,-1):
		var item = GameWorld.pickups[i]
		if not item.active: GameWorld.pickups.remove_at(i); continue
		item.update()
		for t in [GameWorld.player, GameWorld.enemy]:
			if t.hp <= 0: continue
			var d = sqrt(pow(t.pos_x+t.w/2-item.x-item.w/2,2)+pow(t.pos_y+t.h/2-item.y-item.h/2,2))
			if d < 35:
				item.apply_effect(t); item.active = false
				GameWorld.pickups.remove_at(i); break
	# Pickup spawn timer (difficulty-based)
	var interval = _pickup_interval()
	if GameWorld.pickup_timer <= 0:
		_spawn_pickup()
		GameWorld.pickup_timer = interval
	else:
		GameWorld.pickup_timer -= 1
	# Particle lifecycle
	GameWorld.particles = GameWorld.particles.filter(func(p): return p.update())
	# Explosion effects fade out
	for i2 in range(GameWorld.explosion_effects.size() - 1, -1, -1):
		var e = GameWorld.explosion_effects[i2]
		e["life"] -= 1
		e["alpha"] = float(e["life"]) / float(e["max_life"])
		if e["life"] <= 0:
			GameWorld.explosion_effects.remove_at(i2)
	# Game over check —— 击杀瞬间触发 3 秒时缓（胜利/失败演出），时缓结束后再结算
	# 练习模式：死亡不触发游戏结束，改为短延迟复活
	if GameWorld.practice_mode:
		_practice_respawn_update()
	elif GameWorld.death_slowmo_result.is_empty():
		if GameWorld.player.hp <= 0 or GameWorld.enemy.hp <= 0:
			GameWorld.death_slowmo_result = "lose" if GameWorld.player.hp <= 0 else "win"
			GameWorld.trigger_slow_motion(GameWorld.DEATH_SLOWMO_DURATION)
	elif GameWorld.slow_mo_timer <= 0:
		# 时缓结束 → 结算胜负
		GameWorld.game_over = true
		GameWorld.game_result = GameWorld.death_slowmo_result

# ── 练习模式：死亡复活（60 帧 = 1 秒）──
const PRACTICE_RESPAWN_FRAMES := 60

static func _practice_respawn_update():
	if GameWorld.player.hp <= 0 and GameWorld.practice_respawn_player <= 0:
		GameWorld.practice_respawn_player = PRACTICE_RESPAWN_FRAMES
	if GameWorld.enemy.hp <= 0 and GameWorld.practice_respawn_enemy <= 0:
		GameWorld.practice_respawn_enemy = PRACTICE_RESPAWN_FRAMES
	if GameWorld.practice_respawn_player > 0:
		GameWorld.practice_respawn_player -= 1
		if GameWorld.practice_respawn_player <= 0:
			_practice_revive(GameWorld.player)
	if GameWorld.practice_respawn_enemy > 0:
		GameWorld.practice_respawn_enemy -= 1
		if GameWorld.practice_respawn_enemy <= 0:
			_practice_revive(GameWorld.enemy)

## 练习模式复活：清除该角色遗留的投射物/分身/召唤物，满血回出生点
static func _practice_revive(f):
	if not f or f.hp > 0:
		return
	for i in range(GameWorld.projectiles.size() - 1, -1, -1):
		if GameWorld.projectiles[i].get("owner") == f:
			GameWorld.projectiles.remove_at(i)
	for i in range(GameWorld.phantoms.size() - 1, -1, -1):
		if GameWorld.phantoms[i].get("owner") == f:
			GameWorld.phantoms.remove_at(i)
	for i in range(GameWorld.evoker_summons.size() - 1, -1, -1):
		if GameWorld.evoker_summons[i].get("owner") == f:
			GameWorld.evoker_summons.remove_at(i)
	f.hp = f.max_hp
	f.pos_x = f.spawn_x
	f.pos_y = f.spawn_y
	f.vx = 0
	f.vy = 0
	f.grounded = true
	f.attacking = false
	f.attack_timer = 0
	f.attack_delay = 0
	f.attack_hit_dealt = false
	f.dashing = false
	f.dash_remaining = 0
	f.blocking = false
	f.shield_active = false
	f.shield_timer = 0
	f.statuses.clear()
	f.is_invincible = false
	f.invincible_timer = 0
	f.state = "idle"
	f.set_animation_state("idle")
	f.energy = 0.0

static func _pickup_interval() -> int:
	# hard=720 帧（12 秒），hell=900 帧（15 秒），其余=420 帧（7 秒）
	if Constants.difficulty_at_least(GameWorld.difficulty, "hell"):
		return 900
	if Constants.difficulty_at_least(GameWorld.difficulty, "hard"):
		return 720
	return 420

static func _initial_pickup_count() -> int:
	# hard/hell 初始 4 个，其余 6 个
	if Constants.difficulty_at_least(GameWorld.difficulty, "hard"):
		return 4
	return 6

static func _max_pickups() -> int:
	# hard/hell 上限 6 个，其余 10 个
	if Constants.difficulty_at_least(GameWorld.difficulty, "hard"):
		return 6
	return 10

static func init_pickups():
	GameWorld.pickups.clear()
	var count = _initial_pickup_count()
	for i in count:
		_spawn_pickup()

static func _spawn_pickup():
	var max_pickups = _max_pickups()
	if GameWorld.pickups.size() >= max_pickups:
		return
	var px = 100 + randf() * 2200
	var py = 380 - 30 - randf() * 120
	# Weight-based type selection — hell 沿用 hard_weight（更少 attack/cooldown）
	var keys = Pickup.PICKUP_DEFS.keys()
	var total: float = 0.0
	var weight_key = "hard_weight" if Constants.difficulty_at_least(GameWorld.difficulty, "hard") else "weight"
	for k in keys:
		total += Pickup.PICKUP_DEFS[k][weight_key]
	var r = randf() * total
	var chosen = keys[0]
	for k in keys:
		r -= Pickup.PICKUP_DEFS[k][weight_key]
		if r <= 0:
			chosen = k
			break
	GameWorld.pickups.append(Pickup.new(px, py, chosen))
