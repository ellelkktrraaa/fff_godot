# 本文件由 tools/import_more.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。
#   foot_gap / head_gap / center_dx / content_w / content_h
# 帧尺寸: 384x511

class_name PALADIN_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const PALADIN_JUMP_FOOT: Array[int] = [105, 105, 105, 105, 105]

## 每帧头顶偏移（head_gap）
const PALADIN_JUMP_HEAD: Array[int] = [80, 80, 80, 80, 80]

## 每帧中轴水平偏移（center_dx）
const PALADIN_JUMP_CENTER: Array[float] = [-15.5, -15.5, -15.5, -15.5, -15.5]

## 每帧内容尺寸（content_w / content_h）
const PALADIN_JUMP_CONTENT_W: Array[int] = [-1, -1, -1, -1, -1]
const PALADIN_JUMP_CONTENT_H: Array[int] = [-1, -1, -1, -1, -1]

## 汇总（median）
const PALADIN_JUMP_FOOT_MEDIAN: int = 105
const PALADIN_JUMP_HEAD_MEDIAN: int = 80
const PALADIN_JUMP_CENTER_MEDIAN: float = -15.5
const PALADIN_JUMP_HEIGHT_MEDIAN: int = -1
