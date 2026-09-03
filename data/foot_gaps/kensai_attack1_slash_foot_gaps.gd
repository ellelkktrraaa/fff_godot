# 本文件由 scan_feet_offsets.py 生成并整理，数据来源：assets/char_ani/kensai/attack1/sheet。.png（普攻1刀光）
# 每帧刀光锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  内容底部到帧底部的空隙
#   head_gap:  内容顶部到帧顶部的空隙
#   center_dx: 内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 刀光实际内容尺寸
# 帧尺寸: 540x540（3列×3行，仅前8帧有效，第9帧空白已剔除）

class_name KENSAI_ATTACK1_SLASH_FootGaps

## 每帧脚底偏移（foot_gap）
const KENSAI_ATTACK1_SLASH_FOOT: Array[int] = [102, 102, 102, 73, 73, 68, 68, 62]

## 每帧头顶偏移（head_gap）
const KENSAI_ATTACK1_SLASH_HEAD: Array[int] = [219, 219, 219, 209, 209, 170, 170, 198]

## 每帧中轴水平偏移（center_dx）
const KENSAI_ATTACK1_SLASH_CENTER: Array[float] = [-101.5, -101.5, -101.5, 6.0, 6.0, 20.0, 21.0, -60.5]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_ATTACK1_SLASH_CONTENT_W: Array[int] = [278, 278, 278, 483, 483, 461, 463, 382]
const KENSAI_ATTACK1_SLASH_CONTENT_H: Array[int] = [220, 220, 219, 259, 259, 303, 303, 281]

## 汇总（median）
const KENSAI_ATTACK1_SLASH_FOOT_MEDIAN: int = 73
const KENSAI_ATTACK1_SLASH_HEAD_MEDIAN: int = 209
const KENSAI_ATTACK1_SLASH_CENTER_MEDIAN: float = 6.0
const KENSAI_ATTACK1_SLASH_HEIGHT_MEDIAN: int = 259
