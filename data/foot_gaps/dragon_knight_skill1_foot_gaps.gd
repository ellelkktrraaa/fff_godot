# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x384

class_name DRAGON_KNIGHT_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_SKILL1_FOOT: Array[int] = [73, 73, 73, 73, 73, 75, 76, 75, 66, 66, 53, 44, 53, 58, 60, 61, 62]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_SKILL1_HEAD: Array[int] = [106, 106, 44, 85, 87, 38, 9, 73, 83, 124, 110, 87, 71, 67, 67, 60, 50]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_SKILL1_CENTER: Array[float] = [9.5, 24.0, -4.25, -5.5, 7.5, 19.5, 14.5, -9.0, -23.5, -45.0, -40.75, -26.75, -18.25, -13.0, -9.75, -9.25, -5.0]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_SKILL1_CONTENT_W: Array[int] = [226, 255, 208, 260, 294, 276, 284, 349, 284, 241, 213, 168, 185, 201, 285, 386, 403]
const DRAGON_KNIGHT_SKILL1_CONTENT_H: Array[int] = [206, 206, 268, 227, 225, 272, 300, 237, 236, 195, 222, 254, 261, 260, 258, 264, 273]

## 汇总（median）
const DRAGON_KNIGHT_SKILL1_FOOT_MEDIAN: int = 66
const DRAGON_KNIGHT_SKILL1_HEAD_MEDIAN: int = 73
const DRAGON_KNIGHT_SKILL1_CENTER_MEDIAN: float = -9.0
const DRAGON_KNIGHT_SKILL1_HEIGHT_MEDIAN: int = 254
