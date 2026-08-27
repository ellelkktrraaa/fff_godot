class_name RenderSystem

## 调试：按 F2 切换是否绘制碰撞体边框（默认关闭）
static var debug_draw_hitboxes: bool = false

const SHIELD_IMG = preload("res://assets/fx_shield.png")
const FLAME_IMG = preload("res://assets/fx_flame.png")

# 黑白滤镜（canvas_item 着色器）：高对比黑白二值化——以 0.5 亮度为界，阴影近纯黑、高光近纯白
static var _grayscale_shader: Shader = null
static var _grayscale_mat: ShaderMaterial = null

static func _ensure_grayscale_material() -> ShaderMaterial:
	if _grayscale_mat == null:
		_grayscale_shader = Shader.new()
		_grayscale_shader.code = "shader_type canvas_item;\n" \
			+ "uniform float strength : hint_range(0.0, 1.0) = 1.0;\n" \
			+ "uniform float contrast : hint_range(0.0, 100.0) = 20.0;\n" \
			+ "void fragment() {\n" \
			+ "	vec3 c = COLOR.rgb;\n" \
			+ "	float lum = dot(c, vec3(0.299, 0.587, 0.114));\n" \
			+ "	// 对比度 0~100：100=硬黑白二分（step）；0=柔和灰阶；20=保留较多中间调\n" \
			+ "	float half_w = 0.4 * (1.0 - contrast / 100.0);\n" \
			+ "	float bw = smoothstep(0.5 - half_w, 0.5 + half_w, lum);\n" \
			+ "	c = mix(c, vec3(bw), strength);\n" \
			+ "	COLOR.rgb = c;\n" \
			+ "}\n"
		_grayscale_mat = ShaderMaterial.new()
		_grayscale_mat.shader = _grayscale_shader
	return _grayscale_mat

