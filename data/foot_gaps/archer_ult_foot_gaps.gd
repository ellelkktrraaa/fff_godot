# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x672

class_name ARCHER_ULT_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_ULT_FOOT: Array[int] = [157, 157, 157, 157, 157, 157]

## 每帧头顶偏移（head_gap）
const ARCHER_ULT_HEAD: Array[int] = [266, 266, 216, 219, 115, 73]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_ULT_CENTER: Array[float] = [6.75, 6.75, -13.25, -18.75, -21.0, -20.75]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_ULT_CONTENT_W: Array[int] = [227, 227, 197, 193, 192, 193]
const ARCHER_ULT_CONTENT_H: Array[int] = [249, 250, 300, 297, 400, 442]

## 汇总（median）
const ARCHER_ULT_FOOT_MEDIAN: int = 157
const ARCHER_ULT_HEAD_MEDIAN: int = 219
const ARCHER_ULT_CENTER_MEDIAN: float = -13.25
const ARCHER_ULT_HEIGHT_MEDIAN: int = 300
