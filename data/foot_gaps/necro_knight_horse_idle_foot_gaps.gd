# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x360

class_name NECRO_KNIGHT_HORSE_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const NECRO_KNIGHT_HORSE_IDLE_FOOT: Array[int] = [22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22]

## 每帧头顶偏移（head_gap）
const NECRO_KNIGHT_HORSE_IDLE_HEAD: Array[int] = [51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const NECRO_KNIGHT_HORSE_IDLE_CENTER: Array[float] = [1.5, 2.0, 1.0, 0.5, 0.5, 0.5, 1.5, 4.0, 4.0, 1.5, 1.0, 1.0, 2.5]

## 每帧内容尺寸（content_w / content_h）
const NECRO_KNIGHT_HORSE_IDLE_CONTENT_W: Array[int] = [321, 320, 320, 321, 323, 325, 325, 322, 324, 325, 326, 324, 321]
const NECRO_KNIGHT_HORSE_IDLE_CONTENT_H: Array[int] = [287, 287, 287, 287, 287, 287, 287, 287, 287, 287, 287, 287, 287]

## 汇总（median）
const NECRO_KNIGHT_HORSE_IDLE_FOOT_MEDIAN: int = 22
const NECRO_KNIGHT_HORSE_IDLE_HEAD_MEDIAN: int = 51
const NECRO_KNIGHT_HORSE_IDLE_CENTER_MEDIAN: float = 1.5
const NECRO_KNIGHT_HORSE_IDLE_HEIGHT_MEDIAN: int = 287
