# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x512

class_name KNIGHT_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_JUMP_FOOT: Array[int] = [88, 88, 103, 139, 147]

## 每帧头顶偏移（head_gap）
const KNIGHT_JUMP_HEAD: Array[int] = [131, 140, 77, 43, 40]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_JUMP_CENTER: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_JUMP_CONTENT_W: Array[int] = [255, 236, 211, 202, 209]
const KNIGHT_JUMP_CONTENT_H: Array[int] = [294, 285, 332, 330, 326]

## 汇总（median）
const KNIGHT_JUMP_FOOT_MEDIAN: int = 103
const KNIGHT_JUMP_HEAD_MEDIAN: int = 77
const KNIGHT_JUMP_CENTER_MEDIAN: float = 0.0
const KNIGHT_JUMP_HEIGHT_MEDIAN: int = 326