## 入口：绘制整帧
static func draw_frame(game_node: CanvasItem):
	var cam_x = GameWorld.camera.x
	var cam_y = GameWorld.camera.y
	var font = ThemeDB.fallback_font

	# 1. 地图
	_draw_map(game_node, cam_x, cam_y)

	# 1.5 全屏 Overlay（底层，behind_map=true — 地图背景之上、地形之下）
	for entry in GameWorld.active_overlays:
		if not entry is Dictionary:
			continue
		var eo_fs: Dictionary = entry
		if not eo_fs.get("behind_map", false):
			continue
		var fs_anim: FrameAnimation = eo_fs["anim"]
		if not fs_anim or not fs_anim.is_playing():
			continue
		var fs_tex = fs_anim.get_current_texture()
		if not fs_tex:
			continue
		var fs_pos: Dictionary = eo_fs.get("position", {})
		if fs_pos.get("type", "") != "fullscreen":
			continue
		game_node.draw_texture_rect(fs_tex, Rect2(cam_x, cam_y, Constants.W, Constants.H), false)
		var fs_progress = fs_anim.get_progress()
		var fs_border = eo_fs.get("border_color", Color(0.9, 0.15, 0.15))
		var fs_alpha = 0.3 + sin(fs_progress * PI * 6) * 0.2
		game_node.draw_rect(Rect2(cam_x, cam_y, Constants.W, Constants.H), Color(fs_border.r, fs_border.g, fs_border.b, fs_alpha), false, 8)

	# 1.7 平台地形块（背景之上、角色之下，替代场景 sprite 自渲染）
	_draw_platforms(game_node, cam_x, cam_y)

	# 2. 角色实体
	if is_instance_valid(GameWorld.player):
		_draw_fighter(game_node, GameWorld.player, cam_x, cam_y, true)
	if is_instance_valid(GameWorld.enemy):
		_draw_fighter(game_node, GameWorld.enemy, cam_x, cam_y, GameWorld.game_mode == "pvp")

	# 3. 投射物
	_draw_projectiles(game_node, cam_x, cam_y)

	# 4. 火焰区域
	_draw_flame_zones(game_node, cam_x, cam_y)

	# 5. 掉落物
	for p in GameWorld.pickups:
		p.draw(game_node, cam_x, cam_y)

	# 6. 蓄力条（世界空间，跟随角色）
	if is_instance_valid(GameWorld.player):
		HudSystem.draw_charge_bar(game_node, GameWorld.player, cam_x, cam_y)
	if GameWorld.game_mode == "pvp" and is_instance_valid(GameWorld.enemy):
		HudSystem.draw_charge_bar(game_node, GameWorld.enemy, cam_x, cam_y)

	# 7. 粒子
	for pt in GameWorld.particles:
		pt.draw(game_node, cam_x, cam_y)

	# 8. 爆炸特效
	for e in GameWorld.explosion_effects:
		if not e is Dictionary:
			continue
		var ed: Dictionary = e
		var px = ed["x"] - cam_x
		var py = ed["y"] - cam_y
		var alpha = ed.get("alpha", 0.8)
		game_node.draw_circle(Vector2(px + ed["w"] / 2.0, py + ed["h"] / 2.0), ed["w"] / 2.0, Color(1.0, 0.533, 0.267, alpha))

	# 9. 世界空间绘制回调
	for entry in GameWorld.draw_effect_callbacks:
		if not entry is Dictionary:
			continue
		var e_dict: Dictionary = entry
		if e_dict.get("screen_space", false):
			continue
		var cb: Callable = e_dict.get("cb")
		if not (cb and cb.is_valid()):
			continue
		var items: Array = cb.call(font, cam_x, cam_y)
		if items == null: continue
		for item in items:
			_exec_draw_item(game_node, item, font)

	# 10. 世界空间 Overlay（follow / fixed / world）
	for entry in GameWorld.active_overlays:
		if not entry is Dictionary:
			continue
		var eo2: Dictionary = entry
		var overlay_anim: FrameAnimation = eo2["anim"]
		if not overlay_anim or not overlay_anim.is_playing():
			continue
		var tex = overlay_anim.get_current_texture()
		if not tex:
			continue
		var pos: Dictionary = eo2.get("position", {})
		var ptype = pos.get("type", "")
		if ptype == "fullscreen":
			continue  # 后面在屏幕空间单独画
		match ptype:
			"fixed":
				var rect: Rect2 = pos.get("rect", Rect2())
				game_node.draw_texture_rect(tex, rect, false)
			"follow":
				var target = pos.get("target")
				if target and target is Fighter and target.hp > 0:
					var sx = target.pos_x - cam_x + target.w / 2.0 + pos.get("offset", Vector2.ZERO).x
					var sy = target.pos_y - cam_y + target.h / 2.0 + pos.get("offset", Vector2.ZERO).y
					var sc: Vector2 = pos.get("scale", Vector2.ONE)
					var tw = target.w * sc.x
					var th = target.h * sc.y
					if target.facing < 0:
						game_node.draw_set_transform(Vector2(sx, sy), 0.0, Vector2(-sc.x, sc.y))
						game_node.draw_texture_rect(tex, Rect2(-tw / 2.0, -th / 2.0, tw, th), false)
						game_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
					else:
						game_node.draw_set_transform(Vector2(sx, sy), 0.0, Vector2(sc.x, sc.y))
						game_node.draw_texture_rect(tex, Rect2(-tw / 2.0, -th / 2.0, tw, th), false)
						game_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"world":
				var wx = pos.get("x", 0.0) - cam_x
				var wy = pos.get("y", 0.0) - cam_y
				var sc: Vector2 = pos.get("scale", Vector2.ONE)
				game_node.draw_texture_rect(tex, Rect2(wx, wy, tex.get_width() * sc.x, tex.get_height() * sc.y), false)

	# ═══ 屏幕空间（抵消镜头缩放：基准 1.375x × 拉近倍率）═══
	var _screen_comp := 1.0 / (GameWorld.CAMERA_BASE_SCALE * GameWorld.camera_zoom)
	game_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(_screen_comp, _screen_comp))

	# 11. 屏幕空间绘制回调（top_layer 的留到全屏 Overlay 之后，保证 HUD 常驻元素不被全屏动画遮挡）
	for entry in GameWorld.draw_effect_callbacks:
		if not entry is Dictionary:
			continue
		var e_dict2: Dictionary = entry
		if not e_dict2.get("screen_space", false):
			continue
		if e_dict2.get("top_layer", false):
			continue
		var cb2: Callable = e_dict2.get("cb")
		if not (cb2 and cb2.is_valid()):
			continue
		var items2: Array = cb2.call(font, cam_x, cam_y)
		if items2 == null: continue
		for item in items2:
			_exec_draw_item(game_node, item, font)

	# 12. 全屏 Overlay（上层，默认无 behind_map 的原行为）
	for entry in GameWorld.active_overlays:
		if not entry is Dictionary:
			continue
		var eo3: Dictionary = entry
		if eo3.get("behind_map", false):
			continue
		var overlay_anim2: FrameAnimation = eo3["anim"]
		if not overlay_anim2 or not overlay_anim2.is_playing():
			continue
		var tex2 = overlay_anim2.get_current_texture()
		if not tex2:
			continue
		var pos2: Dictionary = eo3.get("position", {})
		if pos2.get("type", "") != "fullscreen":
			continue
		game_node.draw_texture_rect(tex2, Rect2(0, 0, Constants.W, Constants.H), false)
		var progress = overlay_anim2.get_progress()
		var border_color = eo3.get("border_color", Color(0.9, 0.15, 0.15))
		var border_alpha = 0.3 + sin(progress * PI * 6) * 0.2
		game_node.draw_rect(Rect2(0, 0, Constants.W, Constants.H), Color(border_color.r, border_color.g, border_color.b, border_alpha), false, 8)

	# 12b. 顶层屏幕空间绘制回调（全屏 Overlay 之上：千峰破云图标等 HUD 常驻元素）
	for entry in GameWorld.draw_effect_callbacks:
		if not entry is Dictionary:
			continue
		var e_top: Dictionary = entry
		if not e_top.get("screen_space", false) or not e_top.get("top_layer", false):
			continue
		var cb_top: Callable = e_top.get("cb")
		if not (cb_top and cb_top.is_valid()):
			continue
		var items_top: Array = cb_top.call(font, cam_x, cam_y)
		if items_top == null: continue
		for item in items_top:
			_exec_draw_item(game_node, item, font)

	# 13. 减速滤镜
	var dodge_slow = false
	for f in GameWorld.entities:
		if not is_instance_valid(f):
			continue
		if f.state_flags.get("dodge_slow", 0) > 0:
			dodge_slow = true
			break
	if dodge_slow or GameWorld.slow_mo_timer > 0:
		game_node.draw_rect(Rect2(0, 0, Constants.W, Constants.H), Color(0.471, 0.314, 0.784, 0.12))

	# 13b. 黑白滤镜（整帧高对比黑白着色器）
	# [FX-ENHANCE] 灰度渐入渐出：三角波 0→1→0（渐入→满强度→渐出），消除"瞬间闪黑白/硬切回彩色"
	if GameWorld.grayscale_timer > 0:
		var gs_mat = _ensure_grayscale_material()
		# 三角波：0→1→0（渐入渐出），t 用 grayscale_total 归一化剩余时长
		var t := float(GameWorld.grayscale_timer) / float(maxi(GameWorld.grayscale_total, 1))
		var strength := 1.0 - absf(2.0 * t - 1.0)
		strength = clampf(strength, 0.0, 1.0)
		# [FX-ENHANCE] smoothstep 缓入缓出增强，两端更柔和
		strength = strength * strength * (3.0 - 2.0 * strength)
		gs_mat.set_shader_parameter("strength", strength)
		gs_mat.set_shader_parameter("contrast", 20.0)
		game_node.material = gs_mat
	else:
		game_node.material = null

	# 14. HUD
	HudSystem.draw(game_node, font)

	# 15. Debug
	game_node.draw_string(font, Vector2(10, Constants.H - 10), "frame:" + str(GameWorld.frame) + " particles:" + str(GameWorld.particles.size()), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.667, 0.667, 0.667))

	# 恢复变换
	game_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ===== 地图 =====
