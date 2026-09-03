class_name HudSystem

# ── HUD 渲染系统（从 game.gd 提取）──
# 所有绘制方法第一个参数为 game_node (CanvasItem)，用于调用 draw_* API

## 入口：绘制全部 HUD
static func draw(game_node: CanvasItem, font: Font):
	if not is_instance_valid(GameWorld.player) or not is_instance_valid(GameWorld.enemy):
		return
	var player_bars_bottom := _draw_player_bars(game_node, font)
	_draw_enemy_bars(game_node, font)
	_draw_difficulty_badge(game_node, font)
	_draw_skill_cooldowns(game_node, font)
	_draw_talent_buttons(game_node, font)
	_draw_practice_hud(game_node, font, player_bars_bottom)
	_draw_game_over(game_node, font)
	_draw_loading_filter(game_node)  # 最后绘制，盖住整个画面

## 加载中灰色滤镜：透明度呼吸变化 + 上升浮动小圆点
static func _draw_loading_filter(game_node: CanvasItem):
	if GameWorld.loading_filter_frames <= 0:
		return
	var t = Time.get_ticks_msec() / 1000.0
	var breath = 0.5 + 0.5 * sin(t * TAU / 3.0)
	game_node.draw_rect(Rect2(0, 0, Constants.W, Constants.H), Color(0.45, 0.45, 0.45, 0.35 + 0.3 * breath))
	# 上升浮动的小圆点：底部生成、缓慢上浮、左右微摆、透明度闪烁
	const DOT_COUNT := 16
	const DOT_R := 3.0
	const RISE_SPEED := 45.0
	for i in DOT_COUNT:
		var seed_x = float((i * 97 + 13) % 97) / 97.0
		var seed_y = float((i * 53 + 7) % 101) / 101.0
		var x = seed_x * Constants.W + sin(t * 1.5 + seed_x * TAU) * 10.0
		var rise = fmod(t * RISE_SPEED + seed_y * (Constants.H + 80.0), Constants.H + 80.0)
		var y = Constants.H - rise
		var alpha = 0.35 + 0.65 * (0.5 + 0.5 * sin(t * 2.0 + seed_x * TAU))
		game_node.draw_circle(Vector2(x, y), DOT_R, Color(0.88, 0.88, 0.92, alpha))

## 绘制蓄力条（角色上方）
static func draw_charge_bar(game_node: CanvasItem, owner: Fighter, cam_x: float, cam_y: float = 0.0):
	if not is_instance_valid(owner):
		return
	if not owner.charging and not owner.charging_skill1 and not owner.charging_attack:
		return
	var px = owner.pos_x - cam_x + owner.w / 2.0
	var py = owner.pos_y - cam_y - 20
	var max_width = 40.0
	var charge_time: float
	if owner.charging_skill1 or owner.charging_attack:
		charge_time = (Time.get_ticks_msec() - owner.charge_start_time) / 1000.0
	else:
		charge_time = (Time.get_ticks_msec() - owner.charge_start) / 1000.0
	var max_charge = 3.0  # 骑士半月斩最长蓄力3秒
	var progress = clampf(charge_time / max_charge, 0.0, 1.0)

	game_node.draw_rect(Rect2(px - max_width / 2.0 - 2, py - 2, max_width + 4, 10), Color(0, 0, 0, 0.6))
	var fill_color: Color
	if owner.charging_skill1:
		fill_color = Color(1.0, 0.843, 0.0)
	elif owner.charging_attack:
		fill_color = Color(0.533, 0.867, 1.0)
	else:
		fill_color = Color(1.0, 0.867, 0.267)
	game_node.draw_rect(Rect2(px - max_width / 2.0, py, max_width * progress, 6), fill_color)
	game_node.draw_rect(Rect2(px - max_width / 2.0, py, max_width, 6), Color.WHITE, false)

# ===== 内部方法 =====

