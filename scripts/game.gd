extends Node2D

# UI nodes (CanvasLayer)
@onready var ui_layer = $UILayer
@onready var pause_btn = $UILayer/PauseBtn
@onready var pause_menu = $UILayer/PauseMenu
@onready var continue_btn = $UILayer/PauseMenu/PausePanel/ContinueBtn
@onready var menu_btn = $UILayer/PauseMenu/PausePanel/MenuBtn
@onready var exit_btn = $UILayer/PauseMenu/PausePanel/ExitBtn
@onready var touch_controls = $TouchControls

var is_paused := false

# Global texture resources
const BG_IMG = preload("res://assets/801215d83f224786b0f0b4c37c2571d9.png")
const SHIELD_IMG = preload("res://assets/shield-11-20260702203319.png")
const FLAME_IMG = preload("res://assets/17-20260703142847.png")
const PROJ_LIGHT_IMG = preload("res://assets/10-20260702202815.png")

# Evoker summon textures
const EVOKER_SERVANT1 = preload("res://assets/stonem.png")   # 1号召唤物
const EVOKER_SERVANT2_IDLE = preload("res://assets/2idl.png")  # 2号 idle
const EVOKER_SERVANT2_HEAVY = preload("res://assets/2heavy_attack.png")  # 2号重击
const EVOKER_SERVANT2_SKILL = preload("res://assets/2attak.png")  # 2号技能
const EVOKER_SERVANT3 = preload("res://assets/eye.png")   # 3号召唤物
const EVOKER_FIRE_SEA = preload("res://assets/firesea.png")  # 火海
const EVOKER_PULL_BALL = preload("res://assets/pullball.png")  # 引力球
const EVOKER_ULT_CRACK = preload("res://assets/utlgro.png")  # 裂隙
const ROSE_SLASH_IMG = preload("res://assets/%E6%97%A0%E6%A0%87%E9%A2%9893_20260721203233.png")  # 血色蔷薇-刀光
const ASSASSIN_SLASH_IMG = preload("res://assets/53.png")  # 刺客-次元斩

# Shadowwarrior skill textures
const SW_TRAP_A        = preload("res://assets/fx_shadow_trap_a.png")
const SW_TRAP_B        = preload("res://assets/fx_shadow_trap_b.png")
const SW_CLONE_REVEAL  = preload("res://assets/fx_shadow_clone_reveal.png")
const SW_IAIDO_SLASH   = preload("res://assets/fx_shadow_iaido_slash.png")
const SW_RETREAT       = preload("res://assets/fx_shadow_retreat.png")
const SW_BREAK_STRIKE  = preload("res://assets/fx_shadow_break_strike.png")
const SW_GRAB          = preload("res://assets/fx_shadow_grab.png")
const SW_GRAB_BURST    = preload("res://assets/fx_shadow_grab_burst.png")
const SW_IDLE_IMG      = preload("res://assets/char_ani/shadowwarrior/idle/shadowwarrior_idle_f_1.png")
const SW_WALK_IMG      = preload("res://assets/char_ani/shadowwarrior/walk/shadowwarrior_walk_f_1.png")
const SW_ATTACK_IMG    = preload("res://assets/char_ani/shadowwarrior/attack/shadowwarrior_attack_f_1.png")
const SW_ULT_IMG       = preload("res://assets/char_ani/shadowwarrior/ult/shadowwarrior_ult_f_1.png")

# Input state
var keys := {
	"left": false, "right": false, "up": false, "down": false,
	"attack": false, "skill1": false, "skill2": false, "ult": false
}

# Fixed timestep
const FIXED_DT := 1000.0 / 60.0
var _last_time := 0.0
var _accumulator := 0.0

# AI
var ai_think_delay := 0

func _ready():
	print("[Game] _ready() start")
	_last_time = Time.get_ticks_msec()
	CharConfigs.ensure_init()
	print("[Game] configs OK, selected_char = ", GameWorld.selected_char_id)
	
	# Pause UI setup
	_style_pause_ui()
	pause_btn.pressed.connect(_toggle_pause)
	continue_btn.pressed.connect(_toggle_pause)
	menu_btn.pressed.connect(_back_to_menu)
	exit_btn.pressed.connect(_exit_game)
	
	call_deferred("_start_game")

func _start_game():
	var enemy_chars = ["knight","mage","archer","paladin","witch","assassin","shadowwarrior","evoker","rose"]
	var ai_char = enemy_chars[randi() % enemy_chars.size()]
	print("Starting game: player=", GameWorld.selected_char_id, " enemy=", ai_char)
	init_game(GameWorld.selected_char_id, ai_char)

func init_game(player_char_id: String, enemy_char_id: String):
	CharConfigs.ensure_init()
	print("Configs available: ", CharConfigs.configs.keys())
	GameWorld.reset_world()
	var p_skills = CharacterFactory.create_skills(player_char_id)
	var e_skills = CharacterFactory.create_skills(enemy_char_id)
	print("Skills created: p=", p_skills.size(), " e=", e_skills.size())
	GameWorld.player = Fighter.new()
	GameWorld.player.setup(160, 380 - 56, true, player_char_id, p_skills)
	add_child(GameWorld.player)
	GameWorld.enemy = Fighter.new()
	GameWorld.enemy.setup(600, 380 - 56, false, enemy_char_id, e_skills)
	add_child(GameWorld.enemy)
	GameWorld.entities = [GameWorld.player, GameWorld.enemy]
	PickupSystem.init_pickups()
	GameWorld.game_running = true
	GameWorld.game_over = false
	GameWorld.frame = 0
	print("Game initialized! player.hp=", GameWorld.player.hp, " enemy.hp=", GameWorld.enemy.hp)

