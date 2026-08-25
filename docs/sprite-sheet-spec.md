# 角色 Sprite Sheet 接入规范

> 本文档整理本项目中「角色多帧动画 sheet（精灵图集）」从素材到游戏内动画的完整处理流程，
> 是 `scan_feet_offsets.py` 锚点体系 + `FrameAnimation.load_from_sprite_sheet` 的统一接入标准。
> 项目规则依据：[rule/index.md](../rule/index.md)

---

## 一、适用范围

- `assets/char_ani/{char_id}/{state}/sheet.png` — 角色动画帧图集
- `assets/sheet.dragon.png`、`assets/sheet.attack.png` 等全局角色图集
- 视频切帧工具（sprite-video-lab watcher）导出的图集

处理目标：把任意来源的 sheet 安全转换为「按帧切割 + 锚点对齐 + 正确缩放 + 可循环/单次播放」的
`FrameAnimation`，并接入角色 config 的 `animations` 字典。

---

## 二、分析网格（PIL）

**不要想当然地按像素整除猜网格。** 先做行列 alpha 投影找「沟槽」：

```python
# 行投影：每行有内容的像素数（步进采样加速）
row_has[y] = 该行 alpha>8 的像素数（可每 3~4 列采样一次）
col_has[x] = 该列 alpha>8 的像素数（可每 3~4 行采样一次）
# 低密度（<1%）的连续行列区间 = 空白沟槽
# 内容块的间距 = 格尺寸
```

判定标准（候选网格必须全部满足）：

1. 按候选网格切分后，**每格内容包围盒不越界**（宽高 ≤ 格尺寸）
2. 每格内容有合理留白（不紧贴边框，也不几乎占满）
3. ASCII 渲染（缩到 60×16 左右）每格是**完整独立的一帧**
4. 所有格的内容位置规律一致（如都偏左、都居中）

常见坑：

- 内容**横向靠左/靠右**而非居中（本项目 sheet 普遍如此，属正常）
- 内容跨格出血（宽高略大于格尺寸 → 网格划分错误，需重新找沟槽）
- 同一张图可能因行数不同而完全改变帧数（如 `sheet.attack.png` 5376×2304：4×4=16 帧是错的，
  正确是 4×3=12 帧，格 1344×768）

---

## 三、识别有效帧

视频导出常在首尾带**空白帧**（黑场/静帧），必须剔除：

| 场景 | 现象 | 处理 |
|------|------|------|
| 阶梯排列（evoker ult） | 前 4 格 + 后 5 格空白，有效格 4~43（40 帧） | 加载 44 格后运行时 `anim.frames = anim.frames.slice(4, 44)` |
| 尾部空行（dragon sheet） | 4×4 网格仅前 14 格有内容 | `frame_count = 14` 直接截断 |
| 全部有效（attack sheet） | 4×3 网格 12 格全有内容 | `frame_count = 12` |

规则：

- 帧数 = 有效格数，**禁止**把空白格算进动画（会闪黑帧）
- 有效格的行主序（row-major，左→右、上→下）即播放顺序
- 若帧间是连续姿态（如巨龙 14 帧为单一振翅循环），整段作为一个循环动画；
  若确为多组动画（待机/移动/飞行），按行/列分组，每组独立 `FrameAnimation`

---

## 四、生成锚点数据 → `data/foot_gaps/`

逐格扫描 alpha 包围盒，生成 GDScript 常量文件（与 `scan_feet_offsets.py` 输出格式一致）：

```gdscript
# data/foot_gaps/{char_id}_{state}_foot_gaps.gd
class_name DRAGON_KNIGHT_ATTACK_SHEET_FootGaps   # ← 类名必须全项目唯一

const XXX_FOOT: Array[int]       # 每帧脚底到帧底部空隙
const XXX_HEAD: Array[int]       # 每帧头顶到帧顶部空隙
const XXX_CENTER: Array[float]   # 内容中轴相对帧中心线偏移（正=偏右）
const XXX_CONTENT_W: Array[int]  # 内容实际宽度
const XXX_CONTENT_H: Array[int]  # 内容实际高度
const XXX_HEIGHT_MEDIAN: int     # content_h 中位数 → 渲染 ref_h
```

要点：

- 每帧一组 `(foot_gap, head_gap, center_dx, content_w, content_h)`
- `center_dx` 用于渲染时把内容中轴对齐碰撞体中心（内容偏左/偏右的帧不会抖动）
- `HEIGHT_MEDIAN` 是整组动画的统一缩放基准，避免逐帧归一化导致角色忽大忽小
- 文件头注明帧尺寸（如 `# 帧尺寸: 1344x768`）

---

## 五、生成 `.import` 文件

新 PNG 必须提供 `.import`（格式照抄任意现有 sheet 的 `.import`），只需改三处：

1. `uid="uid://xxxxxxxxxxxxx"` — 随机 13 位小写 base32（`[a-z2-7]`）
2. `path` / `dest_files` 中的 ctex 文件名 = **MD5("res://" + 源路径字符串)**
   - 例：`res://assets/sheet.attack.png` → `sheet.attack.png-32bfd215….ctex`
3. `source_file` 指向实际路径

```ini
[remap]
importer="texture"
type="CompressedTexture2D"
uid="uid://xxxxxxxxxxxxx"
path="res://.godot/imported/{文件名}-{md5}.ctex"
...
```

验证 MD5：

```python
import hashlib
hashlib.md5("res://assets/xxx.png".encode()).hexdigest()
```