static func _draw_player_bars(game_node: CanvasItem, font: Font) -> float:
	var p = GameWorld.player
	var bar_x = 16
	var bar_w = 170.0
	var bar_h = 14.0

	var p_cfg = p.config
	var p_name = p_cfg.get("name", "P1")

	# HP bar
	game_node.draw_rect(Rect2(bar_x, 4, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.8))
	var p_hp_pct = maxf(0, p.hp / maxf(p.max_hp, 1.0))
	var hp_color = Color(0.0, 0.667, 1.0) if p_hp_pct > 0.3 else Color(1.0, 0.133, 0.133)
	game_node.draw_rect(Rect2(bar_x, 4, bar_w * p_hp_pct, bar_h), hp_color)
	game_node.draw_string(font, Vector2(bar_x + 4, 6), p_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	game_node.draw_string(font, Vector2(bar_x + bar_w - 50, 6), str(int(p.hp)) + "/" + str(int(p.max_hp)), HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color.WHITE)

	# Energy bar
	var energy_bar_h = 8.0
	game_node.draw_rect(Rect2(bar_x, 20, bar_w, energy_bar_h), Color(0.05, 0.05, 0.08, 0.8))
	var p_eng_pct = minf(1.0, p.energy / maxf(p.max_energy, 1.0))
	game_node.draw_rect(Rect2(bar_x, 20, bar_w * p_eng_pct, energy_bar_h), p.hud_resource_color)
	var res_label = p_cfg.get("resource_label", "能量")
	game_node.draw_string(font, Vector2(bar_x + 52, 20), res_label + " " + str(int(p.energy)), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.667, 0.8, 1.0))

	# 角色 HUD 条：遍历组件统一接口
	var hud_y = 30.0
	var hud_h = 6.0
	var hud_spacing = 2.0
	if p.components:
		for comp in p.components.values():
			var hud_data = comp.get_hud_data()
			if hud_data.is_empty():
				continue
			for hud_key in hud_data:
				var d = hud_data[hud_key]
				var v = d.get("value", 0)
				var m = d.get("max", 1.0)
				var lbl = d.get("label", "")
				var pct = minf(1.0, float(v) / maxf(float(m), 1.0))
				game_node.draw_rect(Rect2(bar_x, hud_y, bar_w, hud_h), Color(0.05, 0.05, 0.08, 0.8))
				if d.get("is_stance", false):
					game_node.draw_rect(Rect2(bar_x, hud_y, bar_w, hud_h), d.get("fill_color", Color(0.53, 0.27, 0.8)))
					game_node.draw_string(font, Vector2(bar_x + 52, hud_y), d.get("stance_label", lbl), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, d.get("label_color", Color(1, 1, 1)))
				else:
					game_node.draw_rect(Rect2(bar_x, hud_y, bar_w * pct, hud_h), d.get("fill_color", Color(0.53, 0.27, 0.8)))
					var txt = lbl + " " + str(int(v))
					game_node.draw_string(font, Vector2(bar_x + 52, hud_y), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, d.get("label_color", Color(1, 1, 1)))
				hud_y += hud_h + hud_spacing
	# 返回能量条下方组件条之后的第一个空闲 y（练习模式伤害显示在其下方绘制）
	return hud_y

static func _draw_enemy_bars(game_node: CanvasItem, font: Font):
	var e = GameWorld.enemy
	var bar_x = 16
	var bar_w = 170.0
	var bar_h = 14.0
	var energy_bar_h = 8.0
	var e_name = e.boss_name if e.boss_name != "" else e.config.get("name", "AI")
	var e_bar_x = Constants.W - bar_x - bar_w

	# HP bar
	game_node.draw_rect(Rect2(e_bar_x, 4, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.8))
	var e_hp_pct = maxf(0, e.hp / maxf(e.max_hp, 1.0))
	var e_hp_color = Color(1.0, 0.133, 0.133) if e_hp_pct > 0.3 else Color(1.0, 0.0, 0.0)
	game_node.draw_rect(Rect2(e_bar_x + bar_w * (1.0 - e_hp_pct), 4, bar_w * e_hp_pct, bar_h), e_hp_color)
	game_node.draw_string(font, Vector2(e_bar_x + bar_w - 4, 6), e_name, HORIZONTAL_ALIGNMENT_RIGHT, -1, 12, Color(1.0, 0.533, 0.533))
	game_node.draw_string(font, Vector2(e_bar_x + bar_w - 4 - 55, 6), str(int(e.hp)) + "/" + str(int(e.max_hp)), HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color.WHITE)

	# Energy bar
	game_node.draw_rect(Rect2(e_bar_x, 20, bar_w, energy_bar_h), Color(0.05, 0.05, 0.08, 0.8))
	var e_eng_pct = minf(1.0, e.energy / maxf(e.max_energy, 1.0))
	game_node.draw_rect(Rect2(e_bar_x + bar_w * (1.0 - e_eng_pct), 20, bar_w * e_eng_pct, energy_bar_h), Color(0.8, 0.267, 0.0))
	game_node.draw_string(font, Vector2(e_bar_x + bar_w - 4, 20), str(int(e.energy)), HORIZONTAL_ALIGNMENT_RIGHT, -1, 8, Color(1.0, 0.667, 0.4))

