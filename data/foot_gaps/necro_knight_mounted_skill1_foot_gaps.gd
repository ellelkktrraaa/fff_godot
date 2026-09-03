# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 336x191

class_name NECRO_KNIGHT_MOUNTED_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const NECRO_KNIGHT_MOUNTED_SKILL1_FOOT: Array[int] = [2, 2, 2, 2, 18, 3, 0, 0, 0, 0]

## 每帧头顶偏移（head_gap）
const NECRO_KNIGHT_MOUNTED_SKILL1_HEAD: Array[int] = [19, 19, 19, 19, 19, 19, 19, 19, 19, 19]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const NECRO_KNIGHT_MOUNTED_SKILL1_CENTER: Array[float] = [-7.0, -14.0, -24.5, -27.5, 4.5, -3.5, 20.5, -25.5, 0.0, -20.0]

## 每帧内容尺寸（content_w / content_h）
const NECRO_KNIGHT_MOUNTED_SKILL1_CONTENT_W: Array[int] = [188, 206, 217, 215, 219, 231, 295, 285, 336, 296]
const NECRO_KNIGHT_MOUNTED_SKILL1_CONTENT_H: Array[int] = [170, 170, 170, 170, 154, 169, 172, 172, 172, 172]

## 汇总（median）
const NECRO_KNIGHT_MOUNTED_SKILL1_FOOT_MEDIAN: int = 2
const NECRO_KNIGHT_MOUNTED_SKILL1_HEAD_MEDIAN: int = 19
const NECRO_KNIGHT_MOUNTED_SKILL1_CENTER_MEDIAN: float = -7.0
const NECRO_KNIGHT_MOUNTED_SKILL1_HEIGHT_MEDIAN: int = 170
