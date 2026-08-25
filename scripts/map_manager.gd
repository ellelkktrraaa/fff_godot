class_name MapManager
## 地图管理：扫描地图文件夹、管理地图池配置、随机选图

# === 地图池配置文件路径 ===
const POOL_CONFIG_PATH := "user://map_pool.cfg"
const POOL_SECTION := "MapPool"
const POOL_KEY := "enabled_maps"

# === 自动扫描路径 ===
const MAPS_DIR := "res://maps/"

# 当前有效的地图列表（场景路径）
static var _all_maps: Array[String] = []
static var _pool_maps: Array[String] = []

# ===== 初始化：扫描地图 + 加载配置 =====
static func ensure_init():
	if _all_maps.is_empty():
		_scan_maps()
		_load_pool_config()

# ===== 扫描 maps/ 目录下所有 .tscn =====
# 打包后 DirAccess 无法扫描 res://，改用预定义列表作为 fallback
static var _builtin_maps: Array[String] = [
	"res://maps/map_01_battlefield.tscn",
	"res://maps/map_02_towers.tscn",
	"res://maps/map_03_broken_bridge.tscn",
	"res://maps/map_04_voids_skypalace.tscn",
]

static func _scan_maps():
	_all_maps.clear()
	var dir = DirAccess.open(MAPS_DIR)
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if fname.ends_with(".tscn") and not fname.begins_with("."):
				_all_maps.append(MAPS_DIR + fname)
			fname = dir.get_next()
		dir.list_dir_end()
		_all_maps.sort()
	# 开发环境未扫到或打包后：使用预定义列表
	if _all_maps.is_empty():
		_all_maps = _builtin_maps.duplicate()
	print("[MapManager] 扫描到 ", _all_maps.size(), " 张地图: ", _all_maps)

# ===== 加载/保存地图池 =====
static func _load_pool_config():
	_pool_maps.clear()
	var cfg = ConfigFile.new()
	if cfg.load(POOL_CONFIG_PATH) != OK:
		# 首次运行：默认启用全部可用地图（不含锁定地图）
		_pool_maps = _get_default_pool()
		_save_pool_config()
		return
	var saved: Array = cfg.get_value(POOL_SECTION, POOL_KEY, [])
	# 只保留仍存在的、且未锁定的地图
	for path in saved:
		if _all_maps.has(path) and not is_locked(path):
			_pool_maps.append(path)
	# 如果全部被过滤掉，退回默认
	if _pool_maps.is_empty():
		_pool_maps = _get_default_pool()

static func _get_default_pool() -> Array[String]:
	var pool: Array[String] = []
	for m in _all_maps:
		if not is_locked(m):
			pool.append(m)
	return pool

static func _save_pool_config():
	var cfg = ConfigFile.new()
	cfg.set_value(POOL_SECTION, POOL_KEY, _pool_maps)
	cfg.save(POOL_CONFIG_PATH)

# ===== 公开 API =====

## 获取所有可用地图
static func get_all_maps() -> Array[String]:
	ensure_init()
	return _all_maps.duplicate()

## 获取地图池中的地图
static func get_pool_maps() -> Array[String]:
	ensure_init()
	return _pool_maps.duplicate()

## 设置地图池
static func set_pool_maps(pool: Array[String]):
	_pool_maps = pool.duplicate()
	_save_pool_config()

## 从池中随机选一张地图（排除锁定地图）
static func pick_random() -> String:
	ensure_init()
	var candidates: Array[String] = []
	for m in _pool_maps:
		if not is_locked(m):
			candidates.append(m)
	if candidates.is_empty():
		candidates = _pool_maps.duplicate()  # fallback
	if candidates.is_empty():
		return ""
	return candidates[randi() % candidates.size()]

## 地图是否锁定（玩家不可选择，界面展示"开发中"）
## 作弊模式开启时全部解锁
static func is_locked(map_path: String) -> bool:
	if GameWorld.infinite_energy:
		return false
	var p: String = map_path.to_lower()
	for kw in _locked_map_keywords:
		if kw in p:
			return true
	return false

const _locked_map_keywords: Array[String] = []  # 地图3（断桥）已开放；后续未完成地图在此登记

## 检查地图是否在池中
static func is_in_pool(map_path: String) -> bool:
	ensure_init()
	return _pool_maps.has(map_path)

## 切换地图的启用/禁用状态
static func toggle_map(map_path: String):
	ensure_init()
	if _pool_maps.has(map_path):
		_pool_maps.erase(map_path)
	else:
		_pool_maps.append(map_path)
	_pool_maps.sort()
	_save_pool_config()

## 获取地图显示名（去掉路径前缀和扩展名）
static func get_display_name(map_path: String) -> String:
	var fname = map_path.get_file()
	return fname.trim_suffix(".tscn")

# ===== 背景图管理 =====

const BG_DIR := "res://assets/battle_bg/"

# 地图关键词 → 背景文件名（精确配对，优先级最高）
# 断桥(map3)→虚空1 / 天宫(map4)→虚空2；战场(map1)/高塔(map2) 不配对，走下方随机池（在其他背景里随机）
static var _map_bg_pairs: Dictionary = {
	"broken_bridge": "bg_void_01.png",
	"skypalace":   "bg_void_02.png",
}

static var _void_bgs: Array = []       # 虚空背景池（未配对时随机）
static var _normal_bgs: Array = []     # 普通背景池（未配对时随机）
static var _bg_cache: Dictionary = {}             # {filename: Texture2D}
static var _bgs_scanned: bool = false

static func _scan_backgrounds():
	if _bgs_scanned:
		return
	_bgs_scanned = true
	_void_bgs.clear()
	_normal_bgs.clear()
	_bg_cache.clear()
	var dir = DirAccess.open(BG_DIR)
	if not dir:
		return
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if fname.ends_with(".png") and not fname.begins_with("."):
			var tex: Texture2D = load(BG_DIR + fname)
			if tex:
				_bg_cache[fname] = tex
				if "void" in fname.to_lower():
					_void_bgs.append(tex)
				else:
					_normal_bgs.append(tex)
		fname = dir.get_next()
	dir.list_dir_end()
	print("[MapManager] 背景扫描: 普通=", _normal_bgs.size(), " 虚空=", _void_bgs.size())

## 根据地图路径获取背景（优先精确配对，否则按类型随机池选取）
static func get_background(map_path: String) -> Texture2D:
	_scan_backgrounds()
	var path_lower: String = map_path.to_lower()
	# 1. 精确配对
	for keyword: String in _map_bg_pairs:
		if keyword in path_lower:
			var bg_name: String = _map_bg_pairs[keyword]
			if _bg_cache.has(bg_name):
				return _bg_cache[bg_name]
	# 2. 回退到随机池
	var is_void_map: bool = "voids" in path_lower
	if is_void_map and not _void_bgs.is_empty():
		return _void_bgs[randi() % _void_bgs.size()]
	if not is_void_map and not _normal_bgs.is_empty():
		return _normal_bgs[randi() % _normal_bgs.size()]
	return null
