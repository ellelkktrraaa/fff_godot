class_name FrameAnimation
extends RefCounted

## 逐帧动画纯数据/计时层 — 不包含任何渲染位置信息
## 位置通过外部 position_spec 注入

class FrameData:
	var texture: Texture2D
	var duration_seconds: float
	var foot_gap: int = 0   # 脚底到帧底部（ground 基准）的偏移，单位：原始像素
	var head_gap: int = 0   # 头顶到帧顶部的偏移
	var center_dx: float = 0.0  # 内容中轴相对帧中心线的水平偏移（正=偏右）
	var content_w: int = 0  # 内容实际宽度（去掉透明边）
	var content_h: int = 0  # 内容实际高度

	func _init(
		p_tex: Texture2D,
		p_dur: float,
		p_foot_gap: int = 0,
		p_head_gap: int = 0,
		p_center_dx: float = 0.0,
		p_content_w: int = 0,
		p_content_h: int = 0
	):
		texture = p_tex
		duration_seconds = p_dur
		foot_gap = p_foot_gap
		head_gap = p_head_gap
		center_dx = p_center_dx
		content_w = p_content_w
		content_h = p_content_h

var frames: Array[FrameData] = []
var total_duration: float = 0.0
var loop: bool = false
var content_h_ref: int = 0  # 锚点参考内容高度（各帧 content_h 的中位数）：渲染统一缩放基准，避免逐帧归一化导致大小抖动

# Runtime state
var _timer: float = 0.0
var _current_index: int = 0
var _playing: bool = false
var _finished: bool = false

# 跳跃动画状态（由 load_jump_sheet 创建时启用）
var jump_sheet: bool = false       # 前 N-1 帧起跳 + 最后一帧滞空 的专用结构
var _jump_state: String = ""       # "takeoff" 起跳 / "hold" 滞空 / "landing" 落地倒放
const JUMP_HOLD_DURATION := 999.0  # 滞空帧时长：到达后保持不动

## 从帧数据加载动画（不依赖外部 .txt 文件）
## frame_specs: Array[Dictionary] —— [{"index":1, "duration":999.0}, ...]
## 可选字段 "filename" 用于自定义文件名（省略时使用 prefix+index+.png）
static func load_from_frames(dir_path: String, prefix: String, frame_specs: Array, p_loop: bool = false) -> FrameAnimation:
	var anim = FrameAnimation.new()
	anim.loop = p_loop
	
	var loaded_count := 0
	for spec in frame_specs:
		var spec_d: Dictionary = spec as Dictionary
		if spec_d == null or spec_d.is_empty():
			continue
		var frame_num: int = spec_d["index"]
		var duration: float = spec_d["duration"]
		var custom_name: String = spec_d.get("filename", "")
		
		var file_name: String
		if not custom_name.is_empty():
			file_name = custom_name
		else:
			file_name = prefix + str(frame_num) + ".png"
		
		var full_path = dir_path + file_name
		
		# 直接 load()，不做存在性检查
		var tex: Texture2D = load(full_path)
		
		# 回退扩展名：png → jpg
		if not tex and file_name.ends_with(".png"):
			var jpg_path = dir_path + file_name.trim_suffix(".png") + ".jpg"
			tex = load(jpg_path)
		
		if tex and tex is Texture2D:
			anim.add_frame(tex, duration)
			loaded_count += 1
		else:
			push_error("[FrameAnimation] Failed to load frame: " + full_path)
	
	print("[FrameAnimation] Loaded ", loaded_count, "/", frame_specs.size(), " frames from ", dir_path)
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

