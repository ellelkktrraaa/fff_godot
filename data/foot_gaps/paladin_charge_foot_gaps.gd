# 本文件由 tools/import_more.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。
#   foot_gap / head_gap / center_dx / content_w / content_h
# 帧尺寸: 512x383

class_name PALADIN_CHARGE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const PALADIN_CHARGE_FOOT: Array[int] = [20, 25, 25, 23, 23, 32, 20, 21]

## 每帧头顶偏移（head_gap）
const PALADIN_CHARGE_HEAD: Array[int] = [26, 26, 26, 26, 26, 26, 26, 26]

## 每帧中轴水平偏移（center_dx）
const PALADIN_CHARGE_CENTER: Array[float] = [-14.0, -11.0, -18.5, -17.5, -13.5, -15.0, -21.0, -19.5]

## 每帧内容尺寸（content_w / content_h）
const PALADIN_CHARGE_CONTENT_W: Array[int] = [324, 324, 341, 337, 323, 326, 338, 335]
const PALADIN_CHARGE_CONTENT_H: Array[int] = [337, 332, 332, 334, 334, 325, 337, 336]

## 汇总（median）
const PALADIN_CHARGE_FOOT_MEDIAN: int = 23
const PALADIN_CHARGE_HEAD_MEDIAN: int = 26
const PALADIN_CHARGE_CENTER_MEDIAN: float = -15.0
const PALADIN_CHARGE_HEIGHT_MEDIAN: int = 334