func _process(_delta: float):
	if not GameWorld.game_running or GameWorld.game_over:
		queue_redraw()
		# Always show UI for game over
		return
	if is_paused:
		queue_redraw()
		return
	var now = Time.get_ticks_msec()
	if _last_time == 0:
		_last_time = now
	var dt = now - _last_time
	_last_time = now
	if dt > 250:
		dt = 250
	_accumulator += dt
	while _accumulator >= FIXED_DT:
		if GameWorld.slow_mo_timer > 0:
			GameWorld.slow_mo_timer -= 1
			GameWorld.slow_mo_tick += 1
			if GameWorld.slow_mo_tick >= GameWorld.SLOW_FACTOR:
				GameWorld.slow_mo_tick = 0
				_update()
		else:
			GameWorld.slow_mo_tick = 0
			_update()
		_accumulator -= FIXED_DT
	queue_redraw()

func _update():
	if GameWorld.hit_stop > 0:
		GameWorld.hit_stop -= 1
		return
	GameWorld.frame += 1
	# Cap particles to prevent performance leak
	if GameWorld.particles.size() > 300:
		GameWorld.particles = GameWorld.particles.slice(GameWorld.particles.size() - 300)
	# Update all skills (cooldowns)
	for f in GameWorld.entities:
		for sk in f.skills:
			sk.update()
	# Input & AI (must happen BEFORE physics, so vx/vy from input take effect same frame)
	InputHandler.update_player_input(GameWorld, keys)
	ai_think_delay = AISystem.update_ai(ai_think_delay)
	# Apply physics (after input, matching JS order)
	_apply_physics_all()
	# 作弊：无限蓝
	if GameWorld.infinite_energy and GameWorld.player:
		GameWorld.player.energy = GameWorld.player.max_energy
	# Systems
	DashSystem.update_dash()
	TornadoSystem.update_tornadoes()
	ProjectileSystem.update_projectiles(self)
	FlameZoneSystem.update_flame_zones()
	SlowSystem.update_slow()
	PickupSystem.update_pickups_and_end()
	CharacterSystems.update_characters()
	CharacterSystems.update_active_overlays()
	CharacterFactory.call_rose_trails()
	EvokerSystem.update()
	# Camera
	var target_cam = GameWorld.player.pos_x - 400.0
	target_cam = clampf(target_cam, 0, 2400 - 800)
	GameWorld.camera.x += (target_cam - GameWorld.camera.x) * 0.1

func _apply_physics_all():
	# Time stop check — skip physics if any entity has time_stop active
	var time_stopped = false
	for f in GameWorld.entities:
		if f.time_stop:
			time_stopped = true
			break
	if not time_stopped:
		for f in GameWorld.entities:
			f.apply_physics()

