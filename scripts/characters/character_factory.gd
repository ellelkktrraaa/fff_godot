class_name CharacterFactory

const Knight = preload("res://scripts/characters/knight.gd")
const Mage = preload("res://scripts/characters/mage.gd")
const Archer = preload("res://scripts/characters/archer.gd")
const Paladin = preload("res://scripts/characters/paladin.gd")
const Witch = preload("res://scripts/characters/witch.gd")
const Assassin = preload("res://scripts/characters/assassin.gd")
const Shadowwarrior = preload("res://scripts/characters/shadowwarrior.gd")
const Evoker = preload("res://scripts/characters/evoker.gd")
const Rose = preload("res://scripts/characters/rose.gd")
const DragonKnight = preload("res://scripts/characters/dragon_knight.gd")

static var _char_registry := {
	"knight": { "cls": Knight, "config": null },
	"mage": { "cls": Mage, "config": null },
	"archer": { "cls": Archer, "config": null },
	"paladin": { "cls": Paladin, "config": null },
	"witch": { "cls": Witch, "config": null },
	"assassin": { "cls": Assassin, "config": null },
	"shadowwarrior": { "cls": Shadowwarrior, "config": null },
	"evoker": { "cls": Evoker, "config": null },
	"rose": { "cls": Rose, "config": null },
	# "dragon_knight": { "cls": DragonKnight, "config": null },  # 暂时移出
}

static func get_config(char_id: String) -> Dictionary:
	var entry = _char_registry.get(char_id, {})
	if entry.is_empty():
		printerr("[CharacterFactory] get_config: unknown char_id=", char_id)
		return {}
	if entry.get("config") == null:
		print("[CharacterFactory] calling get_config() for: ", char_id)
		entry["config"] = entry["cls"].get_config()
		print("[CharacterFactory] get_config() returned for: ", char_id, " empty=", entry["config"].is_empty())
	return entry["config"]

static func create_skills(char_id: String) -> Array:
	var entry = _char_registry.get(char_id, {})
	if entry.is_empty():
		return []
	return entry["cls"].create_skills()
