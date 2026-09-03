# Boss 战框架架构（复用 PVE + Modifier 微调）

> 目标：搭建 Boss 战框架。核心原则是 **尽可能复用现有 PVE 战斗管线**，把 Boss 视为
> PVE 战斗的一次"参数化实例"——不复制任何战斗逻辑，只通过 **Boss 配置 + Modifier**
> 对少数注入点做小改。

## 1. 设计原则

1. **Boss 战 = PVE 战**：战斗场景（`game.tscn`）、初始化流程（`game.gd`）、AI
   （`AISystem`）、地图库（`MapManager`）、结算（`PickupSystem`）、HUD 全部复用。
2. **差异集中在一份 Boss 配置**：敌人是谁、打哪张地图、数值多强，全部由 Boss
   配置里的 `char_id / map / modifiers` 决定，代码里不散落 `if boss` 分支。
3. **Modifier 只做小改**：Modifier 覆盖"角色基础属性 + 全局伤害倍率 + AI 预设增量"，
   不改技能实现、不改角色组件、不改 AI 状态机。
4. **PVE 默认行为不变**：无 Boss 上下文时，所有抽象函数的回退行为 = 现在的 PVE，
   对普通 PVE/练习模式零影响。

## 2. 现有 PVE 战斗管线（复用基线）

```
main_menu.gd ──(难度 → 选人)──▶ game.tscn
game.gd._ready ──▶ CharConfigs.ensure_init()
game.gd._start_game()          # 从 GameWorld 读玩家/敌人/天赋
  └─ init_game(player_char_id, enemy_char_id)
       ├─ _clear_old_fighters()        # 清旧角色
       ├─ GameWorld.reset_world()
       ├─ _load_random_map()           # ◀ 地图：MapManager.pick_random() 随机
       ├─ _find_spawn_positions()      # 按平台推出生点（自动适配任意地图）
       ├─ Fighter.setup() 玩家/敌人    # ◀ 敌人：随机角色（复用 CharacterFactory）
       ├─ _assemble_talents()
       └─ _start_intro()               # 开场动画
_game._update() 固定帧循环
  ├─ AISystem.update_ai()              # ◀ AI：驱动 GameWorld.enemy（与 PVE 同一套）
  ├─ ProjectileSystem / FlameZoneSystem / ...
  └─ PickupSystem.update_pickups_and_end()   # 胜负判定（enemy.hp<=0 → win）
```

**Boss 模式只替换上面标注 ◀ 的三个点**：敌人角色、地图、以及敌人创建后的数值应用。

## 3. 总体架构

```
┌─────────────────────────── Boss 上下文（运行期）───────────────────────────┐
│  GameWorld.boss_id = "fallen_paladin"   （空 = 普通 PVE，行为完全不变）    │
└───────────────────────────────┬───────────────────────────────────────────┘
                                │ 读取
              ┌─────────────────▼─────────────────┐
              │  BossSystem（薄适配层，新增）        │
              │  resolve_enemy_char() / resolve_map │
              │  _path() / apply_modifiers()        │
              └─────────────────┬─────────────────┘
      复用于   ┌───────────────▼───────────────────────────────┐
     PVE 管线  │ game.tscn → init_game → AISystem → 结算 → HUD │  （0 复制）
              └────────────────────────────────────────────────┘
              ▲ 数据源
    data/boss_configs.gd   char_id + map + levels[].modifiers
```

## 4. 数据层：Boss 配置（新增 `res://data/boss_configs.gd`）

