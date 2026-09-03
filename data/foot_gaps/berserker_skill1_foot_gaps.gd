# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x384

class_name BERSERKER_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_SKILL1_FOOT: Array[int] = [2, 2, 2, 2, 2, 2, 2, 2]

## 每帧头顶偏移（head_gap）
const BERSERKER_SKILL1_HEAD: Array[int] = [55, 31, 20, 0, 49, 50, 52, 53]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_SKILL1_CENTER: Array[float] = [-16.5, -30.5, -31.0, 30.0, 52.0, 84.25, 15.5, 19.0]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_SKILL1_CONTENT_W: Array[int] = [326, 355, 358, 237, 279, 344, 206, 213]
const BERSERKER_SKILL1_CONTENT_H: Array[int] = [327, 351, 363, 382, 334, 332, 331, 330]

## 汇总（median）
const BERSERKER_SKILL1_FOOT_MEDIAN: int = 2
const BERSERKER_SKILL1_HEAD_MEDIAN: int = 50
const BERSERKER_SKILL1_CENTER_MEDIAN: float = 19.0
const BERSERKER_SKILL1_HEIGHT_MEDIAN: int = 334
