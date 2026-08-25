# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name KNIGHT_SKILL1_CHARGE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_SKILL1_CHARGE_FOOT: Array[int] = [37, 33, 34, 34, 34, 34]

## 每帧头顶偏移（head_gap）
const KNIGHT_SKILL1_CHARGE_HEAD: Array[int] = [83, 114, 65, 0, 0, 0]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_SKILL1_CHARGE_CENTER: Array[float] = [61.0, 56.5, 21.0, -69.0, -45.0, -41.0]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_SKILL1_CHARGE_CONTENT_W: Array[int] = [620, 655, 668, 572, 484, 472]
const KNIGHT_SKILL1_CHARGE_CONTENT_H: Array[int] = [648, 621, 669, 734, 734, 734]

## 汇总（median）
const KNIGHT_SKILL1_CHARGE_FOOT_MEDIAN: int = 34
const KNIGHT_SKILL1_CHARGE_HEAD_MEDIAN: int = 65
const KNIGHT_SKILL1_CHARGE_CENTER_MEDIAN: float = 21.0
const KNIGHT_SKILL1_CHARGE_HEIGHT_MEDIAN: int = 734
