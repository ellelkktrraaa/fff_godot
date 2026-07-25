# 焰刃流光 — 项目开发规则文档

> **本文档整合项目所有开发规范，是代码编写和审查的唯一强制依据。**
>
> 来源文档：[DEVELOPERS_README/](DEVELOPERS_README/) | [反模式参考](.trae/documents/fix-anti-patterns.md) | [角色开发规范](docs/char-spec.md)

---

## 一、核心原则

**角色即插件（Character as Plugin）。**

添加角色 = 在 `character_factory.gd` registry 加一行 + 创建角色脚本 + 放置贴图，**不修改任何系统文件**。

所有角色资源（贴图、动画、技能行为、专属系统逻辑、图鉴文本）必须自治于角色脚本内部，通过 `CharacterFactory` 统一注册和调度。

**判断标准**：当你写完一段代码后，如果删除某个角色，是否需要修改这段代码？如果是，则违反了此原则。

---

## 二、目录结构规范

```
fff_godot/
├── assets/
│   ├── char_ani/           # 角色动画帧贴图（按角色/状态分目录）
│   │   └── {char_id}/      # 每个角色一个目录
│   │       ├── idle/       # 待机（至少 1 帧）
│   │       ├── walk/       # 行走（至少 1 帧）
│   │       ├── jump/       # 跳跃（至少 1 帧）
│   │       ├── attack/     # 普攻（至少 1 帧）
│   │       └── ult/        # 大招（至少 1 帧）
│   ├── fx_*.png            # 特效/弹射物贴图（fx_ 前缀）
│   ├── ui_*.png            # UI 元素（ui_ 前缀）
│   └── bg_*.png            # 背景图（bg_ 前缀）
├── scripts/
│   ├── characters/         # 角色脚本（插件化自治单元）
│   │   └── character_factory.gd  # 注册表 + 调度器（唯一入口）
│   ├── systems/            # 通用子系统（不含角色硬编码）
│   └── *.gd                # 核心类
├── scenes/                 # Godot 场景文件
├── data/                   # 配置数据
├── docs/                   # 设计文档
├── DEVELOPERS_README/      # 开发者文档（详细 API 等）
├── rule/                   # 本文档：开发规则
└── .trae/documents/        # 历史规范文档
```

---

## 三、命名规范（强制）

所有资源文件必须遵守以下命名规范。**严禁使用 `无标题`、纯数字编号、临时中文名。**

### 文件前缀规则

| 前缀 | 用途 | 示例 |
|------|------|------|
| `bg_` | 背景图 | `bg_main_menu.png` |
| `ui_` | UI 元素 | `ui_btn_pve.png`、`ui_title.png` |
| `fx_` | 通用特效贴图 | `fx_explosion.png` |
| `sfx_` | 音效 | `sfx_hit.wav` |
| `{char_id}_` | 角色帧贴图（仅限 `char_ani/` 下） | `knight_idle_f_1.png` |

### 通用规则

- 全部小写字母，单词用下划线 `_` 分隔
- 禁止中文、空格、特殊字符、`无标题`、`新建`、纯时间戳
- 角色帧贴图固定格式：`{char_id}_{state}_f_{index}.png`
  - `{char_id}`：角色标识，如 `knight`、`archer`
  - `{state}`：动画状态，如 `idle`、`walk`、`jump`、`attack`、`ult`
  - `{index}`：帧序号，从 1 开始

**自检**：看到文件名时，能否在 3 秒内说出它的用途？不能 → 重命名。

---

## 四、图像数据铁律

**所有角色相关的图像数据必须使用 `FrameAnimation` 包装，禁止裸 `preload Texture2D`。**

即使当前只有单帧，也必须用 FrameAnimation 包装：

```gdscript
# ✅ 正确
static func _fa(tex: Texture2D, dur: float = 999.0) -> FrameAnimation:
    var a = FrameAnimation.new(); a.add_frame(tex, dur); a.loop = true; return a

# ❌ 禁止
const MY_IMG = preload("res://assets/xxx.png")
```

原因：FrameAnimation 是统一视觉抽象，未来替换多帧动画无需修改消费代码。

---

## 五、帧动画规范

- **禁止使用 `timetable.txt` 文件**（Godot 运行时无法可靠读取）
- 使用 `FrameAnimation.load_from_frames(dir, prefix, frame_specs, loop)`，帧数据直接嵌入代码
- 每个动画状态一个子目录

```gdscript
# 单帧静态（idle / walk / jump）：duration 用 999 表示无限循环
FrameAnimation.load_from_frames(DIR + "idle/", "char_idle_f_", [{"index":1,"duration":999.0}], true)

# 单帧攻击
FrameAnimation.load_from_frames(DIR + "attack/", "char_attack_f_", [{"index":1,"duration":2.0}], false)

# 多帧序列
FrameAnimation.load_from_frames(DIR + "ult/", "char_ult_f_", [
    {"index": 1, "duration": 0.8},
    {"index": 2, "duration": 0.1},
    {"index": 3, "duration": 0.3},
], false)
```

---

## 六、角色注册与调度

### CharacterFactory — 唯一的角色入口