static func _draw_difficulty_badge(game_node: CanvasItem, font: Font):
	# 练习模式：无难度选择，顶部让位给练习开关按钮
	if GameWorld.practice_mode:
		return
	var diff_label = GameWorld.difficulty.to_upper()
	var diff_color = Color(0.667, 0.667, 0.667)
	if GameWorld.difficulty == "hell":
		diff_color = Color(1.0, 0.2, 0.2)
	elif GameWorld.difficulty == "hard":
		diff_color = Color(1.0, 0.533, 0.0)
	elif GameWorld.difficulty == "medium":
		diff_color = Color(1.0, 0.843, 0.0)
	elif GameWorld.difficulty == "easy":
		diff_color = Color(0.4, 1.0, 0.4)
	game_node.draw_string(font, Vector2(Constants.W / 2.0, 6), "【" + diff_label + "】", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, diff_color)

## 练习模式 HUD：伤害显示固定在镜头左侧、角色能量条下方（屏幕坐标，随镜头保持画面内）
## bar_y 为玩家 HP/能量/组件条下方第一个空闲 y（由 _draw_player_bars 返回）
static func _draw_practice_hud(game_node: CanvasItem, font: Font, bar_y: float = 30.0):
	if not GameWorld.practice_mode or not GameWorld.practice_damage_display:
		return
	# 15 秒（900 帧）未造成伤害 → 清零
	if GameWorld.practice_damage_dealt > 0 \
			and GameWorld.frame - GameWorld.practice_damage_last_frame >= 15 * 60:
		GameWorld.practice_damage_dealt = 0.0
	var bar_x = 16.0
	var bar_w = 170.0
	# 与 HP/能量条一致的深色底块
	game_node.draw_rect(Rect2(bar_x, bar_y, bar_w, 22), Color(0.05, 0.05, 0.08, 0.85))
	game_node.draw_string(font, Vector2(bar_x + 4, bar_y + 11), "累计伤害", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.75, 0.75, 0.85))
	game_node.draw_string(font, Vector2(bar_x + bar_w - 4, bar_y + 11), str(int(GameWorld.practice_damage_dealt)),
		HORIZONTAL_ALIGNMENT_RIGHT, -1, 12, Color(1.0, 0.84, 0.3))
	# 清零倒计时（仅在有累计伤害时）
	if GameWorld.practice_damage_dealt > 0:
		var remain := 15.0 - float(GameWorld.frame - GameWorld.practice_damage_last_frame) / 60.0
		game_node.draw_string(font, Vector2(bar_x + 4, bar_y + 20), "%.1fs 无伤害将清零" % maxf(remain, 0.0),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.65, 0.65, 0.75))

## 玩家实际拥有的技能键（缺失的技能不显示按钮，如非狂战士的 sub/战吼）
static func _player_skill_keys(p: Fighter) -> Array:
	var keys: Array = []
	for key in ["attack", "skill1", "skill2", "ult", "sub"]:
		if p.get_skill(key) != null:
			keys.append(key)
	return keys

