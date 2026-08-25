# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BERSERKER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_IDLE_FOOT: Array[int] = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]

## 每帧头顶偏移（head_gap）
const BERSERKER_IDLE_HEAD: Array[int] = [5, 5, 5, 6, 6, 7, 8, 9, 8, 7, 6, 5, 5]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_IDLE_CENTER: Array[float] = [-0.5, -0.5, -0.5, -1.0, -3.0, -4.0, -3.5, -2.5, -2.0, -1.0, -1.0, -1.0, -0.5]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_IDLE_CONTENT_W: Array[int] = [529, 529, 529, 530, 532, 528, 521, 517, 518, 524, 530, 538, 541]
const BERSERKER_IDLE_CONTENT_H: Array[int] = [760, 760, 760, 759, 759, 758, 757, 756, 757, 758, 759, 760, 760]

## 汇总（median）
const BERSERKER_IDLE_FOOT_MEDIAN: int = 3
const BERSERKER_IDLE_HEAD_MEDIAN: int = 6
const BERSERKER_IDLE_CENTER_MEDIAN: float = -1.0
const BERSERKER_IDLE_HEIGHT_MEDIAN: int = 759
