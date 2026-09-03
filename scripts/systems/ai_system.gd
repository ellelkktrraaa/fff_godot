class_name AISystem

# ===== AI System =====
# FSM显式状态变量
static var _state: String = "IDLE"

# 闪避全局冷却（帧）
static var _dodge_cooldown: int = 0

# ── Alert（警觉）机制 [HELL-ENHANCE]：受击 / 攻击判定将命中 / 玩家起手时按威胁等级临时缩短决策节流 ──
static var _alert: bool = false
static var _alert_level: int = 0      # 威胁等级：ALERT_LEVEL_HIT(1) / IMPACT(2) / WINDUP(3)
static var _alert_timer: int = 0
static var _alert_owner: Fighter = null   # 警觉所属 fighter，换人（重开/换敌）时重置
static var _alert_last_hp: float = -1.0
static var _just_hit := false             # 本帧是否被攻击命中（由 _update_alert 设置）

# ── PRESS（主动压迫）机制 [HELL-ENHANCE] ──
static var _press_retreat_timer: int = 0  # 压迫中断后的撤退/防御锁（帧），期间不重新压迫

# ── 14 角色专属连招表 [HELL-ENHANCE] ──
## 结构：char_id → { 触发事件 → [连招动作序列] }
## 触发事件 key：attack_hit / skill1_hit / skill2_hit / ult_hit / dodge_success /
##   block_success / 角色机制事件（combo_ready_XX、stealth_break、trap_trigger 等，
##   由角色脚本 ai_tactics/组件状态推进，AI 侧队列暂不主动检测）
## 连招动作为角色机制名，经 COMBO_ACTION_MAP 映射执行；能量/冷却/状态不足时
## 跳过该段继续下一段（不中断整个连招）；目标死亡或距离拉开则清空队列。
const COMBO_TABLE := {
	# ── 剑豪：三式滚窗口 + 组合技（千峰破云，由角色脚本 ai_tactics 完整处理）──
	"kensai": {
		"attack_hit":   ["attack2", "attack3"],
		"combo_ready_21": ["skill1"],
		"combo_ready_31": ["skill2"],
		"combo_ready_23": ["ult"],
		"combo_ready_32": ["ult"],
		"stance_break": ["attack1"],
	},
	# ── 骑士：招架反击流 ──
	"knight": {
		"block_success": ["counter", "skill1"],
		"attack_hit":   ["skill1_charge", "skill2"],
	},
	# ── 刺客：影姿态度闪反打 ──
	"assassin": {
		"dodge_success": ["enhanced_slash"],
		"attack_hit":   ["skill2", "ult"],
		"skill2_hit":   ["ult"],
	},
	# ── 弓手：火矢追踪压制 ──
	"archer": {
		"attack_hit":   ["charging_attack"],
		"fire_arrow_hit": ["tracking_shot", "charging_attack"],
	},
	# ── 法师：冰火连携 ──
	"mage": {
		"attack_hit":   ["ice", "fire"],
		"ice_hit":      ["fire"],
	},
	# ── 吟游诗人：音符渐强连奏 ──
	"bard": {
		"attack_hit":   ["perform"],
		"note_hit":     ["note_half", "note_quarter"],
	},
	# ── 龙骑士：龙形态爆发 ──
	"dragon_knight": {
		"attack_hit":   ["flight", "skill2"],
		"skill2_hit":   ["dragon_form", "burn", "ult"],
	},
	# ── 唤魔者：召唤物协同围殴 ──
	"evoker": {
		"summon_hit":   ["attack"],
		"attack_hit":   ["void_rift", "fire_sea"],
	},
	# ── 死灵骑士：骑马冲锋连段 ──
	"necro_knight": {
		"attack_hit":   ["mount", "mounted_charge"],
		"mounted_attack_hit": ["skill1"],
	},
	# ── 圣骑士：圣盾反打 ──
	"paladin": {
		"block_success": ["holy_empower", "counter"],
		"attack_hit":   ["charging_skill1"],
	},
	# ── 玫瑰：血渊爆发链 ──
	"rose": {
		"attack_hit":   ["skill2_enhanced"],
		"skill2_enhanced_hit": ["ult"],
	},
	# ── 暗影武士：隐身居合+陷阱 ──
	"shadowwarrior": {
		"stealth_break": ["iaido_slash"],
		"attack_hit":   ["shadow_trap"],
		"trap_trigger": ["break_strike", "ult"],
	},
	# ── 女巫：龙卷风漩涡连携 ──
	"witch": {
		"attack_hit":   ["tornado"],
		"tornado_hit":  ["vortex", "ult"],
	},
	# ── 占星师：抽卡增幅 ──
	"astrologer": {
		"card_atk":     ["attack", "attack"],
		"attack_hit":   ["skill2_element"],
	},
}
## 连招动作名 → 执行方式（技能 key / "attack" 普攻；未映射的动作 → 跳过该段继续下一段）
const COMBO_ACTION_MAP := {
	"attack1": "attack", "attack2": "attack", "attack3": "attack",
	"counter": "attack", "enhanced_slash": "attack", "iaido_slash": "attack",
	"break_strike": "attack", "mounted_charge": "attack", "charging_attack": "attack",
	"skill1_charge": "skill1", "charging_skill1": "skill1",
	"ice": "skill1", "fire": "attack", "perform": "skill1",
	"note_half": "skill1", "note_quarter": "skill1",
	"flight": "attack", "dragon_form": "ult", "burn": "skill2",
	"void_rift": "ult", "fire_sea": "attack",
	"mount": "skill1", "holy_empower": "skill2",
	"skill2_enhanced": "skill2", "skill2_element": "skill2",
	"shadow_trap": "skill1", "tornado": "skill1", "vortex": "skill2",
	"tracking_shot": "skill2",
	"fire_arrow": "skill1", "shadow_stance": "attack", "card": "skill1",
	"elemental": "skill2", "note": "skill1", "parry": "skill2",
	"half_moon": "skill1", "shield": "skill2", "stealth": "skill1",
	"combo_window": "attack", "stance": "attack",
}
const COMBO_QUEUE_MAX := 3            # 队列最大长度（防无限连锁死）

# ── 角色专属战术配置 [AI-ENHANCE] ──
## 每角色：style 行为风格 / fav_dist 偏好距离 / aggro 攻击性（风格因子）/ skill_priority 技能优先级
## 决策时（PRESS/CHASE/DEFEND/技能选择）按角色查表生效；style 行为规则见各 style 分支
const TACTICS_PROFILE := {
	"archer":   {"style": "kite",    "fav_dist": 220, "aggro": 0.4, "skill_priority": ["charging_attack", "fire_arrow", "tracking_shot"]},
	"assassin": {"style": "rush",    "fav_dist": 80,  "aggro": 0.8, "skill_priority": ["shadow_stance", "enhanced_slash", "ult"]},
	"astrologer": {"style": "adapt", "fav_dist": 160, "aggro": 0.6, "skill_priority": ["card", "elemental"]},
	"bard":     {"style": "kite",    "fav_dist": 180, "aggro": 0.5, "skill_priority": ["perform", "note"]},
	"dragon_knight": {"style": "rush", "fav_dist": 110, "aggro": 0.7, "skill_priority": ["flight", "burn", "dragon_form", "ult"]},
	"evoker":   {"style": "summon",  "fav_dist": 170, "aggro": 0.6, "skill_priority": ["summon", "void_rift", "fire_sea"]},
	"knight":   {"style": "counter", "fav_dist": 90,  "aggro": 0.5, "skill_priority": ["parry", "half_moon", "skill2"]},
	"mage":     {"style": "control", "fav_dist": 200, "aggro": 0.5, "skill_priority": ["ice", "fire", "ult"]},
	"necro_knight": {"style": "charge", "fav_dist": 130, "aggro": 0.7, "skill_priority": ["mount", "mounted_charge", "skill1"]},
	"paladin":  {"style": "tank",    "fav_dist": 100, "aggro": 0.5, "skill_priority": ["shield", "holy_empower", "charging_skill1"]},
	"rose":     {"style": "burst",   "fav_dist": 120, "aggro": 0.65, "skill_priority": ["skill2_enhanced", "ult"]},
	"shadowwarrior": {"style": "assassin", "fav_dist": 70, "aggro": 0.75, "skill_priority": ["stealth", "iaido", "shadow_trap", "ult"]},
	"witch":    {"style": "fly",     "fav_dist": 190, "aggro": 0.6, "skill_priority": ["tornado", "vortex", "ult"]},
	"kensai":   {"style": "combo",   "fav_dist": 100, "aggro": 0.8, "skill_priority": ["combo_window", "stance"]},
}
static var _combo_queue: Array = []           # 待执行连招序列
static var _combo_owner: Fighter = null       # combo 所属 fighter（换人即清空）
static var _last_used_skill_key: String = ""  # AI 最近使用的招式 key
static var _last_ai_attack_hit: bool = false  # 上一帧 AI 攻击判定是否已出（命中注册用）
static var _combo_last_player_hp: float = -1.0  # 玩家 hp 追踪（AI 命中检测用）
static var _combo_was_dashing := false        # 上一帧 AI 是否在闪避（dodge_success 转变检测）
static var _combo_was_blocking := false       # 上一帧 AI 是否在防御（block_success 转变检测）
static var _combo_hit_streak: int = 0         # 连续命中次数（combo 收段骗招判定）

