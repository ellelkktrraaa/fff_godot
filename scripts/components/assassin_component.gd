class_name AssassinComponent
extends CharComponent

var shadow_energy: float = 0
var shadow_energy_max: float = 5
var shadow_stance: bool = false
var shadow_stance_timer: int = 0
var shadow_energy_drain_rate: float = 5.0 / 480.0
var is_invincible: bool = false
var invincible_timer: int = 0
var enhanced_slash: bool = false
var enhanced_slash_timer: int = 0
var slash_active: bool = false
var slash_timer: int = 0
var slash_x: float = 0
var slash_y: float = 0
var slash_facing: int = 1
var slash_damage_dealt: bool = false
var slash_anim = null  # FrameAnimation：普攻斩击动画（每刺客独立，避免同角色对局共享状态）
var skill2_active: bool = false
var skill2_timer: int = 0
var skill2_x: float = 0
var skill2_y: float = 0
var skill2_facing: int = 1
var skill2_damage_dealt: bool = false
var skill2_delay_timer: int = 0      # 剑气延迟出现计时（帧）：释放后 N 帧生成
var skill2_pending: Dictionary = {}  # 待生成的剑气数据
var ult_active: bool = false
var ult_timer: int = 0
var ult_damage_timer: int = 0
var time_stop: bool = false
var time_stop_timer: int = 0
var dodge_success: bool = false
var dodge_slow_mo: int = 0
var shadow_trail: Array = []
var max_shadow_trail: int = 12

var _prev_dodge_success: bool = false  # 完美闪避状态跳变检测（触发演出用）
var _dodge_zoom_pending: bool = false  # 时缓结束才恢复镜头（拉近期间不恢复，避免镜头乱晃）

# 完美闪避演出参数（时缓 + 镜头拉近）
const DODGE_SLOW_MO_FRAMES := 90  # 高强度时缓帧数（≈1.5s 实机）
const DODGE_SLOW_MO_FACTOR := 6   # 时缓力度：6 倍慢速
const DODGE_ZOOM := 1.3           # 镜头拉近倍率

func update():
	# 完美闪避演出：触发高强度时缓 + 设置镜头拉近目标。镜头缩放与位置由 game.gd _process
	# 每渲染帧平滑推进（不受时缓减慢影响，不卡顿），时缓结束恢复常规取景
	if dodge_success and not _prev_dodge_success and owner.is_player:
		GameWorld.trigger_slow_motion(DODGE_SLOW_MO_FRAMES, DODGE_SLOW_MO_FACTOR)
		GameWorld.zoom_character_centered(DODGE_ZOOM)
		_dodge_zoom_pending = true
	elif _dodge_zoom_pending:
		if GameWorld.slow_mo_timer <= 0:
			_dodge_zoom_pending = false
			GameWorld.restore_camera_zoom()
	_prev_dodge_success = dodge_success
	if is_invincible and invincible_timer > 0:
		invincible_timer -= 1
		if invincible_timer <= 0:
			is_invincible = false
	if enhanced_slash_timer > 0:
		enhanced_slash_timer -= 1
		if enhanced_slash_timer <= 0:
			enhanced_slash = false
	if slash_active and slash_timer > 0:
		slash_timer -= 1
		if slash_timer <= 0:
			slash_active = false
	if dodge_slow_mo > 0:
		dodge_slow_mo -= 1
	# 写入黑板（只写全局效果），使用信号驱动
	owner.set_state_flag("time_stop", time_stop)
	owner.set_state_flag("dodge_slow", dodge_slow_mo)
	if shadow_stance:
		shadow_energy -= shadow_energy_drain_rate
		if shadow_energy <= 0:
			shadow_energy = 0
			shadow_stance = false
			shadow_stance_timer = 0
			shadow_trail.clear()
		else:
			shadow_stance_timer -= 1
			if shadow_stance_timer <= 0:
				shadow_stance = false
				shadow_stance_timer = 0
				shadow_trail.clear()
			else:
				if absf(owner.vx) > 0.5 or owner.dashing:
					shadow_trail.append({"x": owner.pos_x, "y": owner.pos_y, "facing": owner.facing, "life": 12})
					if shadow_trail.size() > max_shadow_trail:
						shadow_trail.pop_front()
				for i in range(shadow_trail.size() - 1, -1, -1):
					shadow_trail[i]["life"] -= 1
					if shadow_trail[i]["life"] <= 0:
						shadow_trail.remove_at(i)

func on_damage_received(attacker: Fighter, dmg: float):
	if owner.dashing and is_invincible and not dodge_success:
		dodge_success = true
		dodge_slow_mo = 30
		shadow_energy = minf(shadow_energy_max, shadow_energy + 1)
		if shadow_energy >= shadow_energy_max and not shadow_stance:
			shadow_stance = true
			shadow_stance_timer = 480
		Fighter.emit_particles(owner.pos_x + owner.w / 2.0, owner.pos_y + owner.h / 2.0, 15, Color(0.667, 0.533, 1.0), 3, 5, "star", 0.8)

func get_hud_data() -> Dictionary:
	return {
		"shadow_energy": {
			"value": shadow_energy, "max": shadow_energy_max,
			"label": "暗影", "label_color": Color(0.67, 0.53, 1.0),
			"fill_color": Color(0.53, 0.27, 0.8),
			"is_stance": shadow_stance, "stance_label": "暗影游走"
		}
	}