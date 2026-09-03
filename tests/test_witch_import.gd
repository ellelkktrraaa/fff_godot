extends GutTest
# 魔女新导入动画（walk / jump / attack）冒烟测试：
# exports 新增的 witch_walk / witch_in_air / witch_attack 已 0.5 压缩导入，
# 对应状态动画应能按网格加载且锚点帧数与 sheet 一致。

func _make_cfg() -> Dictionary:
	if not CharConfigs.configs.has("witch"):
		CharConfigs.configs["witch"] = CharacterFactory.get_config("witch")
	return CharConfigs.configs["witch"]

func _anim(state: String):
	return _make_cfg().get("animations", {}).get(state)

func test_witch_walk_anim_loaded():
	var a = _anim("walk")
	assert_not_null(a, "walk 动画应已配置")
	assert_eq(a.frames.size(), 13, "walk 应有 13 帧")
	assert_eq(WitchCharacter._witch_walk_anchors().size(), 13, "walk 锚点应与帧数一致")

func test_witch_jump_anim_loaded():
	var a = _anim("jump")
	assert_not_null(a, "jump 动画应已配置")
	assert_eq(a.frames.size(), 9, "jump(in_air) 应有 9 帧")
	assert_eq(WitchCharacter._witch_jump_anchors().size(), 9, "jump 锚点应与帧数一致")

func test_witch_attack_anim_loaded():
	var a = _anim("attack")
	assert_not_null(a, "attack 动画应已配置")
	assert_eq(a.frames.size(), 10, "attack 应有 10 帧")
	assert_eq(WitchCharacter._witch_attack_anchors().size(), 10, "attack 锚点应与帧数一致")

func test_witch_skill_attack_anim_loaded():
	var a = _anim("skill_attack")
	assert_not_null(a, "skill_attack 施法姿态应已配置")
	assert_eq(a.frames.size(), 10, "skill_attack 应有 10 帧")

func _make_witch() -> Fighter:
	if not CharConfigs.configs.has("witch"):
		CharConfigs.configs["witch"] = CharacterFactory.get_config("witch")
	var f = Fighter.new()
	f.char_id = "witch"
	f.components = ComponentManager.new()
	f.components.init(f)
	f.setup(200, 320, true, "witch", CharacterFactory.create_skills("witch"))
	f.energy = f.max_energy
	return f

func test_witch_hold_up_does_not_flicker_flying():
	# Bug：空中按住 ↑ 时 is_flying 每帧 飞行↔滞空 来回切 → in_air/扫帚动画闪烁。
	# 修复：↑ 改为上升沿触发。
	var f = _make_witch()
	f.grounded = false
	var comp: WitchComponent = f.components.get_component("witch")
	var keys := {"left": false, "right": false, "up": true, "down": false,
		"attack": false, "skill1": false, "skill2": false, "ult": false, "space": false}
	WitchCharacter.handle_input(f, keys)
	assert_true(comp.is_flying, "空中按一下 ↑ 应进入飞行")
	# 持续按住（下一帧仍 up=true）：不得把飞行切回去
	WitchCharacter.handle_input(f, keys)
	assert_true(comp.is_flying, "按住 ↑ 不应反复切换飞行（闪烁 bug）")
	# 松开后再按一次 → 退出飞行
	keys["up"] = false
	WitchCharacter.handle_input(f, keys)
	keys["up"] = true
	WitchCharacter.handle_input(f, keys)
	assert_false(comp.is_flying, "松开后再按 ↑ 应退出飞行")
