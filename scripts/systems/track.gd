class_name TrackSystem

# ===== Pure Tracking AI — 纯导航接口（无技能/攻击/闪避） =====

# ── 物理常量 ──
const GRAVITY := 0.22
const JUMP_VY := 10.0

# ── 有向可达图 ──
const BUILD_MOVE_SPEED := 2.0
const AI_JUMP_BONUS := 1.1   # AI 跳跃性能 = 玩家的 1.1 倍（图构建与执行的跳跃水平速度上限）
const SAFE_MARGIN := 8.0     # 平台安全边距：AI 行走不越过平台边缘，防止无意走出掉落
static var _adj: Array = []
static var _graph_built: bool = false

# ── 跳跃状态 ──
static var _jump_commit: bool = false
static var _jump_vx := 0.0   # 跳跃期间保持的水平速度（可在 0..vmax 内取值，实现水平跳跃）

# ── 路径状态 ──
static var _path: Array = []         # 当前完整路径 [plat0, plat1, ...]
static var _path_move_speed := 0.0   # 当前移动速度
static var _path_dir_to_target := 0  # 朝向目标的方向
static var _target_x := 0.0          # 目标 x 位置（同平台 desire 距离保持用）
static var _target_plat = null       # 目标平台
static var _desire_min := 0.0        # 同平台后的最小 desire 距离
static var _desire_max := 999999.0   # 同平台后的最大 desire 距离
static var _rush := false            # 是否使用 rush 模式（更快起跳）

# ── 辅助：维持速度（已内联到执行路径） ──
static var _last_vx := 0.0
static var _last_dir := 0

# ===== 新接口 =====

## 设置导航目标（由 AISystem 走位策略决定）
## navigate() 只设置内部状态，不直接操作 fighter 的 vx/vy
## from_plat/to_plat 为 null 时视为"无路径目标"
static func navigate(f, from_plat, to_plat, desire_min: float, desire_max: float, rush: bool = false):
	_desire_min = desire_min
	_desire_max = desire_max
	_rush = rush
	_target_plat = to_plat
	_target_x = _get_target_x(f, to_plat)
	
	# 设置移动速度
	var diff = Constants.AI_PRESETS.get(GameWorld.difficulty, Constants.AI_PRESETS["medium"])
	_path_move_speed = diff["move_speed"]
	
	# 设置路径（不重置 _jump_commit：跳跃承诺由 follow_path 在落地时清除，
	# 避免 AI 每帧 navigate 导致空中跳跃时水平速度被清零）
	if from_plat == null or to_plat == null:
		_path = []
		return
	
	# 方向（朝目标）
	var dx = _target_x - f.pos_x
	_path_dir_to_target = 1 if dx > 0 else -1
	
	if from_plat == to_plat:
		_path = [from_plat]  # 同平台，单元素路径
		return
	
	_path = _find_path(from_plat, to_plat)
	_need_think = false