## 从精灵图集（sprite sheet）加载动画 —— 只加载一张大纹理，每帧用 AtlasTexture 切分
## sheet_path: 图集图片路径（res://...png）
## columns/rows: 图集行列数（来自视频切帧的图理论上等宽高，直接整除即可）
## frame_count: 实际帧数（最后一行右边可能有空白区域，用它跳过空位）
## duration_seconds: 每帧时长（视频切帧通常统一，如 0.1）
## anchors: 可选，每帧锚点字典 {foot_gap, head_gap, center_dx, content_w, content_h}
##          （由 scan_feet_offsets.py 生成的 GDScript 常量传入）
static func load_from_sprite_sheet(
	sheet_path: String,
	columns: int,
	rows: int,
	frame_count: int,
	duration_seconds: float = 0.1,
	p_loop: bool = false,
	anchors: Array = []
) -> FrameAnimation:
	var anim = FrameAnimation.new()
	anim.loop = p_loop

	var atlas: Texture2D = load(sheet_path)
	if not atlas:
		push_error("[FrameAnimation] Failed to load sprite sheet: " + sheet_path)
		return anim

	var cell_w: int = floori(float(atlas.get_width()) / columns)
	var cell_h: int = floori(float(atlas.get_height()) / rows)

	var loaded_count := 0
	for i in range(frame_count):
		var col: int = i % columns
		var row: int = floori(float(i) / columns)
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = atlas
		atlas_tex.region = Rect2(col * cell_w, row * cell_h, cell_w, cell_h)
		var anchor: Dictionary = anchors[i] if i < anchors.size() and anchors[i] is Dictionary else {}
		anim.add_frame(
			atlas_tex,
			duration_seconds,
			anchor.get("foot_gap", 0),
			anchor.get("head_gap", 0),
			anchor.get("center_dx", 0.0),
			anchor.get("content_w", 0),
			anchor.get("content_h", 0),
		)
		loaded_count += 1

	print("[FrameAnimation] Loaded ", loaded_count, "/", frame_count, " frames from sprite sheet ", sheet_path)
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

## 从精灵图集加载跳跃动画：前 N-1 帧为起跳（合计 takeoff_seconds 秒），最后一帧为滞空保持。
## 落地时由 Fighter 调用 start_landing() 反向播放起跳帧（跳过滞空帧）。所有角色共用。
static func load_jump_sheet(
	sheet_path: String,
	columns: int,
	rows: int,
	frame_count: int,
	takeoff_seconds: float = 0.2,
	anchors: Array = []
) -> FrameAnimation:
	var anim = FrameAnimation.new()
	anim.loop = false
	anim.jump_sheet = true

	var atlas: Texture2D = load(sheet_path)
	if not atlas:
		push_error("[FrameAnimation] Failed to load sprite sheet: " + sheet_path)
		return anim

	var cell_w: int = floori(float(atlas.get_width()) / columns)
	var cell_h: int = floori(float(atlas.get_height()) / rows)
	var takeoff_frames: int = maxi(0, frame_count - 1)
	var per_frame: float = takeoff_seconds / float(maxi(1, takeoff_frames))

	for i in range(frame_count):
		var col: int = i % columns
		var row: int = floori(float(i) / columns)
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = atlas
		atlas_tex.region = Rect2(col * cell_w, row * cell_h, cell_w, cell_h)
		var anchor: Dictionary = anchors[i] if i < anchors.size() and anchors[i] is Dictionary else {}
		var is_hold: bool = i >= takeoff_frames
		anim.add_frame(
			atlas_tex,
			JUMP_HOLD_DURATION if is_hold else per_frame,
			anchor.get("foot_gap", 0),
			anchor.get("head_gap", 0),
			anchor.get("center_dx", 0.0),
			anchor.get("content_w", 0),
			anchor.get("content_h", 0),
		)
	anim._calc_total_duration()
	anim._calc_content_h_ref()
	return anim

func add_frame(
	texture: Texture2D,
	duration_seconds: float,
	foot_gap: int = 0,
	head_gap: int = 0,
	center_dx: float = 0.0,
	content_w: int = 0,
	content_h: int = 0
):
	frames.append(FrameData.new(texture, duration_seconds, foot_gap, head_gap, center_dx, content_w, content_h))

func _calc_total_duration():
	total_duration = 0.0
	for f in frames:
		total_duration += f.duration_seconds

## 计算锚点参考内容高度：各帧 content_h 的中位数（忽略 0/无锚点帧）
func _calc_content_h_ref():
	var vals: Array = []
	for f in frames:
		if f.content_h > 0:
			vals.append(f.content_h)
	if vals.is_empty():
		content_h_ref = 0
		return
	vals.sort()
	content_h_ref = vals[vals.size() / 2]

## 播放。resume=true 时若动画已在播放则保持当前帧位置继续（循环动画切状态不跳帧）
func play(resume: bool = false):
	if resume and _playing and not _finished:
		return
	_playing = true
	_finished = false
	_timer = 0.0
	_current_index = 0
	if jump_sheet:
		_jump_state = "takeoff"

