extends GutTest
# 练习模式功能测试
# 覆盖：敌人AI开关 / 死亡复活不结束 / 伤害累计 / 技能介绍分类 / 主菜单入口

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
	GameWorld.practice_damage_display = false
	GameWorld.game_mode = "pve"
	GameWorld.difficulty = "medium"
	GameWorld.game_over = false
	GameWorld.death_slowmo_result = ""
	GameWorld.practice_damage_dealt = 0.0
	GameWorld.practice_damage_last_frame = -9999
	GameWorld.practice_respawn_player = 0
	GameWorld.practice_respawn_enemy = 0

# ── 修改过的脚本能编译 ──

func test_modified_scripts_compile():
	assert_not_null(load("res://scripts/game.gd"), "game.gd 编译")
	assert_not_null(load("res://scripts/game_world.gd"), "game_world.gd 编译")
	assert_not_null(load("res://scripts/fighter.gd"), "fighter.gd 编译")
	assert_not_null(load("res://scripts/main_menu.gd"), "main_menu.gd 编译")
	assert_not_null(load("res://scripts/systems/ai_system.gd"), "ai_system.gd 编译")
	assert_not_null(load("res://scripts/systems/pickup_system.gd"), "pickup_system.gd 编译")
	assert_not_null(load("res://scripts/systems/hud_system.gd"), "hud_system.gd 编译")

# ── 练习模式敌人 AI 开关 ──

func test_practice_ai_disabled_by_default():
	var enemy = _make_fighter("knight", 300, 320, false)
	var player = _make_fighter("knight", 450, 320, true)
	GameWorld.player = player
	GameWorld.enemy = enemy
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	GameWorld.practice_enemy_ai = false
	enemy.vx = 0.0
	for i in 5:
		AISystem.update_ai(0)
	assert_eq(enemy.vx, 0.0, "练习模式默认敌人不受 AI 控制（vx 不被修改）")

func test_practice_ai_enemy_attack_is_hell():
	var enemy = _make_fighter("knight", 300, 320, false)
	var player = _make_fighter("knight", 450, 320, true)
	GameWorld.player = player
	GameWorld.enemy = enemy
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	GameWorld.practice_enemy_ai = true
	assert_eq(GameWorld.effective_ai_difficulty(), "hell", "敌人攻击开启 = 地狱 AI")
	GameWorld.platforms = [{"x": 0, "y": 320, "w": 800, "h": 10, "terrain_type": 0}]
	var r = AISystem.update_ai(0)
	assert_true(r >= 0, "敌人攻击开启后 AI 正常运行（地狱）")

func test_effective_difficulty_normal_in_pve():
	GameWorld.game_mode = "pve"
	GameWorld.practice_mode = false
	GameWorld.difficulty = "hard"
	assert_eq(GameWorld.effective_ai_difficulty(), "hard", "非练习模式返回真实难度")

# ── 练习模式死亡不结束 + 复活 ──

func test_practice_no_game_over_and_revive():
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	GameWorld.player = _make_fighter("knight", 200, 300, true)
	GameWorld.enemy = _make_fighter("knight", 600, 300, false)
	GameWorld.enemy.hp = 0
	for i in 70:
		PickupSystem.update_pickups_and_end()
	assert_false(GameWorld.game_over, "练习模式死亡不触发游戏结束")
	assert_gt(GameWorld.enemy.hp, 0, "练习模式敌人应复活")

# ── 练习模式伤害累计 ──

func test_practice_damage_tracking():
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	GameWorld.player = _make_fighter("knight", 200, 300, true)
	GameWorld.enemy = _make_fighter("knight", 600, 300, false)
	Fighter.apply_damage(GameWorld.enemy, 10.0, GameWorld.player)
	assert_eq(GameWorld.practice_damage_dealt, 10.0, "玩家对敌人造成的伤害应累计")
	assert_eq(GameWorld.practice_damage_last_frame, GameWorld.frame, "伤害帧号应记录")

func test_practice_damage_not_tracked_in_pve():
	GameWorld.game_mode = "pve"
	GameWorld.practice_mode = false
	GameWorld.player = _make_fighter("knight", 200, 300, true)
	GameWorld.enemy = _make_fighter("knight", 600, 300, false)
	Fighter.apply_damage(GameWorld.enemy, 10.0, GameWorld.player)
	assert_eq(GameWorld.practice_damage_dealt, 0.0, "非练习模式不累计")

# ── 练习模式主动天赋无冷却 ──

func test_practice_active_talent_no_cd():
	TalentPool.init()
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	var player = _make_fighter("knight", 200, 300, true)
	GameWorld.player = player
	player.talent_manager = TalentManager.new()
	player.talent_manager.init(player, ["blaze_rush"])
	assert_eq(player.talent_slots.size(), 1, "主动天赋已装配")
	player.ad["blaze_rush"]["cd"] = 600
	GameWorld.practice_clear_talent_cd()
	assert_eq(player.ad["blaze_rush"]["cd"], 0, "练习模式下主动天赋冷却被清零")