# ── 战术模式切换 / 随机扰动 / 背板对抗 [AI-ENHANCE] ──
static var _tactical_mode: int = 0       # 0=正常 1=激进 2=稳健
static var _mode_timer: int = 240        # 下次切换评估剩余帧（3~5 秒）
static var _mode_switches: int = 0       # 本局已切换次数（≤3，避免精分）
static var _mode_pause: int = 0          # 切换时思考停顿帧（1 帧不行动）
static var _skill_streak: int = 0        # 连续使用同一技能次数（背板对抗：≥3 强制换招）
static var _skill_streak_key: String = ""

# ── 状态应对（5.3）[HELL-ENHANCE] ──
static var _cc_flee_timer: int = 0   # 冰冻/减速解除后远离玩家位移计时（帧）
static var _had_cc := false          # 上一帧是否处于冰冻/减速（用于检测"刚解除"）

# 物理常量（引用 TrackSystem）
const GRAVITY := 0.22
const JUMP_VY := 10.0
const PRESS_SPEED_MULT := 1.25            # PRESS 压迫推进速度倍率（1.2~1.3 取中值）

# ── Alert 触发与衰减 [HELL-ENHANCE] ──
## 每帧更新警觉（按威胁等级分层，越紧急反应越快）：
##   受击（hp 下降）→ ALERT_LEVEL_HIT（1~2 帧）
##   玩家攻击判定将命中（判定前 ≤12 帧预警）→ ALERT_LEVEL_IMPACT（3~4 帧）
##   玩家起手（前摇早期）→ ALERT_LEVEL_WINDUP（5~8 帧）
## 未再触发时按帧衰减，ALERT_DURATION 后恢复 false，回到正常 think_delay。
static func _update_alert(f: Fighter) -> void:
	# 换 fighter（新对局/换敌）时重置警觉状态
	if _alert_owner != f:
		_alert_owner = f
		_alert_last_hp = f.hp
		_alert = false
		_alert_level = 0
		_alert_timer = 0
		_just_hit = false
	# 触发条件 1：自身受击（hp 下降）→ 最紧急
	var hit_this_frame := f.hp < _alert_last_hp
	_just_hit = hit_this_frame
	_alert_last_hp = f.hp
	var player = GameWorld.player
	var triggered := false
	var level := 0
	if hit_this_frame:
		triggered = true
		level = Constants.ALERT_LEVEL_HIT
	elif player and player.hp > 0 and player.attacking:
		# 触发条件 2：攻击判定将命中（命中前 10~12 帧预警）→ 快速
		if player.attack_delay > 0 and player.attack_delay <= Constants.ALERT_IMPACT_WINDOW \
				and _attack_box_threatens(player, f, Constants.ALERT_IMPACT_MARGIN):
			triggered = true
			level = Constants.ALERT_LEVEL_IMPACT
		# 触发条件 3：玩家起手（前摇早期，判定未进入预警窗口）→ 中等
		elif _player_windup(player, f):
			triggered = true
			level = Constants.ALERT_LEVEL_WINDUP
	if triggered:
		_alert = true
		_alert_level = level
		_alert_timer = Constants.ALERT_DURATION
	elif _alert_timer > 0:
		_alert_timer -= 1
		if _alert_timer == 0:
			_alert = false
			_alert_level = 0

## 玩家攻击判定框是否已/即将覆盖 AI 命中框（margin_px 为预警提前量扩展边距）
static func _attack_box_threatens(player: Fighter, f: Fighter, margin_px: float) -> bool:
	var ab: Rect2 = player.get_attack_box()
	var hb: Rect2 = f.get_hit_box()
	# y 方向无重叠 → 打不到（高度/平台不同）
	if ab.position.y + ab.size.y <= hb.position.y or ab.position.y >= hb.position.y + hb.size.y:
		return false
	# 仅威胁攻击框前方目标（背后不预警）
	if player.facing > 0:
		if f.pos_x + f.w <= player.pos_x + player.w / 2.0:
			return false
		return hb.position.x < ab.position.x + ab.size.x + margin_px
	else:
		if f.pos_x >= player.pos_x + player.w / 2.0:
			return false
		return hb.position.x + hb.size.x > ab.position.x - margin_px

## 玩家起手（前摇早期，攻击判定未进入预警窗口）且距离在玩家攻击范围内
static func _player_windup(player: Fighter, f: Fighter) -> bool:
	if player.attack_delay <= Constants.ALERT_IMPACT_WINDOW:
		return false  # 已进入预警窗口，交由 ALERT_LEVEL_IMPACT 处理
	var pdist := absf(player.pos_x - f.pos_x)
	return pdist < player.attack_range * 1.5

# ── PRESS（主动压迫）机制 ──

## 尝试进入 / 维持 PRESS 状态。
## 返回 true = 本帧已由 PRESS 处理（压迫或退出动作）；false = 交给被动优先级链。
## 难度门控（地狱高优先级 / 其他偶尔）由调用方控制，本函数只处理状态与距离条件。
static func _try_press(f, target, dist, diff) -> bool:
	# 撤退/防御锁：压迫中断后一段时间内不立即重新压迫
	if _press_retreat_timer > 0:
		_press_retreat_timer -= 1
		return false
	# 已在压迫中：优先检查退出条件
	if _state == "PRESS":
		# 退出 1：距离拉远（> attack_range × 1.3）→ 回 CHASE
		if dist > f.attack_range * 1.3:
			_state = "CHASE"
			return false
		# 退出 2：玩家正在反击（攻击帧 + 距离 ≤ attack_range）→ DEFEND/DODGE
		var player = GameWorld.player
		if player and player.hp > 0 and player.attacking and dist <= f.attack_range:
			_press_retreat(f, target, dist, diff)
			return true
		# 退出 3：本帧被攻击命中 → 中断压迫进入 DEFEND/DODGE
		if _just_hit:
			_press_retreat(f, target, dist, diff)
			return true
		# 持续压迫连打
		_do_press(f, target, dist, diff)
		return true
	# 进入条件：距离 ≤ attack_range 且攻击可用（非冷却）
	if dist > f.attack_range or not _attack_ready(f):
		return false
	_do_press(f, target, dist, diff)
	return true


