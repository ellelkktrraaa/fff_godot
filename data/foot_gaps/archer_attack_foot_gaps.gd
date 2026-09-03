# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 480x360

class_name ARCHER_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_ATTACK_FOOT: Array[int] = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]

## 每帧头顶偏移（head_gap）
const ARCHER_ATTACK_HEAD: Array[int] = [0, 0, 0, 0, 0, 2, 2, 3, 3, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_ATTACK_CENTER: Array[float] = [49.25, 38.75, 36.0, 28.5, 25.75, 20.0, 18.5, 14.0, 13.25, 11.25, 10.5, 9.25, 9.0, 8.75, 9.0, 8.5, 8.5, 8.75, 8.75, 8.75, 8.75, 8.75]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_ATTACK_CONTENT_W: Array[int] = [382, 379, 375, 362, 357, 346, 343, 334, 333, 329, 327, 326, 325, 325, 324, 324, 324, 324, 324, 324, 324, 324]
const ARCHER_ATTACK_CONTENT_H: Array[int] = [357, 358, 358, 358, 358, 356, 356, 355, 355, 354, 354, 354, 354, 354, 354, 355, 355, 355, 355, 355, 355, 355]

## 汇总（median）
const ARCHER_ATTACK_FOOT_MEDIAN: int = 3
const ARCHER_ATTACK_HEAD_MEDIAN: int = 3
const ARCHER_ATTACK_CENTER_MEDIAN: float = 10.5
const ARCHER_ATTACK_HEIGHT_MEDIAN: int = 355
