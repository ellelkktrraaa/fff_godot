# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x512

class_name BERSERKER_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_JUMP_FOOT: Array[int] = [53, 53, 53, 53, 53, 107, 115, 111, 90]

## 每帧头顶偏移（head_gap）
const BERSERKER_JUMP_HEAD: Array[int] = [93, 93, 100, 108, 92, 40, 39, 43, 59]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_JUMP_CENTER: Array[float] = [0.0, 0.0, 0.5, 2.5, -2.0, -1.75, -0.25, 1.5, 2.25]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_JUMP_CONTENT_W: Array[int] = [264, 264, 266, 268, 257, 268, 272, 274, 276]
const BERSERKER_JUMP_CONTENT_H: Array[int] = [366, 366, 359, 351, 367, 366, 359, 359, 364]

## 汇总（median）
const BERSERKER_JUMP_FOOT_MEDIAN: int = 53
const BERSERKER_JUMP_HEAD_MEDIAN: int = 92
const BERSERKER_JUMP_CENTER_MEDIAN: float = 0.0
const BERSERKER_JUMP_HEIGHT_MEDIAN: int = 364