## PRESS 行为：持续贴脸推进不后退；出招交给 _press_next_action（combo 优先）
static func _do_press(f, target, dist, diff) -> void:
	var tx = target["x"] if target is Dictionary else target.pos_x
	var dir = 1 if tx > f.pos_x else -1
	f.facing = dir
	# 持续贴脸推进（move_speed × 1.25），攻击间隙不后退
	f.vx = dir * diff["move_speed"] * PRESS_SPEED_MULT
	_press_next_action(f, dir)
	_state = "PRESS"
	_update_state(f, dir)


## PRESS 下一招决策 [HELL-ENHANCE]：
##   1. combo_queue 非空 → 从头遍历执行：跳过不可用段（能量/冷却/状态不足），
##      执行第一个可用段（不穿插其他技能）；目标死亡或距离拉开则清空队列；
##      连击命中≥2 后 30% 概率只打一段就收（骗玩家防御后反打）[AI-ENHANCE]
##   2. 队列空 → 按角色 skill_priority 选技能（attack 兜底）；背板≥3 强制换招；15% 次优
static func _press_next_action(f, dir: int) -> void:
	if not _combo_queue.is_empty():
		var player = GameWorld.player
		# 每招执行前校验：目标仍存活且距离未拉开（≤ attack_range × 1.5），否则清空（不许隔空连招）
		if player == null or player.hp <= 0 or absf(player.pos_x - f.pos_x) > f.attack_range * 1.5:
			_combo_queue.clear()
			_combo_hit_streak = 0
			return
		# 7.3 combo 收段：上两次都命中后，第三次 30% 概率只打一段就收 [AI-ENHANCE]
		var shorten: bool = _combo_hit_streak >= 2 and randf() < 0.3
		# 遍历队列：跳过不可用段继续下一段，执行第一个可用段
		while not _combo_queue.is_empty():
			var action: String = _combo_queue[0]
			_combo_queue.pop_front()
			if _exec_combo_action(f, dir, action):
				if shorten:
					_combo_queue.clear()  # 只打一段收手
					_combo_hit_streak = 0
				return  # 本帧已出招，剩余队列下帧继续
		return
	# 基础循环：按角色 skill_priority 选技能（attack 兜底）
	var used := false
	var priority: Array = _get_skill_priority(f)
	for act in priority:
		var exec := str(act)
		if exec not in ["skill1", "skill2", "ult"]:
			exec = str(COMBO_ACTION_MAP.get(exec, ""))
		if exec == "" or exec == "attack":
			continue
		# 背板对抗 [AI-ENHANCE]：连续 3 次同技能 → 强制换招
		if _skill_streak >= 3 and exec == _skill_streak_key:
			continue
		# 7.1 次优扰动 [AI-ENHANCE]：15% 概率跳过当前最优技能
		if _roll_suboptimal():
			continue
		var sk = f.get_skill(exec)
		if sk and sk.can_use(f):
			f.facing = dir
			sk.try_use(f)
			_last_used_skill_key = exec
			_record_skill_use(exec)
			used = true
			break
	if not used and f.attack_cooldown <= 0 and not f.attacking:
		_exec_ai_attack(f, dir)
		_last_used_skill_key = "attack"
		_record_skill_use("attack")


## 通用普攻执行：assassin 优先用注册的 attack skill，其他直接 attacking
static func _exec_ai_attack(f, dir: int) -> void:
	f.facing = dir
	var atk = f.get_skill("attack")
	if atk and atk.can_use(f):
		atk.try_use(f)
	else:
		f.attacking = true
		f.attack_timer = 30
		f.attack_delay = 8
		f.attack_hit_dealt = false
		f.attack_cooldown = 60
		f.state = "attack"


## 连招事件检测 [HELL-ENHANCE]：命中类（attack/skillX 命中玩家）+ 闪避/防御成功
## 命中判定：AI 攻击判定刚发生（attack_hit_dealt 由 false→true）且玩家 hp 下降
static func _update_combo_event(f) -> void:
	if _combo_owner != f:
		_combo_owner = f
		_combo_queue.clear()
		_last_used_skill_key = ""
		_last_ai_attack_hit = false
		_combo_was_dashing = false
		_combo_was_blocking = false
		_combo_last_player_hp = GameWorld.player.hp if GameWorld.player else -1.0
	var player = GameWorld.player
	# 命中类事件：attack_hit / skill1_hit / skill2_hit / ult_hit
	var ai_just_hit: bool = f.attacking and f.attack_hit_dealt and not _last_ai_attack_hit
	_last_ai_attack_hit = f.attack_hit_dealt
	if ai_just_hit and player and player.hp > 0 and player.hp < _combo_last_player_hp:
		var key := _last_used_skill_key
		if key == "":
			key = "attack"
		var event := "attack_hit"
		if key in ["skill1", "skill2", "ult"]:
			event = key + "_hit"
		_combo_hit_streak += 1  # 连续命中计数（7.3 combo 收段判定）
		_enqueue_combo(f, event)
	_combo_last_player_hp = player.hp if player else _combo_last_player_hp
	# 闪避成功（dashing 刚启动）→ dodge_success
	var now_dashing: bool = f.dashing
	if now_dashing and not _combo_was_dashing:
		_enqueue_combo(f, "dodge_success")
	_combo_was_dashing = now_dashing
	# 防御成功（blocking/护盾刚启动）→ block_success
	var now_blocking: bool = f.blocking or f.shield_active
	if now_blocking and not _combo_was_blocking:
		_enqueue_combo(f, "block_success")
	_combo_was_blocking = now_blocking


## 按角色查表入队连招（队列非空不叠加；专属 AI 战术角色如剑豪由角色脚本管连招）
static func _enqueue_combo(f, event: String) -> void:
	if _combo_queue.size() > 0:
		return
	if CharacterFactory.has_ai_tactics(f.char_id):
		return
	var char_table: Dictionary = COMBO_TABLE.get(f.char_id, {})
	var seq: Array = char_table.get(event, [])
	for action in seq:
		if _combo_queue.size() >= COMBO_QUEUE_MAX:
			break
		_combo_queue.append(action)


## 执行单个连招动作（经 COMBO_ACTION_MAP 映射）。
## 返回 true = 本帧已出招；false = 动作不可用/未映射（调用方跳过该段继续下一段）
static func _exec_combo_action(f, dir: int, action: String) -> bool:
	var exec := action
	if exec not in ["attack", "skill1", "skill2", "ult"]:
		exec = COMBO_ACTION_MAP.get(action, "")
		if exec == "":
			return false  # 未映射 → 跳过该段
	match exec:
		"attack":
			if f.attack_cooldown <= 0 and not f.attacking:
				_exec_ai_attack(f, dir)
				_last_used_skill_key = "attack"
				return true
		"skill1", "skill2", "ult":
			var sk = f.get_skill(exec)
			if sk and sk.can_use(f):
				f.facing = dir
				sk.try_use(f)
				_last_used_skill_key = exec
				return true
	return false  # 能量/冷却/状态不足 → 跳过该段继续下一段


## 压迫中断：优先开技能防御，否则后撤闪避
static func _press_retreat(f, target, dist, diff) -> void:
	_press_retreat_timer = 30   # 0.5s 撤退/防御锁，避免下一帧被 PRESS 立即覆盖
	var tx = target["x"] if target is Dictionary else target.pos_x
	var dir = 1 if tx > f.pos_x else -1
	var skill2 = f.get_skill("skill2")
	if skill2 and skill2.can_use(f):
		f.facing = -dir
		skill2.try_use(f)
		_state = "DEFEND"
	else:
		f.facing = -dir
		f.dashing = true
		f.dash_dir = -dir
		f.dash_remaining = 15
		f.dash_speed = diff["move_speed"] * 5.0
		_dodge_cooldown = 120
		_state = "DODGE"


## 攻击是否可用：普攻非冷却，或任一技能可释放
static func _attack_ready(f) -> bool:
	if f.attack_cooldown <= 0:
		return true
	for sk in f.skills:
		if sk.key in ["skill1", "skill2"] and sk.can_use(f):
			return true
	return false