```gdscript
class_name BossConfigs

const BOSSES := {
	"fallen_paladin": {
		"id": "fallen_paladin",
		"name": "堕圣骑士",               # 战斗内敌方显示名（HUD）
		"char_id": "paladin",             # 复用角色：动画/技能/组件/角色脚本全继承
		"map": "res://maps/map_boss_fallen_throne.tscn",  # ★ Boss 固定地图（索引）
		"levels": [
			{ "difficulty": "easy",   "modifiers": {
				"hp": 600, "attack_damage": 7,
				"damage_multiplier": 1.0, "damage_taken_multiplier": 1.0 } },
			{ "difficulty": "medium", "modifiers": {
				"hp": 900, "attack_damage": 9, "attack_speed": 2.3,
				"damage_multiplier": 1.2, "damage_taken_multiplier": 0.9 } },
			{ "difficulty": "hard",   "modifiers": {
				"hp": 1500, "attack_damage": 12, "defense": 8,
				"damage_multiplier": 1.5, "damage_taken_multiplier": 0.75,
				"ai": { "react": 90, "aggro": 0.9, "move_speed": 1.2 } } },
			{ "difficulty": "hell",   "modifiers": {
				"hp": 2400, "attack_damage": 16, "defense": 15,
				"damage_multiplier": 1.8, "damage_taken_multiplier": 0.6,
				"ai": { "react": 40, "aggro": 0.95, "move_speed": 1.4 } } },
		],
	},
}

# --- 静态 API ---
static func get_boss_ids() -> Array                      # 所有 Boss id
static func get_boss(id: String) -> Dictionary           # 单个定义（空=不存在）
static func get_map_path(id: String) -> String           # 地图索引：每 Boss 固定且不同
static func resolve_modifiers(id: String, difficulty: String) -> Dictionary
	# 匹配 levels[] 中 difficulty 字段；未命中回退第一个 level（缺省档）
```

### 4.1 Modifier 语义（三类键）

| 分类 | 键 | 作用 | 实现位置 |
|---|---|---|---|
| 基础属性覆盖 | `hp` `defense` `attack_damage` `attack_range` `attack_speed` `max_energy` `energy_regen` | 覆盖角色 config 同名初始值 | `Fighter.apply_boss_modifiers()` 改写字段并重建属性基快照 |
| 全局倍率 | `damage_multiplier` | Boss 造成伤害 ×n（普攻/技能/投射物/区域全收口于 `Fighter.apply_damage`） | `apply_damage` 扣血前统一乘 |
| 全局倍率 | `damage_taken_multiplier` | Boss 受到的伤害 ×n | 同上 |
| AI 增量 | `ai: {react, aggro, dodge, skill_rate, move_speed, jump_rate}` | 对当前难度 `AI_PRESETS` 增量覆盖（Boss 更快/更激进） | `AISystem.update_ai` 取 preset 后合并一次 |
| 表现（可选） | `name` | 敌血条名称 | 优先 `enemy.boss_name` |

> **关于"Modifier 小改"的两个关键认识**
> 1. 大量技能伤害是角色脚本内**写死的数字**（例如女巫陨石 40、圣骑士冲锋 15），
>    不受 `attack_damage` 字段覆盖影响；但它们全部经过 `Fighter.apply_damage`，
>    所以 **`damage_multiplier` 可以放大一切伤害来源**——这才是让 Boss "够狠"的主开关。
> 2. Modifier **不改技能实现与角色组件**，角色作为 Boss 出现时连专属 AI 战术
>   （`CharacterFactory.ai_tactics` / `ai_hell_tactics`）也原样复用。

## 5. 代码改动设计

### 5.1 GameWorld：新增 Boss 上下文（`scripts/game_world.gd`）

```gdscript
# 战斗上下文
var boss_id := ""     # 空 = 普通 PVE；非空 = Boss 战（敌人/地图/数值由 BossSystem 决定）
var current_boss_name := ""   # 供 HUD 显示

func is_boss_mode() -> bool:
	return boss_id != ""
```

**不新增 `game_mode` 值**：Boss 战沿用 `game_mode == "pve"`，现有所有
`game_mode == "pve"` 的分支（时缓、结算、拾取等）自动复用，改动面最小。

### 5.2 敌人 / 地图选择：策略化收敛（`game.gd` 的随机点 → BossSystem）

PVE 现有三处"随机敌人/随机地图"点，Boss 模式只需把它们替换为"读 Boss 配置"。

| 位置 | 现状 | 改为 |
|---|---|---|
| `game.gd` `_start_game`（约 L89-95） | `selected_ai_char_id` 为空时随机选敌人 | 敌人选择收敛为 `BossSystem.resolve_enemy_char()` |
| `game.gd` `_do_async_restart`（约 L600-601） | 重开预载随机地图+随机敌人 | `BossSystem.resolve_map_path()` / `resolve_enemy_char()` |
| `game.gd` `_restart_game`（约 L690-695） | 同上随机 | 同上 |
| `game.gd` `init_game` / `_load_random_map`（约 L262） | `MapManager.pick_random()` | Boss 模式固定 `boss["map"]`（抽 `_load_map(path)`） |

