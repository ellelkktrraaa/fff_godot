# 本文件由 tools/import_more.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。
#   foot_gap / head_gap / center_dx / content_w / content_h
# 帧尺寸: 384x383

class_name PALADIN_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const PALADIN_WALK_FOOT: Array[int] = [12, 14, 37, 21, 16, 16, 18, 36, 17, 12]

## 每帧头顶偏移（head_gap）
const PALADIN_WALK_HEAD: Array[int] = [34, 34, 34, 34, 34, 34, 34, 34, 34, 34]

## 每帧中轴水平偏移（center_dx）
const PALADIN_WALK_CENTER: Array[float] = [2.5, -2.0, -13.0, -15.0, -2.5, 7.0, 6.5, 3.0, -3.5, -5.0]

## 每帧内容尺寸（content_w / content_h）
const PALADIN_WALK_CONTENT_W: Array[int] = [349, 334, 306, 320, 343, 356, 353, 332, 337, 350]
const PALADIN_WALK_CONTENT_H: Array[int] = [337, 335, 312, 328, 333, 333, 331, 313, 332, 337]

## 汇总（median）
const PALADIN_WALK_FOOT_MEDIAN: int = 17
const PALADIN_WALK_HEAD_MEDIAN: int = 34
const PALADIN_WALK_CENTER_MEDIAN: float = -2.0
const PALADIN_WALK_HEIGHT_MEDIAN: int = 333
