# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1024x768

class_name DRAGON_KNIGHT_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_SKILL1_FOOT: Array[int] = [146, 145, 145, 145, 145, 149, 151, 149, 132, 131, 105, 87, 105, 115, 119, 121, 123]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_SKILL1_HEAD: Array[int] = [211, 211, 88, 169, 173, 75, 17, 145, 165, 247, 219, 173, 141, 133, 133, 119, 100]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_SKILL1_CENTER: Array[float] = [19.0, 48.0, -8.5, -11.0, 15.0, 39.0, 29.0, -18.0, -47.0, -90.0, -81.5, -53.5, -36.5, -26.0, -19.5, -18.5, -10.0]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_SKILL1_CONTENT_W: Array[int] = [452, 510, 415, 520, 588, 552, 568, 698, 568, 482, 425, 335, 369, 402, 569, 771, 806]
const DRAGON_KNIGHT_SKILL1_CONTENT_H: Array[int] = [411, 412, 535, 454, 450, 544, 600, 474, 471, 390, 444, 508, 522, 520, 516, 528, 545]

## 汇总（median）
const DRAGON_KNIGHT_SKILL1_FOOT_MEDIAN: int = 132
const DRAGON_KNIGHT_SKILL1_HEAD_MEDIAN: int = 145
const DRAGON_KNIGHT_SKILL1_CENTER_MEDIAN: float = -18.0
const DRAGON_KNIGHT_SKILL1_HEIGHT_MEDIAN: int = 508
