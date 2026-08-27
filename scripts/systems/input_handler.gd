class_name InputHandler

const PROJ_LIGHT_IMG = preload("res://assets/fx_lightning_projectile.png")

# ===== Player Input =====
static func update_player_input(world, keys: Dictionary):
	var p = world.player
	# 练习模式：按住空格 → 其他按键改为控制对手角色（如 空格+W=对手跳跃）
	if world.practice_mode and keys.get("space", false) \
			and is_instance_valid(world.enemy) and world.enemy.hp > 0:
		var e = world.enemy
		if e.hp > 0 and not e.has_status("frozen"):
			# 悬挂平台下落：S/↓ 键 + 站在非地面平台上
			if keys["down"] and e.grounded and e.on_platform != null \
					and not e.on_platform.get("is_ground", false):
				e.passthrough_platform = e.on_platform
				e.passthrough_timer = 10
				e.grounded = false
				e.vy = 1
			_handle_char_input(e, keys)
		return
	if p.hp > 0 and not p.has_status("frozen"):
		# 悬挂平台下落：S/↓ 键 + 站在非地面平台上
		if keys["down"] and p.grounded and p.on_platform != null \
			and not p.on_platform.get("is_ground", false):
			p.passthrough_platform = p.on_platform
			p.passthrough_timer = 10
			p.grounded = false
			p.vy = 1
		_handle_char_input(p, keys)

static func _handle_char_input(p: Fighter, keys: Dictionary):
	# 全局规则：技能动画播放期间锁定全部输入（移动/跳跃/普攻/技能全禁用），
	# 动画只能自然播完或被受击提前结束。声明于各角色 config.skill_anim_states。
	# 空格键是练习模式"控制对手"修饰键，保持状态不被清零。
	var anim = p.current_anim
	if anim and anim.is_playing() and p.image_state in p.config.get("skill_anim_states", []):
		for k in keys:
			if k != "space":
				keys[k] = false
		return
	CharacterFactory.handle_input(p.char_id, p, keys)