# ── 角色专属战术 + 随机扰动辅助 [AI-ENHANCE] ──

## 角色行为风格（无配置角色按近战/远程默认）
static func _get_style(f) -> String:
	var prof: Dictionary = TACTICS_PROFILE.get(f.char_id, {})
	if not prof.is_empty():
		return str(prof.get("style", ""))
	return "rush" if _is_melee(f) else "kite"

## 角色偏好距离
static func _get_fav_dist(f) -> float:
	var prof: Dictionary = TACTICS_PROFILE.get(f.char_id, {})
	return float(prof.get("fav_dist", 150.0))

## 角色技能优先级（PRESS 基础循环按此选技能）
static func _get_skill_priority(f) -> Array:
	var prof: Dictionary = TACTICS_PROFILE.get(f.char_id, {})
	return prof.get("skill_priority", [])

## 当前攻击性：难度基础 × 风格因子（各半）× 模式修正（激进×1.3 / 稳健×0.7）
static func _eff_aggro(f, diff) -> float:
	var prof: Dictionary = TACTICS_PROFILE.get(f.char_id, {})
	var style_aggro: float = float(prof.get("aggro", 0.6))
	var eff: float = lerpf(float(diff["aggro"]), style_aggro, 0.5)
	if _tactical_mode == 1:
		eff *= 1.3
	elif _tactical_mode == 2:
		eff *= 0.7
	return clampf(eff, 0.05, 1.0)

## 战术模式切换：每 3~5 秒随机 20% 概率切换激进/稳健；每局 ≤3 次；切换时 1 帧思考停顿
static func _update_tactical_mode() -> void:
	if _mode_timer > 0:
		_mode_timer -= 1
		return
	_mode_timer = 180 + randi() % 121  # 3~5 秒
	if _mode_switches >= 3 or randf() > 0.2:
		return
	_tactical_mode = 1 if _tactical_mode != 1 else 2
	_mode_switches += 1
	_mode_pause = 1  # 思考停顿 1 帧（暗示转变）

## 背板对抗：记录技能连续使用次数（≥3 下次决策强制换招）
static func _record_skill_use(key: String) -> void:
	if key == "":
		return
	if key == _skill_streak_key:
		_skill_streak += 1
	else:
		_skill_streak_key = key
		_skill_streak = 1

## 15% 概率选「次优选项」（防背板；easy 仅 5%，地狱 20%）
static func _roll_suboptimal() -> bool:
	var p := 0.15
	var diff_name := GameWorld.effective_ai_difficulty()
	if diff_name == "easy":
		p = 0.05
	elif diff_name == "hell":
		p = 0.2
	return randf() < p

