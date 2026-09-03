# TDD 测试：头顶锚点偏移 → anim_scale_states 倍率换算。
#
# 渲染公式推导（render_system.gd 锚点路径）：
#   scale = f.h / ref_h * anim_scale * state_scale
#   头顶屏幕位置 = py + f.h - content_h * scale = py + f.h * (1 - anim_scale * state_scale)
# head_gap / content_h 被完全抵消：头顶高度只由 anim_scale * state_scale 决定。
# 因此「移动头顶 N 像素」的锚点意图必须换算成 state_scale 倍率才能生效。
import math

from import_slqs import head_offset_to_scale


def test_zero_offset_keeps_scale():
    assert head_offset_to_scale(0, 304, 1.5) == 1.5


def test_negative_offset_raises_head_scale_up():
    # mounted_idle：头顶 -30（上移）→ 倍率增大（脚底固定，角色变高）
    got = head_offset_to_scale(-30, 304, 1.5)
    assert math.isclose(got, 1.5 * (1 + 30 / 304), rel_tol=1e-9)
    assert got > 1.5


def test_positive_offset_lowers_head_scale_down():
    # mounted_jump：头顶 +35（下移）→ 倍率减小（脚底固定，角色变矮）
    got = head_offset_to_scale(35, 275, 0.92)
    assert math.isclose(got, 0.92 * (1 - 35 / 275), rel_tol=1e-9)
    assert got < 0.92


def test_invalid_ref_h_returns_old_scale():
    assert head_offset_to_scale(-30, 0, 1.5) == 1.5
    assert head_offset_to_scale(-30, -1, 1.5) == 1.5


def test_conversion_matches_naive_anchor_displacement():
    # 语义等价验证：换算后头顶移动量 == 朴素锚点渲染下 head_gap 移动量。
    # 朴素渲染：head_gap 移动 offset → 头顶移动 offset * scale_total 屏幕像素
    # scale 渲染：头顶位置 = py + f.h * (1 - A)，A = anim_scale * state_scale
    f_h, anim_scale, old_state, ref_h, offset = 100.0, 1.2, 1.5, 300, -30
    new_state = head_offset_to_scale(offset, ref_h, old_state)
    a_old = anim_scale * old_state
    a_new = anim_scale * new_state
    head_move = f_h * (a_old - a_new)          # 负 = 上移
    naive_move = offset * (f_h / ref_h * a_old)
    assert math.isclose(head_move, naive_move, rel_tol=1e-9)
