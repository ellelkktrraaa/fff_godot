# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name DRAGON_KNIGHT_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_WALK_FOOT: Array[int] = [36, 39, 40, 40, 41, 38, 38, 37, 33, 33, 33]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_WALK_HEAD: Array[int] = [64, 64, 63, 61, 60, 61, 62, 64, 65, 63, 62]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_WALK_CENTER: Array[float] = [3.5, 3.25, 3.0, 5.0, 7.25, 10.0, 10.25, 8.0, 6.25, 6.75, 4.5]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_WALK_CONTENT_W: Array[int] = [320, 324, 327, 325, 323, 323, 324, 329, 329, 325, 328]
const DRAGON_KNIGHT_WALK_CONTENT_H: Array[int] = [284, 282, 282, 283, 284, 286, 285, 284, 287, 288, 289]

## 汇总（median）
const DRAGON_KNIGHT_WALK_FOOT_MEDIAN: int = 38
const DRAGON_KNIGHT_WALK_HEAD_MEDIAN: int = 63
const DRAGON_KNIGHT_WALK_CENTER_MEDIAN: float = 6.25
const DRAGON_KNIGHT_WALK_HEIGHT_MEDIAN: int = 284
