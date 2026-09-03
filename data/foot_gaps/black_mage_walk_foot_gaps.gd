# 本文件由脚本自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name BLACK_MAGE_WALK_FootGaps

## 每帧脚底偏移（foot_gap）
const BLACK_MAGE_WALK_FOOT: Array[int] = [15, 15, 15, 16, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 16]

## 每帧头顶偏移（head_gap）
const BLACK_MAGE_WALK_HEAD: Array[int] = [20, 18, 17, 22, 17, 14, 14, 10, 17, 15, 20, 19, 18, 22, 18, 15, 12, 19]

## 每帧中轴水平偏移（center_dx）
const BLACK_MAGE_WALK_CENTER: Array[float] = [-11.0, -11.0, -10.75, -10.75, -10.75, -10.75, -11.0, -10.75, -11.0, -11.0, -11.0, -10.75, -10.75, -10.5, -10.75, -10.75, -10.75, -11.0]

## 每帧内容尺寸（content_w / content_h）
const BLACK_MAGE_WALK_CONTENT_W: Array[int] = [271, 271, 271, 270, 270, 270, 271, 270, 271, 271, 271, 271, 271, 271, 270, 270, 270, 271]
const BLACK_MAGE_WALK_CONTENT_H: Array[int] = [350, 352, 352, 346, 351, 353, 353, 357, 350, 352, 347, 348, 349, 345, 349, 352, 355, 350]

## 汇总（median）
const BLACK_MAGE_WALK_FOOT_MEDIAN: int = 18
const BLACK_MAGE_WALK_HEAD_MEDIAN: int = 18
const BLACK_MAGE_WALK_CENTER_MEDIAN: float = -10.75
const BLACK_MAGE_WALK_HEIGHT_MEDIAN: int = 351