static func _draw_map(game_node: CanvasItem, cam_x: float, cam_y: float):
	var bg_tex = GameWorld.battle_bg
	if GameWorld.astrologer_ult_end_frame > 0 and GameWorld.astrologer_ult_bg:
		bg_tex = GameWorld.astrologer_ult_bg
	if bg_tex:
		game_node.draw_texture_rect(bg_tex, Rect2(-cam_x * 0.2, -cam_y * 0.3, Constants.W + 200, Constants.H + 100), false)
	else:
		var from_color = Color(0.102, 0.102, 0.18)
		var to_color = Color(0.169, 0.137, 0.267)
		game_node.draw_rect(Rect2(0, -cam_y, Constants.W, Constants.H * 0.5), from_color)
		game_node.draw_rect(Rect2(0, Constants.H * 0.5 - cam_y, Constants.W, Constants.H * 0.5), to_color)

	for i in range(8):
		var mx = fmod(i * 280 - cam_x * 0.2, Constants.W + 200) - 100
		var my = Constants.GROUND_Y - 60 - sin(i * 1.5) * 30 - cam_y
		var pts = PackedVector2Array([
			Vector2(mx, Constants.GROUND_Y - cam_y),
			Vector2(mx + 120, my),
			Vector2(mx + 240, Constants.GROUND_Y - cam_y)
		])
		game_node.draw_polygon(pts, PackedColorArray([Color(0.267, 0.267, 0.424, 0.3)]))

	game_node.draw_rect(Rect2(0 - cam_x, Constants.GROUND_Y - cam_y - 10, 10, 10), Color(0.914, 0.271, 0.157))
	game_node.draw_rect(Rect2(Constants.MAP_W - 10 - cam_x, Constants.GROUND_Y - cam_y - 10, 10, 10), Color(0.914, 0.271, 0.157))