# ── 主入口（每帧执行） ──
static func update_ai(ai_think_delay: int) -> int:
	if GameWorld.game_mode == "pvp" or GameWorld.enemy.hp <= 0:
		return ai_think_delay
	# 练习模式：默认敌人不受 AI 控制（静止）；开启"敌人攻击"开关后才由地狱 AI 操控
	if GameWorld.practice_mode and not GameWorld.practice_enemy_ai:
		return ai_think_delay
	var f = GameWorld.enemy
	
	# Frozen check
	if f.has_status("frozen"):
		_state = "IDLE"
		return ai_think_delay
	
	# Hit stun check
	if f.hit_cooldown > 0:
		_state = "IDLE"
		return ai_think_delay
	
	var diff = Constants.AI_PRESETS.get(GameWorld.effective_ai_difficulty(), Constants.AI_PRESETS["medium"])
	# Boss Modifier AI 增量：对 preset 副本做增量覆盖（不改难度字符串，地狱专属战术照常生效）。
	# 只在副本上合并，绝不污染 Constants.AI_PRESETS 全局预设。
	if GameWorld.enemy and not GameWorld.enemy.ai_overrides.is_empty():
		diff = diff.duplicate()
		for k in GameWorld.enemy.ai_overrides:
			diff[k] = GameWorld.enemy.ai_overrides[k]

	# ── 7.2 战术模式切换 [AI-ENHANCE]：每 3~5 秒 20% 概率切激进/稳健；切换时 1 帧思考停顿 ──
	_update_tactical_mode()
	if _mode_pause > 0:
		_mode_pause -= 1
		return ai_think_delay

	# Phantom target selection — AI prefers nearest alive phantom
	var target = GameWorld.player
	if GameWorld.phantoms.size() > 0:
		var nearest = null
		var nd = INF
		for ph in GameWorld.phantoms:
			if not ph or ph.hp <= 0:
				continue
			var d = absf(f.pos_x - ph.x)
			if d < nd:
				nd = d
				nearest = ph
		if nearest:
			target = nearest
	
	var dx = (target["x"] if target is Dictionary else target.pos_x) - f.pos_x
	var dist = absf(dx)
	var dir_to_target = 1 if dx > 0 else -1

	# ── 5.3 状态应对 [HELL-ENHANCE]：冰冻/减速解除 → 立即远离玩家 1 秒（不再傻站） ──
	var ply = GameWorld.player
	var now_cc: bool = f.has_status("frozen") or f.has_status("slow") or f.slow_timer > 0
	if now_cc:
		_had_cc = true
	elif _had_cc:
		_had_cc = false
		_cc_flee_timer = 60
	if _cc_flee_timer > 0 and ply and ply.hp > 0:
		_cc_flee_timer -= 1
		var away: int = -1 if ply.pos_x > f.pos_x else 1
		f.facing = away
		f.vx = away * diff["move_speed"]
		_update_state(f, away)
		_state = "DODGE"
		return ai_think_delay
	# 玩家放全屏技/大招：可躲则跳离判定范围（复用导航远离） [HELL-ENHANCE]
	if ply and ply.hp > 0 and not f.has_status("frozen") and _cc_flee_timer <= 0 \
			and ply.image_state.begins_with("ult") and dist < 300:
		var away: int = -1 if ply.pos_x > f.pos_x else 1
		f.facing = away
		f.vx = away * diff["move_speed"] * 1.5
		if f.grounded:
			f.vy = -JUMP_VY
		_update_state(f, away)
		_state = "DODGE"
		return ai_think_delay

	# Alert（警觉）：每帧刷新触发与衰减（先于 think_delay 判定，警觉期间决策更快）
	_update_alert(f)
	# Combo 连招事件检测：AI 命中/闪避成功/防御成功时按角色连招表入队
	_update_combo_event(f)

	# Think delay：决策层休息，但执行层持续跟随上次路径
	# （否则每帧 return 会导致物理摩擦把 vx 磨没，AI 走走停停几乎不动、也不会跳）
	if ai_think_delay > 0:
		var ai_cx_d = f.pos_x + f.w / 2.0
		TrackSystem.follow_path(f, ai_cx_d)
		_state = "IDLE"
		return ai_think_delay - 1
	var new_delay = int(diff["react"] / 16) + randi() % 8
	# 警觉期间：按威胁等级决定反应延迟 [HELL-ENHANCE]
	#   受击 1~2 帧 / 判定将命中 3~4 帧 / 玩家起手 5~8 帧
	if _alert:
		match _alert_level:
			Constants.ALERT_LEVEL_HIT:
				new_delay = Constants.ALERT_DELAY_HIT_MIN + randi() % (Constants.ALERT_DELAY_HIT_MAX - Constants.ALERT_DELAY_HIT_MIN + 1)
			Constants.ALERT_LEVEL_IMPACT:
				new_delay = Constants.ALERT_DELAY_IMPACT_MIN + randi() % (Constants.ALERT_DELAY_IMPACT_MAX - Constants.ALERT_DELAY_IMPACT_MIN + 1)
			_:
				new_delay = Constants.ALERT_DELAY_WINDUP_MIN + randi() % (Constants.ALERT_DELAY_WINDUP_MAX - Constants.ALERT_DELAY_WINDUP_MIN + 1)
		# 7.1 反应帧随机抖动 ±2（地狱 ±1）——人类反应有波动 [AI-ENHANCE]
		var jitter := randi() % 5 - 2
		if GameWorld.effective_ai_difficulty() == "hell":
			jitter = randi() % 3 - 1
		new_delay = maxi(1, new_delay + jitter)
	
	var rand = randf()
	
	# ════════════════════════════════════════
	# 优先级链：PRESS(地狱高优先) → DEFEND → DODGE → ATTACK → PICKUP → CHASE/KITE
	# ════════════════════════════════════════

	# ── 0. PRESS 主动压迫 [HELL-ENHANCE]：地狱 aggro≥0.85 高优先级（进入攻击距离立即压迫连打） ──
	var press_high: bool = GameWorld.effective_ai_difficulty() == "hell" and diff["aggro"] >= 0.85
	if press_high and _try_press(f, target, dist, diff):
		return new_delay

	# ── 1. DEFEND: 前方有投射物 + skill2 可用 ──
	var proj_near = false
	for p in GameWorld.projectiles:
		if p.get("owner") == GameWorld.player and absf(p.get("x", 0) - f.pos_x) < 200:
			proj_near = true
			break
	if proj_near and not f.blocking and f.grounded:
		var skill2 = f.get_skill("skill2")
		if skill2 and skill2.can_use(f):
			f.facing = dir_to_target
			skill2.try_use(f)
			_state = "DEFEND"
			return new_delay
	
	# ── 2. DODGE: 危险临近 + 闪避冷却就绪 ──
	if _should_dodge(f, target, dist, diff):
		var ddir = -dir_to_target
		f.dashing = true
		f.dash_dir = ddir
		f.dash_remaining = 15
		f.dash_speed = diff["move_speed"] * 5.0
		_dodge_cooldown = 120
		_state = "DODGE"
		return new_delay
	
	# ── 技能变量 ──
	var skill1 = f.get_skill("skill1")
	var skill2 = f.get_skill("skill2")
	var ult = f.get_skill("ult")

	var can_use_s1 = skill1 and skill1.can_use(f) and dist < 350
	var can_use_s2 = skill2 and skill2.can_use(f)
	var can_use_ult = ult and ult.can_use(f)

	# ── 5.2 斩杀模式 [HELL-ENHANCE]（下放 hard/medium，hell 已有逻辑）：
	# 玩家残血 + AI 能量够大招 → 优先释放大招终结（打中即赢） ──
	var diff_name = GameWorld.effective_ai_difficulty()
	var kill_thr := -1.0
	match diff_name:
		"hell": kill_thr = 0.35    # hell 维持现状（玩家 < 35% 触发）
		"hard": kill_thr = 0.30    # 玩家 < 30%
		"medium": kill_thr = 0.20  # medium 仅玩家 < 20% 才触发
	if kill_thr > 0.0 and ply and ply.hp > 0 and ply.hp < ply.max_hp * kill_thr:
		var can_kill: bool = diff_name != "hard" or f.hp >= f.max_hp * 0.4  # hard 怕换命：自身 > 40% 才敢
		if can_kill and ult and ult.can_use(f) and dist < 220:
			f.facing = dir_to_target
			ult.try_use(f)
			_state = "ATTACK"
			return new_delay
		# 能量/距离不足 → 攒大招：积极接近贴脸输出（普攻/技能攒能量）
		if can_kill and _is_melee(f) and dist < f.attack_range and _attack_ready(f):
			_do_press(f, target, dist, diff)
			return new_delay

	# ── 6.3 角色专属机制触发 [AI-ENHANCE]（风格核心，行为可辨识） ──
	# 暗影武士：血量<30%（或刚受击被压制）→ 隐身撤退，回复后重新接近
	if f.char_id == "shadowwarrior" and (f.hp < f.max_hp * 0.3 \
			or (_alert and _alert_level == Constants.ALERT_LEVEL_HIT)):
		var sw_m = f.components.get_component("shadowwarrior") if f.components else null
		if sw_m and not sw_m.stealth_active:
			sw_m.stealth_active = true
			sw_m.stealth_timer = 360
			_state = "DODGE"
			return new_delay
	# 死灵骑士：玩家距离>200 且马（skill1）可用 → 上马冲锋；贴脸走下方近战逻辑
	if f.char_id == "necro_knight" and dist > 200 and skill1 and skill1.can_use(f):
		f.facing = dir_to_target
		skill1.try_use(f)
		_state = "ATTACK"
		return new_delay
	# 龙骑士：能量≥60% 且玩家在攻击范围内 → 开龙形态爆发（ult=龙魂）
	if f.char_id == "dragon_knight" and f.energy >= f.max_energy * 0.6 \
			and dist < 160 and ult and ult.can_use(f):
		f.facing = dir_to_target
		ult.try_use(f)
		_state = "ATTACK"
		return new_delay
	# 女巫：玩家放弹幕 → 起飞躲避（飞行免疫地面弹幕）
	if f.char_id == "witch":
		var witch_m = f.components.get_component("witch") if f.components else null
		var witch_proj := false
		for wp in GameWorld.projectiles:
			if wp.get("owner") == GameWorld.player and absf(wp.get("x", 0) - f.pos_x) < 200:
				witch_proj = true
				break
		if witch_m and witch_proj and not witch_m.is_flying and f.grounded:
			witch_m.is_flying = true
			f.vy = -10
			_state = "DODGE"
			return new_delay
	# 圣骑士：护盾激活时站桩引玩家攻击（骗招），圣力强化后爆发由连招表接续
	if f.char_id == "paladin" and f.shield_active and dist < 140:
		f.facing = dir_to_target
		f.vx = 0
		_state = "DEFEND"
		return new_delay

	# ── 3. ATTACK: 地狱战术 → Archer → Evoker → 技能 → 近战 ──

	# ---- Hell-specific tactics ----
	var is_hell = GameWorld.effective_ai_difficulty() == "hell"
	if is_hell:
		var player = GameWorld.player
		# ① 反应闪避: 玩家攻击中+距离<150px → 后跳闪避, 70%概率
		if player and player.hp > 0 and player.attacking and dist < 150 and rand < 0.7:
			f.vx = -dir_to_target * diff["move_speed"] * 2.0
			if f.grounded: f.vy = -8
			_update_state(f, dir_to_target)
			_state = "DODGE"
			return new_delay

		# ② 对空迎击: 玩家在空中+距离<120px → AI跳起迎击, 40%概率
		if player and not player.grounded and f.grounded and dist < 120 and rand < 0.4:
			f.vy = -9
			f.vx = dir_to_target * diff["move_speed"]
			_update_state(f, dir_to_target)
			_state = "ATTACK"
			return new_delay

		# ③ 防御技能: 玩家贴脸攻击中+距离<100px → AI开技二防御, 50%概率
		if skill2 and skill2.can_use(f) and dist < 100 and player and player.attacking and rand < 0.5:
			skill2.try_use(f)
			_state = "DEFEND"
			return new_delay

		# ── 地狱角色专属战术：通过 CharacterFactory 调度到角色脚本（配置驱动，禁止 match char_id 新增分支）──
		var handled_state = CharacterFactory.call_ai_hell_tactics(f, {
			"target": target, "dist": dist, "dir": dir_to_target, "rand": rand,
			"diff": diff, "player": player,
			"skill1": skill1, "skill2": skill2, "ult": ult,
			"can_use_s1": can_use_s1, "can_use_s2": can_use_s2, "can_use_ult": can_use_ult,
		})
		if handled_state != "":
			_state = handled_state
			return new_delay

		match f.char_id:
			"assassin":
				# 刺客：玩家攻击时尝试一技能完美闪避, 60%概率
				if skill1 and skill1.can_use(f) and player and player.attacking and dist < 200 and rand < 0.6:
					f.facing = dir_to_target
					skill1.try_use(f)
					_state = "ATTACK"
					return new_delay

			"witch":
				# 魔女：能量>50%时跳跃进入飞行模式，然后空中打击
				if f.energy > f.max_energy * 0.5 and f.grounded and rand < 0.15:
					f.vy = -10  # 跳跃
					var wc = f.components.get_component("witch") if f.components else null
					if wc: wc.is_flying = true
					_state = "ATTACK"
					return new_delay
				# 飞行中：优先使用普攻和一技能
				var wc = f.components.get_component("witch") if f.components else null
				if wc and wc.is_flying and dist < 400:
					if can_use_s1 and rand < diff["skill_rate"]:
						f.facing = dir_to_target
						skill1.try_use(f)
						_state = "ATTACK"
						return new_delay
					var atk = f.get_skill("attack")
					if atk and atk.can_use(f):
						f.facing = dir_to_target
						atk.try_use(f)
						_state = "ATTACK"
						return new_delay
			
			"shadowwarrior":
				# 影武者：隐身中快速靠近破隐一击
				var sw_comp2 = f.components.get_component("shadowwarrior") if f.components else null
				if sw_comp2 and sw_comp2.stealth_active:
					if dist < 60 and f.attack_cooldown <= 0 and not f.attacking:
						f.attacking = true; f.attack_timer = 30; f.attack_delay = 8
						f.attack_hit_dealt = false; f.attack_cooldown = 60; f.state = "attack"
						sw_comp2.stealth_active = false  # 破隐
						_state = "ATTACK"
						return new_delay

			"paladin":
				# 圣骑士：距离>500时蓄力一技能，蓄满后远距离冲刺撞击
				if dist > 500 and can_use_s1 and not f.charging_skill1 and not f.dashing and rand < 0.2:
					f.facing = dir_to_target
					skill1.try_use(f)
					_state = "ATTACK"
					return new_delay

	# ── 角色特定走位修正 ──

	# ── 角色专属 AI 战术（如剑豪千峰破云连招；返回非空 = 本帧已决策）──
	var tactics_state = CharacterFactory.call_ai_tactics(f, {
		"target": target, "dist": dist, "dir": dir_to_target, "rand": rand,
		"diff": diff, "player": GameWorld.player,
		"skill1": skill1, "skill2": skill2, "ult": ult,
		"can_use_s1": can_use_s1, "can_use_s2": can_use_s2, "can_use_ult": can_use_ult,
	})
	if tactics_state != "":
		_state = tactics_state
		return new_delay

	# ---- Skill usage（有专属 AI 战术的角色不走通用随机释放，如剑豪靠连招触发技能）----
	if not CharacterFactory.has_ai_tactics(f.char_id):
		# 5.4 能量管理 [HELL-ENHANCE]：能量≥70% 且玩家<50% → 优先放技能（主动终结，不攒大招）
		var finisher_mode: bool = f.energy >= f.max_energy * 0.7 and ply and ply.hp > 0 \
				and ply.hp < ply.max_hp * 0.5
		# 技能一：远程距离判定
		var s1_rate: float = 0.85 if finisher_mode else diff["skill_rate"] * 1.5
		if dist > 150 and dist < 350 and can_use_s1 and randf() < s1_rate:
			f.facing = dir_to_target
			skill1.try_use(f)
			if Constants.difficulty_at_least(GameWorld.effective_ai_difficulty(), "hard"):
				skill1.cd = maxi(skill1.cd, 300)
			_state = "ATTACK"
			return new_delay

		# 大招：玩家血量 > 70% 不浪费大招打满血（继续普攻攒机会）
		var waste_ult: bool = ply and ply.hp > 0 and ply.hp > ply.max_hp * 0.7
		if dist < 200 and can_use_ult and not waste_ult and randf() < diff["skill_rate"] * 0.8:
			f.facing = dir_to_target
			ult.try_use(f)
			if Constants.difficulty_at_least(GameWorld.effective_ai_difficulty(), "hard"):
				ult.cd = maxi(ult.cd, 300)
			_state = "ATTACK"
			return new_delay
	
	# ---- Hell-specific tactics (cont.) ----
	if is_hell:
		var player = GameWorld.player
		# ④ 斩杀大招: 玩家血量<40%+距离<150px → 直接丢大招, 80%概率
		if can_use_ult and dist < 150 and player and player.hp < player.max_hp * 0.4 and rand < 0.8:
			f.facing = dir_to_target
			ult.try_use(f)
			_state = "ATTACK"
			return new_delay

		# ⑤ 技能连招: 双技能可用+距离<200px → 技一→技二连发, 35%概率
		if can_use_s1 and can_use_s2 and dist < 200 and rand < 0.35:
			f.facing = dir_to_target
			skill1.try_use(f)
			if skill2.can_use(f): skill2.try_use(f)
			_state = "ATTACK"
			return new_delay

		# ⑥ 影武者：使用技能后尝试进入隐身
		var sw_comp = f.components.get_component("shadowwarrior") if f.components else null
		if sw_comp and not sw_comp.stealth_active and f.char_id == "shadowwarrior" and rand < 0.5:
			sw_comp.stealth_active = true
			sw_comp.stealth_timer = 360
			_state = "ATTACK"
			return new_delay

	# ---- Archer: buff优先 → 无条件蓄力 → 同线放箭 ----
	if f.char_id == "archer":
		f.facing = dir_to_target
		# ① 优先开强化技能（火矢/追踪）
		if skill1 and skill1.can_use(f):
			skill1.try_use(f)
			_state = "ATTACK"
			return new_delay
		if skill2 and skill2.can_use(f):
			skill2.try_use(f)
			_state = "ATTACK"
			return new_delay
		# ② 蓄力中 → 蓄满且在同一水平线时放箭
		if f.charging_attack:
			var ct = (Time.get_ticks_msec() - f.charge_start_time) / 1000.0
			var t_y = target.get("y", 0.0) if target is Dictionary else target.pos_y
			if ct >= 0.8 and absf(f.pos_y - t_y) < 30:
				ArcherCharacter.ai_fire_arrow(f, ct)
			_state = "ATTACK"
			return new_delay
		# ③ 无条件开始蓄力（有箭且能量够即可）
		var archer_comp = f.components.get_component("archer") if f.components else null
		if archer_comp and archer_comp.arrows > 0 and f.energy >= 5:
			f.charging_attack = true
			f.charge_start_time = Time.get_ticks_msec()
			f.attacking = true
			f.attack_timer = 9999
			f.state = "attack"
			_state = "ATTACK"
			return new_delay

	# ---- Evoker: summon management & ranged combat ----
	if f.char_id == "evoker":
		# HP < 30% → 优先大招
		if can_use_ult and f.hp < f.max_hp * 0.3 and dist < 350:
			f.facing = dir_to_target
			ult.try_use(f)
			_state = "ATTACK"
			return new_delay

		# HP < 50% → 防御大招
		if can_use_ult and f.hp < f.max_hp * 0.5 and dist < 250:
			f.facing = dir_to_target
			ult.try_use(f)
			_state = "ATTACK"
			return new_delay

		var has_summon = false
		var summon_state = ""
		for s in GameWorld.evoker_summons:
			if s.get("owner") == f:
				has_summon = true
				summon_state = s.get("state", "")
				break

		if not has_summon and can_use_s1:
			f.facing = dir_to_target
			skill1.try_use(f)
			_state = "ATTACK"
			return new_delay

		var atk_skill = f.get_skill("attack")

		if has_summon and can_use_s2 and randf() < diff["skill_rate"]:
			f.facing = dir_to_target
			skill2.try_use(f)
			_state = "ATTACK"
			return new_delay

		if has_summon and atk_skill and atk_skill.can_use(f):
			f.facing = dir_to_target
			atk_skill.try_use(f)
			_state = "ATTACK"
			return new_delay

		if not has_summon and atk_skill and atk_skill.can_use(f) and dist < 400 and rand < diff["aggro"]:
			f.facing = dir_to_target
			atk_skill.try_use(f)
			_state = "ATTACK"
			return new_delay

	# ---- 远程角色：在同一水平线上时普攻 ----
	if not _is_melee(f):
		f.facing = dir_to_target
		# 通过 skill 系统的角色（witch/evoker 等）
		var atk = f.get_skill("attack")
		if atk and atk.can_use(f):
			var t_y = target.get("y", 0.0) if target is Dictionary else target.pos_y
			if absf(f.pos_y - t_y) < 30 and dist < 600:
				atk.try_use(f)
				_state = "ATTACK"
				return new_delay
		# Mage 的火球普攻没有注册为 skill，需直接处理
		if f.char_id == "mage" and f.attack_cooldown <= 0 and not f.attacking and f.energy >= 10:
			var t_y = target.get("y", 0.0) if target is Dictionary else target.pos_y
			if absf(f.pos_y - t_y) < 30 and dist < 600:
				f.energy -= 10
				f.attacking = true
				f.attack_timer = 30
				f.attack_delay = 0
				f.attack_hit_dealt = true
				f.attack_cooldown = 120
				f.state = "attack"
				var d = f.facing
				var px2 = f.pos_x + (f.w if d == 1 else 0)
				var py2 = f.pos_y + 30
				GameWorld.projectiles.append({"x":px2-16,"y":py2-12,"w":32,"h":24,"vx":3*d,"vy":0,"life":120,"damage":3,"owner":f,"type":"mage_fire","color":Color(1,0.4,0),"reflected":false,"burn":true,"img":preload("res://assets/fx_fire_projectile.png")})
				_state = "ATTACK"
				return new_delay

	# ---- 低优先级 PRESS [HELL-ENHANCE]（非地狱）：保持原被动链，仅 aggro 高时偶尔进入压迫 ----
	if not press_high and rand < _eff_aggro(f, diff) * 0.3 and _try_press(f, target, dist, diff):
		return new_delay

	# ---- 近战普攻判定（远程角色跳过） ----
	if _is_melee(f) and dist < 80 and rand < _eff_aggro(f, diff):
		f.facing = dir_to_target
		if f.char_id == "assassin":
			var atk_skill = f.get_skill("attack")
			if atk_skill and atk_skill.can_use(f):
				atk_skill.try_use(f)
		else:
			if f.attack_cooldown <= 0 and not f.attacking:
				f.attacking = true
				f.attack_timer = 30
				f.attack_delay = 8
				f.attack_hit_dealt = false
				f.attack_cooldown = 60
				f.state = "attack"
		_state = "ATTACK"
		return new_delay
	
	# ── 血量分层 [HELL-ENHANCE]：>60% 正常；30%~60% 防御增强（_should_dodge +30%）；<30% 保守模式 ──
	var max_hp = f.max_hp
	if f.hp < max_hp * 0.3:
		# 保守模式：不主动贴脸反打（斩杀统一走 5.2，需玩家残血才放）；被追时闪避/防御保命
		if dist < 150 and _should_dodge(f, target, dist, diff):
			var ddir = -dir_to_target
			f.dashing = true
			f.dash_dir = ddir
			f.dash_remaining = 15
			f.dash_speed = diff["move_speed"] * 5.0
			_dodge_cooldown = 120
			_state = "DODGE"
			return new_delay
		elif dist < 150 and skill2 and skill2.can_use(f):
			f.facing = dir_to_target
			skill2.try_use(f)
			_state = "DEFEND"
			return new_delay
		# dist >= 150：拉开距离（desire_min=200 修正见下方 CHASE/KITE）
	
	# ── 4. PICKUP: 能量<20% 或 HP<40% → 寻找对应球 ──
	# 识别 AI 当前所在平台（左/右缘落在平台内即算，支持边缘起跳）
	var ai_cx = f.pos_x + f.w / 2.0
	var ai_plat = _find_ai_platform(f)

	var need_energy = f.energy < f.max_energy * 0.2
	var need_health = f.hp < f.max_hp * 0.4
	if need_energy or need_health:
		var pickup_result = _evaluate_pickup(f, ai_plat, dist, need_energy, need_health)
		if pickup_result != null:
			var pickup_plat = pickup_result["plat"]
			var pickup_target = pickup_result["target"]
			var pdist = absf(pickup_target.x + pickup_target.w / 2.0 - f.pos_x)
			if pdist > 150:
				# 导航到拾取物平台
				TrackSystem.navigate(f, ai_plat, pickup_plat, 0, 999999, false)
				TrackSystem.follow_path(f, ai_cx)
				_state = "PICKUP"
				return new_delay
	
	# ── 5. CHASE / KITE: 走位策略 ──
	
	# 地狱·影武者隐身中：无视陷阱直接冲向玩家
	if GameWorld.effective_ai_difficulty() == "hell" and f.char_id == "shadowwarrior":
		var sw_chase = f.components.get_component("shadowwarrior") if f.components else null
		if sw_chase and sw_chase.stealth_active:
			f.vx = dir_to_target * diff["move_speed"]
			_update_state(f, dir_to_target)
			_state = "CHASE"
			return new_delay
	
	# 识别目标所在平台
	var target_feet_x = target.get("x", 0.0) if target is Dictionary else target.pos_x
	var target_feet_y = target.get("y", 0.0) if target is Dictionary else (target.pos_y + target.h)
	var target_plat = _find_target_platform(target_feet_x, target_feet_y)
	
	# 获取走位参数
	var desire = _get_desire_range(f, dist)
	# 角色偏好距离修正 [AI-ENHANCE]：激进档攻击距离 +15%；kite 风格保持偏好距离
	var fav_d: float = _get_fav_dist(f)
	if _tactical_mode == 1:
		desire["min"] = desire["min"] * 1.15
		desire["max"] = desire["max"] * 1.15
	elif _get_style(f) == "kite":
		desire["min"] = maxf(desire["min"], fav_d * 0.7)
	
	# 保守修正 [HELL-ENHANCE]：HP<30% 且 dist>=150 时 desire_min=200（拉开距离）
	if f.hp < max_hp * 0.3 and dist >= 150:
		desire["min"] = maxf(desire["min"], 200)
	
	if _is_melee(f):
		# 近战：CHASE
		TrackSystem.navigate(f, ai_plat, target_plat, desire["min"], desire["max"], true)
		TrackSystem.follow_path(f, ai_cx)
		_state = "CHASE"
	else:
		# 远程：KITE
		TrackSystem.navigate(f, ai_plat, target_plat, desire["min"], desire["max"], false)
		TrackSystem.follow_path(f, ai_cx)
		_state = "KITE"
	
	return new_delay


