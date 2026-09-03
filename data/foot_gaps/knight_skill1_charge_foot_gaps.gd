# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name KNIGHT_SKILL1_CHARGE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_SKILL1_CHARGE_FOOT: Array[int] = [19, 17, 17, 17, 17, 17]

## 每帧头顶偏移（head_gap）
const KNIGHT_SKILL1_CHARGE_HEAD: Array[int] = [42, 57, 33, 0, 0, 0]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_SKILL1_CHARGE_CENTER: Array[float] = [30.5, 28.25, 10.5, -34.5, -22.5, -20.5]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_SKILL1_CHARGE_CONTENT_W: Array[int] = [310, 328, 334, 286, 242, 236]
const KNIGHT_SKILL1_CHARGE_CONTENT_H: Array[int] = [324, 311, 335, 367, 367, 367]

## 汇总（median）
const KNIGHT_SKILL1_CHARGE_FOOT_MEDIAN: int = 17
const KNIGHT_SKILL1_CHARGE_HEAD_MEDIAN: int = 33
const KNIGHT_SKILL1_CHARGE_CENTER_MEDIAN: float = 10.5
const KNIGHT_SKILL1_CHARGE_HEIGHT_MEDIAN: int = 367
