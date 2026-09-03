# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 672x384

class_name DRAGON_KNIGHT_DRAGON_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_DRAGON_FOOT: Array[int] = [38, 3, 34, 0, 0, 30, 88, 88, 70, 26, 0, 0, 85, 79]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_DRAGON_HEAD: Array[int] = [10, 33, 85, 79, 76, 74, 76, 63, 30, 89, 83, 80, 83, 32]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_DRAGON_CENTER: Array[float] = [-17.0, -11.25, 11.25, -12.25, -60.0, -65.5, -55.0, -51.25, -54.25, 3.0, -17.5, -45.0, -51.5, -32.5]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_DRAGON_CONTENT_W: Array[int] = [351, 424, 525, 527, 478, 507, 529, 512, 480, 509, 512, 519, 546, 516]
const DRAGON_KNIGHT_DRAGON_CONTENT_H: Array[int] = [337, 349, 266, 305, 308, 280, 221, 233, 284, 269, 302, 305, 217, 274]

## 汇总（median）
const DRAGON_KNIGHT_DRAGON_FOOT_MEDIAN: int = 34
const DRAGON_KNIGHT_DRAGON_HEAD_MEDIAN: int = 76
const DRAGON_KNIGHT_DRAGON_CENTER_MEDIAN: float = -32.5
const DRAGON_KNIGHT_DRAGON_HEIGHT_MEDIAN: int = 284
