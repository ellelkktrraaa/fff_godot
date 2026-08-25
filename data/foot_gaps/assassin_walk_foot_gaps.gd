# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name ASSASSIN_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_WALK_FOOT: Array[int] = [71, 76, 99, 93, 73, 55, 55, 59, 66, 115, 87, 63, 62, 59, 63]

## 每帧头顶偏移（head_gap）
const ASSASSIN_WALK_HEAD: Array[int] = [116, 102, 93, 88, 93, 100, 104, 99, 91, 90, 93, 97, 105, 106, 102]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_WALK_CENTER: Array[float] = [-63.0, -57.5, -29.5, -22.0, -23.0, -25.0, -54.0, -62.0, -46.0, -38.5, -34.0, -37.0, -57.5, -63.0, -59.0]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_WALK_CONTENT_W: Array[int] = [464, 479, 505, 508, 506, 496, 450, 472, 518, 541, 548, 542, 487, 468, 472]
const ASSASSIN_WALK_CONTENT_H: Array[int] = [581, 590, 576, 587, 602, 613, 609, 610, 611, 563, 588, 608, 601, 603, 603]

## 汇总（median）
const ASSASSIN_WALK_FOOT_MEDIAN: int = 66
const ASSASSIN_WALK_HEAD_MEDIAN: int = 99
const ASSASSIN_WALK_CENTER_MEDIAN: float = -46.0
const ASSASSIN_WALK_HEIGHT_MEDIAN: int = 602
