class_name RoseComponent
extends CharComponent

var blood_abyss: float = 0.0
var blood_heal_timer: int = 0
var rose_skill2_active: bool = false
var rose_skill2_damage_tick: int = 0
var rose_skill2_tick_damage: float = 3.0
var rose_skill2_enhanced: bool = false
var rose_skill2_fly_timer: int = 0
var rose_dash_frame_timer: int = 0  # 一技能冲刺剩余帧数（20f 后静止）
var rose_skill1_grab_done: bool = false  # 冲刺阶段向前判定已完成
var rose_skill1_holding: bool = false   # 强化一技能持续抓取中
var rose_skill1_grab_pos_x: float = 0.0 # 抓取锁定x坐标
var rose_skill1_enhanced_slashes: Array = []
var rose_skill1_slash_spawn_timer: int = 0
var rose_blood_abyss_suppressed: bool = false
var time_stop: bool = false
var time_stop_timer: int = 0

func update():
	if blood_abyss > 0 and owner.hp < owner.max_hp:
		blood_heal_timer += 1
		if blood_heal_timer >= 120:
			blood_heal_timer = 0
			blood_abyss -= 1
			Fighter.try_heal(owner, 1)
	# 全局效果写入黑板，使用信号驱动
	owner.set_state_flag("time_stop", time_stop)

func on_attack_hit(target: Fighter, dmg: float):
	if not rose_blood_abyss_suppressed:
		blood_abyss = minf(40.0, blood_abyss + dmg)
	if rose_blood_abyss_suppressed:
		rose_blood_abyss_suppressed = false

func get_hud_data() -> Dictionary:
	return {
		"blood_abyss": { "value": blood_abyss, "max": 40.0, "label": "血渊", "fill_color": Color(0.9, 0.15, 0.15), "label_color": Color(1.0, 0.4, 0.4) }
	}