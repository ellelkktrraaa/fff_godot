# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x360

class_name DRAGON_KNIGHT_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_IDLE_FOOT: Array[int] = [30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_IDLE_HEAD: Array[int] = [57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_IDLE_CENTER: Array[float] = [8.75, 10.5, 6.5, 3.75, 5.5, 10.0, 9.25, 9.0, 11.5, 6.5, 4.75]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_IDLE_CONTENT_W: Array[int] = [301, 297, 304, 311, 308, 300, 304, 304, 299, 310, 313]
const DRAGON_KNIGHT_IDLE_CONTENT_H: Array[int] = [273, 273, 273, 274, 274, 274, 274, 274, 273, 273, 273]

## 汇总（median）
const DRAGON_KNIGHT_IDLE_FOOT_MEDIAN: int = 30
const DRAGON_KNIGHT_IDLE_HEAD_MEDIAN: int = 57
const DRAGON_KNIGHT_IDLE_CENTER_MEDIAN: float = 8.75
const DRAGON_KNIGHT_IDLE_HEIGHT_MEDIAN: int = 273
