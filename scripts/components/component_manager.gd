class_name ComponentManager

var components: Dictionary = {}
var owner: Fighter = null

func init(owner: Fighter):
	self.owner = owner
	_setup_components()

func _setup_components():
	var comp = CharacterFactory.create_component(owner.char_id, owner)
	if comp:
		components[owner.char_id] = comp

func update():
	for comp in components.values():
		comp.update()

func on_damage_received(attacker: Fighter, dmg: float):
	for comp in components.values():
		comp.on_damage_received(attacker, dmg)

func on_pre_damage(attacker: Fighter, dmg: float) -> float:
	var d = dmg
	for comp in components.values():
		d = comp.on_pre_damage(attacker, d)
	return d

func on_attack_hit(target: Fighter, dmg: float):
	for comp in components.values():
		comp.on_attack_hit(target, dmg)

func get_component(key: Variant, default: Variant = null) -> Variant:
	return components.get(key, default)

func has_component(key: Variant) -> bool:
	return components.has(key)

func size() -> int:
	return components.size()

func keys() -> Array:
	return components.keys()

func values() -> Array:
	return components.values()
