class_name FlameZoneSystem

# ===== Flame Zone System =====
static func update_flame_zones():
	for i in range(GameWorld.flame_zones.size()-1,-1,-1):
		var f = GameWorld.flame_zones[i]
		f["life"] -= 1
		if f["life"] <= 0: GameWorld.flame_zones.remove_at(i); continue
		var target = GameWorld.get_opponent(f["owner"])
		if target and target.hp > 0:
			# AABB overlap check — target inside flame zone
			if target.pos_x + target.w > f["x"] and target.pos_x < f["x"] + f["w"] and target.pos_y + target.h > f["y"] and target.pos_y < f["y"] + f["h"]:
				f["timer"] = f.get("timer", 0) + 1
				var ti = f.get("tick_interval", 60)
				if f["timer"] >= ti:
					f["timer"] = 0
					# 龙骑士免疫火焰区域伤害
					if target.char_id != "dragon_knight":
						Fighter.apply_damage(target, f["damage"], f["owner"], false, Color(1.0, 0.53, 0.27), "hit_enemy", "domain", 0, 1)  # 幽蓝之径火海 = 技能体攻击