# ===== Drawing =====
func _draw():
	var cam_x = GameWorld.camera.x
	var font = ThemeDB.fallback_font

	# 1. drawMap()
	_draw_map(cam_x)

	# 2. drawFighter(player) / drawFighter(enemy)
	# Skip drawing fighters when a fullscreen overlay is active
	var has_fullscreen_overlay = false
	for entry in GameWorld.active_overlays:
		if entry.get("position", {}).get("type") == "fullscreen":
			has_fullscreen_overlay = true
			break
	if not has_fullscreen_overlay:
		if GameWorld.player:
			_draw_fighter(GameWorld.player, true)
		if GameWorld.enemy:
			_draw_fighter(GameWorld.enemy, GameWorld.game_mode == "pvp")

	# 3. drawProjectiles()
	for p in GameWorld.projectiles:
		var px = p["x"] - cam_x
		if px < -50 or px > Constants.W + 50:
			continue
		var pc = p.get("color", Color(0.533, 0.867, 1.0))
		var pimg = p.get("img")
		if pimg is Texture2D:
			if p.get("vx", 0) < 0:
				draw_set_transform(Vector2(px + p["w"], p["y"]), 0.0, Vector2(-1, 1))
				draw_texture_rect(pimg, Rect2(0, 0, p["w"], p["h"]), false, Color(1,1,1,0.8))
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				draw_texture_rect(pimg, Rect2(px, p["y"], p["w"], p["h"]), false, Color(1,1,1,0.8))
		else:
			draw_rect(Rect2(px, p["y"], p["w"], p["h"]), pc)
			draw_rect(Rect2(px + 4, p["y"] + 4, p["w"] - 8, p["h"] - 8), Color.WHITE)
		if GameWorld.frame % 2 == 0:
			Fighter.emit_particles(p["x"] + p["w"] / 2.0, p["y"] + p["h"] / 2.0, 3, pc, 2, 4, "circle")

	# 4. drawTornadoes()
	for t in GameWorld.tornadoes:
		var px = t["x"] - cam_x
		if px > -t["w"] and px < Constants.W + t["w"]:
			if t.has("img") and t["img"] is Texture2D:
				draw_texture_rect(t["img"], Rect2(px, t["y"], t["w"], t["h"]), false, Color(1,1,1,0.8))
			else:
				draw_rect(Rect2(px, t["y"], t["w"], t["h"]), Color(0.533, 0.867, 1.0, 0.8))

	# 5. drawVortexes()
	for v in GameWorld.vortexes:
		var px = v["x"] - cam_x
		if px > -v["w"] and px < Constants.W + v["w"]:
			if v.has("img") and v["img"] is Texture2D:
				draw_texture_rect(v["img"], Rect2(px, v["y"], v["w"], v["h"]), false, Color(1,1,1,0.8))
			else:
				draw_rect(Rect2(px, v["y"], v["w"], v["h"]), Color(0.467, 0.267, 0.667, 0.8))

	# 6. drawFlameZones()
	for fz in GameWorld.flame_zones:
		var px = fz["x"] - cam_x
		if px < -50 or px > Constants.W + 50:
			continue
		if FLAME_IMG:
			draw_texture_rect(FLAME_IMG, Rect2(px, fz["y"], fz["w"], fz["h"]), false, Color(1,1,1,0.8))
		else:
			draw_rect(Rect2(px, fz["y"], fz["w"], fz["h"]), Color(1.0, 0.267, 0.0, 0.8))

	# 7. drawPickups()
	for p in GameWorld.pickups:
		p.draw(self, cam_x)

	# 8. drawChargeBar()
	_draw_charge_bar(GameWorld.player, cam_x)
	if GameWorld.game_mode == "pvp":
		_draw_charge_bar(GameWorld.enemy, cam_x)

	# 9. drawParticles()
	for pt in GameWorld.particles:
		pt.draw(self)

	# 10. drawExplosionEffects()
	for e in GameWorld.explosion_effects:
		var px = e.x - cam_x
		var alpha = e.get("alpha", 0.8)
		draw_circle(Vector2(px + e.w / 2.0, e.y + e.h / 2.0), e.w / 2.0, Color(1.0, 0.533, 0.267, alpha))

	# 11. onOverlayDraw hook (placeholder)
	# Character-specific overlay drawing would be called here.

	# Evoker summons and effects drawing
	_draw_evoker_summons(cam_x)
	_draw_evoker_fire_seas(cam_x)
	_draw_evoker_gravity_balls(cam_x)
	_draw_evoker_void_rifts(cam_x)

	# Shadowwarrior overlays and phantoms
	_draw_shadowwarrior_overlays(cam_x)
	_draw_phantoms(cam_x)

	# 11.5 Active overlay animations (unified position_spec)
	for entry in GameWorld.active_overlays:
		var overlay_anim: FrameAnimation = entry["anim"]
		if not overlay_anim or not overlay_anim.is_playing():
			continue
		var tex = overlay_anim.get_current_texture()
		if not tex:
			continue
		var pos = entry.get("position", {})
		match pos.get("type", ""):
			"fullscreen":
				draw_texture_rect(tex, Rect2(0, 0, Constants.W, Constants.H), false)
				var progress = overlay_anim.get_progress()
				var border_color = Color(0.9, 0.15, 0.15)
				var oid = entry.get("overlay_id", "")
				if oid.begins_with("assassin"):
					border_color = Color(0.53, 0.27, 0.8)
				var border_alpha = 0.3 + sin(progress * PI * 6) * 0.2
				draw_rect(Rect2(0, 0, Constants.W, Constants.H), Color(border_color.r, border_color.g, border_color.b, border_alpha), false, 8)
			"fixed":
				var rect: Rect2 = pos.get("rect", Rect2())
				draw_texture_rect(tex, rect, false)
			"follow":
				var target = pos.get("target")
				if target and target is Fighter and target.hp > 0:
					var sx = target.pos_x - cam_x + target.w / 2.0 + pos.get("offset", Vector2.ZERO).x
					var sy = target.pos_y + target.h / 2.0 + pos.get("offset", Vector2.ZERO).y
					var sc = pos.get("scale", Vector2.ONE)
					var tw = target.w * sc.x
					var th = target.h * sc.y
					if target.facing < 0:
						draw_set_transform(Vector2(sx, sy), 0.0, Vector2(-sc.x, sc.y))
						draw_texture_rect(tex, Rect2(-tw / 2.0, -th / 2.0, tw, th), false)
						draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
					else:
						draw_set_transform(Vector2(sx, sy), 0.0, Vector2(sc.x, sc.y))
						draw_texture_rect(tex, Rect2(-tw / 2.0, -th / 2.0, tw, th), false)
						draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"world":
				var wx = pos.get("x", 0.0) - cam_x
				var wy = pos.get("y", 0.0)
				var sc = pos.get("scale", Vector2.ONE)
				draw_texture_rect(tex, Rect2(wx, wy, tex.get_width() * sc.x, tex.get_height() * sc.y), false)

	# 11.6 Rose slash trails
	for trail in GameWorld.rose_slash_trails:
		var tx = trail["x"] - cam_x
		if tx > -200 and tx < Constants.W + 200:
			var tex: Texture2D = null
			var trail_anim: FrameAnimation = trail.get("anim")
			if trail_anim:
				tex = trail_anim.get_current_texture()
			if not tex:
				tex = trail.get("img", ROSE_SLASH_IMG)
			if tex:
				var dir = trail.get("dir", 1)
				if dir < 0:
					draw_set_transform(Vector2(tx + trail["w"], trail["y"]), 0.0, Vector2(-1, 1))
					draw_texture_rect(tex, Rect2(0, 0, trail["w"], trail["h"]), false, Color(1, 1, 1, 0.85))
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				else:
					draw_texture_rect(tex, Rect2(tx, trail["y"], trail["w"], trail["h"]), false, Color(1, 1, 1, 0.85))

	# 11.6 Assassin dimensional slash
	for f in GameWorld.entities:
		if f.char_id == "assassin" and f.slash_active:
			var sx = f.slash_x - cam_x
			if sx > -120 and sx < Constants.W + 120:
				if f.slash_facing < 0:
					draw_set_transform(Vector2(sx + 100, f.slash_y), 0.0, Vector2(-1, 1))
					draw_texture_rect(ASSASSIN_SLASH_IMG, Rect2(0, 0, 100, 40), false, Color(1, 1, 1, 0.9))
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				else:
					draw_texture_rect(ASSASSIN_SLASH_IMG, Rect2(sx, f.slash_y, 100, 40), false, Color(1, 1, 1, 0.9))

	# 12. Time slow filter
	if GameWorld.slow_mo_timer > 0:
		draw_rect(Rect2(0, 0, Constants.W, Constants.H), Color(0.471, 0.314, 0.784, 0.12))

	# 13. HUD
	_draw_hud(font)

	# Debug text (bottom-left corner)
	draw_string(font, Vector2(10, Constants.H - 10), "frame:" + str(GameWorld.frame) + " particles:" + str(GameWorld.particles.size()), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.667, 0.667, 0.667))

