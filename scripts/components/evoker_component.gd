class_name EvokerComponent
extends CharComponent

var last_summon_type: int = -1
var summon_dead1: bool = false
var summon_dead2: bool = false
var summon_dead3: bool = false
var evoker_gazed: bool = false

func on_damage_received(attacker: Fighter, dmg: float):
	var summon = null
	for s in GameWorld.evoker_summons:
		if s.get("owner") == owner:
			summon = s
			break
	if not summon or summon.get("hp", 0) <= 0:
		return
	if summon.get("state", "") == "随行":
		var transfer = minf(dmg * 0.6, summon["hp"])
		summon["hp"] -= transfer
		Fighter.try_heal(owner, transfer)
		Fighter.emit_particles(summon["x"] + summon["w"] / 2.0, summon["y"] + summon["h"] / 2.0, 8, Color.RED, 2, 10)
	if summon.get("type", -1) == 0 and attacker:
		if signf(attacker.pos_x - summon["x"]) == signf(owner.pos_x - summon["x"]):
			Fighter.try_heal(owner, dmg * 0.2)