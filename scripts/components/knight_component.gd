class_name KnightComponent
extends CharComponent

# 技能2：不屈回响 — 招架
var parry_active: bool = false
var parry_timer: int = 0
var parry_hit: bool = false
var parry_cd_on_end: bool = false  # 招架结束（成功或失败）时进入冷却
var rending_used: bool = false     # 裂空冷却惩罚（仅单次）
var parry_ranged_hit: bool = false  # 本次招架是否已反弹过飞行物（防止重复触发时缓/震动）
var parry_shake_pending: bool = false  # 招架成功后待时缓结束再触发的震动标记

# 招架成功增益计时
var atk_boost_timer: int = 0           # 骑士伤害提升 10% 持续5s
var atk_boost_amt: float = 0.0

# 大招：战至黎明 — 强化模式
var enhanced_mode: bool = false
var enhanced_drain_timer: int = 0       # 能量消耗计时器
var enhanced_attack_cd: int = 0         # 强化普攻冷却
var enhanced_atk_pose_timer: int = 0    # 强化普攻姿态计时

# 一技能：半月斩 — 蓄力
var charging_skill1: bool = false
var charge_start: int = 0               # 蓄力开始时间（毫秒）
var charge_end_pose_timer: int = 0      # 蓄力结束姿态计时

# 被招架者减伤（近战命中时生效）
var debuff_target = null
var debuff_timer: int = 0
var _debuff_original_dmg: float = 0.0

const PARRY_DURATION := 90   # 1.5s
const STUN_DURATION := 120   # 2s
const DEBUFF_DURATION := 300 # 5s
const PARRY_SLOW_MO := 90    # 招架成功时缓帧数（逻辑慢速，90 帧 ≈ 1.5s 实机时间）
const PARRY_SLOW_MO_FACTOR := 12  # 招架时缓力度：每 12 tick 才跑一帧逻辑（默认 3 倍 → 12 倍极慢镜头）
const PARRY_SHAKE := 8.0     # 招架成功屏幕震动强度（中等偏轻）
const PARRY_SHAKE_DUR := 12  # 招架成功屏幕震动持续帧数

func on_damage_received(attacker: Fighter, _dmg: float):
	if not parry_active:
		return
	parry_hit = true

	# ── 近战反击：击退 + 2s眩晕 ──
	if attacker and attacker.hp > 0:
		# 冲击波伤害 = 10 + 收到伤害
		Fighter.apply_damage(attacker, 10 + _dmg, owner)
		attacker.vx = -attacker.facing * 8
		attacker.vy = -5

		# 眩晕 2s（和抓取效果一样）
		attacker.add_status("stun")
		var st = attacker.statuses.back()
		if st and st.id == "stun":
			st.duration = STUN_DURATION
			st.timer = STUN_DURATION

		# ── 淡蓝色冲击波特效 ──
		var vfx_cx = owner.pos_x + owner.w / 2.0
		var vfx_cy = owner.pos_y + owner.h / 2.0
		# 中心爆裂粒子
		owner.emit_particles(vfx_cx, vfx_cy, 40, Color(0.3, 0.6, 1.0), 8, 12, "circle", 1.5)
		# 外环扩散粒子
		owner.emit_particles(vfx_cx, vfx_cy, 25, Color(0.5, 0.75, 1.0, 0.7), 5, 8, "circle", 2.0)
		# 细小星屑粒子
		owner.emit_particles(vfx_cx, vfx_cy, 30, Color(0.8, 0.9, 1.0, 0.5), 3, 5, "star", 1.0)
		# 大星芒粒子
		Fighter.emit_particles(vfx_cx, vfx_cy, 15, Color(0.4, 0.7, 1.0, 0.9), 6, 10, "star", 1.2)
		# 淡蓝光环
		Fighter.emit_particles(vfx_cx, vfx_cy, 8, Color(0.5, 0.8, 1.0, 0.4), 12, 16, "circle", 2.5)

		# ── 时缓特效（参考刺客完美闪避）──
		# 顺序：招架成功 → 时缓 → 时缓结束后再由 update_systems 触发中等震动（不与时缓同时）
		GameWorld.trigger_slow_motion(PARRY_SLOW_MO, PARRY_SLOW_MO_FACTOR)
		parry_shake_pending = true

		# 伤害降低 20% 持续 5s（同目标只刷新计时，不重复叠乘）
		if debuff_target != attacker:
			# 新目标：先还原旧目标的伤害
			if debuff_target and _debuff_original_dmg > 0:
				debuff_target.attack_damage = _debuff_original_dmg
			debuff_target = attacker
			_debuff_original_dmg = attacker.attack_damage
			attacker.attack_damage *= 0.8
		debuff_timer = DEBUFF_DURATION

	# ── 骑士增益：回复15能量 + 伤害提升10%持续5s（重复命中刷新计时不叠加）──
	owner.energy = minf(owner.max_energy, owner.energy + 15)
	if atk_boost_timer <= 0:
		atk_boost_amt = owner.attack_damage * 0.1
		owner.attack_boost += atk_boost_amt
	atk_boost_timer = DEBUFF_DURATION
