extends SceneTree
## 地图验证脚本：加载地图场景，检查所有 TerrainTile 是否成功生成纹理
##
## 用法（项目根目录）:
##   godot --headless -s res://maps/verify_map.gd -- res://maps/map_03_broken_bridge.tscn
## 不传参数时默认验证 map_03_broken_bridge.tscn
## 退出码: 0 = 全部通过, 1 = 加载失败或存在无纹理的地形块

var _tiles := 0
var _errors := 0

func _init():
	var args := OS.get_cmdline_user_args()
	var map_path := "res://maps/map_03_broken_bridge.tscn"
	if not args.is_empty():
		map_path = args[0]

	print("[VerifyMap] 加载: ", map_path)
	var scene: PackedScene = load(map_path)
	if scene == null:
		printerr("[VerifyMap] 场景加载失败: ", map_path)
		quit(1)
		return

	var inst := scene.instantiate()
	_check_tiles(inst)
	print("[VerifyMap] 完成: tiles=", _tiles, " errors=", _errors)
	inst.free()
	quit(1 if _errors > 0 else 0)

func _check_tiles(node: Node) -> void:
	for child in node.get_children():
		if child is TerrainTile:
			_tiles += 1
			if child.texture == null:
				_errors += 1
				printerr("[VerifyMap] 无纹理: ", child.get_path())
			else:
				var t: Texture2D = child.texture
				print("[VerifyMap] ", child.name, " tex=", t.get_width(), "x", t.get_height(), " scale=", child.scale)
		_check_tiles(child)
