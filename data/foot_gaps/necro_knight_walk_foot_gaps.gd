# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x360

class_name NECRO_KNIGHT_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const NECRO_KNIGHT_WALK_FOOT: Array[int] = [20, 23, 22, 19, 17, 15, 17]

## 每帧头顶偏移（head_gap）
const NECRO_KNIGHT_WALK_HEAD: Array[int] = [20, 20, 20, 20, 20, 20, 20]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const NECRO_KNIGHT_WALK_CENTER: Array[float] = [21.5, 15.0, 22.0, 28.0, 34.0, 24.5, 24.5]

## 每帧内容尺寸（content_w / content_h）
const NECRO_KNIGHT_WALK_CONTENT_W: Array[int] = [267, 284, 282, 282, 278, 283, 271]
const NECRO_KNIGHT_WALK_CONTENT_H: Array[int] = [320, 317, 318, 321, 323, 325, 323]

## 汇总（median）
const NECRO_KNIGHT_WALK_FOOT_MEDIAN: int = 19
const NECRO_KNIGHT_WALK_HEAD_MEDIAN: int = 20
const NECRO_KNIGHT_WALK_CENTER_MEDIAN: float = 24.5
const NECRO_KNIGHT_WALK_HEIGHT_MEDIAN: int = 321