## 无贴图平台（如默认平台）的兜底配色，与 terrain_tile.gd 一致
const _TERRAIN_FALLBACK_COLORS := {
	0: Color("3a3a52"),  # GROUND
	1: Color("2e2e3e"),  # WALL
	2: Color("6a4c9c"),  # PLATFORM
	3: Color("1a0a2e"),  # VOID
}

## 绘制平台地形块（位于背景之上、角色与 HUD 之下）
static func _draw_platforms(game_node: CanvasItem, cam_x: float, cam_y: float):
	for p in GameWorld.platforms:
		if not p is Dictionary:
			continue
		var pd: Dictionary = p
		# 占星术士土墙由角色自身的绘制回调渲染，这里跳过避免重复
		if pd.has("wall_ref"):
			continue
		var px: float = pd["x"] - cam_x
		var py: float = pd["y"] - cam_y
		var pw: float = pd["w"]
		var ph: float = pd["h"]
		if px > Constants.W + 100 or px + pw < -100:
			continue
		var tex: Texture2D = pd.get("tex")
		if tex is Texture2D:
			var sx: float = pd.get("scale_x", 1.0)
			var sy: float = pd.get("scale_y", 1.0)
			game_node.draw_texture_rect(tex, Rect2(px, py, pw * sx, ph * sy), false)
		else:
			var col: Color = _TERRAIN_FALLBACK_COLORS.get(pd.get("terrain_type", -1), Color("3a3a52"))
			game_node.draw_rect(Rect2(px, py, pw, ph), col)

