class_name InputRouter

## 将键盘事件映射到 keys 字典
static func map_game_keys(event: InputEvent, keys: Dictionary):
	if not event is InputEventKey:
		return
	var pr = event.pressed
	match event.keycode:
		KEY_A, KEY_LEFT: keys["left"] = pr
		KEY_D, KEY_RIGHT: keys["right"] = pr
		KEY_W, KEY_UP: keys["up"] = pr
		KEY_S, KEY_DOWN: keys["down"] = pr
		KEY_J: keys["attack"] = pr
		KEY_U: keys["skill1"] = pr
		KEY_I: keys["skill2"] = pr
		KEY_O: keys["ult"] = pr
		KEY_7: keys["sub"] = pr  # 子技能（战吼）
		KEY_K: keys["talent1"] = pr
		KEY_L: keys["talent2"] = pr
		KEY_SEMICOLON: keys["talent3"] = pr
		KEY_SPACE: keys["space"] = pr  # 练习模式：按住空格控制对手

## 主动天赋按键激活（每帧调用）
static func handle_talent_keys(keys: Dictionary):
	var _talent_key_names = ["talent1", "talent2", "talent3"]
	var p = GameWorld.player
	if not is_instance_valid(p) or not p.talent_manager:
		return
	# 练习模式：空格按住控制对手期间，K/L/; 不触发玩家主动天赋
	if GameWorld.practice_mode and keys.get("space", false):
		return
	for i in range(p.talent_slots.size()):
		if i >= len(_talent_key_names): break
		var kn = _talent_key_names[i]
		if keys[kn]:
			p.talent_manager.activate_slot(i)
			keys[kn] = false
