extends GutTest
# 死灵骑士 铁骑·地裂（mounted_skill1）动画播放入口测试
#
# Bug：mounted_skill1 播放期间只显示第一帧就被覆盖——
# 因为该状态未声明进 config.skill_anim_states，InputHandler 不锁输入，
# 下一帧 NecroKnightCharacter.handle_input 的骑乘分支就把它覆盖成 mounted_jump/mounted_idle。
# 另：foot_gaps 生成脚本只跑了旧 7 帧导出，锚点与 10 帧 sheet 不匹配。

func _make_necro(skills: Array = []) -> Fighter:
	# 只加载死灵骑士配置（避免全量 ensure_init 加载 16 角色动画导致 headless 资源过重/崩溃）
	if not CharConfigs.configs.has("necro_knight"):
		CharConfigs.configs["necro_knight"] = CharacterFactory.get_config("necro_knight")
	var f = Fighter.new()
	f.char_id = "necro_knight"
	f.components = ComponentManager.new()
	f.components.init(f)
	f.setup(200, 320, true, "necro_knight", skills)
	return f

func _keys() -> Dictionary:
	return {
		"left": false, "right": true, "up": false, "down": false,
		"attack": false, "skill1": false, "skill2": false, "ult": false,
		"space": false,
	}

func test_mounted_skill1_declared_in_skill_anim_states():
	var cfg = CharacterFactory.get_config("necro_knight")
	assert_false(cfg.is_empty(), "necro_knight 配置应已加载")
	var lock_states: Array = cfg.get("skill_anim_states", [])
	assert_true(lock_states.has("mounted_skill1"),
		"mounted_skill1 应声明在 skill_anim_states，播放期间 InputHandler 才会锁输入")

func test_mounted_skill1_anim_kept_during_input():
	var f = _make_necro()
	f.set_animation_state("mounted_skill1")
	assert_eq(f.image_state, "mounted_skill1", "应切到 mounted_skill1")
	assert_true(f.current_anim != null and f.current_anim.is_playing(), "动画应处于播放中")

	var keys := _keys()
	InputHandler._handle_char_input(f, keys)

	assert_eq(f.image_state, "mounted_skill1",
		"mounted_skill1 播放期间输入不应把动画覆盖成移动状态（只显示第一帧的 bug）")
	assert_false(keys["right"], "技能动画播放期间输入应被锁零")

func test_mounted_slam_not_overridden_same_frame():
	# 地裂释放当帧：try_use 同步调用 _mounted_slam 设置 mounted_skill1，
	# 之后 handle_input 骑乘分支不能在同一帧把它覆盖成 mounted_jump
	var f = _make_necro()
	var comp: NecroKnightComponent = f.components.get_component("necro_knight")
	comp.mount()
	f.grounded = true
	NecroKnightCharacter._mounted_slam(f)
	assert_eq(f.image_state, "mounted_skill1", "地裂释放应立即切到 mounted_skill1")

	var keys := _keys()  # 模拟同帧内后续输入的按键状态（含 right=true）
	NecroKnightCharacter.handle_input(f, keys)

	assert_eq(f.image_state, "mounted_skill1",
		"地裂释放当帧 handle_input 不应把动画覆盖成 mounted_jump")
	assert_true(f.current_anim != null and f.current_anim.is_playing(), "动画应继续播放")
	assert_false(keys["skill1"], "技能键在释放后应清零")

func test_mounted_slam_animation_advances_and_ends():
	# 帧级集成：地裂释放后 mounted_skill1 应由 update_systems 逐帧推进、
	# 播到后面帧后自然结束并回到骑乘状态（而不是卡在/回到第一帧或立即被覆盖）
	var f = _make_necro(CharacterFactory.create_skills("necro_knight"))
	f.energy = f.max_energy
	var comp: NecroKnightComponent = f.components.get_component("necro_knight")
	comp.mount()
	f.grounded = true
	var keys := _keys()
	keys["skill1"] = true
	NecroKnightCharacter.handle_input(f, keys)
	assert_eq(f.image_state, "mounted_skill1", "释放当帧应进入 mounted_skill1")

	var advanced := false
	var left_state := false
	for i in range(120):
		NecroKnightCharacter.update_systems(f)
		if f.image_state == "mounted_skill1":
			if f.current_anim and f.current_anim.get_current_index() >= 3:
				advanced = true
		elif i > 0:
			left_state = true
			break
	assert_true(advanced, "mounted_skill1 动画应推进到第 3 帧以后（而非卡在第一帧）")
	assert_true(left_state, "mounted_skill1 播完应由 update_systems 转换离开该状态")

func test_mounted_skill1_anchors_have_10_frames():
	# import_slqs.py 必须按新 10 帧导出重新生成锚点，与 sheet/代码 frame_count=10 对齐
	var anchors = NecroKnightCharacter._necro_mounted_skill1_anchors()
	assert_eq(anchors.size(), 10, "mounted_skill1 锚点应为 10 帧")
	for a in anchors:
		assert_true(a is Dictionary, "每帧锚点应为 Dictionary")
		assert_gt(a.get("content_h", 0), 0, "每帧锚点应有有效 content_h")

func test_mounted_skill1_anim_has_10_frames():
	var anim = CharacterFactory.get_config("necro_knight") \
		.get("animations", {}).get("mounted_skill1")
	assert_not_null(anim, "mounted_skill1 动画应已配置")
	assert_eq(anim.frames.size(), 10, "mounted_skill1 动画应有 10 帧")
