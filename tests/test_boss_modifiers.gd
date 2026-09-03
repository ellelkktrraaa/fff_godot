extends GutTest
# Boss Modifier 单元测试（Fighter.apply_boss_modifiers + apply_damage 全局倍率插桩）
# 覆盖：
#   1) apply_boss_modifiers 后 hp/max_hp/defense/attack_damage/attack_range/attack_speed/
#      max_energy/energy_regen/倍率/ai_overrides/boss_name 全部按 modifiers 覆盖
#   2) 覆盖后 add_stat_mod 天赋修饰仍以 Boss 数值为基（_stat_base 基快照重建）
#   3) damage_multiplier=1.5 的 attacker 打 damage_taken_multiplier=0.5 的目标
#      → 扣血 = 原始 ×0.75（统一在 apply_damage 结算点插桩）
#   4) 默认倍率 1.0：伤害原样结算（PVE 零影响）
#   5) ai_overrides 走副本合并，不污染 Constants.AI_PRESETS 全局预设

func _make_fighter(char_id: String, x: float, y: float, is_player: bool) -> Fighter:
	var f = Fighter.new()
	f.components = ComponentManager.new()
	f.components.init(f)
	f.setup(x, y, is_player, char_id, [])
	f.hp = f.max_hp
	f.energy = f.max_energy
	return f

func before_each():
	GameWorld.practice_mode = false
	GameWorld.practice_enemy_ai = false
	GameWorld.practice_infinite_fire = false
	GameWorld.game_mode = "pve"
	GameWorld.difficulty = "medium"
	GameWorld.boss_id = ""
	GameWorld.game_over = false
	GameWorld.death_slowmo_result = ""

func _sample_mods() -> Dictionary:
	return {
		"hp": 800.0,
		"defense": 8.0,
		"attack_damage": 12.0,
		"attack_range": 70.0,
		"attack_speed": 2.6,
		"max_energy": 150.0,
		"energy_regen": 0.12,
		"damage_multiplier": 1.5,
		"damage_taken_multiplier": 0.5,
		"ai": {"react": 90, "aggro": 0.9, "move_speed": 1.2},
		"boss_name": "堕圣骑士",
	}

func test_apply_boss_modifiers_overwrites_base_stats():
	var f = _make_fighter("paladin", 300, 320, false)
	f.apply_boss_modifiers(_sample_mods())
	assert_eq(f.max_hp, 800.0, "max_hp 覆盖")
	assert_eq(f.hp, 800.0, "hp 同步 max_hp")
	assert_eq(f.max_energy, 150.0, "max_energy 覆盖")
	assert_eq(f.energy_regen, 0.12, "energy_regen 覆盖")
	assert_eq(f.attack_speed, 2.6, "attack_speed 覆盖")
	assert_eq(f.attack_range, 70.0, "attack_range 覆盖")
	assert_eq(f.attack_damage, 12.0, "attack_damage 覆盖")
	assert_eq(f.defense, 8.0, "defense 覆盖")
	assert_eq(f.damage_multiplier, 1.5, "damage_multiplier 解析")
	assert_eq(f.damage_taken_multiplier, 0.5, "damage_taken_multiplier 解析")
	assert_eq(f.ai_overrides.get("react", -1), 90, "ai_overrides 解析 react")
	assert_eq(f.ai_overrides.get("move_speed", -1), 1.2, "ai_overrides 解析 move_speed")
	assert_eq(f.boss_name, "堕圣骑士", "boss_name 解析")

func test_add_stat_mod_after_boss_apply_uses_boss_base():
	var f = _make_fighter("paladin", 300, 320, false)
	f.apply_boss_modifiers(_sample_mods())
	f.add_stat_mod("max_hp", "talent_x", 200.0, 1.0)
	assert_eq(f.max_hp, 1000.0, "天赋修饰以 Boss 数值为基：800 + 200")
	f.add_stat_mod("defense", "talent_y", 2.0, 1.0)
	assert_eq(f.defense, 10.0, "天赋修饰以 Boss 数值为基：8 + 2")
	f.add_stat_mod("attack_damage", "talent_z", 0.0, 1.5)
	assert_eq(f.attack_damage, 18.0, "天赋乘法修饰以 Boss 数值为基：12 × 1.5")
	assert_true(f.hp <= f.max_hp, "max_hp 被放大后 hp 不超上限")

func test_apply_after_add_stat_mod_keeps_boss_base():
	var f = _make_fighter("paladin", 300, 320, false)
	# 先挂一个基于旧基的修饰，再应用 Boss 覆盖 → 重放后仍以 Boss 数值为新基
	f.add_stat_mod("attack_damage", "talent_pre", 5.0, 1.0)
	f.apply_boss_modifiers(_sample_mods())
	assert_eq(f.attack_damage, 17.0, "Boss 覆盖后旧修饰按新基重放：12 + 5")

func test_damage_multipliers_apply_in_apply_damage():
	var attacker = _make_fighter("knight", 200, 300, true)
	var target = _make_fighter("knight", 400, 300, false)
	GameWorld.player = attacker
	GameWorld.enemy = target
	attacker.damage_multiplier = 1.5
	target.damage_taken_multiplier = 0.5
	target.hp = 100.0
	target.defense = 0.0
	var before := target.hp
	Fighter.apply_damage(target, 10.0, attacker)
	var expected := before - 10.0 * 1.5 * 0.5  # = 7.5
	assert_almost_eq(target.hp, expected, 0.001, "扣血 = 原始 ×0.75（attacker×1.5，target×0.5）")

func test_default_multipliers_are_neutral():
	var attacker = _make_fighter("knight", 200, 300, true)
	var target = _make_fighter("knight", 400, 300, false)
	GameWorld.player = attacker
	GameWorld.enemy = target
	target.hp = 100.0
	target.defense = 0.0
	Fighter.apply_damage(target, 10.0, attacker)
	assert_almost_eq(target.hp, 90.0, 0.001, "默认倍率 1.0：伤害原样结算（PVE 零影响）")

func test_ai_overrides_do_not_pollute_presets():
	var enemy = _make_fighter("knight", 300, 320, false)
	var player = _make_fighter("knight", 450, 320, true)
	GameWorld.player = player
	GameWorld.enemy = enemy
	GameWorld.difficulty = "easy"
	var original_react: int = Constants.AI_PRESETS["easy"]["react"]
	enemy.ai_overrides = {"react": 90, "aggro": 0.9, "move_speed": 1.2}
	GameWorld.platforms = [{"x": 0, "y": 320, "w": 800, "h": 10, "terrain_type": 0}]
	for i in 3:
		AISystem.update_ai(0)
	assert_eq(Constants.AI_PRESETS["easy"]["react"], original_react,
		"ai_overrides 合并走副本，全局 preset 不被污染")
