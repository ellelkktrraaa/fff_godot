# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 672x384

class_name DRAGON_KNIGHT_ATTACK_SHEET_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_ATTACK_SHEET_FOOT: Array[int] = [51, 72, 76, 11, 29, 63, 35, 5, 68, 73, 59, 0]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_ATTACK_SHEET_HEAD: Array[int] = [0, 34, 94, 91, 91, 91, 60, 2, 0, 99, 95, 91]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_ATTACK_SHEET_CENTER: Array[float] = [-47.75, -48.0, -31.25, -33.0, -58.0, -52.0, -47.75, -42.5, -51.75, -33.0, -37.25, -56.75]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_ATTACK_SHEET_CONTENT_W: Array[int] = [441, 515, 590, 534, 487, 503, 495, 458, 477, 577, 549, 482]
const DRAGON_KNIGHT_ATTACK_SHEET_CONTENT_H: Array[int] = [334, 279, 215, 282, 265, 230, 290, 378, 316, 213, 231, 294]

## 汇总（median）
const DRAGON_KNIGHT_ATTACK_SHEET_FOOT_MEDIAN: int = 59
const DRAGON_KNIGHT_ATTACK_SHEET_HEAD_MEDIAN: int = 91
const DRAGON_KNIGHT_ATTACK_SHEET_CENTER_MEDIAN: float = -47.75
const DRAGON_KNIGHT_ATTACK_SHEET_HEIGHT_MEDIAN: int = 282
