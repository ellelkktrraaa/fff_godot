# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name DRAGON_KNIGHT_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_JUMP_FOOT: Array[int] = [66, 74, 145, 172]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_JUMP_HEAD: Array[int] = [148, 79, 38, 36]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_JUMP_CENTER: Array[float] = [31.5, 16.0, 34.5, 25.5]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_JUMP_CONTENT_W: Array[int] = [683, 606, 583, 637]
const DRAGON_KNIGHT_JUMP_CONTENT_H: Array[int] = [554, 615, 585, 560]

## 汇总（median）
const DRAGON_KNIGHT_JUMP_FOOT_MEDIAN: int = 145
const DRAGON_KNIGHT_JUMP_HEAD_MEDIAN: int = 79
const DRAGON_KNIGHT_JUMP_CENTER_MEDIAN: float = 31.5
const DRAGON_KNIGHT_JUMP_HEIGHT_MEDIAN: int = 585
