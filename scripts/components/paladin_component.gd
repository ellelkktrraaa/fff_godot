class_name PaladinComponent
extends CharComponent

var divine_shield_active: bool = false
var divine_shield_timer: int = 0
var divine_shield_absorb: float = 0
var holy_empower_active: bool = false
var holy_empower_timer: int = 0

func update():
	if divine_shield_active and divine_shield_timer > 0:
		divine_shield_timer -= 1
		if divine_shield_timer <= 0:
			divine_shield_active = false
	if holy_empower_active:
		holy_empower_timer += 1
		if holy_empower_timer >= 60:
			holy_empower_timer = 0
			owner.energy = maxf(0, owner.energy - 10)
			if owner.energy <= 0:
				holy_empower_active = false
				owner.defense = maxf(0.0, owner.defense - 50.0)  # 还原圣佑防御
	# 角色内部状态：只有角色脚本和伤害系统需要，直接通过组件访问

func on_damage_received(attacker: Fighter, dmg: float):
	# 神圣壁垒：吸收伤害转化为能量
	if divine_shield_active:
		var holy_gain = dmg * 3
		divine_shield_absorb += dmg
		owner.energy = minf(owner.max_energy, owner.energy + holy_gain)
	else:
		# 受伤时获得能量
		owner.energy = minf(owner.max_energy, owner.energy + dmg)