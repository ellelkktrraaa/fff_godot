# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name KNIGHT_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_WALK_FOOT: Array[int] = [22, 25, 27, 29, 25, 26, 24, 21, 21, 21, 21, 21]

## 每帧头顶偏移（head_gap）
const KNIGHT_WALK_HEAD: Array[int] = [42, 41, 39, 37, 39, 40, 42, 42, 40, 38, 39, 40]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_WALK_CENTER: Array[float] = [0.0, 0.0, -0.25, 0.0, 0.0, 0.0, 0.0, 0.0, -0.25, 0.0, 0.0, 0.0]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_WALK_CONTENT_W: Array[int] = [277, 273, 259, 237, 212, 211, 213, 223, 229, 231, 246, 259]
const KNIGHT_WALK_CONTENT_H: Array[int] = [321, 319, 319, 319, 321, 319, 319, 322, 324, 326, 325, 324]

## 汇总（median）
const KNIGHT_WALK_FOOT_MEDIAN: int = 24
const KNIGHT_WALK_HEAD_MEDIAN: int = 40
const KNIGHT_WALK_CENTER_MEDIAN: float = 0.0
const KNIGHT_WALK_HEIGHT_MEDIAN: int = 321
