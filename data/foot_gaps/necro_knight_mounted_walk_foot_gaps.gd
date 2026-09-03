# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 672x383

class_name NECRO_KNIGHT_MOUNTED_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const NECRO_KNIGHT_MOUNTED_WALK_FOOT: Array[int] = [35, 35, 35, 35, 35, 35, 35, 35, 35]

## 每帧头顶偏移（head_gap）
const NECRO_KNIGHT_MOUNTED_WALK_HEAD: Array[int] = [10, 10, 10, 10, 10, 10, 10, 10, 10]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const NECRO_KNIGHT_MOUNTED_WALK_CENTER: Array[float] = [-25.5, -25.5, -25.5, -25.5, -25.5, -25.5, -25.5, -25.5, -25.5]

## 每帧内容尺寸（content_w / content_h）
const NECRO_KNIGHT_MOUNTED_WALK_CONTENT_W: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1, -1]
const NECRO_KNIGHT_MOUNTED_WALK_CONTENT_H: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1, -1]

## 汇总（median）
const NECRO_KNIGHT_MOUNTED_WALK_FOOT_MEDIAN: int = 35
const NECRO_KNIGHT_MOUNTED_WALK_HEAD_MEDIAN: int = 10
const NECRO_KNIGHT_MOUNTED_WALK_CENTER_MEDIAN: float = -25.5
const NECRO_KNIGHT_MOUNTED_WALK_HEIGHT_MEDIAN: int = -1
