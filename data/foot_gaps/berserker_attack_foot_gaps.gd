# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BERSERKER_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_ATTACK_FOOT: Array[int] = [10, 9, 9, 9, 9, 9]

## 每帧头顶偏移（head_gap）
const BERSERKER_ATTACK_HEAD: Array[int] = [0, 95, 22, 14, 15, 17]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_ATTACK_CENTER: Array[float] = [-59.5, -36.0, -24.0, -14.5, -6.0, -7.5]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_ATTACK_CONTENT_W: Array[int] = [649, 696, 720, 667, 636, 633]
const BERSERKER_ATTACK_CONTENT_H: Array[int] = [758, 664, 737, 745, 744, 742]

## 汇总（median）
const BERSERKER_ATTACK_FOOT_MEDIAN: int = 9
const BERSERKER_ATTACK_HEAD_MEDIAN: int = 17
const BERSERKER_ATTACK_CENTER_MEDIAN: float = -14.5
const BERSERKER_ATTACK_HEIGHT_MEDIAN: int = 744
