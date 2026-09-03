# 本文件由脚本自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name BLACK_MAGE_BASE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BLACK_MAGE_BASE_FOOT: Array[int] = [16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16]

## 每帧头顶偏移（head_gap）
const BLACK_MAGE_BASE_HEAD: Array[int] = [17, 14, 10, 13, 8, 12, 9, 18, 19, 16, 12, 9, 11]

## 每帧中轴水平偏移（center_dx）
const BLACK_MAGE_BASE_CENTER: Array[float] = [-9.75, -10.0, -9.75, -10.0, -10.25, -8.25, -6.75, -7.0, -12.75, -10.0, -9.0, -9.25, -9.5]

## 每帧内容尺寸（content_w / content_h）
const BLACK_MAGE_BASE_CONTENT_W: Array[int] = [272, 273, 273, 274, 275, 276, 277, 277, 265, 263, 266, 267, 269]
const BLACK_MAGE_BASE_CONTENT_H: Array[int] = [352, 355, 359, 356, 361, 357, 360, 351, 350, 353, 357, 360, 358]

## 汇总（median）
const BLACK_MAGE_BASE_FOOT_MEDIAN: int = 16
const BLACK_MAGE_BASE_HEAD_MEDIAN: int = 12
const BLACK_MAGE_BASE_CENTER_MEDIAN: float = -9.75
const BLACK_MAGE_BASE_HEIGHT_MEDIAN: int = 357