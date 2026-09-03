# 本文件由脚本自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x512

class_name BLACK_MAGE_JUMP_FootGaps

## 每帧脚底偏移（foot_gap）
const BLACK_MAGE_JUMP_FOOT: Array[int] = [81, 81, 81, 81]

## 每帧头顶偏移（head_gap）
const BLACK_MAGE_JUMP_HEAD: Array[int] = [62, 33, 25, 23]

## 每帧中轴水平偏移（center_dx）
const BLACK_MAGE_JUMP_CENTER: Array[float] = [-11.0, -11.25, -10.0, -8.0]

## 每帧内容尺寸（content_w / content_h）
const BLACK_MAGE_JUMP_CONTENT_W: Array[int] = [296, 302, 323, 337]
const BLACK_MAGE_JUMP_CONTENT_H: Array[int] = [370, 399, 407, 409]

## 汇总（median）
const BLACK_MAGE_JUMP_FOOT_MEDIAN: int = 81
const BLACK_MAGE_JUMP_HEAD_MEDIAN: int = 33
const BLACK_MAGE_JUMP_CENTER_MEDIAN: float = -10.0
const BLACK_MAGE_JUMP_HEIGHT_MEDIAN: int = 407