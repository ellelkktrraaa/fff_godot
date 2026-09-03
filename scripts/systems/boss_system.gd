class_name BossSystem

# ============================================================================
# Boss 薄适配层：把 "Boss 上下文" 翻译成 PVE 管线可直接使用的敌人/地图/数值。
# 核心原则：无 Boss 上下文（GameWorld.boss_id == ""）时所有解析函数回退 = 原 PVE，
# 因此对普通 PVE / 练习模式零影响。
#
# 避免与 fighter.gd 循环依赖：对 BossConfigs 使用运行期 load 延迟引用（_cfg()），
# 不在编译期 preload；Fighter 仅作为全局类型标注（fighter.gd 不反向引用本类）。
# ============================================================================

## 当前是否为 Boss 战（GameWorld.boss_id 非空）
static func is_active() -> bool:
	return GameWorld.boss_id != ""

## 当前 Boss 定义（无 Boss 上下文返回空字典）
static func get_active() -> Dictionary:
	if not is_active():
		return {}
	var cfg: GDScript = _cfg()
	if cfg == null:
		return {}
	return cfg.get_boss(GameWorld.boss_id)

## Boss 模式：返回该 Boss 的 char_id；无 Boss 返回空串（调用方走原 PVE 随机逻辑）
static func resolve_enemy_char() -> String:
	if not is_active():
		return ""
	var cfg: GDScript = _cfg()
	if cfg == null:
		return ""
	return str(cfg.get_boss(GameWorld.boss_id).get("char_id", ""))

## Boss 模式：返回该 Boss 固定地图路径；无 Boss 返回空串
static func resolve_map_path() -> String:
	if not is_active():
		return ""
	var cfg: GDScript = _cfg()
	if cfg == null:
		return ""
	return str(cfg.get_map_path(GameWorld.boss_id))

## 敌人 setup() 之后调用：应用当前难度 modifiers + 写入 Boss 显示名（无 Boss 空操作）
static func apply_to_enemy(enemy: Fighter) -> void:
	if not is_active() or enemy == null:
		return
	var cfg: GDScript = _cfg()
	if cfg == null:
		return
	var mods: Dictionary = cfg.resolve_modifiers(GameWorld.boss_id, GameWorld.difficulty)
	enemy.apply_boss_modifiers(mods)
	var boss_name: String = cfg.get_boss_name(GameWorld.boss_id)
	if boss_name != "":
		enemy.boss_name = boss_name

# ── BossConfigs 延迟引用（运行期 load，避免编译期依赖）──
static var _BossConfigs: GDScript = null

static func _cfg() -> GDScript:
	if _BossConfigs == null:
		_BossConfigs = load("res://data/boss_configs.gd")
	return _BossConfigs
