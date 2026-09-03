# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name BERSERKER_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_ATTACK_FOOT: Array[int] = [5, 5, 5, 5, 5, 5]

## 每帧头顶偏移（head_gap）
const BERSERKER_ATTACK_HEAD: Array[int] = [0, 48, 11, 7, 8, 9]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_ATTACK_CENTER: Array[float] = [-29.75, -18.0, -12.0, -7.25, -3.0, -3.75]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_ATTACK_CONTENT_W: Array[int] = [325, 348, 360, 334, 318, 317]
const BERSERKER_ATTACK_CONTENT_H: Array[int] = [379, 332, 369, 373, 372, 371]

## 汇总（median）
const BERSERKER_ATTACK_FOOT_MEDIAN: int = 5
const BERSERKER_ATTACK_HEAD_MEDIAN: int = 9
const BERSERKER_ATTACK_CENTER_MEDIAN: float = -7.25
const BERSERKER_ATTACK_HEIGHT_MEDIAN: int = 372