func stop():
	_playing = false
	_finished = true

func reset():
	_timer = 0.0
	_current_index = 0
	_finished = false
	if jump_sheet:
		_jump_state = "takeoff"

## 落地倒放：从最后一个起跳帧反向播回第 0 帧（跳过滞空帧），由 Fighter 在落地时调用
func start_landing():
	if not jump_sheet or frames.size() < 2:
		return
	_playing = true
	_finished = false
	_timer = 0.0
	_current_index = frames.size() - 2
	_jump_state = "landing"

## 跳跃动画是否已推进到滞空帧（起跳结束）
func is_hold_phase() -> bool:
	return jump_sheet and _jump_state == "hold"

## 落地倒放是否已结束（回到第 0 帧）
func is_landing_done() -> bool:
	return jump_sheet and _jump_state == "landing" and _finished

## 每帧更新 (frame_dt: 经过的帧数, 1 ≈ 1/60s)
func update(frame_dt: float = 1.0):
	if not _playing or _finished or frames.is_empty():
		return

	# 跳跃动画：起跳帧推进到滞空帧后保持；落地阶段反向播放
	if jump_sheet:
		if _jump_state == "hold":
			return
		if _jump_state == "landing":
			_update_landing(frame_dt)
			return
		if _current_index >= frames.size() - 1:
			_jump_state = "hold"
			return

	var dt_seconds = frame_dt / 60.0
	_timer += dt_seconds
	
	while _timer >= frames[_current_index].duration_seconds:
		if _current_index < frames.size() - 1:
			_timer -= frames[_current_index].duration_seconds
			_current_index += 1
		elif loop:
			_timer -= frames[_current_index].duration_seconds
			_current_index = 0
		else:
			_finished = true
			_playing = false
			_current_index = frames.size() - 1
			break

## 落地倒放推进：从最后一个起跳帧反向走到第 0 帧
func _update_landing(frame_dt: float = 1.0):
	var dt_seconds = frame_dt / 60.0
	_timer += dt_seconds
	while _timer >= frames[_current_index].duration_seconds:
		if _current_index > 0:
			_timer -= frames[_current_index].duration_seconds
			_current_index -= 1
		else:
			_finished = true
			_playing = false
			break

func get_current_texture() -> Texture2D:
	if frames.is_empty() or _current_index >= frames.size():
		return null
	return frames[_current_index].texture

## 当前帧脚底偏移（原始像素）；用于渲染时把脚底对齐地面
func get_current_foot_gap() -> int:
	if frames.is_empty() or _current_index >= frames.size():
		return 0
	return frames[_current_index].foot_gap

## 当前帧头顶偏移（原始像素）
func get_current_head_gap() -> int:
	if frames.is_empty() or _current_index >= frames.size():
		return 0
	return frames[_current_index].head_gap

## 当前帧中轴水平偏移（原始像素，正=内容中轴在帧中心右侧）
func get_current_center_dx() -> float:
	if frames.is_empty() or _current_index >= frames.size():
		return 0.0
	return frames[_current_index].center_dx

## 当前帧内容尺寸（去掉透明边后的实际宽高）
func get_current_content_size() -> Vector2i:
	if frames.is_empty() or _current_index >= frames.size():
		return Vector2i.ZERO
	return Vector2i(frames[_current_index].content_w, frames[_current_index].content_h)

## 当前帧索引（0 起）
func get_current_index() -> int:
	return _current_index

## 直接跳到指定帧（供滞空循环等自定义帧控制），并把帧内计时清零
func set_frame_index(idx: int) -> void:
	if frames.is_empty():
		return
	_current_index = clampi(idx, 0, frames.size() - 1)
	_timer = 0.0

## 当前帧时长（秒）
func get_current_duration() -> float:
	if frames.is_empty() or _current_index >= frames.size():
		return 0.0
	return frames[_current_index].duration_seconds

func is_playing() -> bool:
	return _playing and not _finished

func is_finished() -> bool:
	return _finished

func get_progress() -> float:
	if total_duration <= 0:
		return 0.0
	var elapsed = 0.0
	for i in _current_index:
		elapsed += frames[i].duration_seconds
	elapsed += minf(_timer, frames[_current_index].duration_seconds)
	return clampf(elapsed / total_duration, 0.0, 1.0)
