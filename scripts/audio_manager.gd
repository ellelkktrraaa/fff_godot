extends Node

# ═══════════════════════════════════════════════════════════════
# AudioManager — 全局音频管理器 (Autoload)
# 基于 AudioLayer 池，支持 MP3/OGG/WAV，淡入淡出 / 截断 / 循环
# ═══════════════════════════════════════════════════════════════

const MAX_LAYERS := 16

var _sound_configs: Dictionary = {}       # id → AudioConfig
var _layers: Array = []
var _loop_configs: Dictionary = {}        # id → AudioLayer (循环音效追踪)

# 场景 BGM 状态（play_music 专用，跨界面切换时自动交叉淡入淡出）
var _current_music_id := ""
var _current_music_layer: AudioLayer = null

func _ready():
	for i in range(MAX_LAYERS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		var layer = AudioLayer.new()
		layer.init(player, "SFX")
		_layers.append(layer)
	_register_all_sounds()

func _register_all_sounds():
	register_sound("bard_perform", "res://assets/char_ani/bard/BGM/Whisper of the Leaves.mp3",
		{"loop": true, "volume": 0.7, "fade_in_ms": 300, "fade_out_ms": 300, "category": AudioConfig.Category.MUSIC})
	# ── 场景 BGM（按界面分目录：assets/audio/{bgm_界面名}/ 每个目录一首曲目）──
	# 主界面（The Dawn.mp3）+ 选人/天赋界面（bgm_menu.mp3）各一首
	register_sound("bgm_menu", "res://assets/audio/The Dawn.mp3",
		{"loop": true, "volume": 0.7, "priority": AudioConfig.Priority.LOW,
		 "category": AudioConfig.Category.MUSIC,
		 "fade_in_ms": 1500, "fade_out_ms": 1500, "fade_curve": AudioConfig.FadeCurve.EASE_IN_OUT})
	register_sound("bgm_select", "res://assets/audio/bgm_menu/bgm_menu.mp3",
		{"loop": true, "volume": 0.7, "priority": AudioConfig.Priority.LOW,
		 "category": AudioConfig.Category.MUSIC,
		 "fade_in_ms": 1000, "fade_out_ms": 1000, "fade_curve": AudioConfig.FadeCurve.EASE_IN_OUT})
	# 战斗界面（两首随机：bgm_battle.mp3 / Echo Of The Ruin.mp3，每场战斗随机播一首）
	register_sound("bgm_battle", "res://assets/audio/bgm_battle/bgm_battle.mp3",
		{"loop": true, "volume": 0.7, "priority": AudioConfig.Priority.LOW,
		 "category": AudioConfig.Category.MUSIC,
		 "fade_in_ms": 1200, "fade_out_ms": 1500, "fade_curve": AudioConfig.FadeCurve.EASE_IN_OUT})
	register_sound("bgm_battle_alt", "res://assets/audio/bgm_battle/Echo Of The Ruin.mp3",
		{"loop": true, "volume": 0.7, "priority": AudioConfig.Priority.LOW,
		 "category": AudioConfig.Category.MUSIC,
		 "fade_in_ms": 1200, "fade_out_ms": 1500, "fade_curve": AudioConfig.FadeCurve.EASE_IN_OUT})
	# boss 界面（预留，曲目已就位）
	register_sound("bgm_boss", "res://assets/audio/bgm_boss/bgm_boss.mp3",
		{"loop": true, "volume": 0.7, "priority": AudioConfig.Priority.LOW,
		 "category": AudioConfig.Category.MUSIC,
		 "fade_in_ms": 1000, "fade_out_ms": 1500, "fade_curve": AudioConfig.FadeCurve.EASE_IN_OUT})

# ── 注册音效 ──

func register_sound(id: String, path: String, overrides: Dictionary = {}):
	"""注册一个音效配置。支持 .mp3 / .ogg / .wav。
	
	参数:
	  id       — 音效标识，如 "bard_perform"
	  path     — 资源路径，如 "res://assets/sfx/bard_perform.mp3"
	  overrides — 可选覆盖字段 (volume/loop/fade_in_ms/fade_out_ms/cutoff_ms 等)
	"""
	var cfg := AudioConfig.new(
		id,
		path,
		overrides.get("volume", 0.8),
		overrides.get("priority", AudioConfig.Priority.NORMAL),
		overrides.get("category", AudioConfig.Category.SFX_COMBAT),
		overrides.get("interrupt", AudioConfig.Interrupt.NONE),
		overrides.get("max_overlap", -1),
		overrides.get("fade_in_ms", 0),
		overrides.get("fade_out_ms", 0),
		overrides.get("cutoff_ms", 0),
		overrides.get("fade_curve", AudioConfig.FadeCurve.LINEAR),
		overrides.get("resumable", false),
		overrides.get("pitch_variation", 0.0),
		overrides.get("loop", false),
	)
	_sound_configs[id] = cfg
	print("[Audio] 注册音效: ", id, " → ", path)

# ── 播放 ──

func play_sound(id: String):
	"""播放已注册的音效（兼容旧接口）。
	未注册的音效仅打印提示，不会报错。"""
	if not _sound_configs.has(id):
		print("[Audio] ⚠ 未注册音效: ", id)
		return
	var layer := _find_idle_layer()
	if not layer:
		print("[Audio] ⚠ 无空闲音轨: ", id)
		return
	layer.play(_sound_configs[id])

func play_loop(id: String):
	"""循环播放音效（如 BGM / 演奏）。停止时用 stop_loop(id)。"""
	if _loop_configs.has(id):
		return  # 已在循环中
	if not _sound_configs.has(id):
		print("[Audio] ⚠ 未注册循环音效: ", id)
		return
	var cfg = _sound_configs[id]
	if not cfg.loop:
		cfg.loop = true  # 强制循环
	var layer := _find_idle_layer()
	if not layer:
		print("[Audio] ⚠ 无空闲音轨: ", id)
		return
	layer.play(cfg)
	_loop_configs[id] = layer

func stop_loop(id: String):
	"""停止循环音效。"""
	var layer: AudioLayer = _loop_configs.get(id)
	if layer:
		layer.stop(true)
		_loop_configs.erase(id)

func stop_all():
	"""停止所有音效。"""
	for layer in _layers:
		if layer.is_active():
			layer.stop(false)
	_loop_configs.clear()
	_current_music_id = ""
	_current_music_layer = null

# ── 场景 BGM ──

## 播放场景 BGM（自动停止上一首，交叉淡入淡出切换）。
## 同一曲目文件被多个 ID 共用时（如 bgm_menu 与 bgm_select 指向同一首）不刷新播放，一首歌贯穿。
## 调用方式：AudioManager.play_music("bgm_menu" | "bgm_select" | "bgm_battle" | "bgm_boss")
func play_music(id: String):
	if _current_music_id == id:
		return  # 同一首已在播放
	# 同一曲目文件（不同 ID 共用一首）：保持当前播放不刷新，仅更新记录
	if _current_music_layer and _current_music_layer.config \
			and _sound_configs.has(id) \
			and _current_music_layer.config.path == _sound_configs[id].path:
		_current_music_id = id
		return
	stop_music()
	if not _sound_configs.has(id):
		print("[Audio] ⚠ 未注册 BGM: ", id)
		return
	var layer := _find_idle_layer()
	if not layer:
		print("[Audio] ⚠ 无空闲音轨播放 BGM: ", id)
		return
	var cfg = _sound_configs[id]
	layer.play(cfg)
	if layer.current_config_id() == "":
		print("[Audio] ⚠ BGM 加载失败: ", id, " → ", cfg.path,
			"（请确认文件存在于 assets/audio/bgm_*/ 目录）")
		return
	_current_music_id = id
	_current_music_layer = layer

## 停止当前 BGM（淡出）
func stop_music(fade_out: bool = true):
	if _current_music_layer:
		_current_music_layer.stop(fade_out)
	_current_music_id = ""
	_current_music_layer = null

# ── 内部 ──

func _find_idle_layer() -> AudioLayer:
	for layer in _layers:
		if layer.is_idle():
			return layer
	return null
