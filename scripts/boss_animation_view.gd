extends Control

## Boss 选择界面的角色预览控件：把 FrameAnimation 画到自身（CanvasItem）并持续推进帧。
## 参考渲染先例 scripts/systems/render_system.gd::_draw_fighter（同一套锚点/缩放语义），
## 但这里没有战斗碰撞箱，改为"内容居中铺满预览区"的展示式绘制：
##   - 动画带内容锚点（content_h_ref>0，如骑士 idle 图集）：按内容高度缩放到预览区高度
##     的 FIT_H，内容中心对齐预览区中心，整帧贴图允许超出（透明边）由 clip_contents 裁掉；
##   - 无锚点单帧贴图（如圣骑士 idle 90x90）：按整帧等比缩放进预览区并居中。
## 无动画/无贴图时显示占位文字。

const PAD := 10.0      # 预览区内容留白
const FIT_H := 0.9     # 内容高度占可用区高度上限
const FIT_W := 0.98    # 整帧宽度占可用区宽度上限（防止超宽贴图被裁到内容）

var _anim: FrameAnimation = null
var _placeholder := ""

## 切换展示动画；anim 为 null 时展示 placeholder 文字。
func present(anim, placeholder := ""):
	_anim = anim
	_placeholder = placeholder if anim == null else ""
	if _anim:
		_anim.play()
		set_process(true)
	else:
		set_process(false)
	queue_redraw()

## 当前是否有可播放动画
func has_animation() -> bool:
	return _anim != null and not _anim.frames.is_empty()

func _process(delta: float):
	if _anim == null:
		set_process(false)
		return
	_anim.update(delta * 60.0)
	# 兜底：个别 idle 若为不可循环多帧，播完一镜后从头循环展示
	if _anim.is_finished():
		_anim.play()
	queue_redraw()

func _draw():
	var area_w := size.x
	var area_h := size.y
	var tex: Texture2D = _anim.get_current_texture() if _anim and not _anim.frames.is_empty() else null
	if tex == null:
		_draw_placeholder(area_w, area_h)
		return

	var tex_w := float(tex.get_width())
	var tex_h := float(tex.get_height())
	if tex_w <= 0.0 or tex_h <= 0.0:
		_draw_placeholder(area_w, area_h)
		return

	var avail_w := maxf(1.0, area_w - PAD * 2.0)
	var avail_h := maxf(1.0, area_h - PAD * 2.0)
	var cx := area_w * 0.5
	var cy := area_h * 0.5

	var tw := tex_w
	var th := tex_h
	var tx := cx - tw * 0.5
	var ty := cy - th * 0.5

	if _anim.content_h_ref > 0:
		# ── 锚点动画：按参考内容高度缩放，内容中轴/中心对齐预览区中心 ──
		var ref_h := float(_anim.content_h_ref)
		var scale := (avail_h * FIT_H) / ref_h
		# 宽度兜底：整帧过宽时回退到宽度约束（透明边裁切不影响内容可见）
		scale = minf(scale, (avail_w * FIT_W) / tex_w)
		tw = tex_w * scale
		th = tex_h * scale
		# 内容中心在帧内坐标为 (head_gap + content_h/2)，对齐预览区中心 cy
		ty = cy - (float(_anim.get_current_head_gap()) + ref_h * 0.5) * scale
		# 中轴水平偏移（渲染语义与 _draw_fighter 一致：内容中轴对齐帧中心）
		tx = cx - tw * 0.5 - _anim.get_current_center_dx() * scale
		# 脚下柔和光斑（置于角色内容底部）
		var ground_y := cy + ref_h * scale * 0.5
		_draw_ground_glow(cx, minf(ground_y, area_h - 4.0), ref_h * scale)
	else:
		# ── 无锚点单帧：整帧等比缩放并居中 ──
		var scale := minf(avail_w / tex_w, avail_h / tex_h)
		tw = tex_w * scale
		th = tex_h * scale
		tx = cx - tw * 0.5
		ty = cy - th * 0.5
		_draw_ground_glow(cx, minf(cy + th * 0.5, area_h - 4.0), th)

	draw_texture_rect(tex, Rect2(tx, ty, tw, th), false)

## 角色脚下椭圆光斑（仅装饰，让站立更稳）
func _draw_ground_glow(cx: float, ground_y: float, span: float):
	if span <= 0.0:
		return
	var rx := clampf(span * 0.34, 12.0, 120.0)
	var ry := clampf(span * 0.05, 4.0, 14.0)
	if rx <= 0.0 or ry <= 0.0:
		return
	draw_set_transform(Vector2(cx, ground_y), 0.0, Vector2(rx / ry, 1.0))
	draw_circle(Vector2.ZERO, ry, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_placeholder(area_w: float, area_h: float):
	var text := _placeholder
	if text == "":
		return
	var font := get_theme_default_font()
	if font == null:
		return
	var baseline := area_h * 0.5 + 5.0
	draw_string(font, Vector2(0, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, area_w, 15, Color(0.55, 0.55, 0.65))
