# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 960x720

class_name ARCHER_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_ATTACK_FOOT: Array[int] = [6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]

## 每帧头顶偏移（head_gap）
const ARCHER_ATTACK_HEAD: Array[int] = [0, 0, 0, 0, 0, 3, 4, 5, 6, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_ATTACK_CENTER: Array[float] = [98.5, 77.5, 72.0, 57.0, 51.5, 40.0, 37.0, 28.0, 26.5, 22.5, 21.0, 18.5, 18.0, 17.5, 18.0, 17.0, 17.0, 17.5, 17.5, 17.5, 17.5, 17.5]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_ATTACK_CONTENT_W: Array[int] = [763, 757, 750, 724, 713, 692, 686, 668, 665, 657, 654, 651, 650, 649, 648, 648, 648, 647, 647, 647, 647, 647]
const ARCHER_ATTACK_CONTENT_H: Array[int] = [714, 715, 715, 715, 715, 712, 711, 710, 709, 708, 708, 708, 708, 708, 708, 709, 709, 709, 709, 709, 709, 709]

## 汇总（median）
const ARCHER_ATTACK_FOOT_MEDIAN: int = 5
const ARCHER_ATTACK_HEAD_MEDIAN: int = 6
const ARCHER_ATTACK_CENTER_MEDIAN: float = 21.0
const ARCHER_ATTACK_HEIGHT_MEDIAN: int = 709
