# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x360

class_name NECRO_KNIGHT_MOUNTED_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const NECRO_KNIGHT_MOUNTED_IDLE_FOOT: Array[int] = [28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28]

## 每帧头顶偏移（head_gap）
const NECRO_KNIGHT_MOUNTED_IDLE_HEAD: Array[int] = [58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const NECRO_KNIGHT_MOUNTED_IDLE_CENTER: Array[float] = [2.5, 2.5, 2.0, 2.0, 1.0, 0.0, -0.5, -0.5, -0.5, 0.0, 1.0, 1.5]

## 每帧内容尺寸（content_w / content_h）
const NECRO_KNIGHT_MOUNTED_IDLE_CONTENT_W: Array[int] = [281, 281, 282, 282, 284, 284, 285, 285, 283, 282, 280, 279]
const NECRO_KNIGHT_MOUNTED_IDLE_CONTENT_H: Array[int] = [274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274]

## 汇总（median）
const NECRO_KNIGHT_MOUNTED_IDLE_FOOT_MEDIAN: int = 28
const NECRO_KNIGHT_MOUNTED_IDLE_HEAD_MEDIAN: int = 58
const NECRO_KNIGHT_MOUNTED_IDLE_CENTER_MEDIAN: float = 1.0
const NECRO_KNIGHT_MOUNTED_IDLE_HEIGHT_MEDIAN: int = 274