## 每帧执行路径（同平台走向目标/不同平台图路径+边缘跳跃）
static func follow_path(f, ai_cx: float) -> void:
	var move_speed = _path_move_speed
	var dir_to_target = _path_dir_to_target

	# 跳跃承诺 coast：维持起跳时的水平速度直至落地（支持水平跳跃）
	if not f.grounded and _jump_commit:
		f.vx = _jump_vx
		_update_state(f, sign(f.vx))
		_last_vx = f.vx; _last_dir = 1 if f.vx > 0 else -1
		return

	# 落地清除承诺
	if f.grounded:
		_jump_commit = false

	# 穿透下落 → 维持水平速度直至落地
	if not f.grounded and f.passthrough_timer > 0:
		f.vx = dir_to_target * move_speed * 1.5
		_last_vx = f.vx; _last_dir = dir_to_target
		_update_state(f, dir_to_target)
		return

	# 识别 AI 当前所在平台（左/右缘落在平台内即算在平台上，支持边缘起跳）
	var ai_feet_y = f.pos_y + f.h
	var ai_plat = null
	for p in GameWorld.platforms:
		if p.get("terrain_type", -1) == 3: continue
		if _ai_on_platform(f, p):
			ai_plat = p
			break

	# 同平台 → desire 距离保持
	if ai_plat != null and _target_plat != null and ai_plat == _target_plat:
		var dx_target = _target_x - f.pos_x
		var dist = absf(dx_target)
		var dir_to_target_local = 1 if dx_target > 0 else -1
		
		if dist < _desire_min:
			# 太近 → 后退
			f.vx = -dir_to_target_local * move_speed
		elif dist > _desire_max:
			# 太远 → 前进
			f.vx = dir_to_target_local * move_speed
		else:
			# desire 范围内 → 停止
			f.vx = 0
		_last_vx = f.vx; _last_dir = dir_to_target_local
		_update_state(f, sign(f.vx))
		return

	# 不同平台 + 有路径 → 沿路径走
	if ai_plat != null and _target_plat != null and f.grounded and _path.size() >= 2:
		var next_plat = _path[1]
		_follow_path_step(f, ai_plat, next_plat, move_speed, dir_to_target, ai_cx)
		return

	# 无可达路径 → 朝目标方向走，但受安全区域限制：到边缘停下等待重新规划，
	# 不做盲跳（图不可达时盲跳大概率掉虚空）
	if ai_plat != null and f.grounded:
		var dir_to_plat := 1 if _target_x > f.pos_x else -1
		var safe_l: float = ai_plat["x"] + SAFE_MARGIN
		var safe_r: float = ai_plat["x"] + ai_plat["w"] - SAFE_MARGIN
		if (dir_to_plat > 0 and f.pos_x >= safe_r) or (dir_to_plat < 0 and f.pos_x <= safe_l):
			f.vx = 0  # 已到安全边界 → 停下
		else:
			f.vx = dir_to_plat * move_speed * 0.8
		_last_vx = f.vx; _last_dir = dir_to_plat
		_update_state(f, dir_to_plat)
		return

	# 无有效路径 → 静止
	f.vx = 0
	_last_vx = 0; _last_dir = 0
	_update_state(f, 0)


# ===== 旧接口保留 =====
# 注：update_track() 已删除，改为 navigate() + follow_path()

# ── 需要重新规划路径标志 ──
static var _need_think: bool = true

# ── 沿路径走一步（边缘检测 + 起跳/下落） ──
static func _follow_path_step(f, ai_plat, next_plat, move_speed: float, dir_to_target: int, ai_cx: float):
	var from_y: float = ai_plat["y"]
	var to_y: float = next_plat["y"]
	var next_l: float = next_plat["x"]
	var next_r: float = next_plat["x"] + next_plat["w"]

	# 滞空时间：vy 只有两个取值——
	#   目标在下方 → 走出平台自然下落（vy=0 起，重力加速）
	#   目标在上方/同高 → 起跳（vy=-JUMP_VY 的抛物线）
	var dy: float = from_y - to_y  # 正 = 目标在上方
	var t_air: float = 0.0
	if dy < 0.0:
		t_air = sqrt(2.0 * (to_y - from_y) / GRAVITY)
	else:
		var disc: float = JUMP_VY * JUMP_VY - 2.0 * GRAVITY * dy
		if disc >= 0.0:
			t_air = (JUMP_VY + sqrt(disc)) / GRAVITY

	var speed_mult: float = 1.5 if _rush else 1.0
	# 水平速度上限：至少达到图构建假设（BUILD_MOVE_SPEED），再乘 AI 跳跃加成
	var vmax: float = maxf(move_speed * speed_mult, BUILD_MOVE_SPEED) * AI_JUMP_BONUS

	# 已在目标平台 x 范围内 → 直接执行（上方/同高垂直跳，下方自然下落）
	if ai_cx >= next_l and ai_cx <= next_r and f.grounded:
		if dy >= 0.0:
			_start_jump(f, 0.0, dir_to_target)
		else:
			_start_drop(f, ai_plat, 0.0, dir_to_target, t_air)
		return

	# 方向：走向 next_plat 的 x 范围
	var dir := 0
	if ai_cx < next_l:
		dir = 1
	elif ai_cx > next_r:
		dir = -1
	else:
		dir = dir_to_target

	# 移动（安全区域：AI 行走不越过平台边缘，防止 v 不够时走出掉落）
	var safe_l: float = ai_plat["x"] + SAFE_MARGIN
	var safe_r: float = ai_plat["x"] + ai_plat["w"] - SAFE_MARGIN
	if (dir > 0 and f.pos_x >= safe_r) or (dir < 0 and f.pos_x <= safe_l):
		f.vx = 0  # 已到安全边界 → 停下等待起跳/下落
	else:
		f.vx = dir * move_speed * speed_mult

	# 到边缘起跳/下落：水平速度在 0..vmax 内取值，落点瞄准目标平台近边缘
	var edge_threshold: int = 40 if _rush else 60
	var at_edge: bool = absf(f.pos_x - (ai_plat["x"] + ai_plat["w"] if dir > 0 else ai_plat["x"])) < edge_threshold
	if at_edge and f.grounded and t_air > 0.0:
		# 目标平台近边缘：向右跳瞄准左缘，向左跳瞄准右缘，保证落点在平台内
		var aim_x: float = next_l if dir > 0 else next_r
		# 空中有效飞行帧数 = t_air - 1：起跳/下落帧水平速度置 0
		# （避开地面物理的摩擦衰减与 |vx|<=0.1 清零，空中可精确保持任意小速度）
		var t_flight: float = maxf(t_air - 1.0, 1.0)
		var v: float = clampf((aim_x - f.pos_x) / t_flight, -vmax, vmax)
		# 落点（AI 左缘）：需满足物理落地判定（AI 右缘深入平台 >= 4px），避免落空掉虚空
		var land_x: float = f.pos_x + v * t_flight
		var touch_ok: bool = (dir > 0 and land_x + f.w > next_l + 4) or (dir < 0 and land_x < next_r - 4)
		if not touch_ok:
			# 落点够不到目标平台 → 本帧继续走向边缘，下帧再跳
			_last_vx = f.vx; _last_dir = dir
			_update_state(f, dir)
			return
		if dy < 0.0:
			_start_drop(f, ai_plat, v, dir, t_air)
		else:
			_start_jump(f, v, dir)
		return

	_last_vx = f.vx; _last_dir = dir
	_update_state(f, dir)

