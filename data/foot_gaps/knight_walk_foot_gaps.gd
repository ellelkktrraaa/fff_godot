# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name KNIGHT_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_WALK_FOOT: Array[int] = [43, 49, 53, 57, 49, 51, 47, 41, 41, 41, 41, 42]

## 每帧头顶偏移（head_gap）
const KNIGHT_WALK_HEAD: Array[int] = [83, 82, 78, 74, 77, 80, 84, 83, 79, 76, 77, 79]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_WALK_CENTER: Array[float] = [0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_WALK_CONTENT_W: Array[int] = [554, 546, 517, 474, 424, 422, 426, 446, 457, 462, 492, 518]
const KNIGHT_WALK_CONTENT_H: Array[int] = [642, 637, 637, 637, 642, 637, 637, 644, 648, 651, 650, 647]

## 汇总（median）
const KNIGHT_WALK_FOOT_MEDIAN: int = 47
const KNIGHT_WALK_HEAD_MEDIAN: int = 79
const KNIGHT_WALK_CENTER_MEDIAN: float = 0.0
const KNIGHT_WALK_HEIGHT_MEDIAN: int = 642
