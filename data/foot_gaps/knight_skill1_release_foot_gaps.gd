# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name KNIGHT_SKILL1_RELEASE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_SKILL1_RELEASE_FOOT: Array[int] = [18, 18, 18, 18, 18]

## 每帧头顶偏移（head_gap）
const KNIGHT_SKILL1_RELEASE_HEAD: Array[int] = [0, 5, 20, 87, 87]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_SKILL1_RELEASE_CENTER: Array[float] = [-23.5, -23.75, -4.5, 23.0, 15.5]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_SKILL1_RELEASE_CONTENT_W: Array[int] = [266, 312, 360, 317, 334]
const KNIGHT_SKILL1_RELEASE_CONTENT_H: Array[int] = [367, 362, 347, 280, 280]

## 汇总（median）
const KNIGHT_SKILL1_RELEASE_FOOT_MEDIAN: int = 18
const KNIGHT_SKILL1_RELEASE_HEAD_MEDIAN: int = 20
const KNIGHT_SKILL1_RELEASE_CENTER_MEDIAN: float = -4.5
const KNIGHT_SKILL1_RELEASE_HEIGHT_MEDIAN: int = 347