```gdscript
# scripts/characters/character_factory.gd
const MyChar = preload("res://scripts/characters/mychar.gd")

static var _char_registry := {
    "mychar": { "cls": MyChar, "config": null },  # ← 新增角色在这里加一行
}
```

### 调度方法

| 方法 | 调用者 | 作用 |
|------|--------|------|
| `get_config(id)` | `CharConfigs` | 获取角色配置字典 |
| `create_skills(id)` | `game.gd` | 创建技能数组 |
| `handle_input(id, fighter, keys)` | `InputHandler` | 处理玩家输入，返回 mx |
| `update_char_systems(fighter)` | `CharacterSystems` | 每帧更新角色专属逻辑 |

---

## 七、角色脚本规范

每个角色脚本 `scripts/characters/xxx.gd` 必须实现以下方法。

### 必须实现

| 方法 | 签名 | 说明 |
|------|------|------|
| `get_config()` | `static func get_config() -> Dictionary` | 返回角色完整配置 |
| `create_skills()` | `static func create_skills() -> Array` | 返回 `Skill` 对象数组 |

### 可选实现

| 方法 | 签名 | 说明 |
|------|------|------|
| `handle_input()` | `static func handle_input(fighter: Fighter, keys: Dictionary) -> int` | 输入处理 |
| `update_systems()` | `static func update_systems(fighter: Fighter)` | 每帧专属逻辑 |

### get_config() 必须字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | String | 角色 ID，与 registry key 一致 |
| `name` | String | 显示名称 |
| `hp` | float | 生命值 |
| `max_energy` | float | 能量上限 |
| `energy_regen` | float | 每帧能量回复 |
| `speed` | float | 移动速度倍率 |
| `attack_range` | float | 攻击范围（像素） |
| `attack_damage` | float | 普攻伤害 |
| `attack_cooldown` | int | 普攻冷却（帧数） |
| `attack_delay` | int | 攻击判定延迟（帧数） |
| `attack_duration` | int | 攻击动画时长（帧数） |
| `fields` | Dictionary | 角色专属字段，无则传 `{}` |
| `animations` | Dictionary | 必须含 idle/walk/jump/attack/ult 五个 key |
| `dex` | Dictionary | 图鉴数据，含 icon/intro/stats/skills |

### animations 字典规范

| key | loop | 说明 |
|-----|------|------|
| `idle` | true | 待机动画，至少 1 帧 |
| `walk` | true | 行走动画，至少 1 帧 |
| `jump` | true | 跳跃动画，至少 1 帧 |
| `attack` | false | 普攻动画，至少 1 帧 |
| `ult` | false | 大招动画，至少 1 帧 |

---

## 八、反模式清单（严禁出现）

### 反模式 1：系统脚本中 `match char_id` 分支（🔴 严重）

```gdscript
# ❌ 严禁 — input_handler.gd / ai_system.gd / 任何 systems/ 文件
match p.char_id:
    "knight": _input_knight(p, keys)
    "mage":   _input_mage(p, keys)

# ✅ 正确
var mx = CharacterFactory.handle_input(p.char_id, p, keys)
```

### 反模式 2：系统脚本中角色专属函数（🔴 严重）

```gdscript
# ❌ 严禁 — character_systems.gd
static func update_assassin_logic(): ...

# ✅ 正确 — 调度到角色脚本
CharacterFactory.update_char_systems(fighter)
```

### 反模式 3：Skill/Fighter 中 char_id 判断（🟡 中等）

```gdscript
# ❌ 严禁
if owner.char_id == "archer": return false

# ✅ 正确 — 配置驱动
if not owner.config.get("can_skill_while_attacking", false): return false
```

### 反模式 4：game.gd 硬编码角色列表（🟡 中等）

```gdscript
# ❌ 严禁
var enemy_chars = ["knight", "mage", "archer", ...]

# ✅ 正确
var enemy_chars = CharConfigs.get_all_ids()
```

### 反模式 5：timetable.txt 加载帧数据（🔴 严重）

```gdscript
# ❌ 严禁
FrameAnimation.from_timetable("res://assets/char_ani/knight/idle/timetable.txt")

# ✅ 正确 — 帧数据直接嵌入代码
FrameAnimation.load_from_frames(DIR + "idle/", "knight_idle_f_", [{"index":1,"duration":999.0}], true)
```

### 反模式 6：贴图散落 assets/ 根目录（🟡 中等）

```
# ❌ 严禁
assets/
├── 无标题88_20260712153232.png
├── dragon_knight_walk_f_1.png

# ✅ 正确
assets/char_ani/dragon_knight/walk/dragon_knight_walk_f_1.png
```

### 反模式 7：game.gd `_draw()` 中角色特定绘制（🟡 中等）

```gdscript
# ❌ 严禁
if p.char_id == "rose" and p.skill2_active: draw_circle(...)

# ✅ 正确 — 通过 overlay 系统 / Fighter.emit_particles() 实现
```

### 反模式 8：直接操作全局状态（🟡 中等）

