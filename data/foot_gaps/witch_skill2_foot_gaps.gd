# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x512

class_name WITCH_SKILL2_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const WITCH_SKILL2_FOOT: Array[int] = [74, 74, 74, 74, 74, 74, 74, 74, 74, 74, 74]

## 每帧头顶偏移（head_gap）
const WITCH_SKILL2_HEAD: Array[int] = [71, 71, 70, 69, 68, 68, 68, 68, 69, 70, 71]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const WITCH_SKILL2_CENTER: Array[float] = [16.5, 11.25, -2.0, -10.5, -8.5, -0.5, 8.75, -1.0, -10.25, -8.0, -0.75]

## 每帧内容尺寸（content_w / content_h）
const WITCH_SKILL2_CONTENT_W: Array[int] = [182, 193, 219, 233, 227, 211, 193, 212, 233, 229, 216]
const WITCH_SKILL2_CONTENT_H: Array[int] = [367, 367, 368, 369, 370, 370, 370, 370, 369, 368, 367]

## 汇总（median）
const WITCH_SKILL2_FOOT_MEDIAN: int = 74
const WITCH_SKILL2_HEAD_MEDIAN: int = 69
const WITCH_SKILL2_CENTER_MEDIAN: float = -1.0
const WITCH_SKILL2_HEIGHT_MEDIAN: int = 369
