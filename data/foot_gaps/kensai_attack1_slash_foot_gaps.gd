# 本文件由 scan_feet_offsets.py 生成并整理，数据来源：assets/char_ani/kensai/attack1/sheet。.png（普攻1刀光）
# 每帧刀光锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  内容底部到帧底部的空隙
#   head_gap:  内容顶部到帧顶部的空隙
#   center_dx: 内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 刀光实际内容尺寸
# 帧尺寸: 1080x1080（3列×3行，仅前8帧有效，第9帧空白已剔除）

class_name KENSAI_ATTACK1_SLASH_FootGaps

## 每帧脚底偏移（foot_gap）
const KENSAI_ATTACK1_SLASH_FOOT: Array[int] = [203, 203, 204, 145, 145, 135, 135, 123]

## 每帧头顶偏移（head_gap）
const KENSAI_ATTACK1_SLASH_HEAD: Array[int] = [438, 438, 438, 418, 418, 339, 339, 396]

## 每帧中轴水平偏移（center_dx）
const KENSAI_ATTACK1_SLASH_CENTER: Array[float] = [-203.0, -203.0, -203.0, 12.0, 12.0, 40.0, 42.0, -121.0]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_ATTACK1_SLASH_CONTENT_W: Array[int] = [556, 556, 556, 966, 966, 922, 926, 764]
const KENSAI_ATTACK1_SLASH_CONTENT_H: Array[int] = [439, 439, 438, 517, 517, 606, 606, 561]

## 汇总（median）
const KENSAI_ATTACK1_SLASH_FOOT_MEDIAN: int = 145
const KENSAI_ATTACK1_SLASH_HEAD_MEDIAN: int = 418
const KENSAI_ATTACK1_SLASH_CENTER_MEDIAN: float = 12.0
const KENSAI_ATTACK1_SLASH_HEIGHT_MEDIAN: int = 517
