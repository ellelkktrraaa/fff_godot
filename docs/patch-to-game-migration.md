# Patch → 游戏迁移指南（精简版）

> watcher-godot-importer 流水线最后一步：AI 在 `docs/patch/*.patch.txt` 里给出**建议文本**，
> 由人工（或后续 agent）按本指南迁移到 `scripts/characters/*.gd`。AI 不直接改角色脚本。

## 0. 迁移前先看懂 patch

每个 `docs/patch/{char}_{state}_animation.patch.txt` 对应**一个角色的一个动画**，固定三部分：

| 部分 | 内容 | 落到哪 |
|---|---|---|
| ① const preload | `const XXX_FOOT_GAPS = preload("res://data/foot_gaps/{char}_{state}_foot_gaps.gd")` | 文件顶部 const 区 |
| ② animations 行 | 把 `"<state>": ...` 一行换成 `load_from_sprite_sheet(...)` | `get_config()` 的 animations 字典 |
| ③ 锚点函数 | `static func _<char>_<state>_anchors()` 拼每帧 5 个锚点字段 | 任意 static func 区 |

参考写法：`knight.gd` 的 `_knight_attack_anchors()`。

## 1. 前置校验（3 项，缺一不可）

```powershell
# 在 Godot 项目根执行前，先人工确认：
1. data/foot_gaps/{char}_{state}_foot_gaps.gd 存在，且 class_name 全局唯一（{CHAR}_{STATE}_FootGaps）
2. assets/char_ani/{char}/{state}/sheet.png 存在
3. 网格参数合法：columns × rows ≥ frame_count，且与导出 sheet.json 一致
```

- `class_name` 唯一性很重要：任何两个 foot_gaps 文件 `class_name` 相同，Godot 直接 Parse Error。
- 若 `docs/patch/` 下残留过 `.gd` 副本（历史误写），**删除**，只保留 `.patch.txt`。

## 2. 迁移步骤

### ① 常量（注意命名唯一）

- 同一角色只有 1 个动画用锚点时，可用角色级：`const KNIGHT_FOOT_GAPS = preload(".../knight_attack_foot_gaps.gd")`
- **同一角色多个动画时，必须用状态级**避免重名：

```gdscript
const ROSE_IDLE_FOOT_GAPS = preload("res://data/foot_gaps/rose_idle_foot_gaps.gd")
const ROSE_JUMP_FOOT_GAPS = preload("res://data/foot_gaps/rose_jump_foot_gaps.gd")
```

### ② animations 行

普通动画：

```gdscript
"<state>": FrameAnimation.load_from_sprite_sheet(<CHAR>_ANI_DIR + "<state>/sheet.png", <columns>, <rows>, <frame_count>, <duration>, <loop>, _<char>_<state>_anchors()),
```

**jump 动画必须用 `load_jump_sheet`**（起跳 0.2s → 滞空保持 → 落地自动倒放，Fighter 状态机统一处理）：

```gdscript
"jump": FrameAnimation.load_jump_sheet(ROSE_ANI_DIR + "jump/sheet.png", 2, 2, 4, 0.2, _rose_jump_anchors()),
```

**duration 规则**（多帧动画用 999.0 会冻结在第 1 帧，看起来像没换）：

| 场景 | duration |
|---|---|
| 多帧 idle/walk/jump | `sheet.json duration_ms / 1000`（通常 0.1） |
| 攻击/技能一次性 | `0.1 ~ 0.5, false` |
| 单帧占位（load_from_frames） | `999.0` |

**攻击动画总时长必须 ≤ 攻击窗口**（`attack_timer`，配置默认 30 帧 = 0.5s）：
`frame_count × duration ≤ 0.5`，否则动画播不完就被切走，或在收招边界被反复重放。
（如 shadowwarrior 攻击 10 帧 → duration 用 `0.05`；可参考同角色 `attack_duration` 配置。）

### ③ 锚点函数（照抄 knight 模板，改前缀）

```gdscript
static func _<char>_<state>_anchors() -> Array:
	var anchors := []
	for i in range(<CHAR>_<STATE>_FOOT_GAPS.<CHAR>_<STATE>_FOOT.size()):
		anchors.append({
			"foot_gap": <CHAR>_<STATE>_FOOT_GAPS.<CHAR>_<STATE>_FOOT[i],
			"head_gap": <CHAR>_<STATE>_FOOT_GAPS.<CHAR>_<STATE>_HEAD[i],
			"center_dx": <CHAR>_<STATE>_FOOT_GAPS.<CHAR>_<STATE>_CENTER[i],
			"content_w": <CHAR>_<STATE>_FOOT_GAPS.<CHAR>_<STATE>_CONTENT_W[i],
			"content_h": <CHAR>_<STATE>_FOOT_GAPS.<CHAR>_<STATE>_CONTENT_H[i],
		})
	return anchors
```

### ④ 动画推进检查

该角色 `update_systems` 里必须有每帧推进（多帧动画换帧依赖它）：

```gdscript
if f.current_anim and f.current_anim.is_playing():
	f.current_anim.update(1.0)
```

- 已有：knight / bard / rose / shadowwarrior
- **缺**：archer（无 update_systems）、witch（只有 update_global）——迁移它们前需先补推进

## 3. 验证清单

- [ ] 重启游戏（`CharConfigs.configs` 在启动时构建，热重载不生效）
- [ ] Godot 控制台无 Parse Error / class_name 冲突
- [ ] 动画能换帧（不是定格在第 1 帧）
- [ ] 贴图覆盖碰撞箱（人工锚点 `content_w/h = -1`，渲染器按 `帧高 - foot_gap - head_gap` 自动推算；旧渲染器会画得极小）
- [ ] jump：起跳 0.2s → 空中滞空帧 → 落地倒放

## 4. 常见坑速查

| 现象 | 原因 | 处理 |
|---|---|---|
| Godot Parse Error 全局重名 | 两个 foot_gaps 同 class_name；或 docs/patch 里残留 .gd 副本 | 唯一命名；删除副本 |
| 动画定格不动 | duration 999.0 / 缺 `current_anim.update` | 改时长；补推进 |
| 攻击播不完 / 收招后卡在最后一帧 | 攻击动画总时长 > 攻击窗口；跳跃被攻击打断 | 压缩攻击 duration 到窗口内；跳跃打断已由 Fighter 自动恢复（无需处理） |
| 贴图极小、盖不住碰撞箱 | content_w/h = -1 且渲染器未推算 | 升级 render_system（见本文档 3 验证） |
| 看起来还是旧贴图 | 多帧动画冻结在第 1 帧（与旧图同源） | 改 duration |
| 与最新导出不一致 | 同名导出多个时间戳 | 以最新导出为准，核对网格与 foot_gaps 帧数 |

> 跳跃状态机说明：`load_jump_sheet` 动画由 Fighter 统一管理（起跳 → 滞空 → 落地倒放），
> 中途被攻击/技能打断会自动恢复，迁移时无需额外代码。
