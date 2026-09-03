extends GutTest
# Boss 注册表机制测试（data/boss_configs.gd 聚合器）
# 说明：此前的示例 Boss（圣骑士/骑士）仅供联调测试，已从 data/bosses/ 移除；
# 因此本测试只验证"聚合器机制"在注册表为空时依然安全、查询行为正确。
# 待正式 Boss 配置落地后，可在此补充内容级自洽测试（char_id/map/levels 校验）。

func before_each():
	GameWorld.boss_id = ""
	GameWorld.difficulty = "medium"

func test_registry_empty_safe():
	BossConfigs.ensure_init()
	assert_true(BossConfigs.get_boss_ids() is Array, "get_boss_ids 恒返回数组")
	assert_eq(BossConfigs.get_boss_ids().size(), 0, "示例 Boss 已移除 → 注册表为空（不报错）")

func test_unknown_boss_queries_return_empty():
	BossConfigs.ensure_init()
	assert_true(BossConfigs.get_boss("no_such_boss").is_empty(), "未知 id 返回空")
	assert_eq(BossConfigs.get_boss_name("no_such_boss"), "", "未知 id name 为空")
	assert_eq(BossConfigs.get_map_path("no_such_boss"), "", "未知 id map 为空")
	assert_true(BossConfigs.resolve_modifiers("no_such_boss", "easy").is_empty(), "未知 id modifiers 为空")
