# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x480

class_name NECRO_KNIGHT_MOUNTED_TRANSITION_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const NECRO_KNIGHT_MOUNTED_TRANSITION_FOOT: Array[int] = [114, 114, 125, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81]

## 每帧头顶偏移（head_gap）
const NECRO_KNIGHT_MOUNTED_TRANSITION_HEAD: Array[int] = [120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const NECRO_KNIGHT_MOUNTED_TRANSITION_CENTER: Array[float] = [35.5, 34.0, 33.5, -4.0, -7.0, -8.0, 1.0, 0.5, 0.5, 0.5, 0.0, -0.5, 0.0, 0.5, 1.0, 0.5]

## 每帧内容尺寸（content_w / content_h）
const NECRO_KNIGHT_MOUNTED_TRANSITION_CONTENT_W: Array[int] = [187, 190, 185, 352, 346, 344, 326, 327, 327, 327, 328, 333, 328, 327, 328, 327]
const NECRO_KNIGHT_MOUNTED_TRANSITION_CONTENT_H: Array[int] = [246, 246, 235, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279, 279]

## 汇总（median）
const NECRO_KNIGHT_MOUNTED_TRANSITION_FOOT_MEDIAN: int = 81
const NECRO_KNIGHT_MOUNTED_TRANSITION_HEAD_MEDIAN: int = 120
const NECRO_KNIGHT_MOUNTED_TRANSITION_CENTER_MEDIAN: float = 0.5
const NECRO_KNIGHT_MOUNTED_TRANSITION_HEIGHT_MEDIAN: int = 279
