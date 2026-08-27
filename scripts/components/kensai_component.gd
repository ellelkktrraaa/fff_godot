# 剑豪组件：千峰破云连招记录 + 技能运行状态
# 千峰破云：记录最近2次普攻（1=一式 2=二式 3=三式），常驻显示，新的替换旧的
class_name KensaiComponent
extends CharComponent

var combo_seq: Array = []   # 最近普攻序列（千峰破云：常驻保留最近2次，如 [2, 1]）
var atk_hit_flags: Array = []  # 最近2次普攻是否命中敌人（与 combo_seq 一一对应）
var attack_cd: Dictionary = {}   # 三式普攻独立冷却 {1: 剩余帧, 2: ..., 3: ...}
const COMBO_UNLOCK_WINDOW := 300  # 解锁技能（21/31）释放窗口：5 秒（60fps）
var combo_expire_timer: int = -1  # 解锁技能释放窗口剩余帧；-1 = 无窗口（大招 23/32 不受限）

var atk1_swing: int = 0          # 一式·踏月逐风斩两段挥刀：0=空闲 1=第一刀 2=第二刀
var atk1_plunge_active: bool = false  # 一式空中坠击进行中
var atk1_slash_active: bool = false   # 一式普攻1刀光特效活跃
var atk1_slash_anim = null            # 一式普攻1刀光动画（懒加载）
var atk1_last_hit_frame: int = -1     # 一式普攻1按帧出伤：最近已判定帧索引（-1=未判定）
var atk1_frame_active: bool = false   # 一式普攻1按帧出伤活跃（地面三连挥刀）

var slash_active: bool = false       # 二式·九霄断水吟大范围判定进行中
var slash_hit_timer: int = 0
var slash_damage_dealt: bool = false

var atk3_stage: int = 0        # 三式·云龙贯霄刺：0=空闲 1=前突 2=间隔 3=回身斜上突
var atk3_timer: int = 0
var atk3_air: bool = false     # 空中释放 → 交换两段突进方向
var atk3_dmg1_dealt: bool = false
var atk3_dmg2_dealt: bool = false

var skill1_active: bool = false   # 玄鸟衔月闪（O·31 二技能）进行中
var skill1_stage: int = 0         # 玄鸟衔月闪阶段：0=无 1=抓取 2=斩击
var skill1_dmg_dealt: bool = false      # 抓取伤害（5）是否已出
var skill1_slash_dmg_dealt: bool = false  # 斩击伤害（10）是否已出
var skill1_grabbed: bool = false      # 玄鸟衔月闪本次抓取是否成功（未命中则跳过斩击段）
var skill1_grab_pos_x: float = 0.0  # 玄鸟衔月闪抓取定身 x（敌人中心，抓取段每帧 hold 定身）
var skill1_anim = null            # 玄鸟衔月闪动画（懒加载，帧1~18）
var qflh_active: bool = false     # 千枫落华斩（O·21 一技能）进行中（剑豪消失+全屏刀光）
var qflh_windup_active: bool = false  # 千枫落华斩起手（sheet.png 前6帧）：技能体、无无敌，可被打断
var qflh_windup_timer: int = 0        # 起手计时（到 QFLH_WINDUP_FRAMES 进入全屏斩击）
var qflh_anim = null              # 千枫落华斩刀光动画（6x6 36帧）
var qflh_damage_acc: float = 0.0   # 千枫落华斩按帧出伤：每动画帧累计伤害（floor 取整出伤）
var qflh_last_frame: int = -1      # 千枫落华斩最近已累计伤害的动画帧索引（-1=未开始）
var ult_active: bool = false      # 无想一刀

# 普攻起手（sheet.png 前5帧）：每次普攻前先播放拔刀起手，播完再执行招式
var windup_active: bool = false
var windup_timer: int = 0
var windup_attack: int = 0        # 起手结束后要执行的招式（1/2/3）
var windup_air: bool = false      # 空中普攻1起手：只播前2帧（12帧）就进入招式

