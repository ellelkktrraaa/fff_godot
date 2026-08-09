class_name Skill

var key: String
var skill_name: String
var cooldown: int
var energy_cost: int
var cd: int = 0
var can_use_func: Callable
var execute_func: Callable

# ── 多段技能（一段/二段/三段…）──
# 使用方式（新角色引用）：
#   var s = Skill.make_staged("skill1", "技能名", 900, 15, can_use_func,
#       [Callable(_stage1), Callable(_stage2)], 600, can_next_func)
# 各阶段写成独立函数并返回 Dictionary（{"success": bool}）。
# 一段释放后技能槽变黄（HUD 自动读取 in_next_stage_window()）；
# 释放下一段或窗口超时后黄标消失；三段以上以此类推（每段释放后窗口重新计时）。
# can_next_func 可选：下一段可用性检查，条件不满足则不开等待窗口（黄标不显示）。
var stages: Array = []          # 各阶段独立执行函数（[一段, 二段, ...]）
var stage_index: int = -1       # 当前阶段（-1 = 不在多段流程中）
var stage_window: int = 0       # 等待下一段的窗口帧（>0 → HUD 黄色待释放）
var stage_window_max: int = 0
var can_next_func: Callable = Callable()  # 可选：下一段可用性检查（如狂暴状态才派生二段）
var manual_window: bool = false  # true：一段释放不自动开窗口，由外部 open_next_stage() 开启（跨技能触发）

func _init(p_key: String = "", p_name: String = "", p_cooldown: int = 0, p_energy_cost: int = 0, 
		   p_can_use: Callable = Callable(), p_execute: Callable = Callable()):
	key = p_key
	skill_name = p_name
	cooldown = p_cooldown
	energy_cost = p_energy_cost
	can_use_func = p_can_use
	execute_func = p_execute

## 便捷工厂：创建多段技能（各阶段为独立函数，窗口内可释放下一段）
static func make_staged(p_key: String, p_name: String, p_cooldown: int, p_energy_cost: int,
		p_can_use: Callable, p_stages: Array, p_window_frames: int,
		p_can_next: Callable = Callable()) -> Skill:
	var s = Skill.new(p_key, p_name, p_cooldown, p_energy_cost, p_can_use, Callable())
	s.set_stages(p_stages, p_window_frames)
	s.can_next_func = p_can_next
	return s

## 注册多段技能：stage_funcs 为各阶段独立函数；window_frames 为每段之后等待下一段的窗口（超时未释放则黄标消失）
func set_stages(stage_funcs: Array, window_frames: int):
	stages = stage_funcs
	stage_window_max = window_frames

## 是否处于"可释放下一段"的窗口内（HUD 黄标）
func in_next_stage_window() -> bool:
	return stages.size() > 0 and stage_index >= 0 and stage_window > 0 and stage_index + 1 < stages.size()

## 结束多段流程（黄标消失，之后需重新从一段开始）
func end_stage_flow():
	stage_index = -1
	stage_window = 0

func can_use(owner: Fighter) -> bool:
	if cd > 0:
		return false
	if owner.energy < energy_cost:
		return false
	if owner.charging_attack:
		return false
	if can_use_func.is_valid():
		return can_use_func.call(owner)
	return true

func try_use(owner: Fighter) -> Dictionary:
	# 多段：窗口内再次按下 → 释放下一段（不重复扣能/重置冷却）
	if in_next_stage_window():
		var next = stage_index + 1
		var r = stages[next].call(owner)
		if r is Dictionary and not r.get("success", true):
			return r  # 下一段未成功释放，流程保持等待
		stage_index = next
		if next + 1 >= stages.size():
			stage_index = -1  # 最后一段已释放，流程结束
			stage_window = 0
		else:
			stage_window = _next_window(owner)  # 还有后续段 → 窗口重新计时
		return r if r is Dictionary else {"success": true}
	# 正常释放：一段（或流程结束后重新进入）
	if not can_use(owner):
		return {"success": false}
	owner.energy -= energy_cost
	cd = cooldown
	if stages.size() > 0:
		stage_index = 0
		if not manual_window:
			stage_window = _next_window(owner)
		var r2 = stages[0].call(owner)
		return r2 if r2 is Dictionary else {"success": true}
	if execute_func.is_valid():
		var result = execute_func.call(owner)
		if result is Dictionary:
			return result
	return {"success": true}

## 外部开启下一段等待窗口（跨技能触发，如：使用飞斧后 2s 内可释放地裂）
func open_next_stage(owner: Fighter):
	if stages.size() < 2:
		return
	stage_index = 0
	stage_window = _next_window(owner)

## 下一段等待窗口帧数：can_next 条件不满足则不开窗口（黄标不显示）
func _next_window(owner: Fighter) -> int:
	if can_next_func.is_valid() and not can_next_func.call(owner):
		return 0
	return stage_window_max

func update():
	if cd > 0:
		cd -= 1
	# 多段窗口计时：极限时间未释放下一段 → 结束流程，黄标消失
	if stage_window > 0:
		stage_window -= 1
		if stage_window <= 0:
			stage_index = -1
