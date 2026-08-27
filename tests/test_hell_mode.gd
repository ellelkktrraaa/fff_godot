extends GutTest
# Hell 模式配置自动化测试
# 验证 hell 难度的 AI 预设、难度比较函数、掉落物参数

# ===== Constants.AI_PRESETS =====

func test_ai_presets_contains_hell():
	assert_true(Constants.AI_PRESETS.has("hell"), "AI_PRESETS 应包含 hell 难度")
	assert_true(Constants.AI_PRESETS.has("easy"), "AI_PRESETS 应包含 easy 难度")
	assert_true(Constants.AI_PRESETS.has("medium"), "AI_PRESETS 应包含 medium 难度")
	assert_true(Constants.AI_PRESETS.has("hard"), "AI_PRESETS 应包含 hard 难度")

func test_hell_preset_values():
	var hell = Constants.AI_PRESETS["hell"]
	assert_eq(hell["react"], 42, "hell 反应延迟应为 42（基础 think_delay 降 30%）")
	assert_eq(hell["aggro"], 0.95, "hell 攻击性应为 0.95")
	assert_eq(hell["dodge"], 0.6, "hell 闪避率应为 0.6")
	assert_eq(hell["skill_rate"], 0.9, "hell 技能使用率应为 0.9")
	assert_eq(hell["move_speed"], 1.3, "hell 移动速度应为 1.3")
	assert_eq(hell["jump_rate"], 0.08, "hell 跳跃率应为 0.08")

func test_hell_is_hardest_preset():
	# hell 应该在所有维度上都不低于 hard
	var hell = Constants.AI_PRESETS["hell"]
	var hard = Constants.AI_PRESETS["hard"]
	assert_lt(hell["react"], hard["react"], "hell 反应应比 hard 更快（更小）")
	assert_gt(hell["aggro"], hard["aggro"], "hell 攻击性应高于 hard")
	assert_gt(hell["dodge"], hard["dodge"], "hell 闪避应高于 hard")
	assert_gt(hell["skill_rate"], hard["skill_rate"], "hell 技能率应高于 hard")
	assert_gt(hell["move_speed"], hard["move_speed"], "hell 移动速度应高于 hard")
	assert_gt(hell["jump_rate"], hard["jump_rate"], "hell 跳跃率应高于 hard")

# ===== Constants.DIFFICULTY_LEVELS =====

func test_difficulty_levels_order():
	assert_eq(Constants.DIFFICULTY_LEVELS, ["easy", "medium", "hard", "hell"],
		"难度等级顺序应为 easy < medium < hard < hell")

# ===== Constants.difficulty_at_least =====

func test_difficulty_at_least_basic():
	assert_true(Constants.difficulty_at_least("hell", "hell"), "hell 应不低于 hell")
	assert_true(Constants.difficulty_at_least("hell", "hard"), "hell 应不低于 hard")
	assert_true(Constants.difficulty_at_least("hell", "medium"), "hell 应不低于 medium")
	assert_true(Constants.difficulty_at_least("hell", "easy"), "hell 应不低于 easy")

func test_difficulty_at_least_hard():
	assert_true(Constants.difficulty_at_least("hard", "hard"), "hard 应不低于 hard")
	assert_true(Constants.difficulty_at_least("hard", "medium"), "hard 应不低于 medium")
	assert_false(Constants.difficulty_at_least("hard", "hell"), "hard 不应不低于 hell")

func test_difficulty_at_least_lower():
	assert_false(Constants.difficulty_at_least("easy", "medium"), "easy 不应不低于 medium")
	assert_false(Constants.difficulty_at_least("medium", "hard"), "medium 不应不低于 hard")
	assert_false(Constants.difficulty_at_least("easy", "hell"), "easy 不应不低于 hell")

func test_difficulty_at_least_invalid():
	assert_false(Constants.difficulty_at_least("invalid", "hard"), "未知难度应返回 false")
	assert_false(Constants.difficulty_at_least("hard", "invalid"), "未知阈值应返回 false")
	assert_false(Constants.difficulty_at_least("", ""), "空字符串应返回 false")

# ===== PickupSystem hell 模式参数 =====

func test_pickup_interval_hell():
	GameWorld.difficulty = "hell"
	assert_eq(PickupSystem._pickup_interval(), 900,
		"hell 模式掉落间隔应为 900 帧（15 秒）")

func test_pickup_interval_hard():
	GameWorld.difficulty = "hard"
	assert_eq(PickupSystem._pickup_interval(), 720,
		"hard 模式掉落间隔应为 720 帧（12 秒）")

func test_pickup_interval_medium():
	GameWorld.difficulty = "medium"
	assert_eq(PickupSystem._pickup_interval(), 420,
		"medium 模式掉落间隔应为 420 帧（7 秒）")

func test_pickup_interval_easy():
	GameWorld.difficulty = "easy"
	assert_eq(PickupSystem._pickup_interval(), 420,
		"easy 模式掉落间隔应为 420 帧（7 秒）")

func test_initial_pickup_count_hell():
	GameWorld.difficulty = "hell"
	assert_eq(PickupSystem._initial_pickup_count(), 4,
		"hell 模式初始掉落物应为 4 个")

func test_max_pickups_hell():
	GameWorld.difficulty = "hell"
	assert_eq(PickupSystem._max_pickups(), 6,
		"hell 模式掉落物上限应为 6 个")

func test_max_pickups_easy():
	GameWorld.difficulty = "easy"
	assert_eq(PickupSystem._max_pickups(), 10,
		"easy 模式掉落物上限应为 10 个")
