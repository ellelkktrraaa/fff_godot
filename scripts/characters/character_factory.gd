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
const Bard = preload("res://scripts/characters/bard.gd")
const Astrologer = preload("res://scripts/characters/astrologer.gd")
const NecroKnight = preload("res://scripts/characters/necro_knight.gd")
const Berserker = preload("res://scripts/characters/berserker.gd")

# Component preloads
const COMP_ARCHER = preload("res://scripts/components/archer_component.gd")
const COMP_PALADIN = preload("res://scripts/components/paladin_component.gd")
const COMP_WITCH = preload("res://scripts/components/witch_component.gd")
const COMP_ASSASSIN = preload("res://scripts/components/assassin_component.gd")
const COMP_SHADOWWARRIOR = preload("res://scripts/components/shadowwarrior_component.gd")
const COMP_EVOKER = preload("res://scripts/components/evoker_component.gd")
const COMP_ROSE = preload("res://scripts/components/rose_component.gd")
const COMP_KNIGHT = preload("res://scripts/components/knight_component.gd")
const COMP_MAGE = preload("res://scripts/components/char_component.gd")    # fallback
const COMP_DRAGON_KNIGHT = preload("res://scripts/components/char_component.gd")  # fallback
const COMP_BARD = preload("res://scripts/components/bard_component.gd")
const COMP_ASTROLOGER = preload("res://scripts/components/char_component.gd")  # fallback
const COMP_NECRO_KNIGHT = preload("res://scripts/components/necro_knight_component.gd")
const COMP_BERSERKER = preload("res://scripts/components/berserker_component.gd")

static var _char_registry := {
	"knight": { "cls": Knight, "config": null, "comp": COMP_KNIGHT },
	"mage": { "cls": Mage, "config": null, "comp": COMP_MAGE },
	"archer": { "cls": Archer, "config": null, "comp": COMP_ARCHER },
	"paladin": { "cls": Paladin, "config": null, "comp": COMP_PALADIN },
	"witch": { "cls": Witch, "config": null, "comp": COMP_WITCH },
	"assassin": { "cls": Assassin, "config": null, "comp": COMP_ASSASSIN },
	"shadowwarrior": { "cls": Shadowwarrior, "config": null, "comp": COMP_SHADOWWARRIOR },
	"evoker": { "cls": Evoker, "config": null, "comp": COMP_EVOKER },
	"rose": { "cls": Rose, "config": null, "comp": COMP_ROSE },
	"dragon_knight": { "cls": DragonKnight, "config": null, "comp": COMP_DRAGON_KNIGHT },
	"bard": { "cls": Bard, "config": null, "comp": COMP_BARD },
	"astrologer": { "cls": Astrologer, "config": null, "comp": COMP_ASTROLOGER },
	"necro_knight": { "cls": NecroKnight, "config": null, "comp": COMP_NECRO_KNIGHT },
	"berserker": { "cls": Berserker, "config": null, "comp": COMP_BERSERKER },
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

## 重置所有角色配置缓存（重开游戏时调用，避免大招修改的 config 残留）
static func reset_configs():
	for entry in _char_registry.values():
		entry["config"] = null

static func create_skills(char_id: String) -> Array:
	var entry = _char_registry.get(char_id, {})
	if entry.is_empty():
		return []
	return entry["cls"].create_skills()

## 调度角色输入处理（替代 InputHandler 中的 match char_id）
static func handle_input(char_id: String, fighter: Fighter, keys: Dictionary) -> int:
	var entry = _char_registry.get(char_id, {})
	var cls = entry.get("cls")
	if cls and cls.has_method("handle_input"):
		return cls.handle_input(fighter, keys)
	return 0

## 调度角色专属系统更新（替代 CharacterSystems 中的硬编码函数）
static func update_char_systems(fighter: Fighter):
	var entry = _char_registry.get(fighter.char_id, {})
	var cls = entry.get("cls")
	if cls and cls.has_method("update_systems"):
		cls.update_systems(fighter)

## 调用 rose 的刀光拖尾更新（跨实体逻辑）
static func call_rose_trails():
	var entry = _char_registry.get("rose", {})
	var cls = entry.get("cls")
	if cls and cls.has_method("update_rose_trails"):
		cls.update_rose_trails()

## 创建角色组件（替代 ComponentManager 中的 match char_id）
static func create_component(char_id: String, owner: Fighter) -> CharComponent:
	var entry = _char_registry.get(char_id, {})
	var comp_cls = entry.get("comp")
	if comp_cls:
		var comp = comp_cls.new()
		comp.init(owner)
		return comp
	return null

## 角色全局更新调度（替代 game.gd 直接调用 XXSystem.update()）
static func call_global_update(char_id: String):
	var entry = _char_registry.get(char_id, {})
	var cls = entry.get("cls")
	if cls and cls.has_method("update_global"):
		cls.update_global()

## 返回所有已注册角色 ID
static func get_all_char_ids() -> Array:
	return _char_registry.keys()

## 调度地狱模式 AI 战术（角色脚本实现，替代 AISystem 中的 match char_id）
## 返回已处理的状态（"ATTACK"/"DODGE"/"DEFEND"），空字符串表示未处理走默认 AI
static func call_ai_hell_tactics(f: Fighter, ctx: Dictionary) -> String:
	var entry = _char_registry.get(f.char_id, {})
	var cls = entry.get("cls")
	if cls and cls.has_method("ai_hell_tactics"):
		return cls.ai_hell_tactics(f, ctx)
	return ""

## 调度地狱模式专属走位参数（返回空字典表示不覆盖默认走位）
static func call_ai_hell_desire(f: Fighter) -> Dictionary:
	var entry = _char_registry.get(f.char_id, {})
	var cls = entry.get("cls")
	if cls and cls.has_method("ai_hell_desire"):
		return cls.ai_hell_desire(f)
	return {}

## 触发角色开场动画（有 play_intro 方法的角色）
static func play_intro(char_id: String):
	var entry = _char_registry.get(char_id, {})
	var cls = entry.get("cls")
	if cls and cls.has_method("play_intro"):
		cls.play_intro()

## 重新注入全局绘制（reset_world 清除后调用，仅无参版本）
static func reinject_draws():
	for cid in ["evoker", "witch", "astrologer", "necro_knight"]:
		var entry = _char_registry.get(cid, {})
		var cls = entry.get("cls")
		if cls:
			cls._inject_draw()
