# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x384

class_name BERSERKER_SKILL2_TENDON_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_SKILL2_TENDON_FOOT: Array[int] = [15, 18, 7, 19, 17, 17, 17, 16, 15, 16, 16, 16, 16, 16]

## 每帧头顶偏移（head_gap）
const BERSERKER_SKILL2_TENDON_HEAD: Array[int] = [58, 2, 15, 0, 3, 3, 2, 3, 11, 15, 52, 51, 113, 112]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_SKILL2_TENDON_CENTER: Array[float] = [46.25, -3.25, -8.5, 12.0, 16.75, 17.5, 14.75, 18.5, 27.75, 42.0, 28.25, 29.25, 0.5, -0.5]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_SKILL2_TENDON_CONTENT_W: Array[int] = [289, 413, 444, 368, 370, 368, 370, 366, 347, 293, 266, 269, 225, 227]
const BERSERKER_SKILL2_TENDON_CONTENT_H: Array[int] = [312, 365, 362, 365, 365, 365, 365, 366, 358, 354, 316, 318, 255, 257]

## 汇总（median）
const BERSERKER_SKILL2_TENDON_FOOT_MEDIAN: int = 16
const BERSERKER_SKILL2_TENDON_HEAD_MEDIAN: int = 15
const BERSERKER_SKILL2_TENDON_CENTER_MEDIAN: float = 17.5
const BERSERKER_SKILL2_TENDON_HEIGHT_MEDIAN: int = 362
