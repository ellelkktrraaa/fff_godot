# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x1024

class_name BERSERKER_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_JUMP_FOOT: Array[int] = [106, 106, 106, 106, 106, 213, 229, 221, 179]

## 每帧头顶偏移（head_gap）
const BERSERKER_JUMP_HEAD: Array[int] = [186, 186, 200, 216, 184, 79, 77, 85, 118]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_JUMP_CENTER: Array[float] = [0.0, 0.0, 1.0, 5.0, -4.0, -3.5, -0.5, 3.0, 4.5]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_JUMP_CONTENT_W: Array[int] = [528, 528, 532, 536, 514, 535, 543, 548, 551]
const BERSERKER_JUMP_CONTENT_H: Array[int] = [732, 732, 718, 702, 734, 732, 718, 718, 727]

## 汇总（median）
const BERSERKER_JUMP_FOOT_MEDIAN: int = 106
const BERSERKER_JUMP_HEAD_MEDIAN: int = 184
const BERSERKER_JUMP_CENTER_MEDIAN: float = 0.0
const BERSERKER_JUMP_HEIGHT_MEDIAN: int = 727
