extends GutTest
# 剑豪"千峰破云"连招 HUD 归属测试
#
# Bug：剑豪作为敌方 AI 时（如玩家用死灵骑士打 PvE），其屏幕正下方的连招图标/
# 招式名提示（千枫落华斩/玄鸟衔月闪/孤鸿踏雪 就绪/冷却）仍会画到玩家屏幕上——
# 该 HUD 是玩家操作栏，应只在剑豪为玩家控制的角色时显示。

func _make_kensai(is_player: bool) -> Fighter:
	if not CharConfigs.configs.has("kensai"):
		CharConfigs.configs["kensai"] = CharacterFactory.get_config("kensai")
	var f = Fighter.new()
	f.char_id = "kensai"
	f.components = ComponentManager.new()
	f.components.init(f)
	f.setup(200, 320, is_player, "kensai", CharacterFactory.create_skills("kensai"))
	return f

func _has_qifeng_effect(f: Fighter) -> bool:
	var key = str(f.get_instance_id()) + "_qifeng"
	for e in GameWorld.draw_effect_callbacks:
		if e.get("key") == key:
			return true
	return false

func test_qifeng_hud_not_drawn_for_enemy_kensai():
	var f = _make_kensai(false)  # 敌方剑豪（如 PvE 敌人）
	var comp: KensaiComponent = f.components.get_component("kensai")
	comp.combo_seq = [2, 1]  # 敌方也在拼连招（千峰破云）
	KensaiCharacter.update_systems(f)
	assert_false(_has_qifeng_effect(f),
		"敌方剑豪的千峰破云 HUD 不应画到玩家屏幕")

func test_qifeng_hud_drawn_for_player_kensai():
	var f = _make_kensai(true)  # 玩家自己使用的剑豪
	var comp: KensaiComponent = f.components.get_component("kensai")
	comp.combo_seq = [2, 1]
	KensaiCharacter.update_systems(f)
	assert_true(_has_qifeng_effect(f),
		"玩家剑豪的千峰破云 HUD 应正常显示")
	GameWorld.unregister_draw_effect(str(f.get_instance_id()) + "_qifeng")

func test_qifeng_hud_removed_when_combo_cleared():
	var f = _make_kensai(true)
	var comp: KensaiComponent = f.components.get_component("kensai")
	comp.combo_seq = [2, 1]
	KensaiCharacter.update_systems(f)
	assert_true(_has_qifeng_effect(f), "先确认 HUD 已注册")
	comp.combo_seq.clear()
	KensaiCharacter.update_systems(f)
	assert_false(_has_qifeng_effect(f), "连招清空后 HUD 应取消注册")