# ── 状态更新 ──
static func _update_state(p: Fighter, mx: int):
	if p.grounded and mx == 0 and not p.attacking and not p.dashing:
		p.state = "idle"
	elif p.grounded and mx != 0 and not p.attacking and not p.dashing:
		p.state = "walk"
	if p.attacking and p.attack_timer <= 0:
		p.attacking = false; p.state = "idle"


# ── 角色走位参数 ──

## 判断是否为近战角色
static func _is_melee(f) -> bool:
	var melee_chars = ["knight", "assassin", "rose", "paladin", "dragon_knight", "shadowwarrior", "necro_knight", "kensai"]
	return f.char_id in melee_chars

## 获取角色走位参数
## 返回 {min, max}
static func _get_desire_range(f, dist) -> Dictionary:
	# ── 地狱特殊走位 ──
	if GameWorld.effective_ai_difficulty() == "hell":
		# 角色专属走位（通过 CharacterFactory 调度，配置驱动）
		var custom_desire = CharacterFactory.call_ai_hell_desire(f)
		if not custom_desire.is_empty():
			return custom_desire
		match f.char_id:
			"evoker":
				# HP < 60% → 跟随模式（缩小距离）
				if f.hp < f.max_hp * 0.6:
					return {"min": 0, "max": 120}
			"shadowwarrior":
				# 隐身中 → 快速贴脸
				var sw_comp = f.components.get_component("shadowwarrior") if f.components else null
				if sw_comp and sw_comp.stealth_active:
					return {"min": 0, "max": 30}
			"paladin":
				# 蓄力/冲刺中保持远距离
				if f.charging_skill1 or f.dashing:
					return {"min": 500, "max": 800}
				# 平时也保持较远距离等待蓄力机会
				return {"min": 350, "max": 600}

	match f.char_id:
		"knight":
			return {"min": 0, "max": 80}
		"assassin":
			return {"min": 0, "max": 80}
		"rose":
			return {"min": 0, "max": 80}
		"paladin":
			return {"min": 0, "max": 80}
		"dragon_knight":
			return {"min": 0, "max": 140}
		"necro_knight":
			return {"min": 0, "max": 80}
		"shadowwarrior":
			return {"min": 0, "max": 80}
		"kensai":
			return {"min": 0, "max": 90}
		"archer":
			return {"min": 150, "max": 350}
		"evoker":
			return {"min": 150, "max": 400}
		_:
			# 默认：根据距离判断
			if dist < 80:
				return {"min": 0, "max": 80}
			return {"min": 150, "max": 350}