```gdscript
# ❌ 严禁 — 角色脚本中
GameWorld.hit_stop = 12

# ✅ 正确 — 通过 Fighter 接口间接操作
Fighter.emit_particles(...)
```

### 反模式 9：无意义文件名（🔴 严重）

```
# ❌ 严禁
无标题88_20260712153232.png、34-20260705005653.png、新建文件夹/

# ✅ 正确
bg_main_menu.png、ui_btn_pve.png、fx_assassin_slash.png
```

### 反模式 10：裸 preload Texture2D（🔴 严重）

```gdscript
# ❌ 严禁
const PROJ_SWORD = preload("res://assets/fx_sword_projectile.png")

# ✅ 正确 — FrameAnimation 包装
const PROJ_SWORD_ANI = _fa(preload("res://assets/fx_sword_projectile.png"))
```

---

## 九、新增角色检查清单

每次新增角色，逐项确认：

### 代码层面

- [ ] `character_factory.gd` — registry 加一行 `"mychar": { "cls": MyChar, "config": null }`
- [ ] `scripts/characters/xxx.gd` — 实现 `get_config()` + `create_skills()` + `handle_input()`
- [ ] `animations` 使用 `FrameAnimation.load_from_frames()`（非 timetable）
- [ ] `animations` 中 idle/walk/jump 有至少一帧
- [ ] 技能回调通过 `Callable()` 绑定
- [ ] 所有图像数据使用 FrameAnimation 包装（无裸 Texture2D preload）
- [ ] 不直接修改 `GameWorld` 或 `Game` 全局状态（只读查询允许）
- [ ] 贴图路径指向 `assets/char_ani/{char_id}/` 下的子目录
- [ ] 无 `match char_id`、无角色硬编码

### 资源层面

- [ ] `assets/char_ani/xxx/` — 5 个状态目录各至少 1 帧（idle/walk/jump/attack/ult）
- [ ] 帧文件命名：`{char_id}_{state}_f_{index}.png`
- [ ] 无 `timetable.txt` 文件
- [ ] 无 `无标题`、纯数字编号、中文文件名
- [ ] 无 scatter 在 `assets/` 根目录的未归类贴图

### 不修改的文件

新增角色时，**以下文件绝对不能修改**：
- `systems/` 下任何文件
- `fighter.gd`
- `skill.gd`
- `game.gd`
- `character_systems.gd`

---

## 十、代码审查检查清单

### 系统脚本（systems/、fighter.gd、skill.gd、game.gd）

- [ ] 无 `match char_id` 分支
- [ ] 无 `if xxx.char_id == "..."` 条件判断
- [ ] 无硬编码角色 ID 字符串列表
- [ ] 无角色专属函数定义
- [ ] 无直接操作角色专属字段

### 角色脚本（scripts/characters/xxx.gd）

- [ ] `get_config()` 包含完整配置
- [ ] `animations` 使用 `FrameAnimation.load_from_frames()`
- [ ] 所有图像数据使用 FrameAnimation 包装
- [ ] 不直接修改全局状态

### 资源文件

- [ ] 角色贴图在 `assets/char_ani/{char_id}/{state}/` 中
- [ ] 帧文件命名一致：`{char_id}_{state}_f_{index}.png`
- [ ] 不存在 `.txt` timetable 文件
- [ ] 不存在散落在 `assets/` 根目录的未归类贴图
- [ ] 无 `无标题`、纯数字编号、中文文件名

---

## 十一、Git 工作流规范

### 分支策略

**禁止直接在 main 上开发。** 所有变更通过 feature 分支提交。

```
main
  ├── feat/{描述}         ← 新功能
  ├── fix/{描述}          ← 修复
  ├── refactor/{描述}     ← 重构
  └── docs/{描述}         ← 文档
```

### 强制规则

- ❌ `git add -A` / `git add .` — 必须指定具体文件
- ❌ `git push --force` — 禁止在 main 上使用
- ❌ `.godot/` 不得重新加入追踪
- ✅ 每个 commit 只做一件事
- ✅ commit message 用中文，格式：`类型: 简述`

### 标准工作流

```bash
git checkout main
git pull origin main
git checkout -b feat/my-feature
# 开发 + 提交
git add <具体文件>
git commit -m "feat: xxx"
git push -u origin feat/my-feature
```

---

## 十二、帧数参考

| 帧数 | 时间 |
|------|------|
| 60 | 1 秒 |
| 30 | 0.5 秒 |
| 180 | 3 秒 |
| 300 | 5 秒 |
| 480 | 8 秒 |
| 600 | 10 秒 |
| 720 | 12 秒 |
| 999 | 静态帧（无限） |

---

## 十三、术语对照

| 术语 | 含义 |
|------|------|
| **系统脚本** | `systems/` 下的所有 `.gd` + `fighter.gd` + `skill.gd` + `game.gd` |
| **角色脚本** | `scripts/characters/xxx.gd`，自治单元 |
| **硬编码** | 在代码中直接写入特定角色的 ID 字符串或专属逻辑 |
| **配置驱动** | 通过 `config` 字典控制行为差异，而非通过条件分支 |
| **manifest** | `CharacterFactory._char_registry` 字典，角色的注册入口 |
