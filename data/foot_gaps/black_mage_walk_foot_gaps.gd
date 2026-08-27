# 本文件由脚本自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BLACK_MAGE_WALK_FootGaps

## 每帧脚底偏移（foot_gap）
const BLACK_MAGE_WALK_FOOT: Array[int] = [29, 29, 30, 32, 34, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 31]

## 每帧头顶偏移（head_gap）
const BLACK_MAGE_WALK_HEAD: Array[int] = [39, 36, 34, 44, 33, 27, 28, 20, 33, 30, 40, 38, 36, 44, 36, 30, 23, 37]

## 每帧中轴水平偏移（center_dx）
const BLACK_MAGE_WALK_CENTER: Array[float] = [-22.0, -22.0, -21.5, -21.5, -21.5, -21.5, -22.0, -21.5, -22.0, -22.0, -22.0, -21.5, -21.5, -21.0, -21.5, -21.5, -21.5, -22.0]

## 每帧内容尺寸（content_w / content_h）
const BLACK_MAGE_WALK_CONTENT_W: Array[int] = [541, 541, 542, 540, 540, 540, 541, 540, 541, 541, 541, 542, 542, 541, 540, 540, 540, 541]
const BLACK_MAGE_WALK_CONTENT_H: Array[int] = [700, 703, 704, 692, 701, 706, 705, 713, 700, 703, 693, 695, 697, 689, 697, 703, 710, 700]

## 汇总（median）
const BLACK_MAGE_WALK_FOOT_MEDIAN: int = 35
const BLACK_MAGE_WALK_HEAD_MEDIAN: int = 36
const BLACK_MAGE_WALK_CENTER_MEDIAN: float = -21.5
const BLACK_MAGE_WALK_HEIGHT_MEDIAN: int = 701