# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name BERSERKER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_IDLE_FOOT: Array[int] = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]

## 每帧头顶偏移（head_gap）
const BERSERKER_IDLE_HEAD: Array[int] = [3, 3, 3, 3, 3, 4, 4, 5, 4, 4, 3, 3, 3]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_IDLE_CENTER: Array[float] = [-0.25, -0.25, -0.25, -0.5, -1.5, -2.0, -1.75, -1.25, -1.0, -0.5, -0.5, -0.5, -0.25]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_IDLE_CONTENT_W: Array[int] = [265, 265, 265, 265, 266, 264, 261, 259, 259, 262, 265, 269, 271]
const BERSERKER_IDLE_CONTENT_H: Array[int] = [380, 380, 380, 380, 380, 379, 379, 378, 379, 379, 380, 380, 380]

## 汇总（median）
const BERSERKER_IDLE_FOOT_MEDIAN: int = 2
const BERSERKER_IDLE_HEAD_MEDIAN: int = 3
const BERSERKER_IDLE_CENTER_MEDIAN: float = -0.5
const BERSERKER_IDLE_HEIGHT_MEDIAN: int = 380
