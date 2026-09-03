# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x480

class_name ARCHER_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_JUMP_FOOT: Array[int] = [122, 135, 139, 143, 145, 147, 147, 146, 144, 136, 129, 105, 83, 51, 52, 52]

## 每帧头顶偏移（head_gap）
const ARCHER_JUMP_HEAD: Array[int] = [36, 31, 30, 27, 26, 24, 24, 24, 25, 28, 29, 33, 37, 63, 102, 128]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_JUMP_CENTER: Array[float] = [13.25, 12.25, 11.75, 11.0, 11.0, 10.75, 10.75, 10.75, 11.0, 11.0, 11.5, 12.25, 12.25, 14.0, 17.75, 23.5]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_JUMP_CONTENT_W: Array[int] = [206, 206, 206, 205, 205, 205, 205, 205, 205, 205, 205, 205, 205, 208, 208, 207]
const ARCHER_JUMP_CONTENT_H: Array[int] = [323, 314, 312, 311, 310, 310, 310, 310, 312, 317, 323, 343, 361, 366, 327, 301]

## 汇总（median）
const ARCHER_JUMP_FOOT_MEDIAN: int = 135
const ARCHER_JUMP_HEAD_MEDIAN: int = 29
const ARCHER_JUMP_CENTER_MEDIAN: float = 11.25
const ARCHER_JUMP_HEIGHT_MEDIAN: int = 313
