# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 720x720

class_name DRAGON_KNIGHT_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_IDLE_FOOT: Array[int] = [60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_IDLE_HEAD: Array[int] = [114, 114, 114, 113, 113, 113, 113, 113, 114, 114, 114]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_IDLE_CENTER: Array[float] = [17.5, 21.0, 13.0, 7.5, 11.0, 20.0, 18.5, 18.0, 23.0, 13.0, 9.5]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_IDLE_CONTENT_W: Array[int] = [601, 594, 608, 621, 616, 600, 607, 608, 598, 620, 625]
const DRAGON_KNIGHT_IDLE_CONTENT_H: Array[int] = [546, 546, 546, 547, 547, 547, 547, 547, 546, 546, 546]

## 汇总（median）
const DRAGON_KNIGHT_IDLE_FOOT_MEDIAN: int = 60
const DRAGON_KNIGHT_IDLE_HEAD_MEDIAN: int = 114
const DRAGON_KNIGHT_IDLE_CENTER_MEDIAN: float = 17.5
const DRAGON_KNIGHT_IDLE_HEIGHT_MEDIAN: int = 546
