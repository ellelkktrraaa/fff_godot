# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x671

class_name NECRO_KNIGHT_MOUNTED_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const NECRO_KNIGHT_MOUNTED_JUMP_FOOT: Array[int] = [181, 181, 181, 181, 181, 181, 179, 178, 178, 178]

## 每帧头顶偏移（head_gap）
const NECRO_KNIGHT_MOUNTED_JUMP_HEAD: Array[int] = [180, 180, 180, 180, 180, 180, 180, 180, 180, 180]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const NECRO_KNIGHT_MOUNTED_JUMP_CENTER: Array[float] = [-13.5, 0.5, -10.0, -10.0, -9.0, -4.0, -13.0, -14.0, 2.0, 2.0]

## 每帧内容尺寸（content_w / content_h）
const NECRO_KNIGHT_MOUNTED_JUMP_CONTENT_W: Array[int] = [323, 383, 364, 364, 360, 336, 336, 356, 326, 326]
const NECRO_KNIGHT_MOUNTED_JUMP_CONTENT_H: Array[int] = [310, 310, 310, 310, 310, 310, 312, 313, 313, 313]

## 汇总（median）
const NECRO_KNIGHT_MOUNTED_JUMP_FOOT_MEDIAN: int = 181
const NECRO_KNIGHT_MOUNTED_JUMP_HEAD_MEDIAN: int = 180
const NECRO_KNIGHT_MOUNTED_JUMP_CENTER_MEDIAN: float = -9.0
const NECRO_KNIGHT_MOUNTED_JUMP_HEIGHT_MEDIAN: int = 310