func _draw_map(cam_x: float):
	# Background parallax image
	if BG_IMG:
		draw_texture_rect(BG_IMG, Rect2(-cam_x * 0.2, 0, Constants.W + 200, Constants.H), false)
	else:
		var from_color = Color(0.102, 0.102, 0.18)
		var to_color = Color(0.169, 0.137, 0.267)
		draw_rect(Rect2(0, 0, Constants.W, Constants.H * 0.5), from_color)
		draw_rect(Rect2(0, Constants.H * 0.5, Constants.W, Constants.H * 0.5), to_color)

	# Mountain peaks (decorative triangles)
	for i in range(8):
		var mx = fmod(i * 280 - cam_x * 0.2, Constants.W + 200) - 100
		var my = Constants.GROUND_Y - 60 - sin(i * 1.5) * 30
		var pts = PackedVector2Array([
			Vector2(mx, Constants.GROUND_Y),
			Vector2(mx + 120, my),
			Vector2(mx + 240, Constants.GROUND_Y)
		])
		draw_polygon(pts, PackedColorArray([Color(0.267, 0.267, 0.424, 0.3)]))

	# Ground
	draw_rect(Rect2(0, Constants.GROUND_Y, Constants.W, Constants.H - Constants.GROUND_Y), Color(0.239, 0.239, 0.361))

	# Ground tile stripes
	for i in range(0, Constants.MAP_W, 40):
		var sx = i - cam_x * 0.8
		if sx > -20 and sx < Constants.W + 20:
			draw_rect(Rect2(sx, Constants.GROUND_Y + 4, 20, 4), Color(0.31, 0.31, 0.435))

	# Platforms
	for pl in GameWorld.platforms:
		if pl.get("is_ground"):
			continue
		var sx = pl["x"] - cam_x
		if sx < -pl["w"] - 20 or sx > Constants.W + 20:
			continue
		draw_rect(Rect2(sx, pl["y"], pl["w"], pl["h"]), Color(0.416, 0.298, 0.612))
		draw_rect(Rect2(sx + 4, pl["y"] - 2, pl["w"] - 8, 4), Color(0.541, 0.424, 0.737))
		draw_rect(Rect2(sx + 4, pl["y"] + pl["h"], pl["w"] - 8, 4), Color(0, 0, 0, 0.3))

	# Map boundary markers
	draw_rect(Rect2(0 - cam_x, Constants.GROUND_Y - 10, 10, 10), Color(0.914, 0.271, 0.157))
	draw_rect(Rect2(Constants.MAP_W - 10 - cam_x, Constants.GROUND_Y - 10, 10, 10), Color(0.914, 0.271, 0.157))

func _draw_fighter(f: Fighter, is_local: bool = false):
	if not f:
		return
	# 影武者居合期间：角色贴图由 _draw_shadowwarrior_overlays 绘制
	if f.char_id == "shadowwarrior" and f.iaido_active:
		return
	var px = f.pos_x - GameWorld.camera.x
	if px < -80 or px > 880:
		return

	# Damage flash
	var alpha_mod = 1.0
	if f.damage_flash > 0 and f.damage_flash % 4 < 2:
		alpha_mod = 0.5
	# Stealth transparency for shadowwarrior
	if f.char_id == "shadowwarrior" and f.stealth_active:
		alpha_mod = 0.5

	# Draw texture if available, otherwise colored rect
	var tex: Texture2D = null
	var anim: FrameAnimation = f.current_anim
	if anim:
		tex = anim.get_current_texture()
	# Fallback: try old images dict
	if not tex:
		var imgs = f.config.get("images", {})
		var tex_key = f.image_state if imgs.has(f.image_state) else "idle"
		tex = imgs.get(tex_key)
	if not tex:
		push_warning("FrameAnimation: No texture for " + f.char_id + " image_state=" + f.image_state)
	if tex is Texture2D:
		# Fit texture within fighter box, keeping aspect ratio
		var tw: float = tex.get_width()
		var th: float = tex.get_height()
		var scale = minf(f.w / tw, f.h / th) * f.config.get("image_scale", 1.0)
		tw *= scale; th *= scale
		var tx = px + (f.w - tw) / 2.0
		var ty = f.pos_y + f.h - th
		if f.facing < 0:
			draw_set_transform(Vector2(tx + tw, ty), 0.0, Vector2(-1, 1))
			draw_texture_rect(tex, Rect2(0, 0, tw, th), false, Color(1, 1, 1, alpha_mod))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_texture_rect(tex, Rect2(tx, ty, tw, th), false, Color(1, 1, 1, alpha_mod))
	else:
		# Fallback: colored rectangle
		var c = Color(0.2, 0.6, 1.0, alpha_mod) if f.is_player else Color(1.0, 0.2, 0.2, alpha_mod)
		draw_rect(Rect2(px, f.pos_y, f.w, f.h), c)

	# Shield ring effect
	if f.shield_active and SHIELD_IMG:
		var sw: float = SHIELD_IMG.get_width()
		var sh: float = SHIELD_IMG.get_height()
		draw_texture_rect(SHIELD_IMG, Rect2(px + f.w / 2.0 - sw / 2.0, f.pos_y + f.h / 2.0 - sh / 2.0, sw, sh), false, Color(1,1,1,0.6))
	if f.divine_shield_active or f.holy_empower_active:
		var alpha_s = 0.32 if f.divine_shield_active else 0.24
		draw_arc(Vector2(px + f.w / 2.0, f.pos_y + f.h / 2.0), maxf(f.w, f.h) * 0.75, 0, PI * 2, 32, Color(1.0, 0.843, 0.0, alpha_s), 4)
		if f.holy_empower_active:
			draw_circle(Vector2(px + f.w / 2.0, f.pos_y + f.h / 2.0), maxf(f.w, f.h) * 1.18, Color(1.0, 0.843, 0.0, 0.12))

	# Status effect overlays
	for s in f.statuses:
		if s.timer <= 0:
			continue
		if s.freeze:
			draw_rect(Rect2(px, f.pos_y, f.w, f.h), Color(1.0, 1.0, 1.0, 0.5))
		elif s.vfx_color:
			draw_rect(Rect2(px, f.pos_y, f.w, f.h), Color(s.vfx_color.r, s.vfx_color.g, s.vfx_color.b, 0.4))

	# HP bar (above fighter)
	var hp_pct = f.hp / maxf(f.max_hp, 1.0)
	draw_rect(Rect2(px, f.pos_y - 8, f.w, 4), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(px, f.pos_y - 8, f.w * hp_pct, 4), Color(0.27, 0.67, 0.27))

	# Label
	var lbl = "P1" if f.is_player else ("P2" if is_local else "AI")
	var lbl_color = Color.WHITE if f.is_player else (Color(0.0, 0.667, 1.0) if is_local else Color.RED)
	draw_string(ThemeDB.fallback_font, Vector2(px, f.pos_y - 12), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, lbl_color)

