extends GutTest
# paladin / berserker 新导入动画冒烟测试：
# exports 新增的 paladin_walk/jump/skill1/ult 与 basaker_sub_skill(berserker战吼)
# 已 0.5 压缩导入，对应状态动画应能按网格加载且锚点帧数与 sheet 一致。

func _cfg_of(char_id: String) -> Dictionary:
	if not CharConfigs.configs.has(char_id):
		CharConfigs.configs[char_id] = CharacterFactory.get_config(char_id)
	return CharConfigs.configs[char_id]

func _anim(char_id: String, state: String):
	return _cfg_of(char_id).get("animations", {}).get(state)

func test_paladin_walk_loaded():
	var a = _anim("paladin", "walk")
	assert_not_null(a, "paladin walk 动画应已配置")
	assert_eq(a.frames.size(), 10, "paladin walk 应有 10 帧")
	assert_eq(PaladinCharacter._paladin_walk_anchors().size(), 10)

func test_paladin_jump_loaded():
	var a = _anim("paladin", "jump")
	assert_not_null(a, "paladin jump 动画应已配置")
	assert_eq(a.frames.size(), 5, "paladin jump 应有 5 帧")
	assert_eq(PaladinCharacter._paladin_jump_anchors().size(), 5)

func test_paladin_charge_loaded():
	var a = _anim("paladin", "charge")
	assert_not_null(a, "paladin charge(skill1导出) 动画应已配置")
	assert_eq(a.frames.size(), 8, "paladin charge 应有 8 帧")
	assert_eq(PaladinCharacter._paladin_charge_anchors().size(), 8)

func test_paladin_ult_loaded():
	var a = _anim("paladin", "ult")
	assert_not_null(a, "paladin ult 动画应已配置")
	assert_eq(a.frames.size(), 24, "paladin ult 应有 24 帧")
	assert_eq(PaladinCharacter._paladin_ult_anchors().size(), 24)

func test_berserker_warcry_loaded():
	var a = _anim("berserker", "warcry")
	assert_not_null(a, "berserker warcry 动画应已配置")
	assert_eq(a.frames.size(), 10, "berserker warcry(basaker_sub_skill) 应有 10 帧")
	assert_eq(BerserkerCharacter._berserker_warcry_anchors().size(), 10)

func test_paladin_update_systems_advances_anim():
	# Bug：paladin 换多帧 sheet 后 update_systems 未推进 current_anim → 动画全冻在第一帧
	var f = _make_paladin()
	f.set_animation_state("walk")
	assert_eq(f.current_anim.get_current_index(), 0, "初始在第 0 帧")
	for i in range(12):
		PaladinCharacter.update_systems(f)
	assert_gt(f.current_anim.get_current_index(), 0, "update_systems 应推进 walk 动画帧")

func _make_paladin() -> Fighter:
	if not CharConfigs.configs.has("paladin"):
		CharConfigs.configs["paladin"] = CharacterFactory.get_config("paladin")
	var f = Fighter.new()
	f.char_id = "paladin"
	f.components = ComponentManager.new()
	f.components.init(f)
	f.setup(200, 320, true, "paladin", [])
	return f