# ===== 角色实体 =====
static func _draw_fighter(game_node: CanvasItem, f: Fighter, cam_x: float, cam_y: float, is_local: bool = false):
	if not f:
		return
	var px = f.pos_x - cam_x
	var py = f.pos_y - cam_y
	if px < -80 or px > 880:
		return

	if f.state_flags.get("skip_fighter_draw", false):
		return

	var alpha_mod = f.state_flags.get("draw_alpha_mod", 1.0)
	if f.damage_flash > 0 and f.damage_flash % 4 < 2:
		alpha_mod = 0.5

	var tex: Texture2D = f.state_flags.get("draw_texture_override") if f.state_flags.has("draw_texture_override") else null
	var anim: FrameAnimation = f.current_anim
	if not tex:
		if anim:
			tex = anim.get_current_texture()
	if not tex:
		var imgs = f.config.get("images", {})
		var tex_key = f.image_state if imgs.has(f.image_state) else "idle"
		tex = imgs.get(tex_key)
	if not tex:
		push_warning("FrameAnimation: No texture for " + f.char_id + " image_state=" + f.image_state)

	if tex is Texture2D:
		var tw: float = tex.get_width()
		var th: float = tex.get_height()
		var img_scale = f.config.get("image_scale", 1.0)
		if f.attacking and f.config.has("attack_image_scale"):
			img_scale = f.config.get("attack_image_scale")
		elif f.dashing and f.config.has("dash_image_scale"):
			img_scale = f.config.get("dash_image_scale")
		# draw_texture_override 贴图可叠加独立缩放系数
		if f.state_flags.has("draw_texture_override"):
			img_scale *= f.state_flags.get("draw_texture_override_scale", 1.0)
		# draw_texture_override 贴图可叠加垂直偏移（如影武者后撤贴图下移 30px）
		var override_offset_y := 0.0
		if f.state_flags.has("draw_texture_override"):
			override_offset_y = f.state_flags.get("draw_texture_override_offset_y", 0.0)

		# 默认：整帧缩放 + 居中 + 帧底对齐（兼容无锚点的旧贴图）
		var scale = minf(f.w / tw, f.h / th) * img_scale
		tw *= scale; th *= scale
		var tx = px + (f.w - tw) / 2.0
		var ty = py + f.h - th + f.config.get("image_offset_y", 0.0) + override_offset_y

		# 锚点对齐：当前动画帧带锚点数据时，按 内容中轴/脚底/内容高度 统一呈现
		if anim:
			var foot_gap: int = anim.get_current_foot_gap()
			var head_gap: int = anim.get_current_head_gap()
			var center_dx: float = anim.get_current_center_dx()
			var csize: Vector2i = anim.get_current_content_size()
			# 人工标记锚点（uniform）不含 content 尺寸（-1）：用帧尺寸减去上下空隙推算内容高度，
			# 否则会退回旧整帧缩放，把 768×1344 整格压进碰撞箱，角色小到盖不住碰撞体。
			var content_h: float = csize.y
			if (csize.x <= 0 or csize.y <= 0) and tex is AtlasTexture:
				content_h = tex.get_height() - foot_gap - head_gap
			if content_h > 0:
				# 锚点对齐：统一身高 = 内容实际高度(content_h) → 碰撞体高度(f.h)。
				# 注意：不再乘 img_scale —— 那是无锚点旧贴图时代的整帧手调系数，
				# 锚点数据已包含内容真实尺寸，再乘 img_scale 会双重缩放导致大小不对。
				# anim_scale：锚点动画专属缩放系数（默认 1.0），仅对显式配置的角色生效。
				# 统一缩放基准：用动画的参考内容高度（中位数），避免跳跃等动作各帧
				# content_h 差异大（如 413→629）被逐帧归一化导致角色忽大忽小。
				var ref_h: float = anim.content_h_ref if anim.content_h_ref > 0 else content_h
				scale = f.h / float(ref_h) * f.config.get("anim_scale", 1.0)
				# 按动画状态区分的独立缩放（anim_scale_states: {image_state: 倍率}），
				# 用于单个技能动画放大（如断筋斩 1.8×），不影响角色其他动画。
				scale *= float(f.config.get("anim_scale_states", {}).get(f.image_state, 1.0))
				# draw_texture_override 贴图分辨率常与动画帧不同（如连斩 2048×2048），
				# 锚点路径下也要叠加独立缩放系数，否则 override 贴图按动画 content_h 缩放会过大。
				if f.state_flags.has("draw_texture_override"):
					scale *= f.state_flags.get("draw_texture_override_scale", 1.0)
				tw = tex.get_width() * scale
				th = tex.get_height() * scale
				# 内容中轴对齐碰撞体中心（减去内容相对帧中心线的水平偏移）
				# facing<0 时贴图整体翻转，center_dx 需取反，否则镜像后内容中轴偏 2×|center_dx|（向左动画靠后/位移感）
				var cd: float = center_dx if f.facing > 0 else -center_dx
				tx = px + f.w / 2.0 - tw / 2.0 - cd * scale
				# 脚底对齐碰撞体底部（图片底边比脚底低 foot_gap，需下移）
				ty = py + f.h - th + foot_gap * scale + f.config.get("image_offset_y", 0.0) + override_offset_y

		if f.facing < 0:
			game_node.draw_set_transform(Vector2(tx + tw, ty), 0.0, Vector2(-1, 1))
			game_node.draw_texture_rect(tex, Rect2(0, 0, tw, th), false, Color(1, 1, 1, alpha_mod))
			game_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			game_node.draw_texture_rect(tex, Rect2(tx, ty, tw, th), false, Color(1, 1, 1, alpha_mod))
	else:
		var c = Color(0.2, 0.6, 1.0, alpha_mod) if f.is_player else Color(1.0, 0.2, 0.2, alpha_mod)
		game_node.draw_rect(Rect2(px, py, f.w, f.h), c)

	if f.shield_active and SHIELD_IMG:
		var sw: float = SHIELD_IMG.get_width()
		var sh: float = SHIELD_IMG.get_height()
		game_node.draw_texture_rect(SHIELD_IMG, Rect2(px + f.w / 2.0 - sw / 2.0, py + f.h / 2.0 - sh / 2.0, sw, sh), false, Color(1,1,1,0.6))

	for ov in f.draw_overrides:
		if not ov is Dictionary:
			continue
		var ovd: Dictionary = ov
		var ov_cb: Callable = ovd.get("cb")
		if ov_cb and ov_cb.is_valid():
			ov_cb.call(px)

	var pa = f.state_flags.get("paladin_aura")
	if pa:
		var cx = px + f.w / 2.0; var cy = py + f.h / 2.0; var r = maxf(f.w, f.h) * 0.75
		game_node.draw_arc(Vector2(cx, cy), r, 0, PI * 2, 32, Color(1.0, 0.843, 0.0, pa["shield_alpha"]), 4)
		if pa["holy_active"]:
			game_node.draw_circle(Vector2(cx, cy), maxf(f.w, f.h) * 1.18, Color(1.0, 0.843, 0.0, 0.12))

	for s in f.statuses:
		if s.timer <= 0:
			continue
		if s.freeze:
			game_node.draw_rect(Rect2(px, py, f.w, f.h), Color(1.0, 1.0, 1.0, 0.5))
		elif s.vfx_color:
			game_node.draw_rect(Rect2(px, py, f.w, f.h), Color(s.vfx_color.r, s.vfx_color.g, s.vfx_color.b, 0.4))

	var hp_pct = f.hp / maxf(f.max_hp, 1.0)
	game_node.draw_rect(Rect2(px, py - 8, f.w, 4), Color(0.2, 0.2, 0.2))
	game_node.draw_rect(Rect2(px, py - 8, f.w * hp_pct, 4), Color(0.27, 0.67, 0.27))

	# 调试：碰撞体边框（F2 切换）。黄框=碰撞体；角色帧描边单独画在身体纹理上
	if debug_draw_hitboxes:
		var hb: Rect2 = f.get_hit_box()
		game_node.draw_rect(Rect2(hb.position.x - cam_x, hb.position.y - cam_y, hb.size.x, hb.size.y), Color(1, 1, 0), false, 1.5)

	var lbl = "P1" if f.is_player else ("P2" if is_local else "AI")
	var lbl_color = Color.WHITE if f.is_player else (Color(0.0, 0.667, 1.0) if is_local else Color.RED)
	var lbl_font = ThemeDB.fallback_font
	game_node.draw_string(lbl_font, Vector2(px, py - 12), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, lbl_color)