static func _draw_skill_cooldowns(game_node: CanvasItem, font: Font):
	var p = GameWorld.player
	var default_labels = {"attack": "J 普攻", "skill1": "U 技1", "skill2": "I 技2", "ult": "O 大招", "sub": "7 战吼"}
	var skill_labels = p.hud_skill_labels if not p.hud_skill_labels.is_empty() else default_labels
	# 只显示角色实际拥有的技能按钮（如非狂战士没有 sub/战吼）
	var skill_keys = _player_skill_keys(p)
	var btn_x_start = (Constants.W - skill_keys.size() * 60) / 2.0
	for i in skill_keys.size():
		var key = skill_keys[i]
		var sk = p.get_skill(key)
		var bx = btn_x_start + i * 64
		var by = Constants.H - 28
		var awaiting = sk != null and sk.in_next_stage_window()  # 多段技能：等待释放下一段 → 黄标
		var buffing = sk != null and sk.buff_timer > 0  # 强化/增益状态：技能槽黄条显示剩余时间（如黑法师强化状态）
		if buffing:
			# 强化黄条：黄底 + 剩余时间 + 黄边（样式参考多段技能黄标）
			game_node.draw_rect(Rect2(bx, by, 58, 22), Color(1.0, 0.84, 0.1, 0.9))
			game_node.draw_string(font, Vector2(bx + 4, by + 4), skill_labels.get(key, key), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.1, 0.1, 0.1))
			game_node.draw_string(font, Vector2(bx + 4, by + 14), "强化 " + str(ceil(sk.buff_timer / 60.0)) + "s", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.15, 0.1, 0.0))
			game_node.draw_rect(Rect2(bx, by, 58, 22), Color(1.0, 0.7, 0.0), false, 2)
		elif awaiting:
			game_node.draw_rect(Rect2(bx, by, 58, 22), Color(1.0, 0.84, 0.1, 0.9))
			game_node.draw_string(font, Vector2(bx + 4, by + 4), skill_labels.get(key, key), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.1, 0.1, 0.1))
			game_node.draw_string(font, Vector2(bx + 4, by + 14), "下一段 " + str(ceil(sk.stage_window / 60.0)) + "s", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.15, 0.1, 0.0))
			game_node.draw_rect(Rect2(bx, by, 58, 22), Color(1.0, 0.7, 0.0), false, 2)
		else:
			game_node.draw_rect(Rect2(bx, by, 58, 22), Color(0.1, 0.1, 0.15, 0.85))
			game_node.draw_string(font, Vector2(bx + 4, by + 4), skill_labels.get(key, key), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.667, 0.667, 0.8))
			if sk and sk.cd > 0:
				var cd_pct = float(sk.cd) / float(sk.cooldown)
				game_node.draw_rect(Rect2(bx, by, 58 * cd_pct, 22), Color(0, 0, 0, 0.6))
				game_node.draw_string(font, Vector2(bx + 29, by + 14), str(ceil(sk.cd / 60.0)) + "s", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.533, 0.533))
			game_node.draw_rect(Rect2(bx, by, 58, 22), Color(0.3, 0.3, 0.5), false)

static func _draw_talent_buttons(game_node: CanvasItem, font: Font):
	var p = GameWorld.player
	if not is_instance_valid(p) or not p.talent_manager or p.talent_slots.is_empty():
		return
	# 起点与技能按钮行对齐（按实际技能数偏移，非狂战士少一个战吼键）
	var skill_count = _player_skill_keys(p).size()
	var btn_x_start = (Constants.W - skill_count * 60) / 2.0 + skill_count * 64
	var by = Constants.H - 28
	var _talent_key_labels = ["K", "L", ";"]
	for i in range(p.talent_slots.size()):
		if i >= len(_talent_key_labels): break
		var inst = p.talent_slots[i]
		var bx = btn_x_start + i * 64
		game_node.draw_rect(Rect2(bx, by, 58, 22), Color(0.15, 0.1, 0.05, 0.85))
		var label = _talent_key_labels[i] + " " + inst.talent_name
		game_node.draw_string(font, Vector2(bx + 4, by + 4), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1.0, 0.667, 0.4))
		var cd_data = p.ad.get(inst.talent_id, {})
		var cd = cd_data.get("cd", 0)
		if cd > 0:
			var cd_pct = float(cd) / 300.0
			game_node.draw_rect(Rect2(bx, by, 58 * cd_pct, 22), Color(0, 0, 0, 0.6))
			game_node.draw_string(font, Vector2(bx + 29, by + 14), str(ceil(cd / 60.0)) + "s", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.533, 0.533))
		game_node.draw_rect(Rect2(bx, by, 58, 22), Color(0.5, 0.35, 0.1), false)

static func _draw_game_over(game_node: CanvasItem, font: Font):
	if not GameWorld.game_over:
		return
	game_node.draw_rect(Rect2(0, 0, Constants.W, Constants.H), Color(0, 0, 0, 0.6))
	var is_win = GameWorld.game_result == "win"
	var title = "🏆 胜利!" if is_win else "💀 战败"
	var sub = "你击败了 " + GameWorld.difficulty.to_upper() + " 难度对手!" if is_win else "AI 取得了胜利..."
	game_node.draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 - 20), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 36, Color(1.0, 0.843, 0.0) if is_win else Color(1.0, 0.267, 0.267))
	game_node.draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 + 16), sub, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)
	game_node.draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 + 42), "按 R 重新开始", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.667, 0.667, 0.667))
	game_node.draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 + 58), "按 C 角色选择", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.667, 0.533, 1.0))
	game_node.draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 + 74), "按 ESC 返回菜单", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.467, 0.467, 0.467))
