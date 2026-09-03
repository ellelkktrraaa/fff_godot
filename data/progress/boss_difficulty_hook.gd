class_name BossDifficultyHook
extends RefCounted

# ============================================================================
# Boss 难度解锁 hook（纯逻辑层，不直接接触 ConfigFile）
# - 每 Boss 独立状态：_state[boss_id] = 已解锁最高档下标（初始恒 easy）
# - 每 Boss 独立配置节：INITIAL_UNLOCK_INDEX[boss_id] = 初始解锁档（缺省 0 = easy）
# - 持久化桥接由 ProgressSystem 完成：以 SAVE_SECTION 作为该 hook 专属的
#   ConfigFile section（键 boss_id → 解锁档下标），本类只导入/导出状态字典。
#   → 与其它 hook 互不干扰，各自独立 section / 独立状态，天然隔离。
# ============================================================================

## 专属持久化 section 名（与 ProgressSystem.BOSS_UNLOCK_SECTION 对应）
const SAVE_SECTION := "boss_unlocks"

## 每 Boss 初始解锁档配置（下标 0=easy）。未登记 Boss 一律 0（easy 恒解锁）。
## 例：若要某 Boss 初始开放到 medium（下标 1），在此加一行 "boss_id": 1
const INITIAL_UNLOCK_INDEX := {}

## 独立状态：boss_id -> 已解锁最高档下标（>初始档的部分才会被写入存档）
var _state: Dictionary = {}

# ── 持久化桥（ProgressSystem 调用；本 hook 自身不碰 ConfigFile）──

func section_name() -> String:
	return SAVE_SECTION

func export_state() -> Dictionary:
	return _state.duplicate()

## 缺键 / 非法值回退默认：值会被夹到 [0, 最高档]
func import_state(data: Dictionary) -> void:
	_state.clear()
	var cap := Constants.DIFFICULTY_LEVELS.size() - 1
	for k in data:
		_state[str(k)] = clampi(int(data[k]), 0, cap)

# ── 纯解锁逻辑 ──

## 该 Boss 的初始解锁档（缺省 0）
func default_index(boss_id: String) -> int:
	return clampi(int(INITIAL_UNLOCK_INDEX.get(boss_id, 0)), 0, Constants.DIFFICULTY_LEVELS.size() - 1)

## 该 Boss 当前已解锁最高档下标（内存状态与初始档取高者，保证不回退到初始之下）
func unlocked_index(boss_id: String) -> int:
	var d := default_index(boss_id)
	return maxi(int(_state.get(boss_id, d)), d)

## 该难度是否已解锁：难度下标 <= 已解锁最高档
func is_unlocked(boss_id: String, difficulty: String) -> bool:
	var idx := Constants.DIFFICULTY_LEVELS.find(difficulty)
	if idx < 0:
		return false
	return idx <= unlocked_index(boss_id)

## 击败某难度后推进解锁档：stored = maxi(stored, mini(idx+1, 最高档))
## 幂等：重复/低于当前档调用返回 false，不推进。返回是否有变更（供调用方决定是否写盘）
func advance(boss_id: String, difficulty: String) -> bool:
	var idx := Constants.DIFFICULTY_LEVELS.find(difficulty)
	if idx < 0:
		return false
	var target := mini(idx + 1, Constants.DIFFICULTY_LEVELS.size() - 1)
	if target <= unlocked_index(boss_id):
		return false
	_state[boss_id] = target
	return true

## 清除该 Boss 的内存状态回到初始档。返回是否有变更（有变更才需落盘擦除）
func reset_boss(boss_id: String) -> bool:
	if not _state.has(boss_id):
		return false
	_state.erase(boss_id)
	return true