新增薄适配层（Boss 上下文为空时内部委托原逻辑，PVE 行为 0 变化）：

```gdscript
## scripts/systems/boss_system.gd（class_name BossSystem）
static func is_active() -> bool:
	return GameWorld.boss_id != ""

static func get_active() -> Dictionary:      # 当前 Boss 定义（空 = 普通 PVE）
static func resolve_enemy_char() -> String:  # Boss: char_id；PVE: 保持原有随机策略
static func resolve_map_path() -> String:    # Boss: get_map_path；PVE: MapManager.pick_random()

## 敌人创建完成后调用：应用 modifiers + 显示名 + AI 覆盖
static func apply_to_enemy(enemy: Fighter) -> void:
	if not is_active():
		return
	var mods := BossConfigs.resolve_modifiers(GameWorld.boss_id, GameWorld.difficulty)
	enemy.apply_boss_modifiers(mods)
	enemy.boss_name = BossConfigs.get_boss(GameWorld.boss_id).get("name", enemy.char_id)
```

### 5.3 Fighter：Modifier 应用（`scripts/fighter.gd`）

新增字段（默认值对 PVE/PVP 零影响）：

```gdscript
var damage_multiplier := 1.0         # 造成伤害倍率
var damage_taken_multiplier := 1.0   # 受到伤害倍率
var ai_overrides := {}               # AI_PRESETS 增量覆盖（modifier["ai"]）
var boss_name := ""                  # Boss 显示名（空 = 常规，HUD 读 config.name）
```

新增 `apply_boss_modifiers(mods: Dictionary)`，在 `setup()` 之后调用：

1. 直接赋值基础属性字段（`hp/max_hp` 同步、`defense`、`attack_damage` 等）；
2. **重建 `_stat_base` 快照并重放既有 `add_stat_mod`**，防止天赋/技能修饰基于旧基
   把 Boss 数值冲掉（对应 `_init_from_config` 末尾的 `_snapshot_stats()`，
   L261-267 与 `_recalc_stat` L293-319）；
3. 只写 Fighter 字段，**不修改共享的 config 缓存**（config 被 `CharConfigs.reset()`
   统一还原，见 `data/char_configs.gd`）。

伤害插桩（唯一结算点，覆盖普攻/技能/投射物/区域/灼烧等所有走 `apply_damage` 的伤害）：

```gdscript
# Fighter.apply_damage 内、target.hp -= final_dmg（现 L871）之前：
var dealt_mult := attacker.damage_multiplier if attacker else 1.0
final_dmg *= dealt_mult * target.damage_taken_multiplier
```

格挡/护盾/无敌等前置判定链位置不动，只放大最终结算。

### 5.4 AI 完全共享 + 一处增量（`scripts/systems/ai_system.gd`）

`AISystem` 只以 `GameWorld.enemy` 为目标（`update_ai` L524-529），Boss 作为 enemy
出现即自动受控，状态机/连招表/警觉/压迫全部复用。唯一微调：

```gdscript
# update_ai 内取 preset 处（现 L542）：
var diff = Constants.AI_PRESETS.get(GameWorld.effective_ai_difficulty(), Constants.AI_PRESETS["medium"])
if GameWorld.enemy and not GameWorld.enemy.ai_overrides.is_empty():
	for k in GameWorld.enemy.ai_overrides:
		diff[k] = GameWorld.enemy.ai_overrides[k]   # 增量覆盖，不改全局 preset
```

> 语义约定：Boss **不改变难度字符串**（`effective_ai_difficulty()` 仍返回所选难度，
> 地狱专属战术分支照常生效）；`modifier.ai` 只对预设数值做增量，保持"难度 = AI
> 风格 + 数值档位"的一致性。

#### 5.4.1 AI 状态机数值相对化（死数值 → 百分比 / 相对量）

**问题**：AI 状态迁移中存在大量"固定像素距离"阈值（下为现 L1003/L741/L757/L1204
等处的同类判定）。这些是死数值：角色数值（尤其 `attack_range`）一旦被 modifier
覆盖（Boss 攻击范围被放大），AI 依旧按旧像素贴脸才出招，状态判定失真。

```gdscript
if _is_melee(f) and dist < 80 and rand < _eff_aggro(f, diff):   # L1003 死值 80
```

