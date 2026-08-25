# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1344x768

class_name DRAGON_KNIGHT_ATTACK_SHEET_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_ATTACK_SHEET_FOOT: Array[int] = [101, 143, 151, 22, 58, 126, 69, 9, 136, 145, 117, 0]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_ATTACK_SHEET_HEAD: Array[int] = [0, 68, 187, 182, 181, 182, 120, 4, 0, 197, 189, 181]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_ATTACK_SHEET_CENTER: Array[float] = [-95.5, -96.0, -62.5, -66.0, -116.0, -104.0, -95.5, -85.0, -103.5, -66.0, -74.5, -113.5]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_ATTACK_SHEET_CONTENT_W: Array[int] = [881, 1030, 1179, 1068, 974, 1006, 989, 916, 953, 1154, 1097, 963]
const DRAGON_KNIGHT_ATTACK_SHEET_CONTENT_H: Array[int] = [667, 557, 430, 564, 529, 460, 579, 755, 632, 426, 462, 587]

## 汇总（median）
const DRAGON_KNIGHT_ATTACK_SHEET_FOOT_MEDIAN: int = 117
const DRAGON_KNIGHT_ATTACK_SHEET_HEAD_MEDIAN: int = 181
const DRAGON_KNIGHT_ATTACK_SHEET_CENTER_MEDIAN: float = -95.5
const DRAGON_KNIGHT_ATTACK_SHEET_HEIGHT_MEDIAN: int = 564