# ===== 投射物 =====
static func _draw_projectiles(game_node: CanvasItem, cam_x: float, cam_y: float):
	for p in GameWorld.projectiles:
		if not p is Dictionary:
			continue
		var pd: Dictionary = p
		var px = pd["x"] - cam_x
		var py = pd["y"] - cam_y
		if px < -50 or px > Constants.W + 50:
			continue
		var pc = pd.get("color", Color(0.533, 0.867, 1.0))
		var pimg = pd.get("img")
		# 支持动画投射物：img 为 FrameAnimation 时画当前帧
		var ptex: Texture2D = pimg.get_current_texture() if pimg is FrameAnimation else pimg
		if ptex is Texture2D:
			if pd.get("vx", 0) < 0:
				game_node.draw_set_transform(Vector2(px + pd["w"], py), 0.0, Vector2(-1, 1))
				game_node.draw_texture_rect(ptex, Rect2(0, 0, pd["w"], pd["h"]), false, Color(1,1,1,0.8))
				game_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				game_node.draw_texture_rect(ptex, Rect2(px, py, pd["w"], pd["h"]), false, Color(1,1,1,0.8))
		else:
			game_node.draw_rect(Rect2(px, py, pd["w"], pd["h"]), pc)
			game_node.draw_rect(Rect2(px + 4, py + 4, pd["w"] - 8, pd["h"] - 8), Color.WHITE)
		if GameWorld.frame % 2 == 0:
			Fighter.emit_particles(pd["x"] + pd["w"] / 2.0, pd["y"] + pd["h"] / 2.0, 3, pc, 2, 4, "circle")