**现状盘点**（`ai_system.gd`）：
- HP / 能量判定**已是百分比**：`f.hp < f.max_hp * 0.3`（L693/L922/L1022）、
  `ply.hp < ply.max_hp * kill_thr`（L679）、`f.energy >= f.max_energy * 0.7`
  （L840）等。Boss 把 HP 改到 2400 后这些分支**自动正确**，无需改。
- 距离判定是死值，需相对化：80（贴身普攻）、100/120/150（玩家贴脸反制与闪避）、
  200/220（技能/斩杀）、300（全屏技规避）、350/400（技能施放带）、500（蓄力距离）。
- PRESS 距离已相对化（`dist > f.attack_range * 1.3`，L254；combo 校验
  `attack_range * 1.5`，L297）——作为相对化写法的模板，无需改。

**改造原则**：
1. **行为距离一律用相对量**，参照物取语义对象：
   - 出招贴身带 → 自身 `f.attack_range` 系（modifier 放大攻击范围 → 更早出招）；
   - 玩家威胁带 → 玩家 `target.attack_range` 系（识别"会不会被打到"）；
   - 技能施放带 → 角色技能射程 / `TACTICS_PROFILE.fav_dist` 系。
2. **HP / 能量状态判定禁止绝对数值**，一律 `x < max_hp * 百分比`（现状已满足，
   作为防回归规范写死在注释中）。
3. **世界空间常量保留死值**：平台几何容差（20px）、投射物威胁距离（150/200，屏幕
   尺度）、状态时长帧数（`dash_remaining = 15` 等）不随角色 modifier 变化，不改。
4. **非 Boss 对局手感不变**：相对化系数取"与原固定值等效果"的倍率，配套回归测试。

**建议实现**（新增统一距离带 helper，替换各死值）：

```gdscript
# AISystem 内：语义化距离带（返回像素目标值，供各状态判定使用）
static func _melee_zone(f) -> float:      # 贴身出招带（原 ~80）
	return f.attack_range + f.w * 0.6
static func _threat_zone(t) -> float:     # 对手威胁带（原 100~150）
	return t.attack_range * 1.6
static func _cast_zone(f) -> float:       # 技能施放带（原 350 系）
	return maxf(_melee_zone(f) * 3.0, f.attack_range * 6.0)
```

改造点示例（实现阶段按上表逐行替换并跑测试校准）：

| 位置 | 现死值 | 语义 | 替换 |
|---|---|---|---|
| L1003 近战普攻触发 | `dist < 80` | 自身攻击可及 | `dist < _melee_zone(f)` |
| L741/L757/L1204 贴脸反制/闪避 | `100~150` | 对手攻击威胁 | `dist < _threat_zone(player)` |
| L667/L844 技能一施放 | `150~350` | 技能中距离带 | `dist > _melee_zone(f) and dist < _cast_zone(f)` |
| L1003 之后弓手/刺客特判 | `80/60` | 各自攻击可及 | `_melee_zone(f)` |
| L854/L866 大招/斩杀 | `150~220` | 斩杀贴身带 | `_threat_zone(player)` 系 |

这样 `modifier` 放大 Boss 的 `attack_range` / `attack_speed` 后，AI 的出招距离带
自动外扩，状态机不再依赖会失真的死数值。

### 5.5 地图复用与隔离（`scripts/map_manager.gd`）

- Boss 地图就是 `maps/` 场景库中的普通地图，共享现有扫描/加载/背景逻辑，**零改造**；
- 约定命名 `map_boss_*.tscn`，若不允许它进入 PVE 随机池，登记到
  `MapManager._locked_map_keywords`（现有锁定机制，作弊模式自动解锁）；
- "地图索引" = `BossConfigs.get_map_path(id)`，Boss 流程不经过 `pick_random()`；
- 出生点由 `_find_spawn_positions()` 按平台自动推导，Boss 地图无需特殊处理。

### 5.6 表现小改

| 位置 | 改动 |
|---|---|
| `HudSystem._draw_enemy_bars`（L121-141） | 名称优先 `enemy.boss_name`，否则 `config.name` |
| `game.gd` 开场 BGM（L401） | Boss 模式播放 `bgm_boss`（`AudioManager` 已注册资源） |

## 6. 改动清单

