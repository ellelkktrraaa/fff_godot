# 黑法师组件：角色专属状态（待填充）
# 框架说明：在此声明黑法师的专属运行字段（如暗能量计数、技能阶段、持续施法标志等），
# 由 scripts/characters/black_mage.gd 的 update_systems() 每帧读取推进。
class_name BlackMageComponent
extends CharComponent

# ── 技能一·妄相皆破/凛冬：施法第5帧震飞 + 第10帧召唤冰棱 + 进入强化状态 ──
var skill1_active: bool = false   # 技能一演出中
var skill1_cast_armor: bool = false  # 技能一施法霸体是否开启
var shockwave_dealt: bool = false # 施法第 5 帧震飞（妄相皆破）是否已触发
var enhanced: bool = false        # 强化状态标志（持续 15s）
var enhanced_timer: int = 0       # 强化状态剩余帧数（900 = 15s，对应技能一黄条）

# ── 凛冬（技能一施法第 10 帧自动召唤 4 冰棱）──
var crystals_spawned: bool = false   # 冰棱是否已召唤（施法第 10 帧置 true）
var ult_active: bool = false         # 凛冬状态（有冰棱环绕/可发射/可格挡）
var crystals: Array = []             # 冰棱数组：[{state, x, y, offset_x, offset_y, phase}]；state: idle/fired/blocked
var crystal_hits: int = 0            # 冰棱累计命中数（4 次全中 → 5s 冻结）
var crystal_anim: FrameAnimation = null     # 冰棱待机动画（4 个冰棱共享循环）
var crystal_break_anim: FrameAnimation = null  # 冰棱破碎动画（命中/格挡时播放）

# ── 灰烬（U+S：技能一+下方向，施法召唤 3 火球快速旋转，普攻发射火球）──
var ash_active: bool = false          # 灰烬施法中（与凛冬共用 skill1_active）
var fireballs_spawned: bool = false   # 火球是否已召唤（施法第 5 帧置 true）
var fireballs: Array = []             # 环绕火球：[{angle, x, y, fired}]；fired=true 表示已发射消耗
var fireball_anim: FrameAnimation = null     # 环绕火球动画（sheet_fire 6 帧循环）
var fireball_shot_anim: FrameAnimation = null # 发射火球动画（sheet_fireball 12 帧）
var fireball_hits: int = 0        # 发射火球累计命中数（3 个全部命中 → 爆炸）

# ── 雷霆（W+U：技能一+上方向，电流覆盖身上，强化全程霸体，强化普攻召唤巨大闪电）──
var thunder_active: bool = false          # 雷霆施法中/强化中（电流覆盖标志）
var thunder_armor: bool = false           # 雷霆强化全程霸体是否开启
var thunder_aura_anim: FrameAnimation = null  # 电流特效动画（sheet_I 12 帧循环）
var lightning: Dictionary = {}            # 巨大闪电区域 {x,y,w,h,timer,dmg_acc}（召唤后独立推进）

# ── 大招·终焉灭相（全屏暗物质光球）──
var ult_play_active: bool = false         # 大招演出中（全屏 overlay 动画）
var ult_anim_obj: FrameAnimation = null   # 全屏动画对象（独立推进，不与 current_anim 共用）
var ult_dot_dealt: int = 0                # 已结算伤害（累计期望取整法精确补满总伤）

# ── 技能二·轮回断绝：施法 → 召唤法阵（增益结界）──
var skill2_active: bool = false   # 技能二演出中
var skill2_stage: int = 0         # 0=无 1=施法中 2=法阵演出中
var matrix_spawned: bool = false  # 法阵是否已召唤（第5帧置 true）
var cast_armor: bool = false      # 施法全程霸体是否开启
var matrix_rect: Rect2 = Rect2()  # 法阵增益区域（宽300 高300，固定位置）
var matrix_timer: int = 0         # 法阵剩余帧数
var in_matrix: bool = false       # 黑法师当前是否在法阵内（增益已应用）
var heal_acc: float = 0.0         # 法阵回血累加器

# ── 普攻·万法归尘：挥杖法力弹飞敌人（3伤命中 + 弹墙：弹到板边撞墙2伤 + 弹回指定位置，全程带击飞）──
var atk_active: bool = false      # 普攻演出中（动画播放中）
var atk_hit_dealt: bool = false   # 首段命中（3伤）是否已判定
var launch_stage: int = 0         # 弹墙状态机：0=无 1=弹飞中 2=弹回中
var launch_dir: int = 1           # 弹飞方向（朝敌人身后板边）
var launch_vy: float = 0.0        # 击飞竖直速度（frozen 锁 vy，手动模拟弹跳）
var hit_x: float = 0.0            # 命中时敌人 x（弹回位置参照）
var launch_dist: float = 0.0      # 飞出距离（命中点→板边），弹回距离 = 飞出距离 × 比例

# ── 待填充：黑法师专属机制字段 ──
# 示例（可删除/改名）：
# var dark_energy: float = 0.0        # 暗能量（机制资源）
# var channel_timer: int = 0          # 持续施法计时
# var skill1_stage: int = 0           # 技能一阶段状态机
# var ult_damage_acc: float = 0.0     # 大招按帧出伤累计（期望值法）

func update():
	# 每帧通用逻辑（动画推进等由角色 update_systems 处理；此处放组件级计时）
	pass

## 受伤前钩子：凛冬状态（有冰棱环绕）被命中 → 消耗 1 个空闲冰棱格挡，
## 只受 30% 伤害（免击退/击飞由 fighter.gd 读 bm_ice_block 标志处理），播放破碎动画。
func on_pre_damage(attacker: Fighter, dmg: float) -> float:
	if owner == null or not is_instance_valid(owner):
		return dmg
	if not (enhanced and crystals_spawned and ult_active):
		return dmg
	for c in crystals:
		if c["state"] == "idle":
			c["state"] = "blocked"
			BlackMageCharacter.play_crystal_break(c["x"], c["y"])
			owner.state_flags["bm_ice_block"] = true
			Fighter.emit_particles(c["x"], c["y"], 20, Color(0.53, 0.87, 1.0), 5, 7, "star", 1.0)
			return dmg * BlackMageCharacter.BLOCK_DAMAGE_RATIO
	return dmg
