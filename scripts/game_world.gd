extends Node

# Game state
var game_running := false
var game_over := false
var game_result := ""  # "win" or "lose"
var game_mode := "pve" # "pve" or "pvp"
var difficulty := "medium"
var frame := 0
var hit_stop := 0

# Slow motion
var slow_mo_timer := 0
var slow_mo_tick := 0
const SLOW_FACTOR := 3
const SLOW_DURATION := 90
const SLOW_MAX := 300

# Entities
var player = null
var enemy = null
var entities: Array = []

# World arrays
var projectiles: Array = []
var particles: Array = []
var pickups: Array = []
var flame_zones: Array = []
var explosion_effects: Array = []
var tornadoes: Array = []
var vortexes: Array = []
var phantoms: Array = []
var evoker_summons: Array = []
var void_rifts: Array = []
var evoker_fire_seas: Array = []
var gravity_balls: Array = []
var rose_slash_trails: Array = []
var rose_joystick_dir: Vector2 = Vector2.ZERO
var active_overlays: Array = []  # [{anim, position, owner, overlay_id, on_finish}]

# Platforms
var platforms: Array = []

# Camera
var camera := {"x": 0.0}
var screen_shake_intensity: float = 0.0
var screen_shake_duration: int = 0

# Pickup timer
var pickup_timer := 0.0

# Selected character
var selected_char_id := "knight"

func _ready():
	init_platforms()

func init_platforms():
	platforms = [
		{"x": 0, "y": Constants.GROUND_Y, "w": Constants.MAP_W, "h": 10, "is_ground": true},
		{"x": 400, "y": Constants.GROUND_Y - 120, "w": 120, "h": 12},
		{"x": 1000, "y": Constants.GROUND_Y - 160, "w": 140, "h": 12},
		{"x": 1600, "y": Constants.GROUND_Y - 110, "w": 130, "h": 12},
	]

func reset_world():
	projectiles.clear()
	particles.clear()
	pickups.clear()
	flame_zones.clear()
	explosion_effects.clear()
	tornadoes.clear()
	vortexes.clear()
	phantoms.clear()
	evoker_summons.clear()
	void_rifts.clear()
	evoker_fire_seas.clear()
	gravity_balls.clear()
	rose_slash_trails.clear()
	active_overlays.clear()
	entities.clear()
	camera.x = 0
	pickup_timer = 0
	slow_mo_timer = 0
	slow_mo_tick = 0

func get_opponent(fighter: Fighter) -> Fighter:
	if fighter == player:
		return enemy
	return player

func trigger_slow_motion(duration: int = SLOW_DURATION):
	if game_mode == "pvp":
		return
	slow_mo_timer = min(SLOW_MAX, slow_mo_timer + duration)