### 新增
| 文件 | 说明 |
|---|---|
| `res://data/boss_configs.gd` | Boss 注册表 + 解析 API + 示例 Boss |
| `res://scripts/systems/boss_system.gd` | 薄适配层（敌人/地图选择策略 + apply_to_enemy） |
| `res://tests/test_boss_configs.gd` | TDD 测试（见 §8） |
| `res://tests/test_boss_modifiers.gd` | TDD 测试 |

### 修改
| 文件 | 改动 |
|---|---|
| `scripts/fighter.gd` | 倍率字段、`apply_boss_modifiers`、`apply_damage` 插桩、属性基重建 |
| `scripts/game_world.gd` | `boss_id` / `is_boss_mode()` |
| `scripts/game.gd` | 敌人/地图选择收敛到 BossSystem；`_load_map` 重构；BGM 分支 |
| `scripts/systems/ai_system.gd` | 取 preset 后合并 `enemy.ai_overrides`（仅 1 处） |
| `scripts/systems/hud_system.gd` | 敌血条名优先 `boss_name` |
| `scripts/main_menu.gd` + `main_menu.tscn` | Boss 入口（复用难度选择面板） |

### 复用不改
`AISystem` 主体、`CharacterFactory` 全部角色、`CharacterSystems`、`Skill`、
`ProjectileSystem`、`PickupSystem`、`MapManager` 主体、`Fighter.setup/_init_from_config`、
`game.tscn`、练习模式。

## 7. 入口与流程（UI 复用）

PVE 菜单链为 `主菜单 → 难度 → 选人 → game.tscn`。Boss 入口复用同一结构：

```
主菜单 [BOSS 挑战] → (复用难度面板 diff_select，设置 GameWorld.difficulty)
  → 选人界面（隐藏敌方随机选择，提示 "对手：堕圣骑士"）
  → 跳 game.tscn 前：GameWorld.boss_id = "fallen_paladin"
game.gd._start_game() 检测 boss_id → BossSystem 决定敌人/地图 → init_game(...)
  → BossSystem.apply_to_enemy() → 开场 → 战斗（AI/结算全复用）→ R 重开同一 Boss
```

## 8. TDD 测试策略

项目使用 GUT（`.gutconfig.json` → `res://tests`）。每项先写测试再实现。

| 测试文件 | 覆盖 |
|---|---|
| `test_boss_configs.gd` | 注册表自洽：`char_id` 均在 `CharacterFactory`、`map` 可加载；`resolve_modifiers` 按 easy/medium/hard/hell 取档，未命中回退缺省档 |
| `test_boss_modifiers.gd` | 角色 setup 后 apply：`hp/max_hp/attack_speed/defense/attack_range/max_energy` 符合预期；`add_stat_mod` 与 apply 先后两种顺序数值均正确（属性基重建）；`damage_multiplier=1.5` + 目标 `damage_taken_multiplier=0.5` → 扣血 = 原值 ×0.75；`ai_overrides` 合并后 preset 字段被覆盖 |
| `test_boss_integration.gd` | Boss 上下文下初始化后 enemy 的 `char_id / max_hp / boss_name` 正确、地图路径为指定图、R 重开后不漂移 |

## 9. 里程碑

1. **M1 数据与单元层**：`boss_configs.gd` + `Fighter` 字段/`apply_boss_modifiers`/
   `apply_damage` 插桩，绿 `test_boss_configs` / `test_boss_modifiers`。
2. **M2 战斗集成**：GameWorld 上下文 + BossSystem + `game.gd`/AI/HUD 微调，
   绿 `test_boss_integration`，实机跑一局 Boss 战。
3. **M3 入口与内容**：主菜单 Boss 入口；正式 Boss 专属地图素材
   （框架阶段先以现有地图路径占位验证索引机制）。

## 10. 扩展位（本框架不实现，仅预留）

- **Boss 阶段切换**（血量阈值转阶段）：可在 `Fighter` 增加 `boss_phase` + 阈值事件，
  由角色脚本/系统监听，后续内容层接入；
- **技能级强化**：若需仅强化某技能，可在 `apply_boss_modifiers` 上留
  `on_boss_applied` 钩子，角色脚本自订阅；
- **Boss 专属演出**（登场动画/胜利结算）：复用 `_start_intro` / game_over 绘制位，
  不做结构改动。
