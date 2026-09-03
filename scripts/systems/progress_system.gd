class_name ProgressSystem

# ============================================================================
# 游戏进度系统：通用持久化注册容器 + Boss 难度解锁 hook 调度层。
# - 可扩展：每个 hook 是一份"独立逻辑 + 独立状态 + 独立 ConfigFile section"
#   的插件；新增功能只需新建 hook 文件并在 _ensure_hooks() 注册一行。
# - 持久化：统一读写 user ConfigFile（默认 user://boss_progress.cfg）；
#   每次状态变更立即写盘；加载失败/缺键回退各 hook 默认。
# - 延迟引用：对 BossDifficultyHook 使用运行期 load，避免编译期耦合
#   （参照 boss_system.gd 的 _cfg() 模式）。
# ============================================================================

## 对外可重定向保存路径；空 = 默认 user://boss_progress.cfg（请勿在其它处硬编码）
static var save_path := ""

const DEFAULT_SAVE_PATH := "user://boss_progress.cfg"

## Boss 难度解锁 hook 专属 section（与 BossDifficultyHook.SAVE_SECTION 对应）
const BOSS_UNLOCK_SECTION := "boss_unlocks"

# ── 内部状态 ──

static var _hooks: Array = []        # 已注册 hook 实例（有序；每 hook 状态/节相互隔离）
static var _initialized := false
static var _loaded_for_path := ""    # 当前内存态对应的磁盘路径（路径变更后自动重读）

# ── 初始化与持久化 ──

## 确保 hook 已注册且状态已按当前 save_path 加载（首次 / 路径变更时重读）
static func ensure_init() -> void:
	_ensure_hooks()
	var path := _effective_path()
	if _initialized and _loaded_for_path == path:
		return
	_load_from_disk(path)
	_loaded_for_path = path
	_initialized = true

## 默认 hook 注册点：新增功能在此追加注册即可（每 hook 独立 section）
static func _ensure_hooks() -> void:
	if not _hooks.is_empty():
		return
	_register_hook(load("res://data/progress/boss_difficulty_hook.gd").new())

static func _register_hook(hook) -> void:
	if hook == null:
		return
	for existing in _hooks:
		if String(existing.section_name()) == String(hook.section_name()):
			return  # 同名 section 不重复注册
	_hooks.append(hook)

static func _effective_path() -> String:
	return DEFAULT_SAVE_PATH if save_path.is_empty() else save_path

## 读盘：文件缺失/损坏 → 全部 hook 回退默认；缺节/缺键 → 该 hook 内部默认
static func _load_from_disk(path: String) -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(path)
	if err != OK:
		for hook in _hooks:
			hook.import_state({})
		return
	for hook in _hooks:
		var section := String(hook.section_name())
		var data := {}
		if cfg.has_section(section):
			for k in cfg.get_section_keys(section):
				data[str(k)] = cfg.get_value(section, str(k))
		hook.import_state(data)

## 写盘：先载入旧档（保留其它 hook / 未知节），再整体覆盖各 hook 自己的 section
static func _save() -> void:
	var path := _effective_path()
	var cfg := ConfigFile.new()
	if FileAccess.file_exists(path):
		cfg.load(path)  # 失败则 cfg 为空，后续覆盖写入即可
	for hook in _hooks:
		var section := String(hook.section_name())
		cfg.erase_section(section)
		var data: Dictionary = hook.export_state()
		for k in data:
			cfg.set_value(section, str(k), data[k])
	var base := path.get_base_dir()
	if base != "" and not DirAccess.dir_exists_absolute(base):
		DirAccess.make_dir_recursive_absolute(base)
	var save_err := cfg.save(path)
	if save_err != OK:
		push_warning("[ProgressSystem] 保存进度失败: %s (%s)" % [path, error_string(save_err)])

# ── Boss 难度解锁 hook 调度层 ──

## Boss 难度解锁 hook 实例（无则返回 null）
## 返回类型显式标注，供上层 `var hook := _boss_hook()` 类型推断；
## BossDifficultyHook 为纯逻辑类、不反向引用本系统，单向依赖安全。
static func _boss_hook() -> BossDifficultyHook:
	ensure_init()
	for hook in _hooks:
		if hook != null and String(hook.section_name()) == BOSS_UNLOCK_SECTION:
			return hook as BossDifficultyHook
	return null

static func is_boss_difficulty_unlocked(boss_id: String, difficulty: String) -> bool:
	var hook: BossDifficultyHook = _boss_hook()
	if hook == null:
		return false
	return bool(hook.is_unlocked(boss_id, difficulty))

static func get_boss_unlocked_index(boss_id: String) -> int:
	var hook: BossDifficultyHook = _boss_hook()
	if hook == null:
		return 0
	return int(hook.unlocked_index(boss_id))

## 幂等推进解锁（规则见 BossDifficultyHook.advance）：仅状态变更时立即写盘
static func on_boss_defeated(boss_id: String, difficulty: String) -> void:
	var hook: BossDifficultyHook = _boss_hook()
	if hook == null:
		return
	if not hook.advance(boss_id, difficulty):
		return
	_save()

static func reset_boss_progress(boss_id: String) -> void:
	var hook: BossDifficultyHook = _boss_hook()
	if hook == null:
		return
	if not hook.reset_boss(boss_id):
		return
	_save()

# ── 测试辅助（不影响契约 API）──

## 仅供测试/重置：清空内存状态并解除路径绑定，令下次 ensure_init 从当前 save_path 重读
static func reset_for_tests() -> void:
	_initialized = false
	_loaded_for_path = ""
	for hook in _hooks:
		hook.import_state({})