# ===== 火焰区域 =====
static func _draw_flame_zones(game_node: CanvasItem, cam_x: float, cam_y: float):
	for fz in GameWorld.flame_zones:
		var px = fz["x"] - cam_x
		var py = fz["y"] - cam_y
		if px < -50 or px > Constants.W + 50:
			continue
		if FLAME_IMG:
			game_node.draw_texture_rect(FLAME_IMG, Rect2(px, py, fz["w"], fz["h"]), false, Color(1,1,1,0.8))
		else:
			game_node.draw_rect(Rect2(px, py, fz["w"], fz["h"]), Color(1.0, 0.267, 0.0, 0.8))

# ===== 绘制指令执行器 =====
static func _exec_draw_item(game_node: CanvasItem, item: Dictionary, font: Font):
	match item.get("type"):
		"set_transform":
			game_node.draw_set_transform(item["pos"], item.get("rot", 0.0), item["scale"])
		"tex":
			game_node.draw_texture_rect(item["tex"], item["rect"], false, item.get("color", Color.WHITE))
		"rect":
			game_node.draw_rect(item["rect"], item["color"], item.get("filled", true), item.get("border_width", -1.0))
		"circle":
			game_node.draw_circle(item["pos"], item["radius"], item["color"])
		"arc":
			game_node.draw_arc(item["pos"], item["radius"], item["start"], item["end"], item["segments"], item["color"], item.get("width", 1.0))
		"string":
			game_node.draw_string(font, item["pos"], item["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, item.get("size", 10), item.get("color", Color.WHITE))
		"reset_transform":
			game_node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
