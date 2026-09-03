# 本文件由 scan_feet_offsets.py 生成并整理，数据来源：assets/char_ani/kensai/attack1/sheet.png
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 720x540（3列×2行，仅前5帧有效，第6帧空白已剔除）

class_name KENSAI_ATTACK1_FootGaps

## 每帧脚底偏移（foot_gap）
const KENSAI_ATTACK1_FOOT: Array[int] = [14, 14, 31, 34, 34]

## 每帧头顶偏移（head_gap）
const KENSAI_ATTACK1_HEAD: Array[int] = [57, 57, 0, 41, 41]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KENSAI_ATTACK1_CENTER: Array[float] = [-23.5, -14.25, 8.0, 15.0, 15.25]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_ATTACK1_CONTENT_W: Array[int] = [378, 413, 474, 483, 484]
const KENSAI_ATTACK1_CONTENT_H: Array[int] = [470, 470, 509, 466, 466]

## 汇总（median）
const KENSAI_ATTACK1_FOOT_MEDIAN: int = 31
const KENSAI_ATTACK1_HEAD_MEDIAN: int = 41
const KENSAI_ATTACK1_CENTER_MEDIAN: float = 8.0
const KENSAI_ATTACK1_HEIGHT_MEDIAN: int = 470
