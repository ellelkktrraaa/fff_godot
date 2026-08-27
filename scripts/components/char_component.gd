class_name CharComponent

var owner = null # Fighter (deferred type resolution for cold cache)

func init(owner):
	self.owner = owner

func update():
	pass

func on_damage_received(attacker: Fighter, dmg: float):
	pass

## 受伤前钩子：在伤害结算前调用，可消耗资源/减伤/格挡，返回修正后伤害（原样返回 = 不干预）
func on_pre_damage(attacker: Fighter, dmg: float) -> float:
	return dmg

func on_attack_hit(target: Fighter, dmg: float):
	pass

# 统一 HUD 数据接口：game.gd 遍历组件即可，无需 match char_id
# 返回 Dict，key 为 hud 类型，如 "blood_abyss", "shadow_energy", "arrows"
func get_hud_data() -> Dictionary:
	return {}