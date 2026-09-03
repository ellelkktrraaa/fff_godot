# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name KNIGHT_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_IDLE_FOOT: Array[int] = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20]

## 每帧头顶偏移（head_gap）
const KNIGHT_IDLE_HEAD: Array[int] = [38, 38, 38, 37, 37, 36, 35, 35, 35, 35, 35, 35, 36]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_IDLE_CENTER: Array[float] = [-2.5, -2.5, -2.5, -2.0, -1.5, -0.5, 1.0, 0.75, 0.25, -1.25, -3.5, -7.5, -7.25]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_IDLE_CONTENT_W: Array[int] = [234, 234, 234, 235, 236, 240, 245, 251, 254, 257, 256, 254, 249]
const KNIGHT_IDLE_CONTENT_H: Array[int] = [327, 327, 327, 327, 328, 328, 329, 330, 330, 330, 330, 329, 329]

## 汇总（median）
const KNIGHT_IDLE_FOOT_MEDIAN: int = 20
const KNIGHT_IDLE_HEAD_MEDIAN: int = 36
const KNIGHT_IDLE_CENTER_MEDIAN: float = -2.0
const KNIGHT_IDLE_HEIGHT_MEDIAN: int = 329
