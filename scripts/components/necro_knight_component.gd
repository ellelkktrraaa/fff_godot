class_name NecroKnightComponent
extends CharComponent

# ── 死契：双状态系统 ──
const MOUNT_SEPARATED := 0
const MOUNT_MOUNTED := 1
var mount_state: int = MOUNT_SEPARATED
var mounted_dmg: float = 0.0
const MOUNT_DMG_THRESHOLD := 20.0
const MOUNTED_SPEED := 3.0
const MOUNTED_JUMP_BOOST := 1.3

var horse_atk_cd := 0
var horse_hp_max := 80.0
var horse_hp := 80.0
var horse_alive := false
var soul_energy := 0

# ── 缚命裁决 ──
var skill1_pull_active := false
var skill1_pull_timer := 0      # 30 帧 (0.5s)
var skill1_pull_dmg := {}       # {enemy_id: dmg_dealt}
var skill1_finisher := false    # 敌人进入 100px 范围
var skill1_execute_flash := 0   # 终结贴图持续时间

# ── 大招：亡者行军 ──
var ult_active := false
var ult_timer := 0
var ult_damage_acc := 0.0
var ult_anim_obj = null  # FrameAnimation 引用，仿 Bard 模式

# ── 不死之身 ──
var undying_triggered := false   # 本场战斗已触发
var undying_active := false      # 复活动画中
var undying_timer := 0           # 动画计时器 0~180
var undying_frame := 0           # 当前帧 0/1/2
var recent_dmg := 0.0
var recent_dmg_frames := 0       # 伤害窗口剩余帧数

func is_mounted() -> bool:
	return mount_state == MOUNT_MOUNTED

func update():
	# 伤害窗口倒计时
	if recent_dmg_frames > 0:
		recent_dmg_frames -= 1
		if recent_dmg_frames <= 0:
			recent_dmg = 0.0

func mount():
	if mount_state == MOUNT_MOUNTED:
		return
	mount_state = MOUNT_MOUNTED
	mounted_dmg = 0.0
	Fighter.set_super_armor(owner)  # 骑乘霸体（持续直到下马）

func dismount(forced: bool = false):
	if mount_state == MOUNT_SEPARATED:
		return
	mount_state = MOUNT_SEPARATED
	mounted_dmg = 0.0
	Fighter.clear_super_armor(owner)
	if forced:
		_apply_dismount_penalty()

func _apply_dismount_penalty():
	if owner.skills.size() < 2:
		return
	var s2 = owner.skills[1]
	if s2.cd <= 0:
		s2.cd = 480
	else:
		s2.cd += 180

func on_damage_received(attacker: Fighter, dmg: float):
	# 不死之身伤害追踪
	recent_dmg += dmg
	recent_dmg_frames = 60  # 1s 窗口
	# 致命伤触发不死之身
	if owner.hp <= dmg and not undying_triggered and not undying_active:
		undying_active = true
		undying_timer = 180
		undying_frame = 0
		recent_dmg = 0.0
		recent_dmg_frames = 0
		owner.hp = dmg + 20  # 确保扣血后存活
		GameWorld.hit_stop = 180
		GameWorld.screen_shake_intensity = 8
		GameWorld.screen_shake_duration = 30
	if not is_mounted():
		return
	mounted_dmg += dmg
	if owner.vy >= 0:
		owner.vy = 0
	owner.vx = 0
	if mounted_dmg >= MOUNT_DMG_THRESHOLD:
		dismount(true)

func on_attack_hit(target: Fighter, dmg: float):
	pass