# ── 起跳/下落辅助 ──

## 起跳：vy=-JUMP_VY。起跳帧 vx 置 0（地面物理会把小速度清零），空中保持 air_vx
static func _start_jump(f, air_vx: float, dir: int):
	f.vx = 0
	f.vy = -JUMP_VY
	_jump_commit = true
	_jump_vx = air_vx
	_last_vx = air_vx
	_last_dir = dir
	_update_state(f, dir)

## 自然下落：走出边缘，vy 从 0 起。同样起跳帧 vx 置 0，空中保持 air_vx
static func _start_drop(f, from_plat, air_vx: float, dir: int, t_air: float):
	f.passthrough_platform = from_plat  # 穿透当前平台，避免下落时被原平台顶部接住
	f.passthrough_timer = maxi(30, int(t_air) + 20)
	f.grounded = false
	f.vy = 0
	f.vx = 0
	_jump_commit = true
	_jump_vx = air_vx
	_last_vx = air_vx
	_last_dir = dir
	_update_state(f, dir)

# ── 辅助：获取目标 x 位置 ──
static func _get_target_x(f, target_plat) -> float:
	if target_plat != null:
		return target_plat["x"] + target_plat["w"] / 2.0
	return GameWorld.player.pos_x + GameWorld.player.w / 2.0


# ===== 状态更新 =====
static func _update_state(p, mx: int):
	if p.grounded and mx == 0 and not p.attacking and not p.dashing:
		p.state = "idle"
	elif p.grounded and mx != 0 and not p.attacking and not p.dashing:
		p.state = "walk"
	if p.attacking and p.attack_timer <= 0:
		p.attacking = false; p.state = "idle"

# ===== 平台辅助函数 =====
static func _is_on_platform(x: float, y: float, p: Dictionary) -> bool:
	if p.get("terrain_type", -1) == 3: return false
	return x >= p["x"] and x <= p["x"] + p["w"] and absf(y - p["y"]) < 20

## AI 是否站在平台 p 上（允许部分伸出边缘：左缘或右缘在平台内）
static func _ai_on_platform(f, p: Dictionary) -> bool:
	if p.get("terrain_type", -1) == 3: return false
	if absf((f.pos_y + f.h) - p["y"]) > 20: return false
	return f.pos_x + f.w > p["x"] and f.pos_x < p["x"] + p["w"]