---

## 六、代码接入（角色脚本内）

### 1. 常量 + 锚点组装

```gdscript
const XXX_FOOT_GAPS = preload("res://data/foot_gaps/xxx_foot_gaps.gd")
const XXX_SHEET = "res://assets/char_ani/{char_id}/{state}/sheet.png"

static func _xxx_anchors() -> Array[Dictionary]:
    var anchors: Array[Dictionary] = []
    for i in XXX_FOOT_GAPS.XXX_FOOT.size():
        anchors.append({
            "foot_gap": ..., "head_gap": ..., "center_dx": ...,
            "content_w": ..., "content_h": ...,
        })
    return anchors
```

### 2. config["animations"] 注册

```gdscript
"ult_attack": FrameAnimation.load_from_sprite_sheet(
    XXX_SHEET, 4, 3, 12,   # 路径, 列, 行, 帧数
    0.05,                   # 每帧秒数
    false,                  # 是否循环
    _xxx_anchors()),        # 锚点数组（长度必须 == 帧数）
```

参数约定：

| 参数 | 说明 |
|------|------|
| columns / rows | 分析确认的网格，勿用 sheet 宽高反推 |
| frame_count | 有效帧数（不含空白格） |
| duration_seconds | 动画节奏；技能/普攻常用 0.05~0.1，循环待机 0.1 |
| loop | 待机/行走/飞行循环=true，攻击/技能/大招=false |

### 3. 动画状态切换（角色 update_systems 内）

- 单次动画：切到目标状态播放，`is_finished()` 后切回待机
- 同状态重复调用 `set_animation_state` 不会重置播放位置（连续普攻不打断）
- 状态切换会 `play()` 从头播放 → 不同状态引用同一 sheet 时避免高频互切（会每帧重置）

---

## 七、尺寸控制（核心）

锚点渲染公式（`render_system.gd`）：

```gdscript
scale = f.h(56) / ref_h × anim_scale × anim_scale_states[image_state]
```

| 场景 | 配置 | 说明 |
|------|------|------|
| 默认（等身） | 不配置 | 内容高 → 碰撞体高（56px） |
| 单状态放大 | `"anim_scale_states": {"skill1": 1.2}` | 蓄力帧偏矮时填满碰撞盒 |
| 保持与原贴图同尺寸 | `anim_scale_states = 目标渲染高 / 56` | 见下方公式 |

**"与原贴图一样大"的计算方法：**

```
原贴图渲染高 = 原贴图高 × min(32/宽, 56/高) × image_scale
            （2048² 巨龙 × image_scale 6.0 → 336px）
anim_scale_states = 原渲染高 / 56 = 336 / 56 = 6.0
（如需缩小 40% → 6.0 × 0.6 = 3.6 → 渲染约 202px）
```

注意：

- 锚点路径**不再乘 image_scale**（那是无锚点旧贴图的系数），放大走 `anim_scale_states`
- `anim_scale` 是全局系数（影响该角色所有动画）；只放大某个状态用 `anim_scale_states`
- 内容中位高（ref_h）决定基准缩放，个别矮帧（如特效单帧）会略小，属素材固有

---

## 八、大招演出（时停）

| 演出类型 | 实现 | 时停 |
|----------|------|------|
| 全屏 cinematic | `active_overlays` + `position:{type:"fullscreen"}` + `overlay_id` 以 `_ult` 结尾 | `is_time_stopped()` 自动全程时停 |
| 定点演出 | `position:{type:"world", x, y, scale}` + `GameWorld.trigger_time_stop(帧数)` | 手动触发，帧数 = 动画总长 |

```gdscript
GameWorld.active_overlays.append({
    "anim": ult_anim,
    "position": {"type": "world", "x": fx, "y": fy, "scale": Vector2(s, s)},
    "owner": owner,
    "overlay_id": "xxx_ult",
    "on_finish": func(): _spawn_effect(...),
})
GameWorld.trigger_time_stop(int(ult_anim.total_duration * 60) + 1)
```

---

## 九、接入检查清单

- [ ] 网格经行列投影确认，非猜测
- [ ] 空白帧已剔除，frame_count = 有效帧数
- [ ] 锚点文件类名全项目唯一，帧数与 sheet 一致
- [ ] `.import` 的 uid 随机、MD5 与源路径一致
- [ ] `animations` 条目参数（列/行/帧数）与锚点匹配
- [ ] 尺寸：默认等身；特殊角色用 `anim_scale_states` 控制
- [ ] 循环/单次语义正确；状态切换不产生每帧重置
- [ ] 演出型大招按第八节接入时停
- [ ] `GetDiagnostics` 0 错误

---

## 十、常见坑速查

1. **网格猜错** → 帧被拦腰切开。先看行列投影沟槽，再逐格 ASCII 验证
2. **空白帧计入** → 动画开头/结尾闪黑。检查首尾格 alpha
3. **类名冲突** → `class_name XXX_FootGaps` 全项目唯一（历史上发生过 FootGaps 重名）
4. **MD5 写错** → 资源加载失败。MD5 对象是 `"res://" + 源路径` 字符串
5. **内容出血** → 包围盒宽高 > 格尺寸说明网格错，或扫描阈值过低（应 alpha>8）
6. **同 sheet 多状态互切** → `set_animation_state` 状态名变化会 `play()` 重置，避免高频互切
7. **放大生效位置** → 锚点路径下 `image_scale` 无效，必须用 `anim_scale_states`