func test_active_talent_cd_normal_outside_practice():
	TalentPool.init()
	GameWorld.game_mode = "pve"
	GameWorld.practice_mode = false
	var player = _make_fighter("knight", 200, 300, true)
	GameWorld.player = player
	player.talent_manager = TalentManager.new()
	player.talent_manager.init(player, ["blaze_rush"])
	player.ad["blaze_rush"]["cd"] = 600
	GameWorld.practice_clear_talent_cd()
	assert_eq(player.ad["blaze_rush"]["cd"], 600, "非练习模式主动天赋冷却不受影响")

# ── 练习模式：空格按住控制对手 ──

func _make_keys(space: bool, up: bool = false, attack: bool = false) -> Dictionary:
	return {
		"left": false, "right": false, "up": up, "down": false,
		"attack": attack, "skill1": false, "skill2": false, "ult": false, "sub": false,
		"talent1": false, "talent2": false, "talent3": false, "space": space,
	}

func test_practice_space_controls_enemy_jump():
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	var player = _make_fighter("knight", 200, 300, true)
	var enemy = _make_fighter("knight", 600, 300, false)
	GameWorld.player = player
	GameWorld.enemy = enemy
	player.grounded = true
	enemy.grounded = true
	InputHandler.update_player_input(GameWorld, _make_keys(true, true))
	assert_false(enemy.grounded, "空格+W 控制对手跳跃")
	assert_eq(enemy.vy, -10.0, "对手跳跃初速度")
	assert_true(player.grounded, "玩家不受空格+W 影响")

func test_practice_space_controls_enemy_attack():
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	var player = _make_fighter("knight", 200, 300, true)
	var enemy = _make_fighter("knight", 600, 300, false)
	GameWorld.player = player
	GameWorld.enemy = enemy
	InputHandler.update_player_input(GameWorld, _make_keys(true, false, true))
	assert_true(enemy.attacking, "空格+J 控制对手普攻")
	assert_false(player.attacking, "玩家不受空格+J 影响")

func test_practice_no_space_player_normal_control():
	GameWorld.game_mode = "practice"
	GameWorld.practice_mode = true
	var player = _make_fighter("knight", 200, 300, true)
	var enemy = _make_fighter("knight", 600, 300, false)
	GameWorld.player = player
	GameWorld.enemy = enemy
	player.grounded = true
	enemy.grounded = true
	InputHandler.update_player_input(GameWorld, _make_keys(false, true))
	assert_false(player.grounded, "未按空格：W 正常控制玩家跳跃")
	assert_true(enemy.grounded, "敌人不受影响")

# ── 技能介绍分类 ──

func test_practice_skill_intro_classify():
	var game = load("res://scripts/game.gd").new()
	# 无关键词 → 按顺序补位
	var s1 = game._classify_dex_skills([
		{"name": "三式刀法", "desc": "普攻"},
		{"name": "千枫落华斩", "desc": "一技能"},
		{"name": "玄鸟衔月闪", "desc": "二技能"},
		{"name": "孤鸿踏雪", "desc": "大招"},
	])
	assert_true(s1.has("attack") and s1.has("skill1") and s1.has("skill2") and s1.has("ult"),
		"无关键词技能按顺序补位：%s" % [s1.keys()])
	# 带关键词 → 直接归类
	var s2 = game._classify_dex_skills([
		{"name": "射箭（普通攻击）", "desc": "x"},
		{"name": "火矢（技能一）", "desc": "x"},
		{"name": "追踪（技能二）", "desc": "x"},
		{"name": "箭雨（大招）", "desc": "x"},
	])
	assert_true(s2.has("attack") and s2.has("skill1") and s2.has("skill2") and s2.has("ult"),
		"带关键词技能直接归类")
	# 唤魔者：第一个是特殊机制，普攻带关键词 → 特殊机制归入 special
	var s3 = game._classify_dex_skills([
		{"name": "契约（特殊机制）", "desc": "召唤物机制"},
		{"name": "冥炎弹 / 役使（普攻）", "desc": "x"},
		{"name": "深渊召令（技能一）", "desc": "x"},
		{"name": "幽蓝之境 / 魔令（技能二）", "desc": "x"},
		{"name": "虚空裂隙（大招）", "desc": "x"},
	])
	assert_true(s3.has("attack") and s3.has("skill1") and s3.has("skill2") and s3.has("ult"),
		"唤魔者技能分类")
	assert_true(s3.get("special", []).size() > 0, "唤魔者特殊机制归入 special")
	game.free()

# ── 主菜单入口：右键 PVE 触发 ──

func test_main_menu_pve_right_click_wired():
	# 不加入场景树（避免 _ready 加载资源在 headless 下产生噪音错误），仅校验入口结构与接线函数
	var scene: PackedScene = load("res://scenes/main_menu.tscn")
	var inst = scene.instantiate()
	var btn = inst.find_child("PVEButton", true, false)
	assert_not_null(btn, "PVE 按钮存在")
	assert_false(inst.find_child("PracticeBtn", true, false) != null, "独立练习按钮已移除")
	assert_true(inst.has_method("_on_pve_gui_input"), "PVE 右键处理函数已定义（接线见 _ready）")
	inst.free()
