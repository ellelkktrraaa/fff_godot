class_name Constants

# Map dimensions
const W := 800
const H := 450
const MAP_W := 2400
const GROUND_Y := 380

# Physics
const GRAVITY := 0.22
const JUMP_SPEED := -10.0
const FRICTION := 0.88

# Fighter size
const FIGHTER_W := 32
const FIGHTER_H := 56

# AI difficulty presets
const AI_PRESETS := {
	"easy": {"react": 600, "aggro": 0.3, "dodge": 0.1, "skill_rate": 0.15, "move_speed": 0.75, "jump_rate": 0.0},
	"medium": {"react": 350, "aggro": 0.5, "dodge": 0.25, "skill_rate": 0.3, "move_speed": 0.9, "jump_rate": 0.02},
	"hard": {"react": 120, "aggro": 0.8, "dodge": 0.4, "skill_rate": 0.6, "move_speed": 1.1, "jump_rate": 0.05},
	"hell": {"react": 42, "aggro": 0.95, "dodge": 0.6, "skill_rate": 0.9, "move_speed": 1.3, "jump_rate": 0.08},  # [HELL-ENHANCE] 地狱基础 think_delay 降 30%（60→42）
}

# AI 警觉（alert）机制 [HELL-ENHANCE]：按威胁等级分层，触发后决策节流临时缩短
const ALERT_DURATION := 54              # 警觉持续 0.9s（0.8~1.0s 取中，60 帧 = 1 秒）
const ALERT_LEVEL_HIT := 1              # 威胁等级：贴身受击（最紧急）
const ALERT_LEVEL_IMPACT := 2           # 威胁等级：攻击判定将命中（预警触发）
const ALERT_LEVEL_WINDUP := 3           # 威胁等级：玩家起手（前摇早期，最慢）
const ALERT_DELAY_HIT_MIN := 1          # 受击反应：1~2 帧（被打了要立刻动）
const ALERT_DELAY_HIT_MAX := 2
const ALERT_DELAY_IMPACT_MIN := 3       # 判定将命中反应：3~4 帧（看到刀来了才躲）
const ALERT_DELAY_IMPACT_MAX := 4
const ALERT_DELAY_WINDUP_MIN := 5       # 玩家起手反应：5~8 帧（能看到起手，非极限反应）
const ALERT_DELAY_WINDUP_MAX := 8
const ALERT_IMPACT_WINDOW := 12         # 预警窗口：玩家攻击判定前 ≤12 帧（10~12 帧预警）
const ALERT_IMPACT_MARGIN := 30.0       # 预警扩展边距（px，≈12 帧 × AI 逼近速度估计）

# 难度等级排序（用于比较和"不低于 hard"的判定）
const DIFFICULTY_LEVELS := ["easy", "medium", "hard", "hell"]

# 判断当前难度是否不低于指定难度
static func difficulty_at_least(diff: String, threshold: String) -> bool:
	var di = DIFFICULTY_LEVELS.find(diff)
	var ti = DIFFICULTY_LEVELS.find(threshold)
	if di < 0 or ti < 0:
		return false
	return di >= ti