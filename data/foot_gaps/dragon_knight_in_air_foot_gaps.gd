# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name DRAGON_KNIGHT_IN_AIR_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_IN_AIR_FOOT: Array[int] = [38, 36, 39, 43, 48, 50, 49, 44, 39]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_IN_AIR_HEAD: Array[int] = [164, 111, 137, 254, 249, 246, 247, 228, 197]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_IN_AIR_CENTER: Array[float] = [-9.5, -19.5, -14.0, 0.0, -2.0, -0.5, 1.0, -5.0, -2.0]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_IN_AIR_CONTENT_W: Array[int] = [749, 661, 740, 768, 738, 577, 620, 740, 764]
const DRAGON_KNIGHT_IN_AIR_CONTENT_H: Array[int] = [566, 621, 592, 471, 471, 472, 472, 496, 532]

## 汇总（median）
const DRAGON_KNIGHT_IN_AIR_FOOT_MEDIAN: int = 43
const DRAGON_KNIGHT_IN_AIR_HEAD_MEDIAN: int = 228
const DRAGON_KNIGHT_IN_AIR_CENTER_MEDIAN: float = -2.0
const DRAGON_KNIGHT_IN_AIR_HEIGHT_MEDIAN: int = 496
