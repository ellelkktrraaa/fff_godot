# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BERSERKER_GROUND_SPLIT_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_GROUND_SPLIT_FOOT: Array[int] = [4, 4, 4, 45, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

## 每帧头顶偏移（head_gap）
const BERSERKER_GROUND_SPLIT_HEAD: Array[int] = [8, 0, 0, 0, 22, 46, 54, 56, 57, 58, 59, 60, 61, 61, 62, 62]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_GROUND_SPLIT_CENTER: Array[float] = [-10.0, -3.5, 21.0, -49.5, -50.5, -33.0, -27.0, -25.5, -25.0, -24.5, -24.5, -24.0, -24.0, -23.5, -23.5, -23.5]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_GROUND_SPLIT_CONTENT_W: Array[int] = [492, 371, 394, 611, 667, 702, 714, 717, 718, 719, 719, 720, 720, 721, 721, 721]
const BERSERKER_GROUND_SPLIT_CONTENT_H: Array[int] = [756, 764, 764, 723, 701, 722, 714, 712, 711, 710, 709, 708, 707, 707, 706, 706]

## 汇总（median）
const BERSERKER_GROUND_SPLIT_FOOT_MEDIAN: int = 0
const BERSERKER_GROUND_SPLIT_HEAD_MEDIAN: int = 57
const BERSERKER_GROUND_SPLIT_CENTER_MEDIAN: float = -24.0
const BERSERKER_GROUND_SPLIT_HEIGHT_MEDIAN: int = 711
