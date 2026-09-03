class_name BossConfigs

# ============================================================================
# Boss 配置聚合器（静态注册表 / 索引层）
# 数据与逻辑分离：每个 Boss 的定义放在 data/bosses/boss_<id>.gd（外部配置文件，
# 提供 static func get_boss() -> Dictionary）。本类只负责扫描/注册/查询，不持有
# 具体 Boss 内容，因此不与被引用的外部配置形成循环依赖。
#
# 扫描策略参考 MapManager：开发环境用 DirAccess 扫描 res://data/bosses/；
# 打包后 DirAccess 扫不到 res:// 时回退到 _builtin_boss_files 预定义列表。
# ============================================================================

const BOSS_DIR := "res://data/bosses/"

## 打包后（DirAccess 无法扫描 res://）的兜底文件列表：与 data/bosses/ 目录一一对应。
## 此前用于测试的示例 Boss（圣骑士/骑士）已移除，正式 Boss 配置落地后再在此登记。
static var _builtin_boss_files: Array[String] = []

## 注册表：boss_id -> boss 定义（登记时深拷贝，防外部篡改）
static var _bosses: Dictionary = {}
static var _initialized := false

# ===== 初始化 =====
static func ensure_init():
	if _initialized:
		return
	_initialized = true
	_scan_and_register()

# ===== 注册 =====
static func _scan_and_register():
	_bosses.clear()
	var files: Array[String] = []
	var dir := DirAccess.open(BOSS_DIR)
	if dir:
		dir.list_dir_begin()
		var fname := dir.get_next()
		while fname != "":
			if fname.ends_with(".gd") and not fname.begins_with("."):
				files.append(BOSS_DIR + fname)
			fname = dir.get_next()
		dir.list_dir_end()
		files.sort()
	# 打包后或扫描不到：使用 builtin 文件列表 fallback
	if files.is_empty():
		files = _builtin_boss_files.duplicate()
	for path in files:
		var script: GDScript = load(path)
		if script == null or not _has_static_get_boss(script):
			push_warning("[BossConfigs] 跳过无效 Boss 配置文件: ", path)
			continue
		var boss: Dictionary = script.get_boss()
		_register_boss(boss)
	print("[BossConfigs] 注册 Boss: ", get_boss_ids())

static func _has_static_get_boss(script: GDScript) -> bool:
	for m in script.get_script_method_list():
		if str(m.get("name", "")) == "get_boss":
			return true
	return false

static func _register_boss(boss: Dictionary):
	if boss.is_empty():
		return
	var id := str(boss.get("id", ""))
	if id == "":
		return
	if not boss.has("char_id") or not boss.has("map") or not boss.has("levels"):
		push_warning("[BossConfigs] Boss 定义缺少 char_id/map/levels: ", id)
	_bosses[id] = boss.duplicate(true)

# ===== 公开 API =====

## 所有已注册 Boss id（空 = 未注册任何 Boss）
static func get_boss_ids() -> Array[String]:
	ensure_init()
	var ids: Array[String] = []
	for id in _bosses:
		ids.append(str(id))
	ids.sort()
	return ids

## 单个 Boss 定义（深拷贝；未知 id 返回空字典）
static func get_boss(id: String) -> Dictionary:
	ensure_init()
	var boss: Dictionary = _bosses.get(id, {})
	if boss.is_empty():
		return {}
	return boss.duplicate(true)

## Boss 显示名（未知 id 返回空串）
static func get_boss_name(id: String) -> String:
	var boss := get_boss(id)
	if boss.is_empty():
		return ""
	return str(boss.get("name", ""))

## Boss 固定地图路径（未知 id 返回空串）
static func get_map_path(id: String) -> String:
	var boss := get_boss(id)
	if boss.is_empty():
		return ""
	return str(boss.get("map", ""))

## 按 difficulty 匹配 levels[] 项的 modifiers；未命中回退第一个 level（缺省档）
static func resolve_modifiers(id: String, difficulty: String) -> Dictionary:
	var boss := get_boss(id)
	if boss.is_empty():
		return {}
	var levels: Array = boss.get("levels", [])
	if levels.is_empty():
		return {}
	for lv in levels:
		if lv is Dictionary and str(lv.get("difficulty", "")) == difficulty:
			var mods: Dictionary = lv.get("modifiers", {})
			return mods.duplicate(true)
	# 未命中 → 回退第一个 level（缺省档）
	var first: Dictionary = levels[0]
	if first is Dictionary:
		var fallback: Dictionary = first.get("modifiers", {})
		return fallback.duplicate(true)
	return {}
