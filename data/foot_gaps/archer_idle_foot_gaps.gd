# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x360

class_name ARCHER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_IDLE_FOOT: Array[int] = [11, 11, 6, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 8]

## 每帧头顶偏移（head_gap）
const ARCHER_IDLE_HEAD: Array[int] = [10, 9, 9, 9, 10, 11, 13, 14, 14, 15, 15, 15, 14, 14, 14, 13, 12, 11, 10, 10, 9]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_IDLE_CENTER: Array[float] = [-7.5, -43.5, 7.75, 5.75, 1.25, 1.0, 1.0, 1.0, 0.75, 1.5, 1.5, 1.5, 1.5, 1.5, 1.25, 1.0, 1.0, 0.75, 0.5, 0.25, 0.0]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_IDLE_CONTENT_W: Array[int] = [162, 236, 345, 345, 337, 335, 335, 335, 335, 333, 333, 333, 333, 333, 334, 333, 333, 334, 334, 334, 333]
const ARCHER_IDLE_CONTENT_H: Array[int] = [340, 341, 346, 344, 342, 341, 339, 338, 338, 337, 337, 337, 338, 338, 338, 339, 340, 341, 342, 342, 344]

## 汇总（median）
const ARCHER_IDLE_FOOT_MEDIAN: int = 9
const ARCHER_IDLE_HEAD_MEDIAN: int = 12
const ARCHER_IDLE_CENTER_MEDIAN: float = 1.0
const ARCHER_IDLE_HEIGHT_MEDIAN: int = 340
