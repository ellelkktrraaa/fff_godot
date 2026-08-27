# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name DRAGON_KNIGHT_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_WALK_FOOT: Array[int] = [72, 77, 80, 80, 81, 75, 75, 73, 65, 66, 66]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_WALK_HEAD: Array[int] = [128, 127, 125, 122, 120, 121, 124, 128, 129, 126, 124]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_WALK_CENTER: Array[float] = [7.0, 6.5, 6.0, 10.0, 14.5, 20.0, 20.5, 16.0, 12.5, 13.5, 9.0]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_WALK_CONTENT_W: Array[int] = [640, 647, 654, 650, 645, 646, 647, 658, 657, 649, 656]
const DRAGON_KNIGHT_WALK_CONTENT_H: Array[int] = [568, 564, 563, 566, 567, 572, 569, 567, 574, 576, 578]

## 汇总（median）
const DRAGON_KNIGHT_WALK_FOOT_MEDIAN: int = 75
const DRAGON_KNIGHT_WALK_HEAD_MEDIAN: int = 125
const DRAGON_KNIGHT_WALK_CENTER_MEDIAN: float = 12.5
const DRAGON_KNIGHT_WALK_HEIGHT_MEDIAN: int = 568
