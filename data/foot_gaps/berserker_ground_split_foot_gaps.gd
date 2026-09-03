# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name BERSERKER_GROUND_SPLIT_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_GROUND_SPLIT_FOOT: Array[int] = [2, 2, 2, 23, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

## 每帧头顶偏移（head_gap）
const BERSERKER_GROUND_SPLIT_HEAD: Array[int] = [4, 0, 0, 0, 11, 23, 27, 28, 29, 29, 30, 30, 31, 31, 31, 31]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_GROUND_SPLIT_CENTER: Array[float] = [-5.0, -1.75, 10.5, -24.75, -25.25, -16.5, -13.5, -12.75, -12.5, -12.25, -12.25, -12.0, -12.0, -11.75, -11.75, -11.75]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_GROUND_SPLIT_CONTENT_W: Array[int] = [246, 186, 197, 306, 334, 351, 357, 359, 359, 360, 360, 360, 360, 361, 361, 361]
const BERSERKER_GROUND_SPLIT_CONTENT_H: Array[int] = [378, 382, 382, 362, 351, 361, 357, 356, 356, 355, 355, 354, 354, 354, 353, 353]

## 汇总（median）
const BERSERKER_GROUND_SPLIT_FOOT_MEDIAN: int = 0
const BERSERKER_GROUND_SPLIT_HEAD_MEDIAN: int = 29
const BERSERKER_GROUND_SPLIT_CENTER_MEDIAN: float = -12.0
const BERSERKER_GROUND_SPLIT_HEIGHT_MEDIAN: int = 356
