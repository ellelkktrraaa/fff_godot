class_name BardComponent
extends CharComponent

var perform_active: bool = false
var was_down_pressed: bool = false
var last_down_press_frame: int = -999
var _was_perform_active: bool = false  # 状态变化检测（音频播放/停止）

# 音符命中特效追踪
var _tracked_note: Dictionary = {}
var _tracked_hit_img = null
var _tracked_note_damage: float = 0.0
var _tracked_note_id: String = ""

# 忧伤的纷争：收集系统
var _collected_notes: Array = []        # 已收集的音符类型 ["whole","half",...]
var _confusion_timer: int = 0           # 紊乱倒计时
var _confusion_active: bool = false     # 敌人是否处于紊乱
var _confused_enemy = null     # 被紊乱的敌人

# 技能1：我含泪而笑
var skill1_active: bool = false        # 技能1是否正在释放
var skill1_wave_index: int = 0         # 当前波次索引 (0,1,2)
var skill1_wave_timer: int = 0         # 距下一波剩余帧数
var skill1_hits: int = 0               # 技能1声波命中次数
var _skill1_tracked_waves: Array = []  # 跟踪的声波弹射物引用

# 技能2：月相盈亏 — 领域
var skill2_active: bool = false
var domain_type: String = ""  # "waxing" 月盈 or "waning" 月亏
var domain_x: float = 0.0
var domain_y: float = 0.0
var domain_center_x: float = 0.0  # 领域圆心（世界坐标）
var domain_center_y: float = 0.0
var domain_radius: float = 200.0
var domain_timer: int = 0
var domain_img = null
var domain_color: Color = Color.GOLD
var domain_cd_applied: bool = false  # 2s CD reduction applied
var domain_enemy_debuffed: bool = false  # 敌人 debuff 已应用
var domain_def_applied: bool = false  # 领域防御加成已应用
var _domain_projectile: Dictionary = {}  # 领域贴图弹射物引用

# 大招：胜过天上的星辰
var ult_active: bool = false
var ult_timer: int = 0
var ult_damage_acc: float = 0.0  # 出伤累加器
var ult_anim_obj = null  # 大招覆盖动画引用

# 彩蛋显示
var easter_egg_text: String = ""
var easter_egg_timer: int = 0

## 受击退出演奏（灼烧等持续伤害走 status_effect 直接扣血，不会触发此回调）
func on_damage_received(_attacker: Fighter, _dmg: float):
	perform_active = false
