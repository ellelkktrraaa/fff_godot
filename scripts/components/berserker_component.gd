# 狂战士 (berserker) 专属组件
class_name BerserkerComponent
extends CharComponent

# ── 浴血机制：每减少 10 血，攻击力 +4%（数值相加，最多 +24%）──
const BLOOD_STEP_HP := 10.0     # 每 10 血
const BLOOD_ATK_PER_STEP := 0.04  # 每层 +4%
const BLOOD_ATK_MAX := 0.24     # 封顶 +24%
const BLOOD_MOD_SOURCE := "berserker_bloodbath"
var blood_bonus: float = 0.0    # 当前浴血攻击加成（1.0 = +0%）
var blood_stacks: int = 0       # 当前层数

func init(owner):
	super.init(owner)
	# 浴血代价：狂战士无法被治疗（天赋、生命球等均无效）
	owner.heal_blocked = true
	_update_blood_bath()

func update():
	_update_blood_bath()

## 浴血：按损失血量（max_hp - hp）计算攻击加成并刷新到攻击力
func _update_blood_bath():
	if not owner:
		return
	var lost: float = owner.max_hp - owner.hp
	var stacks: int = int(lost / BLOOD_STEP_HP)
	var bonus: float = minf(BLOOD_ATK_MAX, stacks * BLOOD_ATK_PER_STEP)
	if absf(bonus - blood_bonus) < 0.0001:
		return  # 无变化
	blood_bonus = bonus
	blood_stacks = stacks
	# 先移除旧加成，再应用新加成（数值相加，非迭代）
	owner.remove_stat_mod("attack_damage", BLOOD_MOD_SOURCE)
	if bonus > 0.0:
		owner.add_stat_mod("attack_damage", BLOOD_MOD_SOURCE, 0.0, 1.0 + bonus)

## HUD 显示浴血层数（格式与 HUD 系统要求的字典结构一致）
func get_hud_data() -> Dictionary:
	return {
		"blood": {
			"value": blood_stacks, "max": int(BLOOD_ATK_MAX / BLOOD_ATK_PER_STEP),
			"label": "浴血",
			"label_color": Color(0.9, 0.2, 0.1),
			"fill_color": Color(0.8, 0.1, 0.0),
		},
	}
