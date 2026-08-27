# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1024x768

class_name DRAGON_KNIGHT_SKILL2_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_SKILL2_FOOT: Array[int] = [90, 90, 87, 96, 97, 97, 97, 96, 96, 97, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_SKILL2_HEAD: Array[int] = [177, 0, 187, 141, 140, 140, 130, 125, 122, 120, 140, 134, 128, 122, 139, 129, 123, 121, 140, 134, 129, 123, 123, 131]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_SKILL2_CENTER: Array[float] = [58.5, -28.5, 11.5, -39.0, -55.5, -46.0, -10.0, -14.0, -21.5, -2.5, -10.0, -17.0, -23.5, -5.0, -8.0, -14.5, -18.0, -5.0, -8.0, -27.5, -20.5, -6.5, -9.5, -23.0]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_SKILL2_CONTENT_W: Array[int] = [637, 485, 701, 602, 635, 666, 678, 688, 711, 683, 680, 686, 705, 676, 678, 687, 696, 682, 682, 711, 699, 679, 685, 704]
const DRAGON_KNIGHT_SKILL2_CONTENT_H: Array[int] = [501, 678, 494, 531, 531, 531, 541, 547, 550, 551, 532, 538, 544, 550, 533, 543, 549, 551, 532, 538, 543, 549, 549, 541]

## 汇总（median）
const DRAGON_KNIGHT_SKILL2_FOOT_MEDIAN: int = 96
const DRAGON_KNIGHT_SKILL2_HEAD_MEDIAN: int = 130
const DRAGON_KNIGHT_SKILL2_CENTER_MEDIAN: float = -14.0
const DRAGON_KNIGHT_SKILL2_HEIGHT_MEDIAN: int = 543
