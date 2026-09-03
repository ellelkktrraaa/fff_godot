extends GutTest
# Boss 战胜利进度（难度解锁 + 持久化）测试
# 覆盖：
#   1) 默认：easy 恒解锁，medium/hard/hell 锁定；未知 Boss / 非法难度安全回退
#   2) 击败 easy → medium 解锁、hard/hell 仍锁
#   3) 连续/重复击败幂等不越级
#   4) 从初始直接击败 hard → 解锁 hell（idx2 → idx3）
#   5) 击败低于当前档位不回退
#   6) get_boss_unlocked_index 各阶段数值正确
#   7) 持久化：save_path 指向临时文件，写入后清内存 + ensure_init 读回相同状态
#   8) reset_boss_progress 恢复初始且不影响其它 Boss，并落盘

const TEST_SAVE_PATH := "user://tmp_boss_progress_test.cfg"

func before_each():
	# 重置内存状态与路径绑定；指向临时存档并确保文件不存在 → 每次从干净默认态开始
	ProgressSystem.reset_for_tests()
	ProgressSystem.save_path = TEST_SAVE_PATH
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)

func test_scripts_compile():
	assert_not_null(load("res://scripts/systems/progress_system.gd"), "progress_system.gd 编译")
	assert_not_null(load("res://data/progress/boss_difficulty_hook.gd"), "boss_difficulty_hook.gd 编译")
	assert_not_null(load("res://scripts/systems/pickup_system.gd"), "pickup_system.gd 编译")

func test_default_easy_unlocked_others_locked():
	ProgressSystem.ensure_init()
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "easy"), "默认 easy 解锁")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "medium"), "默认 medium 锁定")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hard"), "默认 hard 锁定")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hell"), "默认 hell 锁定")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 0, "默认解锁档 = 0")

func test_unknown_boss_and_invalid_difficulty_safe():
	ProgressSystem.ensure_init()
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("no_such_boss", "easy"), "未知 Boss easy 解锁")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("no_such_boss", "hard"), "未知 Boss hard 锁定")
	assert_eq(ProgressSystem.get_boss_unlocked_index("no_such_boss"), 0, "未知 Boss 解锁档 = 0")
	ProgressSystem.on_boss_defeated("fallen_paladin", "nightmare")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 0, "非法难度不推进")

func test_defeat_easy_unlocks_medium_not_hard_hell():
	ProgressSystem.on_boss_defeated("fallen_paladin", "easy")
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "easy"), "easy 仍解锁")
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "medium"), "击败 easy 后 medium 解锁")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hard"), "hard 仍锁")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hell"), "hell 仍锁")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 1, "解锁档推进到 1")

func test_repeated_defeat_is_idempotent_no_skip():
	for i in 5:
		ProgressSystem.on_boss_defeated("fallen_paladin", "easy")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 1, "重复击败 easy 不越级")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hard"), "重复 easy 不会解锁 hard")
	for i in 3:
		ProgressSystem.on_boss_defeated("fallen_paladin", "medium")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 2, "击败 medium 推进到 2")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hell"), "hell 仍锁")
	ProgressSystem.on_boss_defeated("fallen_paladin", "medium")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 2, "重复击败 medium 仍为 2")

func test_direct_hard_defeat_unlocks_hell_from_initial():
	ProgressSystem.on_boss_defeated("fallen_paladin", "hard")
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hard"), "hard 解锁")
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hell"), "击败 hard 解锁 hell")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 3, "直接击败 hard 解锁档 = 3")

func test_defeat_lower_difficulty_never_regresses():
	ProgressSystem.on_boss_defeated("fallen_paladin", "hard")   # → 3
	ProgressSystem.on_boss_defeated("fallen_paladin", "easy")   # 不回落
	ProgressSystem.on_boss_defeated("fallen_paladin", "medium") # 不回落
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 3, "击败低档不回退")
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hell"), "hell 仍解锁")

func test_get_boss_unlocked_index_tracks_steps():
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 0, "初始 0")
	ProgressSystem.on_boss_defeated("fallen_paladin", "medium")   # idx1 → 2
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 2, "击败 medium → 2")
	ProgressSystem.on_boss_defeated("fallen_paladin", "hell")     # idx3 → 封顶 3
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 3, "击败 hell 封顶 3")

func test_persistence_roundtrip():
	ProgressSystem.on_boss_defeated("fallen_paladin", "hard")   # → 3
	ProgressSystem.on_boss_defeated("order_warden", "easy")     # → 1
	assert_true(FileAccess.file_exists(TEST_SAVE_PATH), "变更后立即写盘")
	# 模拟新进程：清内存 → 同路径 ensure_init 从磁盘读回
	ProgressSystem.reset_for_tests()
	ProgressSystem.save_path = TEST_SAVE_PATH
	ProgressSystem.ensure_init()
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 3, "读回 fallen_paladin 状态")
	assert_eq(ProgressSystem.get_boss_unlocked_index("order_warden"), 1, "读回 order_warden 状态")
	assert_true(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "hell"), "读回后 hell 仍解锁")

func test_reset_boss_progress_restores_default_and_isolated():
	ProgressSystem.on_boss_defeated("fallen_paladin", "medium")  # → 2
	ProgressSystem.on_boss_defeated("order_warden", "easy")      # → 1
	ProgressSystem.reset_boss_progress("fallen_paladin")
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 0, "reset 恢复初始 0")
	assert_false(ProgressSystem.is_boss_difficulty_unlocked("fallen_paladin", "medium"), "reset 后 medium 锁回")
	assert_eq(ProgressSystem.get_boss_unlocked_index("order_warden"), 1, "其它 Boss 不受 reset 影响")
	# reset 需落盘：清内存重读后 fallen_paladin 仍为初始、order_warden 仍在
	ProgressSystem.reset_for_tests()
	ProgressSystem.save_path = TEST_SAVE_PATH
	ProgressSystem.ensure_init()
	assert_eq(ProgressSystem.get_boss_unlocked_index("fallen_paladin"), 0, "reset 已持久化")
	assert_eq(ProgressSystem.get_boss_unlocked_index("order_warden"), 1, "order_warden 持久化仍在")