# 特殊机制1：乘岚斩霞（拔刀蓄力）
var stance_active: bool = false     # 蓄力架势中（长按 S）
var was_down_pressed: bool = false  # S/↓ 按键边缘检测
var attack_buff: bool = false       # 蓄力中释放的本次攻击正在享受 +30% 强化
var stance_hits_taken: int = 0      # 本次蓄力已承受的伤害次数
var stance_armor_broken: bool = false  # 本次蓄力霸体是否已被破（受 2 次伤害后变普攻体）
var ult_damage_dealt: bool = false   # 孤鸿踏雪是否已出瞬间伤（output_0027 帧 30 伤）
var ult_dot_last_frame: int = -1     # 孤鸿踏雪持续出伤：最近已判定动画帧（output_0028~0050 按帧累计）
var ult_dot_acc: float = 0.0         # 孤鸿踏雪持续出伤累计（期望值法，避免浮点累计误差）
var ult_anim_obj = null
var qflh_origin_x: float = 0.0       # 千枫落华斩释放瞬间 x（判定中心快照）
var qflh_origin_y: float = 0.0

## 记录一次普攻，推进连招序列（千峰破云：常驻保留最近2次，新的替换旧的）
func record_attack(atk_id: int):
	combo_seq.append(atk_id)
	atk_hit_flags.append(false)
	if combo_seq.size() > 2:
		combo_seq.pop_front()
		atk_hit_flags.pop_front()
	# 解锁技能（21/31，不含大招 23/32）：开启 5 秒释放窗口（黄条）；非技能组合无窗口
	var key := combo_key()
	if key == "21" or key == "31":
		combo_expire_timer = COMBO_UNLOCK_WINDOW
	else:
		combo_expire_timer = -1

## 标记最近一次普攻命中敌人（供玄鸟衔月闪判断：前两次普攻任意命中 → 瞬移身后释放）
func mark_attack_hit():
	if not atk_hit_flags.is_empty():
		atk_hit_flags[-1] = true

## 当前连招序列字符串："12" / "21" 等（千峰破云组合）
func combo_key() -> String:
	var s := ""
	for v in combo_seq:
		s += str(v)
	return s

func update():
	# 三式普攻独立冷却计时
	var expired := []
	for k in attack_cd.keys():
		attack_cd[k] -= 1
		if attack_cd[k] <= 0:
			expired.append(k)
	for k in expired:
		attack_cd.erase(k)

## 受击：乘岚斩霞霸体期间只格挡 1 次伤害（挡后霸体立刻结束，变普攻体）；否则照常打断
func on_damage_received(_attacker: Fighter, _dmg: float):
	if stance_active and not stance_armor_broken:
		# 霸体：只能格挡 1 次伤害，受击后霸体立刻结束（变普攻体，下次受击即被打断）
		stance_hits_taken += 1
		stance_armor_broken = true
		return
	stance_active = false
	windup_active = false
	windup_timer = 0
	windup_attack = 0
	windup_air = false
	atk1_slash_active = false
	atk1_frame_active = false
	atk1_last_hit_frame = -1
	# 千枫落华斩起手被打断：清理（起手阶段技能体、无无敌，被打断则取消技能）
	if qflh_windup_active:
		qflh_windup_active = false
		qflh_windup_timer = 0
	# 玄鸟衔月闪被高优先级技能打断：清理技能状态（防止 skill1_active 残留导致锁移动）
	if skill1_active or skill1_stage != 0:
		skill1_active = false
		skill1_stage = 0
		if skill1_anim:
			skill1_anim.stop()
		# 解除敌人抓取冻结（防止打断后敌人长时间不可操作）
		var e = GameWorld.get_opponent(owner) if owner else null
		if e:
			e.statuses = e.statuses.filter(func(s): return s.id != "frozen")
