extends SceneTree

func _init():
	var anim = FrameAnimation.load_from_sprite_sheet("res://assets/sheet_skeleton.png", 5, 4, 18, 0.05, false)
	print("[CHECK-SKEL] loaded=", anim.frames.size())
	if anim.frames.size() >= 3:
		anim.frames = anim.frames.slice(2, 18)
		anim._calc_total_duration()
	print("[CHECK-SKEL] sliced=", anim.frames.size(), " total=", anim.total_duration, " loop=", anim.loop)
	quit(0)
