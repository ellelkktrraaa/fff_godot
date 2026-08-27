# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1024x768

class_name BERSERKER_SKILL2_PARRY_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_SKILL2_PARRY_FOOT: Array[int] = [10, 10, 18, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22]

## 每帧头顶偏移（head_gap）
const BERSERKER_SKILL2_PARRY_HEAD: Array[int] = [13, 17, 24, 7, 37, 32, 34, 35, 36, 41, 48, 52, 53, 53, 49, 45, 43]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_SKILL2_PARRY_CENTER: Array[float] = [43.5, 39.5, 7.5, -7.5, -13.5, -13.5, -15.0, -16.5, -17.5, -20.0, -24.0, -26.5, -27.5, -27.0, -24.5, -21.0, -19.5]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_SKILL2_PARRY_CONTENT_W: Array[int] = [381, 379, 377, 419, 513, 513, 514, 515, 515, 516, 518, 517, 517, 518, 517, 516, 515]
const BERSERKER_SKILL2_PARRY_CONTENT_H: Array[int] = [745, 741, 726, 739, 709, 714, 712, 711, 710, 705, 698, 694, 693, 693, 697, 701, 703]

## 汇总（median）
const BERSERKER_SKILL2_PARRY_FOOT_MEDIAN: int = 22
const BERSERKER_SKILL2_PARRY_HEAD_MEDIAN: int = 37
const BERSERKER_SKILL2_PARRY_CENTER_MEDIAN: float = -17.5
const BERSERKER_SKILL2_PARRY_HEIGHT_MEDIAN: int = 709
