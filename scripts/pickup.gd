class_name Pickup

var x: float
var y: float
var w: float = 16
var h: float = 16
var type: String
var active: bool = true
var glow: float = 0.0
var bob: float = 0.0

const PICKUP_DEFS := {
	"energy": {"weight": 0.5, "hard_weight": 0.5, "color": Color(0, 0.67, 1.0), "symbol": "⚡"},
	"health": {"weight": 0.3, "hard_weight": 0.3, "color": Color(0.27, 1.0, 0.27), "symbol": "❤"},
	"attack": {"weight": 0.1, "hard_weight": 0.1, "color": Color(1.0, 0.27, 0.27), "symbol": "⚔"},
	"cooldown": {"weight": 0.1, "hard_weight": 0.1, "color": Color(1.0, 0.87, 0.0), "symbol": "↻"},
}

func _init(p_x: float, p_y: float, p_type: String):
	x = p_x
	y = p_y
	type = p_type
	glow = randf() * PI * 2
	bob = randf() * 100

func update() -> bool:
	glow += 0.04
	bob += 0.02
	y += sin(bob) * 0.1
	return active

func apply_effect(target: Fighter):
	var def = PICKUP_DEFS.get(type)
	if not def:
		return
	match type:
		"energy":
			target.energy = minf(target.max_energy, target.energy + 20)
			if target.char_id == "archer":
				target.arrows = mini(target.max_arrows, target.arrows + 5)

		"health":
			target.hp = minf(target.max_hp, target.hp + 20)
		"attack":
			target.attack_boost = 10
			target.boost_timer = 180
		"cooldown":
			if target.char_id == "archer":
				target.arrows = mini(target.max_arrows, target.arrows + 5)
			var skill_keys = ["skill1", "skill2", "ult"]
			var key = skill_keys[randi() % skill_keys.size()]
			var skill = target.get_skill(key)
			if skill:
				skill.cd = 0

func draw(canvas: CanvasItem, cam_x: float):
	if not active:
		return
	var px = x - cam_x
	if px < -30 or px > Constants.W + 30:
		return
	var def = PICKUP_DEFS.get(type)
	var color: Color = def["color"] if def else Color.WHITE
	var symbol: String = def["symbol"] if def else "?"
	var pulse = 1.0 + 0.1 * sin(glow)
	canvas.draw_circle(Vector2(px + w/2, y + h/2), 10 * pulse, color)
	canvas.draw_circle(Vector2(px + w/2, y + h/2), 5 * pulse, Color.WHITE)
	# Draw symbol as text
	var font = ThemeDB.fallback_font
	canvas.draw_string(font, Vector2(px + w/2 - 4, y + h/2 + 4), symbol, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.BLACK)