# ── 闪避判定 ──

## 判断 AI 是否应闪避
## 条件：
##   玩家攻击中 + dist < 100
##   或前方 150px 内有投射物
##   或 Archer 被贴脸 (dist < 80) → 100%
## 全局冷却 120 帧
## hell 概率 70%, other 20-50%
static func _should_dodge(f, target, dist, diff) -> bool:
	# 全局冷却
	if _dodge_cooldown > 0:
		_dodge_cooldown -= 1
		return false
	
	var roll = randf()
	var hell_bonus = 0.7 if GameWorld.effective_ai_difficulty() == "hell" else (0.5 if GameWorld.effective_ai_difficulty() == "hard" else 0.2)
	# 血量 30%~60%：防御倾向提升（闪避权重 +30%），但不逃跑 [HELL-ENHANCE]
	if f.hp < f.max_hp * 0.6 and f.hp >= f.max_hp * 0.3:
		hell_bonus = minf(1.0, hell_bonus + 0.3)
	# 被燃烧（持续伤害）：走位权重 +20%（躲后续伤害） [HELL-ENHANCE]
	if f.has_status("burn") or f.burn_timer > 0:
		hell_bonus = minf(1.0, hell_bonus + 0.2)
	
	# Archer 被贴脸 → 100% 闪避
	if f.char_id == "archer" and dist < 80:
		return true
	
	# 玩家攻击中 + 距离 < 100（仅当目标是 Fighter 时才检查 attacking）
	if target is Fighter and target.hp > 0 and target.attacking and dist < 100 and roll < hell_bonus:
		return true
	
	# 前方 150px 内有敌方投射物（仅当 target 是 Fighter 时检查，phantom 不发射投射物）
	var target_x = target.pos_x if target is Fighter else (target.get("x", 0) if target is Dictionary else 0)
	var dir = 1 if target and (target_x > f.pos_x) else -1
	if target is Fighter:
		for p in GameWorld.projectiles:
			var owner = p.get("owner")
			if owner == target and absf(p.get("x", 0) - f.pos_x) < 150:
				return true
	
	return false


