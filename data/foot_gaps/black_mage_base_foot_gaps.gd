# 本文件由脚本自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BLACK_MAGE_BASE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BLACK_MAGE_BASE_FOOT: Array[int] = [31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31]

## 每帧头顶偏移（head_gap）
const BLACK_MAGE_BASE_HEAD: Array[int] = [34, 28, 19, 25, 15, 23, 17, 36, 37, 31, 23, 18, 22]

## 每帧中轴水平偏移（center_dx）
const BLACK_MAGE_BASE_CENTER: Array[float] = [-19.5, -20.0, -19.5, -20.0, -20.5, -16.5, -13.5, -14.0, -25.5, -20.0, -18.0, -18.5, -19.0]

## 每帧内容尺寸（content_w / content_h）
const BLACK_MAGE_BASE_CONTENT_W: Array[int] = [544, 545, 546, 547, 550, 552, 554, 553, 530, 525, 531, 534, 537]
const BLACK_MAGE_BASE_CONTENT_H: Array[int] = [703, 709, 718, 712, 722, 714, 720, 701, 700, 706, 714, 719, 715]

## 汇总（median）
const BLACK_MAGE_BASE_FOOT_MEDIAN: int = 31
const BLACK_MAGE_BASE_HEAD_MEDIAN: int = 23
const BLACK_MAGE_BASE_CENTER_MEDIAN: float = -19.5
const BLACK_MAGE_BASE_HEIGHT_MEDIAN: int = 714