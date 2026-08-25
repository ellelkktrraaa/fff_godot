extends Node

## 临时复现：释放完二技能后能否移动
var player: Fighter
var enemy: Fighter
var comp

func _ready():
	CharConfigs.ensure_init()
	GameWorld.reset_world()
	var p_skills = CharacterFactory.create_skills("kensai")
	var e_skills = CharacterFactory.create_skills("knight")
	player = Fighter.new()
	player.setup(200, 400, true, "kensai", p_skills)
	add_child(player)
	enemy = Fighter.new()
	enemy.setup(600, 400, false, "knight", e_skills)
	add_child(enemy)
	GameWorld.player = player
	GameWorld.enemy = enemy
	GameWorld.entities = [player, enemy]
	comp = player.components.get_component("kensai")
	player.energy = 100.0
	comp.record_attack(3)
	comp.record_attack(1)
	_fire_ult()
	print("[A] after cast: skill1_active=", comp.skill1_active, " state=", player.state,
		" attacking=", player.attacking)
	# 推进到动画结束
	for i in range(120):
		CharacterFactory.update_char_systems(player)
	print("[B] after 120 frames: skill1_active=", comp.skill1_active,
		" stage=", comp.skill1_stage, " state=", player.state,
		" attacking=", player.attacking)
	# 模拟按住右移动
	var px0: float = player.pos_x
	var keys := {"left": false, "right": true, "up": false, "down": false,
		"attack": false, "skill1": false, "skill2": false, "ult": false}
	for i in range(30):
		CharacterFactory.Kensai.handle_input(player, keys)
		Fighter.apply_movement(player, 1, player.attack_speed)
		Fighter.update_state(player, 1)
	print("[C] after 30 frames right: pos_x=", player.pos_x, " (was ", px0, ") moved=", player.pos_x != px0)
	get_tree().quit(0)

func _fire_ult():
	var keys := {"ult": true, "attack": false, "skill1": false, "skill2": false,
		"left": false, "right": false, "up": false, "down": false}
	CharacterFactory.Kensai.handle_input(player, keys)
