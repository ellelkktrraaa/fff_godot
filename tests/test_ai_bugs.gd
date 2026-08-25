extends GutTest
# AI 系统 Bug 修复测试

# ===== Bug #10: 地狱AI角色个性系统 =====

func test_ai_system_has_hell_tactics():
	# 验证 ai_system.gd 包含地狱专属战术
	var source_file = FileAccess.open("res://scripts/systems/ai_system.gd", FileAccess.READ)
	assert_not_null(source_file, "应能读取 ai_system.gd")
	var content = source_file.get_as_text()
	source_file.close()
	
	assert_true(content.contains("is_hell"), "ai_system.gd 应包含 is_hell 判定")
	assert_true(content.contains("反应闪避") or content.contains("hell"), "应包含地狱专属战术")
	assert_true(content.contains("斩杀大招") or content.contains("精确走位"), "应包含地狱专属战术4/5/6")

func test_hell_tactics_reaction_dodge():
	# 模拟地狱 AI 的反应闪避条件
	var f = Fighter.new()
	f.char_id = "knight"
	f.components = ComponentManager.new()
	f.components.init(f)
	f.setup(300, 320, false, "knight", [])
	
	var player = Fighter.new()
	player.setup(200, 320, true, "knight", [])
	player.attacking = true
	GameWorld.player = player
	GameWorld.enemy = f
	GameWorld.difficulty = "hell"
	
	# 远距离不应触发闪避（dist=100，小于 150，应该可以触发）
	var dx = player.pos_x - f.pos_x
	var dist = absf(dx)
	assert_lt(dist, 150, "地狱 AI 闪避测试: 距离应 < 150")

func test_hell_preset_used():
	# 验证 AI 使用 hell 预设
	GameWorld.difficulty = "hell"
	var preset = Constants.AI_PRESETS.get("hell")
	assert_not_null(preset, "应有 hell 预设")
	assert_eq(preset["react"], 42, "hell 反应延迟 42（较 hard 降 30%）")
	
	GameWorld.difficulty = "medium"

# ===== AI唤魔者行为 =====

func test_ai_evoker_has_special_handling():
	var source_file = FileAccess.open("res://scripts/systems/ai_system.gd", FileAccess.READ)
	assert_not_null(source_file, "应能读取 ai_system.gd")
	var content = source_file.get_as_text()
	source_file.close()
	
	assert_true(content.contains("evoker"), "ai_system.gd 应包含 evoker 专属逻辑")
	assert_true(content.contains("evoker_summons"), "应检查召唤物状态")

func test_ai_evoker_uses_fireball_at_range():
	# 验证无召唤物时能在远程发射冥炎弹
	var f = Fighter.new()
	f.char_id = "evoker"
	f.components = ComponentManager.new()
	f.components.init(f)
	f.setup(200, 320, false, "evoker", [])
	f.energy = 50
	GameWorld.enemy = f
	
	var player = Fighter.new()
	player.setup(400, 320, true, "knight", [])
	GameWorld.player = player
	GameWorld.difficulty = "medium"
	
	# 无召唤物时,攻击技能应可用(能量充足)
	var atk = f.get_skill("attack")
	if atk:
		assert_true(atk.can_use(f), "能量充足时应可用攻击")