func _draw_charge_bar(owner: Fighter, cam_x: float):
	if not owner:
		return
	if not owner.charging and not owner.charging_skill1 and not owner.charging_attack:
		return
	var px = owner.pos_x - cam_x + owner.w / 2.0
	var py = owner.pos_y - 20
	var max_width = 40.0
	var charge_time: float
	if owner.charging_skill1 or owner.charging_attack:
		charge_time = (Time.get_ticks_msec() - owner.charge_start_time) / 1000.0
	else:
		charge_time = (Time.get_ticks_msec() - owner.charge_start) / 1000.0
	var max_charge = 2.0 if (owner.charging_skill1 or owner.charging_attack) else 3.0
	var progress = clampf(charge_time / max_charge, 0.0, 1.0)

	# Background
	draw_rect(Rect2(px - max_width / 2.0 - 2, py - 2, max_width + 4, 10), Color(0, 0, 0, 0.6))
	# Fill
	var fill_color: Color
	if owner.charging_skill1:
		fill_color = Color(1.0, 0.843, 0.0)
	elif owner.charging_attack:
		fill_color = Color(0.533, 0.867, 1.0)  # Light blue for archer charge
	else:
		fill_color = Color(1.0, 0.867, 0.267)
	draw_rect(Rect2(px - max_width / 2.0, py, max_width * progress, 6), fill_color)
	# Border
	draw_rect(Rect2(px - max_width / 2.0, py, max_width, 6), Color.WHITE, false)

