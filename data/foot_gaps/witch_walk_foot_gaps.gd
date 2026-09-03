# 本文件由 tools/import_witch.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x383

class_name WITCH_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const WITCH_WALK_FOOT: Array[int] = [7, 6, 7, 7, 7, 7, 7, 8, 8, 9, 9, 9, 7]

## 每帧头顶偏移（head_gap）
const WITCH_WALK_HEAD: Array[int] = [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9]

## 每帧中轴水平偏移（center_dx）
const WITCH_WALK_CENTER: Array[float] = [-12.0, -9.5, -9.0, -7.0, -5.5, -16.0, -19.0, -18.5, -18.5, -17.0, -7.0, -10.5, -13.5]

## 每帧内容尺寸（content_w / content_h）
const WITCH_WALK_CONTENT_W: Array[int] = [296, 289, 274, 264, 259, 280, 298, 299, 295, 276, 242, 267, 285]
const WITCH_WALK_CONTENT_H: Array[int] = [367, 368, 367, 367, 367, 367, 367, 366, 366, 365, 365, 365, 367]

## 汇总（median）
const WITCH_WALK_FOOT_MEDIAN: int = 7
const WITCH_WALK_HEAD_MEDIAN: int = 9
const WITCH_WALK_CENTER_MEDIAN: float = -12.0
const WITCH_WALK_HEIGHT_MEDIAN: int = 367
