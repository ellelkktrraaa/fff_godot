# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1024x768

class_name BERSERKER_SKILL2_TENDON_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_SKILL2_TENDON_FOOT: Array[int] = [29, 35, 14, 38, 33, 33, 34, 31, 30, 31, 32, 32, 32, 31]

## 每帧头顶偏移（head_gap）
const BERSERKER_SKILL2_TENDON_HEAD: Array[int] = [116, 4, 30, 0, 5, 5, 4, 5, 22, 30, 104, 101, 226, 224]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_SKILL2_TENDON_CENTER: Array[float] = [92.5, -6.5, -17.0, 24.0, 33.5, 35.0, 29.5, 37.0, 55.5, 84.0, 56.5, 58.5, 1.0, -1.0]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_SKILL2_TENDON_CONTENT_W: Array[int] = [577, 825, 888, 736, 739, 736, 739, 732, 693, 586, 531, 537, 450, 454]
const BERSERKER_SKILL2_TENDON_CONTENT_H: Array[int] = [623, 729, 724, 730, 730, 730, 730, 732, 716, 707, 632, 635, 510, 513]

## 汇总（median）
const BERSERKER_SKILL2_TENDON_FOOT_MEDIAN: int = 32
const BERSERKER_SKILL2_TENDON_HEAD_MEDIAN: int = 30
const BERSERKER_SKILL2_TENDON_CENTER_MEDIAN: float = 35.0
const BERSERKER_SKILL2_TENDON_HEIGHT_MEDIAN: int = 724