func _draw_hud(font: Font):
	if not GameWorld.player or not GameWorld.enemy:
		return
	var p = GameWorld.player
	var e = GameWorld.enemy
	var bar_x = 10
	var bar_w = 180.0
	var bar_h = 14.0

	# === Player (left side) ===
	var p_cfg = p.config
	var p_name = p_cfg.get("name", "P1")
	
	# HP bar background
	draw_rect(Rect2(bar_x, 4, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.8))
	var p_hp_pct = maxf(0, p.hp / maxf(p.max_hp, 1.0))
	var hp_color = Color(0.0, 0.667, 1.0) if p_hp_pct > 0.3 else Color(1.0, 0.133, 0.133)
	draw_rect(Rect2(bar_x, 4, bar_w * p_hp_pct, bar_h), hp_color)
	# HP label
	draw_string(font, Vector2(bar_x + 4, 6), p_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_string(font, Vector2(bar_x + bar_w - 50, 6), str(int(p.hp)) + "/" + str(int(p.max_hp)), HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color.WHITE)

	# Energy bar
	var energy_bar_h = 8.0
	draw_rect(Rect2(bar_x, 20, bar_w, energy_bar_h), Color(0.05, 0.05, 0.08, 0.8))
	var p_eng_pct = minf(1.0, p.energy / maxf(p.max_energy, 1.0))
	var eng_color = Color(1.0, 0.843, 0.0) if p.char_id == "paladin" else Color(0.0, 0.831, 1.0)
	draw_rect(Rect2(bar_x, 20, bar_w * p_eng_pct, energy_bar_h), eng_color)
	var res_label = p_cfg.get("resource_label", "能量")
	draw_string(font, Vector2(bar_x + 52, 20), res_label + " " + str(int(p.energy)), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.667, 0.8, 1.0))

	# Blood Abyss bar (rose only)
	if p.char_id == "rose":
		var ba_y = 30.0
		var ba_h = 6.0
		draw_rect(Rect2(bar_x, ba_y, bar_w, ba_h), Color(0.05, 0.05, 0.08, 0.8))
		var ba_pct = minf(1.0, p.blood_abyss / 40.0)
		draw_rect(Rect2(bar_x, ba_y, bar_w * ba_pct, ba_h), Color(0.9, 0.15, 0.15))
		draw_string(font, Vector2(bar_x + 52, ba_y), "血渊 " + str(int(p.blood_abyss)), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.4, 0.4))

	# Shadow Energy bar (assassin only)
	if p.char_id == "assassin":
		var se_y = 30.0
		var se_h = 6.0
		draw_rect(Rect2(bar_x, se_y, bar_w, se_h), Color(0.05, 0.05, 0.08, 0.8))
		var se_pct = minf(1.0, p.shadow_energy / 5.0)
		draw_rect(Rect2(bar_x, se_y, bar_w * se_pct, se_h), Color(0.53, 0.27, 0.8))
		var se_label = "暗影游走" if p.shadow_stance else "暗影 " + str(int(p.shadow_energy)) + "/5"
		draw_string(font, Vector2(bar_x + 52, se_y), se_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.67, 0.53, 1.0))

	# Arrow count bar (archer only)
	if p.char_id == "archer":
		var ar_y = 30.0
		var ar_h = 6.0
		draw_rect(Rect2(bar_x, ar_y, bar_w, ar_h), Color(0.05, 0.05, 0.08, 0.8))
		var ar_pct = float(p.arrows) / maxf(p.max_arrows, 1.0)
		draw_rect(Rect2(bar_x, ar_y, bar_w * ar_pct, ar_h), Color(0.8, 0.6, 0.2))
		draw_string(font, Vector2(bar_x + 52, ar_y), "箭矢 " + str(p.arrows), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.7, 0.3))

	# === Enemy (right side) ===
	var e_name = e.config.get("name", "AI")
	var e_bar_x = Constants.W - bar_x - bar_w
	
	# HP bar
	draw_rect(Rect2(e_bar_x, 4, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.8))
	var e_hp_pct = maxf(0, e.hp / maxf(e.max_hp, 1.0))
	var e_hp_color = Color(1.0, 0.133, 0.133) if e_hp_pct > 0.3 else Color(1.0, 0.0, 0.0)
	draw_rect(Rect2(e_bar_x + bar_w * (1.0 - e_hp_pct), 4, bar_w * e_hp_pct, bar_h), e_hp_color)
	draw_string(font, Vector2(e_bar_x + bar_w - 4, 6), e_name, HORIZONTAL_ALIGNMENT_RIGHT, -1, 12, Color(1.0, 0.533, 0.533))
	draw_string(font, Vector2(e_bar_x + bar_w - 4 - 55, 6), str(int(e.hp)) + "/" + str(int(e.max_hp)), HORIZONTAL_ALIGNMENT_RIGHT, -1, 10, Color.WHITE)

	# Energy bar (enemy)
	draw_rect(Rect2(e_bar_x, 20, bar_w, energy_bar_h), Color(0.05, 0.05, 0.08, 0.8))
	var e_eng_pct = minf(1.0, e.energy / maxf(e.max_energy, 1.0))
	draw_rect(Rect2(e_bar_x + bar_w * (1.0 - e_eng_pct), 20, bar_w * e_eng_pct, energy_bar_h), Color(0.8, 0.267, 0.0))
	draw_string(font, Vector2(e_bar_x + bar_w - 4, 20), str(int(e.energy)), HORIZONTAL_ALIGNMENT_RIGHT, -1, 8, Color(1.0, 0.667, 0.4))

	# === Skill cooldowns at bottom ===
	var skill_labels: Dictionary
	if p.char_id == "rose":
		skill_labels = {"attack": "J 血刃", "skill1": "U 血之月华", "skill2": "I 夜翼瞬袭", "ult": "O 暗夜华尔兹"}
	else:
		skill_labels = {"attack": "J 普攻", "skill1": "U 技1", "skill2": "I 技2", "ult": "O 大招"}
	var btn_x_start = (Constants.W - 4 * 60) / 2.0
	var skill_keys = ["attack", "skill1", "skill2", "ult"]
	for i in skill_keys.size():
		var key = skill_keys[i]
		var sk = p.get_skill(key)
		var bx = btn_x_start + i * 64
		var by = Constants.H - 28
		# Background
		draw_rect(Rect2(bx, by, 58, 22), Color(0.1, 0.1, 0.15, 0.85))
		# Label
		draw_string(font, Vector2(bx + 4, by + 4), skill_labels.get(key, key), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.667, 0.667, 0.8))
		# Cooldown overlay
		if sk and sk.cd > 0:
			var cd_pct = float(sk.cd) / float(sk.cooldown)
			draw_rect(Rect2(bx, by, 58 * cd_pct, 22), Color(0, 0, 0, 0.6))
			draw_string(font, Vector2(bx + 29, by + 14), str(ceil(sk.cd / 60.0)) + "s", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(1.0, 0.533, 0.533))
		# Border
		draw_rect(Rect2(bx, by, 58, 22), Color(0.3, 0.3, 0.5), false)

	# === Game Over overlay ===
	if GameWorld.game_over:
		draw_rect(Rect2(0, 0, Constants.W, Constants.H), Color(0, 0, 0, 0.6))
		var is_win = GameWorld.game_result == "win"
		var title = "🏆 胜利!" if is_win else "💀 战败"
		var sub = "你击败了 " + GameWorld.difficulty.to_upper() + " 难度对手!" if is_win else "AI 取得了胜利..."
		draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 - 20), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 36, Color(1.0, 0.843, 0.0) if is_win else Color(1.0, 0.267, 0.267))
		draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 + 16), sub, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)
		draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 + 42), "按 R 重新开始", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.667, 0.667, 0.667))
		draw_string(font, Vector2(Constants.W / 2.0, Constants.H / 2.0 + 58), "按 ESC 返回菜单", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.467, 0.467, 0.467))

# ===== Evoker drawing functions =====

