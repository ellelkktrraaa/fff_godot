# 本文件由 tools/import_more.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。
#   foot_gap / head_gap / center_dx / content_w / content_h
# 帧尺寸: 384x511

class_name BERSERKER_WARCY_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_WARCY_FOOT: Array[int] = [38, 38, 38, 38, 38, 38, 39, 39, 39, 39]

## 每帧头顶偏移（head_gap）
const BERSERKER_WARCY_HEAD: Array[int] = [110, 110, 110, 110, 110, 110, 110, 110, 110, 110]

## 每帧中轴水平偏移（center_dx）
const BERSERKER_WARCY_CENTER: Array[float] = [16.0, 18.0, 17.0, 33.5, 32.5, -4.5, -5.0, -1.0, -0.5, -9.0]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_WARCY_CONTENT_W: Array[int] = [298, 316, 318, 315, 307, 293, 286, 298, 317, 318]
const BERSERKER_WARCY_CONTENT_H: Array[int] = [363, 363, 363, 363, 363, 363, 362, 362, 362, 362]

## 汇总（median）
const BERSERKER_WARCY_FOOT_MEDIAN: int = 38
const BERSERKER_WARCY_HEAD_MEDIAN: int = 110
const BERSERKER_WARCY_CENTER_MEDIAN: float = 16.0
const BERSERKER_WARCY_HEIGHT_MEDIAN: int = 363
