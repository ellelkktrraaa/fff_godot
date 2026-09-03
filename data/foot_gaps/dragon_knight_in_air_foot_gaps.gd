# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name DRAGON_KNIGHT_IN_AIR_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_IN_AIR_FOOT: Array[int] = [19, 18, 20, 22, 24, 25, 25, 22, 20]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_IN_AIR_HEAD: Array[int] = [82, 56, 69, 127, 125, 123, 124, 114, 99]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_IN_AIR_CENTER: Array[float] = [-4.75, -9.75, -7.0, 0.0, -1.0, -0.25, 0.5, -2.5, -1.0]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_IN_AIR_CONTENT_W: Array[int] = [375, 331, 370, 384, 369, 289, 310, 370, 382]
const DRAGON_KNIGHT_IN_AIR_CONTENT_H: Array[int] = [283, 311, 296, 236, 236, 236, 236, 248, 266]

## 汇总（median）
const DRAGON_KNIGHT_IN_AIR_FOOT_MEDIAN: int = 22
const DRAGON_KNIGHT_IN_AIR_HEAD_MEDIAN: int = 114
const DRAGON_KNIGHT_IN_AIR_CENTER_MEDIAN: float = -1.0
const DRAGON_KNIGHT_IN_AIR_HEIGHT_MEDIAN: int = 248