# ── 拾取评估 ──

## 评估拾取物
## 遍历所有活跃拾取物，找到所在平台
## 玩家在拾取物同平台 → 评分 -80（危险）
## 路径第一跳平台是玩家所在平台 → 评分 -60
## 评分 > 50 且 dist > 150 → 执行 PICKUP 状态
## 返回 {target, plat} 或 null
static func _evaluate_pickup(f, ai_plat, dist_to_enemy: float, need_energy: bool, need_health: bool):
	# 检查是否已被玩家接近（dist < 150 时不应拾取）
	if dist_to_enemy < 150:
		return null

	var best_score = 0.0
	var best_target = null
	var best_plat = null

	for item in GameWorld.pickups:
		if not item or not item.active:
			continue

		# 找到拾取物所在平台
		var item_cx = item.x + item.w / 2.0
		var item_feet_y = item.y + item.h / 2.0
		var item_plat = null
		for p in GameWorld.platforms:
			if p.get("terrain_type", -1) == 3: continue
			if _is_on_platform(item_cx, item_feet_y, p):
				item_plat = p
				break

		if item_plat == null:
			continue

		# 基础评分
		var score = 50.0

		# 角色特定权重
		if f.char_id == "assassin" and item.type == "energy":
			score += 20.0
		elif f.char_id == "paladin" and item.type == "health":
			score += 30.0
		elif f.char_id == "evoker" and item.type == "cooldown":
			score += 40.0

		# 通用需求权重：需能量时能量球+20，需血量时血球+20
		if need_energy and item.type == "energy":
			score += 20.0
		if need_health and item.type == "health":
			score += 20.0
		# 保守模式（HP<30%）：血球权重拉到最高 [HELL-ENHANCE]
		if f.hp < f.max_hp * 0.3 and item.type == "health":
			score += 40.0
		
		# 玩家在拾取物同平台 → 危险，评分 -80
		var player_on_plat = false
		if GameWorld.player:
			var pcx = GameWorld.player.pos_x + GameWorld.player.w / 2.0
			var pfy = GameWorld.player.pos_y + GameWorld.player.h
			for p in GameWorld.platforms:
				if p.get("terrain_type", -1) == 3: continue
				if _is_on_platform(pcx, pfy, p) and p == item_plat:
					player_on_plat = true
					break
		if player_on_plat:
			score -= 80.0
		elif ai_plat != null and item_plat != ai_plat:
			# 不同平台：检查路径第一跳是否是玩家平台
			var path = TrackSystem._find_path(ai_plat, item_plat)
			if path.size() >= 2:
				var first_jump = path[1]
				if GameWorld.player:
					var pcx2 = GameWorld.player.pos_x + GameWorld.player.w / 2.0
					var pfy2 = GameWorld.player.pos_y + GameWorld.player.h
					for p in GameWorld.platforms:
						if p.get("terrain_type", -1) == 3: continue
						if _is_on_platform(pcx2, pfy2, p) and p == first_jump:
							score -= 60.0
							break
		
		if score > best_score:
			best_score = score
			best_target = item
			best_plat = item_plat
	
	if best_score > 50 and best_target != null:
		return {"target": best_target, "plat": best_plat}
	
	return null


# ── 平台辅助 ──

## 查找 AI 所在平台（允许部分伸出边缘：左缘或右缘在平台内）
static func _find_ai_platform(f):
	var feet_y = f.pos_y + f.h
	for p in GameWorld.platforms:
		if p.get("terrain_type", -1) == 3: continue
		if f.pos_x + f.w > p["x"] and f.pos_x < p["x"] + p["w"] and absf(feet_y - p["y"]) < 20:
			return p
	return null

## 查找目标所在平台
static func _find_target_platform(feet_x: float, feet_y: float):
	for p in GameWorld.platforms:
		if p.get("terrain_type", -1) == 3: continue
		if _is_on_platform(feet_x, feet_y, p):
			return p
	return null

## 判断点 (x, y) 是否站在平台 p 上
static func _is_on_platform(x: float, y: float, p: Dictionary) -> bool:
	if p.get("terrain_type", -1) == 3:
		return false
	return x >= p["x"] and x <= p["x"] + p["w"] and absf(y - p["y"]) < 20

## 在 GameWorld.platforms 中查找平台下标
static func _plat_index(plat: Dictionary) -> int:
	for i in range(GameWorld.platforms.size()):
		if GameWorld.platforms[i] == plat:
			return i
	return -1
