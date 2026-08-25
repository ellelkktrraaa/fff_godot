# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name KNIGHT_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_IDLE_FOOT: Array[int] = [40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40]

## 每帧头顶偏移（head_gap）
const KNIGHT_IDLE_HEAD: Array[int] = [75, 75, 75, 74, 73, 72, 70, 69, 69, 69, 69, 70, 71]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_IDLE_CENTER: Array[float] = [-5.0, -5.0, -5.0, -4.0, -3.0, -1.0, 2.0, 1.5, 0.5, -2.5, -7.0, -15.0, -14.5]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_IDLE_CONTENT_W: Array[int] = [468, 468, 468, 470, 472, 480, 490, 501, 507, 513, 512, 508, 497]
const KNIGHT_IDLE_CONTENT_H: Array[int] = [653, 653, 653, 654, 655, 656, 658, 659, 659, 659, 659, 658, 657]

## 汇总（median）
const KNIGHT_IDLE_FOOT_MEDIAN: int = 40
const KNIGHT_IDLE_HEAD_MEDIAN: int = 71
const KNIGHT_IDLE_CENTER_MEDIAN: float = -4.0
const KNIGHT_IDLE_HEIGHT_MEDIAN: int = 657