static func _get_reachable_x_interval(plat: Dictionary, target_y: float, move_speed: float) -> Array:
	# vy 只有两个取值，覆盖区域 = 平台 x 范围 ± vmax*t：
	#   目标在下方 → 走出边缘自然下落（vy=0 起，重力加速）
	#   目标在上方/同高 → 起跳（vy=-JUMP_VY 的抛物线）
	# 水平速度 v 可在 0..move_speed 内任意取值，落点可在区间内任意选择
	var a_l = plat["x"]; var a_r = plat["x"] + plat["w"]; var a_y = plat["y"]
	var dy = a_y - target_y  # 正 = 目标在上方
	var t := 0.0
	if dy < 0.0:
		t = sqrt(2.0 * (target_y - a_y) / GRAVITY)
	else:
		var disc = JUMP_VY * JUMP_VY - 2.0 * GRAVITY * dy
		if disc < 0: return []  # 目标过高
		t = (JUMP_VY + sqrt(disc)) / GRAVITY
	return [a_l - move_speed * t, a_r + move_speed * t]

static func _is_platform_reachable(from_plat: Dictionary, to_plat: Dictionary, move_speed: float) -> bool:
	if from_plat.get("terrain_type", -1) == 3 or to_plat.get("terrain_type", -1) == 3: return false
	var interval = _get_reachable_x_interval(from_plat, to_plat["y"], move_speed)
	return interval.size() >= 2 and not (to_plat["x"] + to_plat["w"] < interval[0] or to_plat["x"] > interval[1])

static func _build_graph() -> void:
	var n = GameWorld.platforms.size()
	_adj = []; _adj.resize(n)
	for i in range(n):
		_adj[i] = []
		var from_plat = GameWorld.platforms[i]
		if from_plat.get("terrain_type", -1) == 3: continue
		for j in range(n):
			if i == j: continue
			var to_plat = GameWorld.platforms[j]
			if to_plat.get("terrain_type", -1) == 3: continue
			# 遮挡不影响可达性：中途平台可先落/跳一步再继续，故不做轨迹拦截检查
			# AI 跳跃性能 = 玩家 * 1.1，可达范围相应扩大
			if _is_platform_reachable(from_plat, to_plat, BUILD_MOVE_SPEED * AI_JUMP_BONUS):
				var from_cx = from_plat["x"] + from_plat["w"] / 2.0; var to_cx = to_plat["x"] + to_plat["w"] / 2.0
				_adj[i].append({"to": j, "weight": sqrt((to_cx - from_cx) * (to_cx - from_cx) + (to_plat["y"] - from_plat["y"]) * (to_plat["y"] - from_plat["y"]))})
	_graph_built = true

static func _dijkstra(start_idx: int, goal_idx: int) -> Array:
	if not _graph_built or _adj.size() != GameWorld.platforms.size(): _build_graph()
	var n = GameWorld.platforms.size()
	if start_idx < 0 or start_idx >= n or goal_idx < 0 or goal_idx >= n: return []
	var dist = []; var prev = []; var visited = []
	dist.resize(n); prev.resize(n); visited.resize(n)
	for i in range(n): dist[i] = INF; prev[i] = -1; visited[i] = false
	dist[start_idx] = 0.0
	while true:
		var u = -1; var min_d = INF
		for i in range(n):
			if not visited[i] and dist[i] < min_d: min_d = dist[i]; u = i
		if u == -1 or u == goal_idx: break
		visited[u] = true
		for edge in _adj[u]:
			var v = edge["to"]; var nd = dist[u] + edge["weight"]
			if nd < dist[v]: dist[v] = nd; prev[v] = u
	if prev[goal_idx] == -1 and start_idx != goal_idx: return []
	var path = []; var cur = goal_idx
	while cur != -1: path.push_front(cur); cur = prev[cur]
	return path

static func _plat_index(plat: Dictionary) -> int:
	for i in range(GameWorld.platforms.size()):
		if GameWorld.platforms[i] == plat: return i
	return -1

static func _find_path(from_plat: Dictionary, to_plat: Dictionary) -> Array:
	if GameWorld.platforms.size() == 0: return []
	var si = _plat_index(from_plat); var ti = _plat_index(to_plat)
	if si < 0 or ti < 0: return []
	var idx_path = _dijkstra(si, ti)
	if idx_path.size() == 0: return []
	var result = []
	for idx in idx_path: result.append(GameWorld.platforms[idx])
	return result
