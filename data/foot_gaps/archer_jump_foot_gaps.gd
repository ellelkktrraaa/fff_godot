# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 720x960

class_name ARCHER_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_JUMP_FOOT: Array[int] = [243, 270, 277, 286, 289, 293, 293, 292, 287, 271, 257, 209, 165, 102, 103, 103]

## 每帧头顶偏移（head_gap）
const ARCHER_JUMP_HEAD: Array[int] = [71, 62, 59, 53, 51, 48, 48, 48, 50, 55, 58, 66, 74, 126, 204, 256]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_JUMP_CENTER: Array[float] = [26.5, 24.5, 23.5, 22.0, 22.0, 21.5, 21.5, 21.5, 22.0, 22.0, 23.0, 24.5, 24.5, 28.0, 35.5, 47.0]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_JUMP_CONTENT_W: Array[int] = [411, 411, 411, 410, 410, 409, 409, 409, 410, 410, 410, 409, 409, 416, 415, 414]
const ARCHER_JUMP_CONTENT_H: Array[int] = [646, 628, 624, 621, 620, 619, 619, 620, 623, 634, 645, 685, 721, 732, 653, 601]

## 汇总（median）
const ARCHER_JUMP_FOOT_MEDIAN: int = 270
const ARCHER_JUMP_HEAD_MEDIAN: int = 58
const ARCHER_JUMP_CENTER_MEDIAN: float = 22.5
const ARCHER_JUMP_HEIGHT_MEDIAN: int = 626