func _draw_evoker_summons(cam_x: float):
	for summon in GameWorld.evoker_summons:
		var sx = summon["x"] - cam_x
		var sy = summon["y"]
		var sw = summon["w"]
		var sh = summon["h"]
		var stype = summon["type"]
		
		# Choose texture based on type and action
		var tex = null
		match stype:
			0: tex = EVOKER_SERVANT1
			1:
				if summon.get("action_timer", 0) > 0 and summon.get("action_type") == "heavy":
					tex = EVOKER_SERVANT2_HEAVY
				elif summon.get("action_timer", 0) > 0 and summon.get("action_type") == "skill":
					tex = EVOKER_SERVANT2_SKILL
				else:
					tex = EVOKER_SERVANT2_IDLE
			2: tex = EVOKER_SERVANT3
		
		if tex:
			# Summon textures are drawn facing left natively; flip toward enemy
			var owner = summon.get("owner")
			var face_dir = 1
			if owner:
				var enemy = GameWorld.get_opponent(owner)
				if enemy:
					face_dir = 1 if (enemy.pos_x + enemy.w/2) > (summon["x"] + sw/2) else -1
				else:
					face_dir = owner.facing
			
			draw_set_transform(Vector2(sx + sw/2, sy + sh/2), 0.0, Vector2(-face_dir, 1))
			draw_texture_rect(tex, Rect2(-sw/2, -sh/2, sw, sh), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
		# HP bar
		var hp_pct = summon.get("hp", 0) / maxf(summon.get("max_hp", 1), 1.0)
		draw_rect(Rect2(sx, sy - 10, sw, 6), Color(0.2, 0.2, 0.2))
		var hp_color = Color.GREEN if hp_pct > 0.5 else (Color.ORANGE if hp_pct > 0.25 else Color.RED)
		draw_rect(Rect2(sx, sy - 10, sw * hp_pct, 6), hp_color)
		# State label
		draw_string(ThemeDB.fallback_font, Vector2(sx + sw/2, sy - 16), summon.get("state", ""), HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.WHITE)

func _draw_evoker_fire_seas(cam_x: float):
	for fs in GameWorld.evoker_fire_seas:
		var fx = fs["x"] - cam_x
		var fy = fs["y"] + 60  # offset to ground level
		if EVOKER_FIRE_SEA:
			draw_texture_rect(EVOKER_FIRE_SEA, Rect2(fx, fy, fs["w"], fs["h"]), false, Color(1,1,1,0.7))

func _draw_evoker_gravity_balls(cam_x: float):
	for b in GameWorld.gravity_balls:
		var bx = b["x"] - cam_x
		if EVOKER_PULL_BALL:
			draw_texture_rect(EVOKER_PULL_BALL, Rect2(bx, b["y"], b["w"], b["h"]), false)

func _draw_evoker_void_rifts(cam_x: float):
	for rift in GameWorld.void_rifts:
		var rx = rift["x"] - cam_x
		if EVOKER_ULT_CRACK:
			draw_texture_rect(EVOKER_ULT_CRACK, Rect2(rx, rift["y"], rift["w"], rift["h"]), false, Color(1,1,1,0.7))
		# Pulsing border
		var pulse = sin(rift.get("timer", 0) * 0.1) * 0.3 + 0.7
		draw_rect(Rect2(rx, rift["y"], rift["w"], rift["h"]), Color(0.784, 0.392, 1.0, pulse * 0.8), false, 3)


# ── 影武者覆盖层绘制 ──
func _sw_draw_tex(img: Texture2D, wx: float, wy: float, w: float, h: float, cam_x: float, facing: int = 1, alpha: float = 1.0):
	if not img: return
	var px = wx - cam_x
	var cx = px + w / 2.0
	var cy = wy + h / 2.0
	var sc = Vector2(-1 if facing < 0 else 1, 1)
	draw_set_transform(Vector2(cx, cy), 0.0, sc)
	draw_texture_rect(img, Rect2(-w / 2.0, -h / 2.0, w, h), false, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_shadowwarrior_overlays(cam_x: float):
	for f in GameWorld.entities:
		if f.char_id != "shadowwarrior" or f.hp <= 0: continue

		# 暗影替身（陷阱）
		if f.shadow_trap_active and not f.shadow_trap.is_empty():
			var trap = f.shadow_trap
			match trap["phase"]:
				"idle":
					var img = SW_TRAP_A if (trap["anim"] / 30) % 2 == 0 else SW_TRAP_B
					_sw_draw_tex(img, trap["x"], trap["y"]+f.h*0.4, f.w, f.h*0.6, cam_x, f.facing, 0.7)
				"capture":
					var cap: Fighter = trap["captured"]
					if cap and cap is Fighter and cap.hp > 0:
						_sw_draw_tex(SW_GRAB, cap.pos_x - 10, cap.pos_y - 10, cap.w + 20, cap.h + 20, cam_x, 1, 0.95)
				"burst":
					var cap: Fighter = trap["captured"]
					var bx = cap.pos_x - 10 if (cap and cap is Fighter) else trap["x"] - 10
					var by = cap.pos_y - 10 if (cap and cap is Fighter) else trap["y"] - 10
					var bw = (cap.w + 20 if (cap and cap is Fighter) else trap["w"] + 20)
					var bh = (cap.h + 20 if (cap and cap is Fighter) else trap["h"] + 20)
					_sw_draw_tex(SW_GRAB_BURST, bx, by, bw, bh, cam_x, 1, 1.0)

		# 居合刀光 + 定格姿态（替代角色贴图，等比缩放底部对齐）
		if f.iaido_active and not f.iaido_slash.is_empty():
			var slash = f.iaido_slash
			_sw_draw_tex(SW_IAIDO_SLASH, slash["x"], slash["y"], slash["w"], slash["h"], cam_x, slash.get("dir", 1), 0.85)
			# 定格姿态：等比缩放到角色框内，底部贴地
			var img_w: float = SW_ULT_IMG.get_width()
			var img_h: float = SW_ULT_IMG.get_height()
			var s = minf(f.w / img_w , f.h   / img_h ) 
			var dw = img_w * s; var dh = img_h * s
			_sw_draw_tex(SW_ULT_IMG, f.pos_x + (f.w - dw) / 2.0, f.pos_y + f.h - dh*1.5, dw, dh*1.5, cam_x, f.facing, 1.0)

		# 后撤贴图
		if f.retreat_timer > 0:
			var alpha = 0.5 if (f == GameWorld.player and f.stealth_active) else 1.0
			_sw_draw_tex(SW_RETREAT, f.pos_x, f.pos_y, f.w, f.h, cam_x, f.facing, alpha)

		# 幻影·舞遮挡贴图（与角色同尺寸）
		if f.clone_reveal_timer > 0:
			_sw_draw_tex(SW_CLONE_REVEAL, f.pos_x, f.pos_y + f.h * 0.5, f.w, f.h * 0.6, cam_x, f.facing, 1.0)


func _draw_phantoms(cam_x: float):
	for ph in GameWorld.phantoms:
		if ph.get("hp", 0) <= 0: continue

		var state = ph.get("image_state", "idle")
		var img: Texture2D = SW_IDLE_IMG
		match state:
			"attack": img = SW_ATTACK_IMG
			"walk":   img = SW_WALK_IMG

		var px = ph["x"] - cam_x
		if px < -ph["w"] or px > Constants.W + ph["w"]: continue

		# 分身绘制（半透明，位置/尺寸与陷阱分身一致）
		var py = ph["y"] + ph["h"] * 0.5
		var dh = ph["h"] * 0.6
		if ph["facing"] < 0:
			draw_set_transform(Vector2(px + ph["w"], py), 0.0, Vector2(-1, 1))
			draw_texture_rect(img, Rect2(0, 0, ph["w"], dh), false, Color(1, 1, 1, 0.75))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_texture_rect(img, Rect2(px, py, ph["w"], dh), false, Color(1, 1, 1, 0.75))

		# 分身血条
		var hp_pct = maxf(0, ph["hp"] / maxf(ph.get("max_hp", 1.0), 1.0))
		draw_rect(Rect2(px, py - 8, ph["w"], 4), Color(0, 0, 0, 0.5))
		draw_rect(Rect2(px, py - 8, ph["w"] * hp_pct, 4), Color(0.53, 0.27, 0.8))

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if GameWorld.game_over:
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			else:
				_toggle_pause()
			return
		var pr = event.pressed
		match event.keycode:
			KEY_A, KEY_LEFT: keys["left"] = pr
			KEY_D, KEY_RIGHT: keys["right"] = pr
			KEY_W, KEY_UP, KEY_K: keys["up"] = pr
			KEY_S, KEY_DOWN: keys["down"] = pr
			KEY_J: keys["attack"] = pr
			KEY_U: keys["skill1"] = pr
			KEY_I: keys["skill2"] = pr
			KEY_O: keys["ult"] = pr
			KEY_R:
				if pr and GameWorld.game_over:
					_restart_game()

func _restart_game():
	# Clean up old fighters
	if GameWorld.player: GameWorld.player.queue_free()
	if GameWorld.enemy: GameWorld.enemy.queue_free()
	GameWorld.player = null
	GameWorld.enemy = null
	var enemy_chars = ["knight","mage","archer","paladin","witch","assassin","shadowwarrior","evoker","rose"]
	var ai_char = enemy_chars[randi() % enemy_chars.size()]
	init_game(GameWorld.selected_char_id, ai_char)

# ===== Pause menu =====

func _toggle_pause():
	is_paused = not is_paused
	pause_menu.visible = is_paused
	# Hide/show touch controls with pause state
	if touch_controls:
		touch_controls.visible = not is_paused
	# Clear lingering keys so they don't trigger actions right after unpause
	if not is_paused:
		keys["attack"] = false
		keys["skill1"] = false
		keys["skill2"] = false
		keys["ult"] = false
		keys["up"] = false

func _back_to_menu():
	is_paused = false
	# Stop game loop and clean up before changing scene
	GameWorld.game_running = false
	GameWorld.game_over = true
	if GameWorld.player:
		GameWorld.player.queue_free()
		GameWorld.player = null
	if GameWorld.enemy:
		GameWorld.enemy.queue_free()
		GameWorld.enemy = null
	GameWorld.reset_world()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _exit_game():
	get_tree().quit()

func _style_pause_ui():
	# Pause button — small, subtle, top-right
	pause_btn.add_theme_font_size_override("font_size", 14)
	pause_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	pause_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	
	# Pause title
	var pause_title = $UILayer/PauseMenu/PausePanel/PauseTitle
	pause_title.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	
	# Style the three menu buttons
	_style_pause_button(continue_btn, Color(0.298, 0.686, 0.314))
	_style_pause_button(menu_btn, Color(1.0, 0.843, 0.0))
	_style_pause_button(exit_btn, Color(0.914, 0.271, 0.157))

func _style_pause_button(btn: Button, accent: Color):
	btn.add_theme_font_size_override("font_size", 16)
	
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(accent.r, accent.g, accent.b, 0.15)
	normal.set_corner_radius_all(10)
	normal.border_width_left = 2; normal.border_width_right = 2
	normal.border_width_top = 2; normal.border_width_bottom = 2
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.5)
	btn.add_theme_stylebox_override("normal", normal)
	
	var hover = normal.duplicate()
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.35)
	hover.border_color = accent
	btn.add_theme_stylebox_override("hover", hover)
	
	btn.add_theme_color_override("font_color", accent)
